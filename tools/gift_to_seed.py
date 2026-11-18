"""Convert the supported Moodle GIFT multichoice export into an idempotent SQL seed."""

from __future__ import annotations

import html
import re
import sys
from pathlib import Path


QUESTION = re.compile(
    r"(?ms)^// question: (?P<id>\d+)\s+name: (?P<comment>.*?)\r?\n"
    r"::(?P<name>(?:\\.|[^:])*)::\[html\](?P<body>.*?)(?=^// question:|\Z)"
)
TAG = re.compile(r"<[^>]+>")


def unescape_gift(value: str) -> str:
    value = value.replace("\\n", "\n")
    value = re.sub(r"\\([~=#{}:])", r"\1", value)
    return value


def plain(value: str) -> str:
    value = re.sub(r"(?i)<br\s*/?>|</p>|</div>|</li>|</pre>", "\n", value)
    value = TAG.sub("", value)
    value = html.unescape(unescape_gift(value))
    return re.sub(r"[ \t]+", " ", re.sub(r"\n{3,}", "\n\n", value)).strip()


def sql(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def split_body(body: str) -> tuple[str, str]:
    closing = body.rfind("}")
    if closing < 0:
        raise ValueError("answer block has no closing brace")
    opening = closing
    while opening >= 0:
        opening = body.rfind("{", 0, opening)
        if opening < 0:
            break
        slashes = 0
        pos = opening - 1
        while pos >= 0 and body[pos] == "\\":
            slashes += 1
            pos -= 1
        if slashes % 2 == 0:
            return body[:opening], body[opening + 1 : closing]
    raise ValueError("answer block has no opening brace")


def parse_answers(block: str) -> list[tuple[str, float, int]]:
    answers = []
    for order, line in enumerate(block.splitlines(), 1):
        line = line.strip()
        if not line or line[0] not in "=~":
            continue
        correct = line[0] == "="
        value = line[1:]
        weight = None
        weighted = re.match(r"%(-?\d+(?:\.\d+)?)%(.*)", value, re.S)
        if weighted:
            weight = float(weighted.group(1)) / 100
            value = weighted.group(2)
        fraction = weight if weight is not None else (1.0 if correct else 0.0)
        answers.append((plain(value), fraction, order))
    if len(answers) < 2 or not any(fraction > 0 for _, fraction, _ in answers):
        raise ValueError("question must have at least two answers and one correct answer")
    return answers


def difficulty(name: str) -> str:
    lowered = name.lower()
    if "легкий" in lowered or "лёгкий" in lowered:
        return "EASY"
    if "сложный" in lowered:
        return "HARD"
    return "MEDIUM"


def main() -> None:
    source = Path(sys.argv[1]).read_text(encoding="utf-8-sig")
    questions = []
    for match in QUESTION.finditer(source):
        question_text, answer_block = split_body(match.group("body"))
        answers = parse_answers(answer_block)
        name = unescape_gift(match.group("name")).strip()
        questions.append({
            "id": match.group("id"),
            "name": name,
            "text": plain(question_text),
            "difficulty": difficulty(name),
            "single": sum(fraction > 0 for _, fraction, _ in answers) == 1,
            "answers": answers,
        })

    expected = len(re.findall(r"(?m)^// question: (?!0\b)", source))
    if not questions or len(questions) != expected:
        raise ValueError(f"parsed {len(questions)} of {expected} questions")

    out = []
    out.append("-- Generated from the Moodle GIFT export; do not edit by hand.\n")
    out.append("INSERT INTO mdl_question_categories (idnumber, name, sortorder)\n")
    out.append("SELECT 'erp-reports-certification', 'ERP: Сертификация Отчёты', 50\n")
    out.append("WHERE NOT EXISTS (SELECT 1 FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification');\n")
    out.append("UPDATE mdl_question_categories SET name = 'ERP: Сертификация Отчёты', sortorder = 50 WHERE idnumber = 'erp-reports-certification';\n\n")
    out.append("INSERT INTO mdl_quiz (idnumber, name, created_by, timelimit, visible)\n")
    out.append("SELECT 'erp-reports-certification', 'Сертификация: Отчёты ERP', id, 10800, TRUE\n")
    out.append("FROM mdl_user WHERE username = 'mentor' AND NOT EXISTS (SELECT 1 FROM mdl_quiz WHERE idnumber = 'erp-reports-certification');\n")
    out.append("UPDATE mdl_quiz SET name = 'Сертификация: Отчёты ERP', timelimit = 10800, visible = TRUE WHERE idnumber = 'erp-reports-certification';\n\n")
    out.append("UPDATE mdl_quiz SET visible = FALSE WHERE idnumber IN ('java', 'spring', 'galaxy', 'erp-autonomous-forms');\n\n")

    for question in questions:
        code = f"moodle-q{question['id']}"
        out.append("INSERT INTO mdl_question (category, idnumber, name, questiontext, single_answer, difficulty, source_question_id)\n")
        out.append(
            "SELECT id, %s, %s, %s, %s, %s, %s FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification' "
            "AND NOT EXISTS (SELECT 1 FROM mdl_question WHERE idnumber = %s);\n"
            % (sql(code), sql(question["name"]), sql(question["text"]),
               "TRUE" if question["single"] else "FALSE", sql(question["difficulty"]), question["id"], sql(code))
        )
        out.append("UPDATE mdl_question SET category = (SELECT id FROM mdl_question_categories WHERE idnumber = 'erp-reports-certification'), ")
        out.append("name = %s, questiontext = %s, single_answer = %s, difficulty = %s, source_question_id = %s WHERE idnumber = %s;\n" %
                   (sql(question["name"]), sql(question["text"]), "TRUE" if question["single"] else "FALSE",
                    sql(question["difficulty"]), question["id"], sql(code)))
        out.append(f"DELETE FROM mdl_question_answers WHERE question = (SELECT id FROM mdl_question WHERE idnumber = {sql(code)});\n")
        for answer, fraction, order in question["answers"]:
            out.append("INSERT INTO mdl_question_answers (question, answer, fraction, answer_order) ")
            out.append(f"SELECT id, {sql(answer)}, {fraction:.7f}, {order} FROM mdl_question WHERE idnumber = {sql(code)};\n")
        out.append("\n")

    out.append("DELETE FROM mdl_quiz_slots WHERE quizid = (SELECT id FROM mdl_quiz WHERE idnumber = 'erp-reports-certification');\n")
    for slot, question in enumerate(questions, 1):
        code = f"moodle-q{question['id']}"
        out.append("INSERT INTO mdl_quiz_slots (quizid, slot, page, questionid, maxmark) ")
        out.append("SELECT quiz.id, %d, %d, question.id, 1 FROM mdl_quiz quiz, mdl_question question " % (slot, (slot - 1) // 20 + 1))
        out.append(f"WHERE quiz.idnumber = 'erp-reports-certification' AND question.idnumber = {sql(code)};\n")

    sys.stdout.write("".join(out))
    print(f"-- Imported questions: {len(questions)}", file=sys.stderr)


if __name__ == "__main__":
    main()
