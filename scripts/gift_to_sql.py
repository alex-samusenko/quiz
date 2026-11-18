#!/usr/bin/env python3
"""Convert the subset of Moodle GIFT used by the attestation app to SQL."""

from __future__ import annotations

import argparse
import hashlib
import html
import re
import sys
from pathlib import Path


QUESTION_RE = re.compile(
    r"^::(?P<title>(?:\\.|[^:])+)::(?:\[html\])?(?P<text>.*?)(?<!\\)\{(?P<answers>.*?)(?<!\\)\}\s*$",
    re.MULTILINE | re.DOTALL,
)
ANSWER_RE = re.compile(
    r"^\s*(?P<kind>[=~])(?:%(?P<fraction>-?\d+(?:\.\d+)?)%)?(?P<text>.*?)(?=\n\s*[=~](?:%-?\d+(?:\.\d+)?%)?|\Z)",
    re.MULTILINE | re.DOTALL,
)


def gift_unescape(value: str) -> str:
    value = value.replace(r"\n", "\n")
    return re.sub(r"\\([~=#{}:\\])", r"\1", value)


def plain_text(value: str) -> str:
    value = gift_unescape(value)
    value = re.sub(r"<br\s*/?>", "\n", value, flags=re.IGNORECASE)
    value = re.sub(r"</(?:p|pre|div|li|h\d)>", "\n", value, flags=re.IGNORECASE)
    value = re.sub(r"<[^>]+>", "", value)
    value = html.unescape(value)
    value = re.sub(r"[ \t]+\n", "\n", value)
    value = re.sub(r"\n{3,}", "\n\n", value)
    return value.strip()


def sql(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def difficulty(title: str) -> str:
    lowered = title.lower()
    if "сложн" in lowered:
        return "HARD"
    if "средн" in lowered:
        return "MEDIUM"
    return "EASY"


def parse_gift(source: str) -> list[dict]:
    questions = []
    for match in QUESTION_RE.finditer(source):
        title = plain_text(match.group("title"))
        answers = []
        for answer_match in ANSWER_RE.finditer(match.group("answers")):
            raw_fraction = answer_match.group("fraction")
            fraction = float(raw_fraction) / 100 if raw_fraction is not None else (
                1.0 if answer_match.group("kind") == "=" else 0.0
            )
            answers.append((plain_text(answer_match.group("text")), fraction))
        if not answers:
            raise ValueError(f"No answers parsed for question: {title}")
        code = "ard-" + hashlib.sha1(title.encode("utf-8")).hexdigest()[:12]
        questions.append({
            "code": code,
            "title": title,
            "text": plain_text(match.group("text")),
            "difficulty": difficulty(title),
            "single": sum(fraction > 0 for _, fraction in answers) == 1,
            "answers": answers,
        })
    return questions


def render_sql(questions: list[dict], quiz_code: str, quiz_title: str, mentor: str) -> str:
    lines = [
        "BEGIN;",
        "INSERT INTO mdl_question_categories (idnumber, name, sortorder)",
        f"VALUES ({sql(quiz_code)}, {sql(quiz_title)}, 100)",
        "ON CONFLICT (idnumber) DO UPDATE SET name = EXCLUDED.name;",
        "",
        "INSERT INTO mdl_quiz (idnumber, name, created_by, timelimit)",
        f"VALUES ({sql(quiz_code)}, {sql(quiz_title)}, (SELECT id FROM mdl_user WHERE username = {sql(mentor)}), 600)",
        "ON CONFLICT (idnumber) DO UPDATE SET name = EXCLUDED.name, created_by = EXCLUDED.created_by;",
        "",
    ]
    for slot, question in enumerate(questions, 1):
        lines.extend([
            "INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty)",
            f"SELECT id, {sql(question['code'])}, {sql(question['title'][:255])}, {sql(question['text'])}, "
            f"{'TRUE' if question['single'] else 'FALSE'}, {sql(question['difficulty'])}",
            f"FROM mdl_question_categories WHERE idnumber = {sql(quiz_code)}",
            "ON CONFLICT (idnumber) DO UPDATE SET",
            "  category = EXCLUDED.category, name = EXCLUDED.name, questiontext = EXCLUDED.questiontext,",
            "  single_answer = EXCLUDED.single_answer, difficulty = EXCLUDED.difficulty;",
            f"DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = {sql(question['code'])});",
        ])
        for order, (answer, fraction) in enumerate(question["answers"], 1):
            lines.append(
                "INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) "
                f"SELECT id, {sql(answer)}, {fraction:.7f}, {order} FROM mdl_question WHERE idnumber = {sql(question['code'])};"
            )
        lines.extend([
            "INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark)",
            f"SELECT quiz.id, {slot}, 1, question.id, 1 FROM mdl_quiz quiz, mdl_question question",
            f"WHERE quiz.idnumber = {sql(quiz_code)} AND question.idnumber = {sql(question['code'])}",
            "ON CONFLICT (quizid, slot) DO UPDATE SET questionid = EXCLUDED.questionid, maxmark = EXCLUDED.maxmark;",
            "",
        ])
    lines.extend([
        f"DELETE FROM mdl_quiz_slots WHERE quizid = (SELECT id FROM mdl_quiz WHERE idnumber = {sql(quiz_code)}) AND slot > {len(questions)};",
        "COMMIT;",
    ])
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("gift_file", type=Path)
    parser.add_argument("--quiz-code", default="ard")
    parser.add_argument("--quiz-title", default="Сертификация Отчеты ERP")
    parser.add_argument("--mentor", default="mentor")
    args = parser.parse_args()

    source = args.gift_file.read_text(encoding="utf-8-sig")
    questions = parse_gift(source)
    if not questions:
        raise SystemExit("No supported multiple-choice questions found")
    print(render_sql(questions, args.quiz_code, args.quiz_title, args.mentor))
    print(f"-- Imported questions: {len(questions)}", file=sys.stderr)


if __name__ == "__main__":
    main()
