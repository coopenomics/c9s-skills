---
name: c9s-bmb-builder
description: |
  Конструктор расширений bmad-c9s: новые скиллы, шаблоны, команды под Coopenomics. Русский язык.
  Новые артефакты — в bmad-c9s/, не в канон Capital без явного запроса.
allowed-tools: Read, Write, Edit, Glob, Grep, TodoWrite
---

# Builder (bmad-c9s)

**Назначение:** расширять пакет **bmad-c9s** — скиллы, шаблоны, команды.

**Источник методологии (v6, EN):** `~/.claude/skills/bmad/bmb/builder/SKILL.md` · опционально репозиторий `bmad-skills/builder/` при открытом пакете.

---

## Правила

1. Новый скилл: каталог `bmad-c9s/skills/.../SKILL.md` с YAML frontmatter (`name`, `description`, `allowed-tools`).
2. Текст **на русском**, если не оговорено иное.
3. Каждый скилл bmad-c9s, работающий с Capital, **должен ссылаться** на [FORMAT-CAPITAL-GITHUB.md](~/.claude/config/bmad/FORMAT-CAPITAL-GITHUB.md).
4. Скиллы, которые создают или правят **`issues/*.md`**, дополнительно ссылаются на [TASKS-DOCUMENTS-TIME-POLICY.md](~/.claude/config/bmad/TASKS-DOCUMENTS-TIME-POLICY.md) **§1–2**: сначала issue, затем story в **`requirements/`**; поля **`created_by`**, **`submaster`**, **`creators`**; **`on_review`** только по команде оператора (**`c9s-submit-for-review`**).
5. Не дублировать полные главы из v6 — укажи `~/.claude/skills/bmad/…/SKILL.md` или `bmad-v6/…` **только** если workspace — корень `claude-code-bmad-skills`.

---

## Структура SKILL.md (напоминание)

- Триггеры в `description`.
- Роль, фаза, запреты (например **не done**).
- Таблица выходов и путей.
- «Заметки для LLM».

---

## Заметки для LLM

- Перед добавлением команды проверь, нет ли дубля в `bmad-c9s/commands/`.
- Шаблоны frontmatter для issue/story — совместимость с парсером controller и с [issue.template.md](../../../templates/issue.template.md) / **TASKS §1** (три поля учёта в новых задачах).
