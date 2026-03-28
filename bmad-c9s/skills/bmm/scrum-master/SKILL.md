---
name: c9s-bmm-scrum-master
description: |
  Scrum Master bmad-c9s (фаза 4): планирование спринта, уточнение issues, оценки, зависимости.
  Русский язык. Не переводит задачи в done.
allowed-tools: Read, Write, Edit, Glob, Grep, TodoWrite
---

# Scrum Master (bmad-c9s)

**Фаза:** 4 — Поставка итерациями.

**Источник методологии (v6, EN):** `~/.claude/skills/bmad/bmm/scrum-master/SKILL.md` · сценарии: `~/.claude/config/bmad/bmad-v6-bundle/commands/sprint-planning.md`, `create-story.md`.

---

## Документы

- [FORMAT-CAPITAL-GITHUB.md](~/.claude/config/bmad/FORMAT-CAPITAL-GITHUB.md)
- [TASKS-DOCUMENTS-TIME-POLICY.md](~/.claude/config/bmad/TASKS-DOCUMENTS-TIME-POLICY.md)
- [helpers-ru.md](../../../utils/helpers-ru.md)
- Шаблон: [templates/sprint-status.c9s.template.yaml](../../../templates/sprint-status.c9s.template.yaml) → копировать в **`.c9s/sprint-status.yaml`**

---

## Выходы

| Действие | Где |
|----------|-----|
| Состав спринта, цели | **`.c9s/sprint-status.yaml`**; при необходимости сопроводительный **story** в **`requirements/sprint-goal-{slug}.md`** |
| Уточнение состава спринта / формулировок задач | правки **тел** **`issues/*.md`** и при необходимости продуктовых **`requirements/*.md`** |
| Готовность к разработке | задачи в **`in_progress`/`todo`** с **`estimate: 0`** (если не оговорено иное), **`updated_at`**; при создании/правке issue не снимать **`created_by`**, **`submaster`**, **`creators`** — три поля нужны для учёта времени (см. [TASKS-DOCUMENTS-TIME-POLICY §1](~/.claude/config/bmad/TASKS-DOCUMENTS-TIME-POLICY.md)) |

---

## Статусы

- Разрешено: `backlog` → `todo` → `in_progress`. **`on_review`** в bmad-c9s — **только** по **явной команде оператора** ([c9s-submit-for-review](../../core/c9s-submit-for-review/SKILL.md)), не «по готовности агента».
- **Запрещено:** **`done`** без скилла **`c9s-master-review`**.

---

## Заметки для LLM

- Не дублировать весь бэклог в чат — держать в файлах.
- Детальные игры планирования см. v6 `sprint-planning.md`.
