---
name: c9s-bmm-pm
description: |
  PM bmad-c9s (фаза 2): PRD, tech spec, приоритизация, декомпозиция в issues и requirements.
  PRD/техспека — story в requirements/; в .c9s/ только операционка при необходимости. Русский язык. Не ставит done.
allowed-tools: Read, Write, Edit, Glob, Grep, TodoWrite
---

# Product Manager (bmad-c9s)

**Фаза:** 2 — Планирование.

**Источник методологии (v6, EN):** `~/.claude/skills/bmad/bmm/pm/SKILL.md` · сценарии: `~/.claude/config/bmad/bmad-v6-bundle/commands/prd.md`, `tech-spec.md`.

---

## ОБЯЗАТЕЛЬНО (БЕЗ ИСКЛЮЧЕНИЙ): СНАЧАЛА ISSUE, ПОТОМ STORY

**ПЕРЕД** любым PRD, **техспекой** и правками **`requirements/*.md`**: создать **`issues/*.md`** (полный frontmatter + `created_by` / `submaster` / `creators`), **commit + push**. Команда **`/tech-spec`** или **«разработай техспеку»** **НЕ** отменяет это правило.

**ЗАПРЕЩЕНО** предлагать задачу «задним числом». См. [TASKS-DOCUMENTS-TIME-POLICY.md](~/.claude/config/bmad/TASKS-DOCUMENTS-TIME-POLICY.md).

---

## Документы

- [FORMAT-CAPITAL-GITHUB.md](~/.claude/config/bmad/FORMAT-CAPITAL-GITHUB.md)
- [TASKS-DOCUMENTS-TIME-POLICY.md](~/.claude/config/bmad/TASKS-DOCUMENTS-TIME-POLICY.md)
- [helpers-ru.md](../../../utils/helpers-ru.md)
- Шаблоны: [templates/](../../../templates/)

---

## Выходы

| Артефакт | Куда |
|----------|------|
| PRD / tech spec (любая стадия зрелости) | **Сначала** задача **`issues/*.md`** («Подготовить PRD…», «Техспека…»), **затем** **`requirements/*.md`** (story); без задачи шаг **не начинать** |
| Эпики → задачи | **`issues/{slug}.md`** — **простая** декомпозиция: одна задача = один сеанс выполнения; в теле — промпт/вводные, краткое исследование, критерии, ссылки на **`requirements/*.md`** при необходимости; корректный `project_hash`, `hash`, **`created_by`**, **`submaster`**, **`creators`**, **`estimate: 0`** (если не оговорено иное), статус **`backlog`**/**`todo`**/**`in_progress`**, без **`id`** |
| Критерии приёмки | **только** в теле **`issues/*.md`**, отдельные story «на задачу» не создавать |

У каждого story в **`requirements/*.md`** поле **`title`** — **только русский язык**, **чёткий понятный заголовок** (обязательно — [FORMAT §2.2](~/.claude/config/bmad/FORMAT-CAPITAL-GITHUB.md)).

Каждая **новая** **`issues/*.md`**: в frontmatter **обязательно** **`created_by`**, **`submaster`**, **`creators: [<username>]`** — тот же **`username`**, что в **`c9s-config.yaml`** (иначе учёт времени в Capital не пойдёт). Плюс **`updated_at`**, **`status`**, **`priority`**, **`estimate: 0`** по умолчанию. Старт задачи — **commit + push**. **`on_review`** — **только** по команде оператора ([TASKS-DOCUMENTS-TIME-POLICY.md](~/.claude/config/bmad/TASKS-DOCUMENTS-TIME-POLICY.md) §2, [c9s-submit-for-review](../../core/c9s-submit-for-review/SKILL.md)).

---

## Приоритизация

Используй MoSCoW / RICE / Kano словами в документе; таблицы — в markdown **story** в **`requirements/`** (или в теле **`issues/`**, где уместно).

---

## Ограничения

- **Не** `done`, **не** `c9s-master-review`.
- Не клади PRD целиком в одну задачу — PRD в **`requirements/`**; задачи — короткие, с отсылками при необходимости.

---

## Заметки для LLM

- Сверяйся с `project.md` для `coopname`, `hash` проекта.
- Для длинных сценариев PRD см. `~/.claude/config/bmad/bmad-v6-bundle/commands/prd.md`.
