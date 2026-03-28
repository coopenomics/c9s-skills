---
name: c9s-results-push
description: |
  Репозиторий результатов Capital: базовый режим — агент сам commit/push после правок (GIT-COMMITS-POLICY).
  Этот скилл — для явной команды пользователя с особым сообщением коммита или повторного push.
  Монорепо кода не трогать — только c9s-monorepo-component-git.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
---

# Push результатов в Git (c9s-results-push)

## Назначение

**По умолчанию** агент **уже** выполняет **`git commit`** и **`git push`** в репозитории результатов после значимых правок — см. [GIT-COMMITS-POLICY.md](~/.claude/config/bmad/GIT-COMMITS-POLICY.md) §1.

Этот скилл нужен, когда пользователь **явно** просит:

- отдельный коммит с **заданным** текстом сообщения;
- повторный **`git push`**;
- «запушь results» / `c9s-push-results` как **отдельную** операцию.

**Не** использовать как оправдание **не** коммитить после обычной работы — автофиксация по политике обязательна.

---

## Обязательные ссылки

- [GIT-COMMITS-POLICY.md](~/.claude/config/bmad/GIT-COMMITS-POLICY.md)
- [TASKS-DOCUMENTS-TIME-POLICY.md](~/.claude/config/bmad/TASKS-DOCUMENTS-TIME-POLICY.md)
- [CLAUDE.md](../../../CLAUDE.md)
- [helpers-ru.md](../../../utils/helpers-ru.md)

---

## Алгоритм (явный вызов)

1. Прочитать `c9s-config.yaml`, корень git-репозитория результатов (`results_root`).
2. `git status` — показать изменения.
3. Сообщение коммита: **русский**, по указанию пользователя или по смыслу изменений.
4. `git add` → `git commit` → при необходимости `git push`.
5. Без `force-push` на общие ветки без прямого указания пользователя.

---

## Запреты

- Не применять к **монорепозиторию кода** — только [c9s-monorepo-component-git](../c9s-monorepo-component-git/SKILL.md).
