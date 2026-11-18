from pathlib import Path

from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.style import WD_STYLE_TYPE
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK, WD_LINE_SPACING
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches, Pt, RGBColor


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "docs" / "Техническое-задание-аттестация.docx"

BLACK = "000000"
NAVY = "164E63"
PALE_BLUE = "EAF4F7"
PALE_GRAY = "F5F7F8"
GRID = "D9D9D9"
MUTED = "52606D"


def set_cell_shading(cell, fill):
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = tc_pr.find(qn("w:shd"))
    if shd is None:
        shd = OxmlElement("w:shd")
        tc_pr.append(shd)
    shd.set(qn("w:fill"), fill)


def set_cell_margins(cell, top=110, start=130, bottom=110, end=130):
    tc = cell._tc
    tc_pr = tc.get_or_add_tcPr()
    tc_mar = tc_pr.first_child_found_in("w:tcMar")
    if tc_mar is None:
        tc_mar = OxmlElement("w:tcMar")
        tc_pr.append(tc_mar)
    for margin, value in (("top", top), ("start", start), ("bottom", bottom), ("end", end)):
        node = tc_mar.find(qn(f"w:{margin}"))
        if node is None:
            node = OxmlElement(f"w:{margin}")
            tc_mar.append(node)
        node.set(qn("w:w"), str(value))
        node.set(qn("w:type"), "dxa")


def set_table_borders(table, color=GRID, size="6"):
    tbl_pr = table._tbl.tblPr
    borders = tbl_pr.first_child_found_in("w:tblBorders")
    if borders is None:
        borders = OxmlElement("w:tblBorders")
        tbl_pr.append(borders)
    for edge in ("top", "left", "bottom", "right", "insideH", "insideV"):
        tag = f"w:{edge}"
        element = borders.find(qn(tag))
        if element is None:
            element = OxmlElement(tag)
            borders.append(element)
        element.set(qn("w:val"), "single")
        element.set(qn("w:sz"), size)
        element.set(qn("w:color"), color)


def set_repeat_table_header(row):
    tr_pr = row._tr.get_or_add_trPr()
    tbl_header = OxmlElement("w:tblHeader")
    tbl_header.set(qn("w:val"), "true")
    tr_pr.append(tbl_header)


def set_keep_with_next(paragraph, value=True):
    paragraph.paragraph_format.keep_with_next = value


def remove_paragraph_borders(element):
    p_pr = element.get_or_add_pPr()
    border = p_pr.find(qn("w:pBdr"))
    if border is not None:
        p_pr.remove(border)


def add_page_number(paragraph):
    paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = paragraph.add_run()
    fld_char1 = OxmlElement("w:fldChar")
    fld_char1.set(qn("w:fldCharType"), "begin")
    instr_text = OxmlElement("w:instrText")
    instr_text.set(qn("xml:space"), "preserve")
    instr_text.text = " PAGE "
    fld_char2 = OxmlElement("w:fldChar")
    fld_char2.set(qn("w:fldCharType"), "end")
    run._r.extend([fld_char1, instr_text, fld_char2])


def set_font(run, name="Aptos", size=None, bold=None, color=BLACK):
    run.font.name = name
    run._element.get_or_add_rPr().rFonts.set(qn("w:ascii"), name)
    run._element.get_or_add_rPr().rFonts.set(qn("w:hAnsi"), name)
    run._element.get_or_add_rPr().rFonts.set(qn("w:eastAsia"), name)
    if size:
        run.font.size = Pt(size)
    if bold is not None:
        run.bold = bold
    run.font.color.rgb = RGBColor.from_string(color)


def add_bullet(doc, text, level=0):
    p = doc.add_paragraph()
    p.paragraph_format.left_indent = Inches(0.28 if level == 0 else 0.52)
    p.paragraph_format.first_line_indent = Inches(-0.18)
    p.paragraph_format.space_before = Pt(12 if doc.paragraphs[-2].style.name.startswith("Heading") else 0)
    p.paragraph_format.space_after = Pt(3)
    p.add_run(f"• {text}")
    return p


def add_number(doc, number, text):
    p = doc.add_paragraph()
    p.paragraph_format.left_indent = Inches(0.3)
    p.paragraph_format.first_line_indent = Inches(-0.3)
    p.paragraph_format.line_spacing = Pt(18)
    p.paragraph_format.space_after = Pt(5)
    p.add_run(f"{number}. {text}")
    return p


def add_question_group(doc, title, questions):
    p = doc.add_paragraph(title, style="Heading 2")
    set_keep_with_next(p)
    for question in questions:
        add_bullet(doc, question)


doc = Document()
section = doc.sections[0]
section.page_width = Inches(8.5)
section.page_height = Inches(11)
section.top_margin = Inches(0.72)
section.bottom_margin = Inches(0.68)
section.left_margin = Inches(0.82)
section.right_margin = Inches(0.82)
section.header_distance = Inches(0.3)
section.footer_distance = Inches(0.3)

styles = doc.styles
normal = styles["Normal"]
normal.font.name = "Aptos"
normal._element.rPr.rFonts.set(qn("w:ascii"), "Aptos")
normal._element.rPr.rFonts.set(qn("w:hAnsi"), "Aptos")
normal.font.size = Pt(10.8)
normal.font.color.rgb = RGBColor.from_string(BLACK)
normal.paragraph_format.space_after = Pt(5.5)
normal.paragraph_format.line_spacing = Pt(16)

title_style = styles["Title"]
title_style.font.name = "Aptos Display"
title_style._element.rPr.rFonts.set(qn("w:ascii"), "Aptos Display")
title_style._element.rPr.rFonts.set(qn("w:hAnsi"), "Aptos Display")
title_style.font.size = Pt(27)
title_style.font.bold = True
title_style.font.color.rgb = RGBColor.from_string(BLACK)
title_style.paragraph_format.space_after = Pt(14)
remove_paragraph_borders(title_style.element)

for name, size, before, after in (("Heading 1", 17, 14, 6), ("Heading 2", 13, 10, 4), ("Heading 3", 11.5, 8, 3)):
    style = styles[name]
    style.font.name = "Aptos Display"
    style._element.rPr.rFonts.set(qn("w:ascii"), "Aptos Display")
    style._element.rPr.rFonts.set(qn("w:hAnsi"), "Aptos Display")
    style.font.size = Pt(size)
    style.font.bold = True
    style.font.color.rgb = RGBColor.from_string(BLACK)
    style.paragraph_format.space_before = Pt(before)
    style.paragraph_format.space_after = Pt(after)
    style.paragraph_format.line_spacing = Pt(size * 1.3)
    style.paragraph_format.keep_with_next = True

for name in ("List Bullet", "List Bullet 2", "List Number"):
    styles[name].font.name = "Aptos"
    styles[name]._element.rPr.rFonts.set(qn("w:ascii"), "Aptos")
    styles[name]._element.rPr.rFonts.set(qn("w:hAnsi"), "Aptos")
    styles[name].font.size = Pt(10.6)
    styles[name].paragraph_format.space_before = Pt(1.5)
    styles[name].paragraph_format.space_after = Pt(3)
    styles[name].paragraph_format.line_spacing = Pt(14.5)

doc.core_properties.title = "Техническое задание на систему аттестации"
doc.core_properties.subject = "Требования к веб-приложению учебного центра"
doc.core_properties.author = "Учебный центр"
doc.core_properties.keywords = "аттестация, тестирование, Moodle, техническое задание"

# Cover and purpose
p = doc.add_paragraph(style="Title")
p.add_run("Техническое задание на систему аттестации")
remove_paragraph_borders(p._p)
p = doc.add_paragraph()
r = p.add_run("Веб-приложение учебного центра корпорации")
set_font(r, size=14, color=MUTED)
p.paragraph_format.space_after = Pt(20)

meta = doc.add_table(rows=4, cols=2)
meta.alignment = WD_TABLE_ALIGNMENT.LEFT
meta.autofit = False
meta.columns[0].width = Inches(1.45)
meta.columns[1].width = Inches(5.1)
for row, (label, value) in zip(meta.rows, [
    ("Статус", "Рабочий проект для согласования"),
    ("Версия", "0.1"),
    ("Дата", "18 ноября 2026 года"),
    ("Основание", "Текущее состояние прототипа и обсуждение процесса аттестации"),
]):
    row.cells[0].width = Inches(1.45)
    row.cells[1].width = Inches(5.1)
    row.cells[0].text = label
    row.cells[1].text = value
    set_cell_shading(row.cells[0], PALE_BLUE)
    for cell in row.cells:
        cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
        set_cell_margins(cell)
    set_font(row.cells[0].paragraphs[0].runs[0], bold=True)
set_table_borders(meta)

p = doc.add_paragraph()
p.paragraph_format.space_before = Pt(16)
r = p.add_run("Назначение документа")
set_font(r, size=12, bold=True)
p = doc.add_paragraph(
    "Документ фиксирует назначение системы, реализованные правила работы прототипа и решения, "
    "которые необходимо согласовать до промышленной разработки. После получения ответов открытые "
    "вопросы должны быть преобразованы в однозначные требования и критерии приёмки."
)

p = doc.add_paragraph()
p.paragraph_format.space_before = Pt(8)
r = p.add_run("Главный результат согласования")
set_font(r, size=12, bold=True)
doc.add_paragraph(
    "Команда разработки должна получить утверждённые правила назначения, прохождения, проверки и "
    "хранения результатов аттестации, а также границы интеграции с Moodle и другими системами."
)

doc.add_page_break()

doc.add_heading("Область применения", level=1)
doc.add_paragraph(
    "Система предназначена для дистанционной аттестации сотрудников корпорации, специалистов "
    "заказчиков и партнёров. Аттестация подтверждает квалификацию по продуктам корпорации, "
    "разработке расширений и администрированию, а также может использоваться при допуске к работам "
    "на проектах внедрения и поддержки."
)
add_bullet(doc, "Заказчик результата - руководитель подразделения или внешний заказчик внедрения.")
add_bullet(doc, "Успешный результат - достижение проходного балла за ограниченное время.")
add_bullet(doc, "Аттестация может быть первичной или повторной.")
add_bullet(doc, "Первый выпуск охватывает тестовые задания с выбором вариантов ответа.")

doc.add_heading("Текущее решение", level=1)
doc.add_paragraph(
    "Прототип реализован как веб-приложение с ролевым доступом, каталогом тестов, назначениями и "
    "попытками. Учётные записи читаются из локальной имитации таблицы Moodle, а назначения и "
    "завершённые попытки сохраняются в PostgreSQL. Банк вопросов хранится в CSV-файлах."
)

doc.add_heading("Пользователи и роли", level=2)
roles = doc.add_table(rows=1, cols=3)
roles.alignment = WD_TABLE_ALIGNMENT.CENTER
roles.autofit = False
widths = [Inches(1.25), Inches(2.05), Inches(3.25)]
for i, text in enumerate(("Роль", "Назначение", "Доступ в прототипе")):
    roles.rows[0].cells[i].width = widths[i]
    roles.rows[0].cells[i].text = text
    set_cell_shading(roles.rows[0].cells[i], NAVY)
    set_font(roles.rows[0].cells[i].paragraphs[0].runs[0], bold=True, color="FFFFFF")
    roles.rows[0].cells[i].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
set_repeat_table_header(roles.rows[0])
role_rows = [
    ("Администратор", "Контроль пользователей", "Просматривает список слушателей и данные их учётных записей."),
    ("Менеджер", "Организация аттестации", "Назначает тесты и просматривает завершённые попытки."),
    ("Преподаватель", "Содержание и результаты", "Видит свои тесты и число успешных и неуспешных попыток."),
    ("Слушатель", "Прохождение аттестации", "Видит назначения, запускает попытку и просматривает свои результаты."),
]
for idx, values in enumerate(role_rows):
    cells = roles.add_row().cells
    for i, value in enumerate(values):
        cells[i].width = widths[i]
        cells[i].text = value
        cells[i].vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
        set_cell_margins(cells[i])
        if idx % 2:
            set_cell_shading(cells[i], PALE_GRAY)
set_table_borders(roles)

doc.add_heading("Авторизация", level=2)
add_bullet(doc, "При открытии приложения пользователь вводит логин и пароль.")
add_bullet(doc, "Учётные записи прототипа читаются из имитации таблицы Moodle mdl_user.")
add_bullet(doc, "Роли прототипа: admin, manager, mentor и user.")
add_bullet(doc, "В демонстрационной среде пароль хранится как MD5-хеш. Для промышленного решения этот механизм должен быть заменён или согласован отдельно.")

doc.add_heading("Банк тестов и вопросов", level=2)
add_bullet(doc, "Один CSV-файл соответствует одному тесту.")
add_bullet(doc, "Первая строка содержит логин преподавателя и название теста.")
add_bullet(doc, "Вопрос содержит текст, сложность, тип выбора и варианты с признаком правильности.")
add_bullet(doc, "Поддерживаются единичный и множественный выбор.")
add_bullet(doc, "Поддерживаются уровни сложности EASY, MEDIUM и HARD.")
add_bullet(doc, "Каталог тестов хранится в src/main/resources/tests/catalog.csv.")

doc.add_heading("Назначение и попытка", level=2)
add_bullet(doc, "Менеджер назначает слушателю конкретный тест.")
add_bullet(doc, "Переход слушателя к назначению запускает попытку.")
add_bullet(doc, "Одно назначение предоставляет одну завершённую попытку.")
add_bullet(doc, "Для пересдачи менеджер создаёт новое назначение.")
add_bullet(doc, "На экране показывается один вопрос; слушатель может переходить между вопросами и менять ответы до завершения.")
add_bullet(doc, "Ограничение времени действует на весь тест.")
add_bullet(doc, "Текущая версия использует все вопросы файла; случайная выборка по сложности ещё не реализована.")

doc.add_heading("Оценивание", level=2)
add_bullet(doc, "Результат рассчитывается по шкале от 0 до 100 баллов.")
add_bullet(doc, "Текущий проходной балл - 80.")
add_bullet(doc, "Вес лёгкого вопроса - 10, среднего - 20, сложного - 40 баллов.")
add_bullet(doc, "Итог нормируется до 100 баллов пропорционально суммарному весу вопросов попытки.")
add_bullet(doc, "Для множественного выбора балл начисляется только при полном совпадении выбранного набора с правильным.")

doc.add_heading("Хранение данных", level=2)
add_bullet(doc, "Пользователи находятся в схеме public PostgreSQL в имитации Moodle.")
add_bullet(doc, "Назначения и завершённые попытки хранятся в схеме attestation.")
add_bullet(doc, "Незавершённая попытка хранится в памяти процесса.")
add_bullet(doc, "После перезапуска приложения незавершённую попытку можно начать заново, пока назначение не завершено.")
add_bullet(doc, "Консольный профиль остаётся автономным и работает без базы данных и авторизации.")

doc.add_heading("Требования к целевому процессу", level=1)
doc.add_paragraph(
    "Следующие требования отражают согласованное направление развития. Числовые значения и правила, "
    "которые ещё не утверждены, вынесены в раздел открытых вопросов."
)

requirements = [
    ("Управление назначениями", [
        "Менеджер выбирает слушателя, тест и условия прохождения.",
        "Система показывает статус назначения: доступно, выполняется, завершено, просрочено или отменено.",
        "Повторная попытка создаётся отдельным назначением либо по утверждённому правилу пересдачи.",
    ]),
    ("Прохождение аттестации", [
        "Перед стартом слушатель видит название теста, число вопросов, лимит времени и правила завершения.",
        "Система фиксирует время старта и оставшееся время на сервере.",
        "Ответы сохраняются в ходе попытки, чтобы обновление страницы не приводило к потере данных.",
        "Слушатель может переходить между вопросами и менять ответ до завершения, если иное не задано настройками теста.",
        "По истечении времени система автоматически завершает попытку и рассчитывает результат.",
    ]),
    ("Проверка и результат", [
        "Автоматически проверяемые вопросы оцениваются по утверждённому алгоритму.",
        "Результат включает набранный балл, проходной балл и статус сдачи.",
        "Доступ слушателя к правильным ответам и ошибкам определяется настройками теста.",
        "Менеджер и преподаватель получают отчёт в пределах своих полномочий.",
    ]),
    ("Надёжность и аудит", [
        "Завершённые результаты не теряются при перезапуске приложения.",
        "Система регистрирует существенные действия: вход, назначение, старт, сохранение ответа, завершение и изменение результата.",
        "Сервер считается источником истины для времени и статуса попытки.",
        "Повторная отправка запроса не должна создавать дубликаты результата.",
    ]),
]
for title, items in requirements:
    doc.add_heading(title, level=2)
    for item in items:
        add_bullet(doc, item)

doc.add_heading("Известные ограничения прототипа", level=1)
add_bullet(doc, "Нет случайной выборки заданного числа вопросов по уровням сложности.")
add_bullet(doc, "Активная попытка не восстанавливается после перезапуска приложения.")
add_bullet(doc, "MD5 и демонстрационный пароль нельзя использовать в промышленной среде.")
add_bullet(doc, "Руководитель подразделения пока не выделен в отдельную роль.")
add_bullet(doc, "Не реализованы сертификаты, реестр документов и повторная печать.")
add_bullet(doc, "Не определены интеграции для передачи результата в кадровые и проектные системы.")
add_bullet(doc, "Не согласованы сроки хранения персональных данных, попыток и журнала действий.")
add_bullet(doc, "Не определены требования к внешнему доступу, нагрузке и отказоустойчивости.")

doc.add_heading("Вопросы к разработке", level=1)
doc.add_paragraph(
    "Ответы на вопросы ниже нужны до детализации архитектуры, модели данных и критериев приёмки. "
    "Если правило зависит от типа теста, следует указать это в ответе."
)

question_groups = [
    ("Назначения и попытки", [
        "Кто вправе создавать, изменять и отменять назначение?",
        "Может ли назначение иметь дату начала, срок окончания и отдельное окно доступности?",
        "Сколько попыток допускается по одному назначению?",
        "Кто и при каких условиях разрешает пересдачу?",
        "Нужен ли обязательный интервал между неудачной попыткой и пересдачей?",
        "Можно ли назначать один тест группе слушателей одной операцией?",
        "Что происходит с активной попыткой при отмене назначения?",
        "Нужно ли менеджеру принудительно завершать или аннулировать попытку?",
    ]),
    ("Время", [
        "Как задаётся лимит времени: для теста, назначения или конкретной попытки?",
        "Когда начинается отсчёт: при открытии назначения, подтверждении старта или показе первого вопроса?",
        "Разрешена ли пауза и кто может её предоставить?",
        "Что происходит при кратковременной потере связи?",
        "Нужно ли предупреждать об остатке времени и за сколько минут?",
        "Какие ответы учитываются при автоматическом завершении?",
        "Какая часовая зона используется для сроков и отчётов?",
    ]),
    ("Состав теста", [
        "Сколько вопросов должно быть в попытке?",
        "Нужно ли выбирать фиксированное число вопросов каждой сложности?",
        "Должны ли вопросы и варианты ответов перемешиваться?",
        "Нужно ли исключать ранее показанные вопросы при пересдаче?",
        "Может ли один вопрос входить в несколько тестов?",
        "Нужны ли категории, темы, теги и версии вопросов?",
        "Как поступать, если в банке недостаточно вопросов нужной сложности?",
    ]),
    ("Проверка ответов", [
        "Сохраняется ли правило полного совпадения для множественного выбора?",
        "Нужны ли частичные баллы за неполный правильный набор?",
        "Есть ли штраф за лишний или неверный вариант?",
        "Допускаются ли вопросы без вариантов ответа?",
        "Нужна ли ручная проверка практических или текстовых заданий?",
        "Можно ли менять ключ ответа после того, как появились завершённые попытки?",
        "Как пересчитывать старые результаты после исправления ошибочного вопроса?",
    ]),
    ("Проходной результат", [
        "Проходной балл 80 является общим или задаётся для каждого теста?",
        "Нужен ли минимальный результат по отдельным темам или практической части?",
        "Как округляется итоговый балл?",
        "Есть ли статусы кроме сдано и не сдано?",
        "Кто может изменить или аннулировать рассчитанный результат?",
    ]),
    ("Просмотр результатов", [
        "Что видит слушатель сразу после завершения?",
        "Показывать ли правильные ответы, ошибки и пояснения?",
        "Можно ли ограничить просмотр ошибок по времени или до окончания экзаменационной группы?",
        "Нужна ли процедура апелляции и кто её рассматривает?",
        "Должен ли преподаватель видеть ответы конкретного слушателя?",
        "Должен ли руководитель видеть только сотрудников своего подразделения?",
        "Кому разрешён экспорт персональных результатов?",
    ]),
    ("Форматирование вопросов", [
        "Нужны ли изображения, таблицы, формулы, фрагменты кода и вложения?",
        "Нужны ли пояснения к правильному ответу?",
        "Какие форматы импорта должны поддерживаться кроме GIFT и CSV?",
        "Нужно ли сохранять категории и служебные поля Moodle при импорте?",
        "Как обрабатывать неподдерживаемые типы вопросов GIFT?",
        "Нужен ли предварительный просмотр и протокол ошибок импорта?",
        "Кто может публиковать и архивировать вопросы?",
    ]),
    ("Интеграция с Moodle", [
        "Moodle остаётся источником пользователей или требуется двусторонняя синхронизация?",
        "Как сопоставлять роли и подразделения?",
        "Нужно ли использовать единый вход вместо отдельного пароля?",
        "Какие поля пользователя обязательны для аттестации?",
        "Нужно ли автоматически отключать уволенных или заблокированных пользователей?",
        "Откуда поступают тесты: GIFT-файл, таблицы Moodle или API?",
        "Нужно ли возвращать результаты в журнал оценок Moodle?",
        "Как часто выполняется синхронизация?",
        "Как разрешаются конфликты изменений?",
        "Кто отвечает за доступ к промышленной базе и API Moodle?",
    ]),
    ("Пользователи и роли", [
        "Нужна ли отдельная роль руководителя подразделения?",
        "Может ли один пользователь иметь несколько ролей?",
        "Кто создаёт пользователей, отсутствующих в Moodle?",
        "Какие данные пользователя может редактировать менеджер?",
        "Нужно ли разделять менеджеров по учебным направлениям или организациям?",
        "Может ли преподаватель видеть чужие тесты?",
        "Нужна ли временная передача полномочий на период отсутствия сотрудника?",
    ]),
    ("Активная попытка", [
        "Должна ли попытка продолжаться после обновления страницы и повторного входа?",
        "Можно ли продолжить попытку на другом устройстве?",
        "Допускается ли одновременное открытие в нескольких вкладках?",
        "Как долго хранится незавершённая попытка?",
        "Нужно ли сохранять каждый ответ немедленно или пакетно?",
        "Что считать техническим сбоем, позволяющим восстановить попытку?",
        "Кто принимает решение о восстановлении или аннулировании?",
    ]),
    ("Отчётность и документы", [
        "Какие отчёты нужны менеджеру, преподавателю и руководителю?",
        "Какие фильтры и форматы выгрузки обязательны?",
        "Нужна ли аналитика по вопросам, темам и сложности?",
        "Нужно ли хранить снимок формулировок и ключей на момент попытки?",
        "Какой утверждённый шаблон сертификата используется?",
        "Нужны ли номер, срок действия, печать и электронная подпись?",
        "Нужен ли реестр выданных сертификатов и повторная печать?",
        "Куда передавать итог: в кадровую систему, личное дело, портал или систему допуска?",
    ]),
    ("Эксплуатация и безопасность", [
        "Сколько одновременных пользователей и попыток нужно поддерживать?",
        "Будет ли система доступна из интернета или только из корпоративной сети?",
        "Какие браузеры и мобильные устройства поддерживаются?",
        "Какой допустимый простой и время восстановления?",
        "Нужны ли резервное копирование и отдельный план восстановления?",
        "Каков срок хранения назначений, ответов, результатов и журналов?",
        "Какие требования действуют для персональных данных?",
        "Нужны ли протоколирование административных изменений и неизменяемый аудит?",
        "Какие действия требуют дополнительного подтверждения?",
        "Кто сопровождает систему и принимает обращения пользователей?",
    ]),
]
for title, questions in question_groups:
    add_question_group(doc, title, questions)

doc.add_heading("Приоритетные решения первого этапа", level=1)
doc.add_paragraph(
    "Для следующего цикла разработки достаточно сначала ответить на вопросы ниже. Они определяют "
    "модель попытки, сохранение состояния и правила результата."
)
priority = [
    "Сколько попыток допускается по одному назначению и как оформляется пересдача?",
    "Когда начинается отсчёт времени и что происходит при его истечении?",
    "Должна ли незавершённая попытка восстанавливаться после обновления страницы и перезапуска сервера?",
    "Можно ли продолжать попытку на другом устройстве или одновременно в нескольких вкладках?",
    "Как формируется набор вопросов: все вопросы, случайная выборка или квота по сложности?",
    "Перемешиваются ли вопросы и варианты ответов?",
    "Сохраняется ли полное совпадение для множественного выбора или вводятся частичные баллы?",
    "Проходной балл общий или задаётся для каждого теста?",
    "Что слушатель видит после завершения попытки?",
    "Какие данные должны сохраняться для аудита и разбора спорных результатов?",
]
for number, item in enumerate(priority, start=1):
    add_number(doc, number, item)
    spacer = doc.add_paragraph()
    spacer.paragraph_format.space_before = Pt(0)
    spacer.paragraph_format.space_after = Pt(0)
    spacer.paragraph_format.line_spacing = Pt(6)
    spacer.add_run(" ").font.size = Pt(1)

for sec in doc.sections:
    footer = sec.footer
    fp = footer.paragraphs[0]
    fp.paragraph_format.space_before = Pt(4)
    add_page_number(fp)
    for run in fp.runs:
        set_font(run, size=9, color=MUTED)

OUTPUT.parent.mkdir(parents=True, exist_ok=True)
doc.save(OUTPUT)
print(OUTPUT)
