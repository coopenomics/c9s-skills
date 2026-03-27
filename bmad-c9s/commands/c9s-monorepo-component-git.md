# c9s-monorepo-component-git

Работа с **монорепозиторием кода**: создание ветки **`component/…`** от **`dev`**, коммиты только в ней, по команде — **merge в `dev`**, запись полного SHA merge в **`results_commits.yaml`** в **репозитории результатов** (по умолчанию **`.c9s/results_commits.yaml`** у проекта; см. GIT-COMMITS-POLICY §2.4), затем commit/push **results**.

Полная логика: скилл `bmad-c9s/skills/core/c9s-monorepo-component-git/SKILL.md`.

Политика: `bmad-c9s/docs/GIT-COMMITS-POLICY.md`.

Прямые коммиты в `dev` **запрещены**.
