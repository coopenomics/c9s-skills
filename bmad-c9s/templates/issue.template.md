---
type: issue
title: "{{TITLE}}"
hash: "{{ISSUE_HASH}}"
project_hash: "{{PROJECT_HASH}}"
status: backlog
priority: medium
estimate: 0 # bmad-c9s: 0, пока оператор явно не задал иначе; фактическое время до on_review (on_review — только по команде оператора)
created_by: "{{USERNAME}}"
submaster: "{{USERNAME}}"
creators: ["{{USERNAME}}"]
labels: []
sort_order: 0
created_at: "{{ISO_TIMESTAMP}}"
updated_at: "{{ISO_TIMESTAMP}}"
---

## Описание

## Критерии приёмки

## Связи

- При необходимости ссылки на продуктовые **`requirements/*.md`** (пути от корня `base`). Всё для выполнения этой задачи — в разделах выше (одна dev-задача, один промпт).

**bmad-c9s:** подставь **`{{USERNAME}}`** из **`c9s-config.yaml` → `username`** во все три поля (`created_by`, `submaster`, `creators`) — иначе учёт времени в Capital не запустится. В **начале** работы — создать задачу и **push**. **`on_review`** агент **не ставит** сам: только после **явной команды оператора** (**`/c9s-submit-for-review`**, «отправь на ревью») — тогда **`on_review`**, **`updated_at`**, commit/push. До команды — **`in_progress`** (или **`todo`**). См. [docs/TASKS-DOCUMENTS-TIME-POLICY.md](../docs/TASKS-DOCUMENTS-TIME-POLICY.md) §1–2.
