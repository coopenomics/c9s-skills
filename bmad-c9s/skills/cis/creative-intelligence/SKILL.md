---
name: c9s-creative-intelligence
description: |
  Креативное мышление bmad-c9s: SWOT, SCAMPER, исследовательские вопросы. Результаты — story MARKDOWN
  в requirements/*.md. Русский язык. Не меняет статусы задач на done.
allowed-tools: Read, Write, Edit, Glob, Grep, TodoWrite
---

# Creative Intelligence (bmad-c9s)

**Фаза:** 1 (и ретроспективы в 4 по запросу).

**Источник методологии (v6, EN):** `~/.claude/skills/bmad/cis/creative-intelligence/SKILL.md`.

---

## ОБЯЗАТЕЛЬНО (БЕЗ ИСКЛЮЧЕНИЙ): СНАЧАЛА `issues/*.md` + PUSH, ПОТОМ `requirements/`

SWOT, штурм и любые story — **ТОЛЬКО** после задачи **`issues/*.md`** и **commit + push**. **ЗАПРЕЩЕНО** «задним числом». [TASKS-DOCUMENTS-TIME-POLICY.md](~/.claude/config/bmad/TASKS-DOCUMENTS-TIME-POLICY.md).

---

## Документы

- [FORMAT-CAPITAL-GITHUB.md](~/.claude/config/bmad/FORMAT-CAPITAL-GITHUB.md)
- [TASKS-DOCUMENTS-TIME-POLICY.md](~/.claude/config/bmad/TASKS-DOCUMENTS-TIME-POLICY.md)
- [helpers-ru.md](../../../utils/helpers-ru.md)

---

## Выходы

| Сессия | Куда писать |
|--------|-------------|
| Мозговой штурм, SWOT, варианты решений | **Сначала** **`issues/*.md`** на сессию (например «Мозговой штурм по …») с полями **`created_by`**, **`submaster`**, **`creators`** ([TASKS §1](~/.claude/config/bmad/TASKS-DOCUMENTS-TIME-POLICY.md)), **затем** **`requirements/…md`** — `type: story`, **`content_format: MARKDOWN`** |
| Отобранные идеи как отдельные требования | при необходимости отдельная **задача** (те же поля учёта) + **`requirements/idea-*.md`** |

Не начинать оформленную сессию **только** story без **issue** — см. [TASKS-DOCUMENTS-TIME-POLICY.md](~/.claude/config/bmad/TASKS-DOCUMENTS-TIME-POLICY.md).

**`title`** у каждого story — **только русский**, **чёткий заголовок**; имя файла — транслит от заголовка ([FORMAT §2.2](~/.claude/config/bmad/FORMAT-CAPITAL-GITHUB.md)), а не голые префиксы `brainstorm-`/`idea-` без смысла в **`title`**.

---

## Методы (кратко)

- **SCAMPER** — по пунктам в markdown-списках.
- **SWOT** — четыре квадранта заголовками `##`.
- **Six Thinking Hats** — роли по подзаголовкам.

---

## Заметки для LLM

- **`on_review`** и **`done`** этим скиллом **не** выставлять; ревью — **`c9s-submit-for-review`** (оператор), завершение — **`c9s-master-review`**.
- Избегай «воды»; каждая идея — проверяемое утверждение или вопрос.
- Скрипты из v6 (`scamper-prompts.sh` и т.д.) — опционально, если пользователь установил bmad-skills.
