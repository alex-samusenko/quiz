import re
from pathlib import Path

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches, Pt, RGBColor


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs" / "tz.md"
OUTPUT = ROOT / "docs" / "Техническое-задание-аттестация-v0.7.docx"

BLACK = "000000"
MUTED = "52606D"


def configure_font(style, name, size, bold=False):
    style.font.name = name
    style._element.get_or_add_rPr().rFonts.set(qn("w:ascii"), name)
    style._element.get_or_add_rPr().rFonts.set(qn("w:hAnsi"), name)
    style._element.get_or_add_rPr().rFonts.set(qn("w:eastAsia"), name)
    style.font.size = Pt(size)
    style.font.bold = bold
    style.font.color.rgb = RGBColor.from_string(BLACK)


def add_page_number(paragraph):
    paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = paragraph.add_run()
    begin = OxmlElement("w:fldChar")
    begin.set(qn("w:fldCharType"), "begin")
    text = OxmlElement("w:instrText")
    text.set(qn("xml:space"), "preserve")
    text.text = " PAGE "
    end = OxmlElement("w:fldChar")
    end.set(qn("w:fldCharType"), "end")
    run._r.extend([begin, text, end])


def add_inline_markdown(paragraph, text):
    """Render the small Markdown subset used by docs/tz.md."""
    token = re.compile(r"(\*\*.+?\*\*|`.+?`)")
    position = 0
    for match in token.finditer(text):
        if match.start() > position:
            paragraph.add_run(text[position:match.start()])
        value = match.group(0)
        if value.startswith("**"):
            paragraph.add_run(value[2:-2]).bold = True
        else:
            run = paragraph.add_run(value[1:-1])
            run.font.name = "Consolas"
            run._element.get_or_add_rPr().rFonts.set(qn("w:ascii"), "Consolas")
            run._element.get_or_add_rPr().rFonts.set(qn("w:hAnsi"), "Consolas")
            run.font.size = Pt(9.5)
        position = match.end()
    if position < len(text):
        paragraph.add_run(text[position:])


def build_document():
    doc = Document()
    section = doc.sections[0]
    section.page_width = Inches(8.5)
    section.page_height = Inches(11)
    section.top_margin = Inches(0.72)
    section.bottom_margin = Inches(0.68)
    section.left_margin = Inches(0.85)
    section.right_margin = Inches(0.85)
    section.footer_distance = Inches(0.3)

    normal = doc.styles["Normal"]
    configure_font(normal, "Aptos", 10.8)
    normal.paragraph_format.space_after = Pt(5)
    normal.paragraph_format.line_spacing = Pt(15.5)

    title = doc.styles["Title"]
    configure_font(title, "Aptos Display", 26, True)
    title.paragraph_format.space_after = Pt(8)
    title.paragraph_format.keep_with_next = True
    title_ppr = title.element.get_or_add_pPr()
    title_border = title_ppr.find(qn("w:pBdr"))
    if title_border is not None:
        title_ppr.remove(title_border)

    for name, size, before, after in (
        ("Heading 1", 16, 16, 6),
        ("Heading 2", 13, 12, 5),
        ("Heading 3", 11.5, 10, 4),
    ):
        style = doc.styles[name]
        configure_font(style, "Aptos Display", size, True)
        style.paragraph_format.space_before = Pt(before)
        style.paragraph_format.space_after = Pt(after)
        style.paragraph_format.keep_with_next = True

    for name in ("List Bullet", "List Number"):
        style = doc.styles[name]
        configure_font(style, "Aptos", 10.6)
        style.paragraph_format.space_after = Pt(3)
        style.paragraph_format.line_spacing = Pt(14.5)
        style.paragraph_format.keep_together = True

    doc.core_properties.title = "Техническое задание на систему аттестации"
    doc.core_properties.subject = "Согласованные требования к веб-приложению учебного центра"
    doc.core_properties.author = "Учебный центр"

    lines = SOURCE.read_text(encoding="utf-8").splitlines()
    first_heading = True
    for raw in lines:
        text = raw.strip()
        if not text:
            continue
        if text.startswith("# "):
            p = doc.add_paragraph(style="Title")
            add_inline_markdown(p, text[2:])
            if first_heading:
                subtitle = doc.add_paragraph()
                subtitle.paragraph_format.space_after = Pt(16)
                run = subtitle.add_run("Согласованные требования, данные регламентов и открытые вопросы • версия 0.7 • 19 ноября 2026 года")
                run.font.name = "Aptos"
                run.font.size = Pt(11.5)
                run.font.color.rgb = RGBColor.from_string(MUTED)
                first_heading = False
            continue
        if text.startswith("## "):
            p = doc.add_paragraph(style="Heading 1")
            add_inline_markdown(p, text[3:])
            continue
        if text.startswith("### "):
            p = doc.add_paragraph(style="Heading 2")
            add_inline_markdown(p, text[4:])
            continue
        if text.startswith("- "):
            p = doc.add_paragraph(style="List Bullet")
            add_inline_markdown(p, text[2:])
            continue
        number = re.match(r"^(\d+)\.\s+(.+)$", text)
        if number:
            p = doc.add_paragraph()
            p.paragraph_format.left_indent = Inches(0.28)
            p.paragraph_format.first_line_indent = Inches(-0.28)
            p.paragraph_format.space_after = Pt(3)
            p.paragraph_format.keep_together = True
            p.add_run(f"{number.group(1)}. ")
            add_inline_markdown(p, number.group(2))
            continue
        p = doc.add_paragraph()
        add_inline_markdown(p, text)

    for sec in doc.sections:
        footer = sec.footer.paragraphs[0]
        add_page_number(footer)
        for run in footer.runs:
            run.font.name = "Aptos"
            run.font.size = Pt(9)
            run.font.color.rgb = RGBColor.from_string(MUTED)

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    doc.save(OUTPUT)
    print(OUTPUT)


if __name__ == "__main__":
    build_document()
