---
name: c9s-submit-for-review
description: |
  Перевод задачи Capital в on_review по ЯВНОЙ команде оператора (не автоматически после работы агента).
  Обновить updated_at, commit и push в репозиторий результатов. Триггеры: /c9s-submit-for-review,
  «отправь задачу на ревью», «переведи issue … в on_review».
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
---

# Передача задачи на ревью мастеру (c9s-submit-for-review)

## Назначение

Выполнять **только** после **явного** указания **оператора** (человека): он прочитал/проверил результат (PRD, правки, код в контексте задачи и т.д.) и **сознательно** готов передать задачу мастеру в очередь ревью.

**Запрещено:** переводить в **`on_review`** «потому что агент закончил черновик» — см. [TASKS-DOCUMENTS-TIME-POLICY.md](~/.claude/config/bmad/TASKS-DOCUMENTS-TIME-POLICY.md) §2.

---

## Обязательные ссылки

- [TASKS-DOCUMENTS-TIME-POLICY.md](~/.claude/config/bmad/TASKS-DOCUMENTS-TIME-POLICY.md)
- [FORMAT-CAPITAL-GITHUB.md](~/.claude/config/bmad/FORMAT-CAPITAL-GITHUB.md)
- [GIT-COMMITS-POLICY.md](~/.claude/config/bmad/GIT-COMMITS-POLICY.md)

---

## Алгоритм

1. Убедиться, что пользователь **явно** попросил перевести **конкретную** задачу (или все перечисленные) в ревью.
2. Найти **`{base}/issues/{slug}.md`**. Если нет **`created_by`**, **`submaster`** или пустой **`creators`** — предупредить оператора: учёт времени в Capital мог не работать; при согласии — добавить поля из **`c9s-config.yaml` → `username`** и только затем ревью. Выставить **`status: on_review`**, новый **`updated_at`** (ISO UTC).
3. При необходимости кратко дополнить **тело** задачи (что сдано на ревью), без подмены решения мастера.
4. **Commit + push** в репозиторий результатов (сообщение на русском, например: «Задача … передана на ревью»).
5. **Не** ставить **`done`** — это **`c9s-master-review`**.

---

## Заметки для LLM

- Если пользователь не формулировал команду как «на ревью», а только «закончи задачу» — **уточнить**: оставить **`in_progress`** до проверки или уже **`on_review`**.
- По умолчанию «закончи» = довести артефакт до состояния **`in_progress`**, **без** `on_review`, пока оператор не скажет иначе.
