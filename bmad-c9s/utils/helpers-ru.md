# Утилиты bmad-c9s (справка для агента)

Сокращённые инструкции без исполняемых скриптов: агент выполняет шаги через чтение/запись файлов.

Полная спецификация путей и полей: [../docs/FORMAT-CAPITAL-GITHUB.md](../docs/FORMAT-CAPITAL-GITHUB.md).

Git (results / монорепо): [../docs/GIT-COMMITS-POLICY.md](../docs/GIT-COMMITS-POLICY.md). Задачи, документы, `estimate`, `on_review`: [../docs/TASKS-DOCUMENTS-TIME-POLICY.md](../docs/TASKS-DOCUMENTS-TIME-POLICY.md).

---

## Загрузка конфигурации

1. Найти `c9s-config.yaml`:
   - сначала в **корне активного репозитория результатов** (рядом с `project.md` или корневой папкой проекта);
   - при отсутствии — путь из подсказки пользователя или из глобальных настроек.
2. Прочитать YAML и извлечь:
   - `results_root` (обязательно)
   - `active_project_slug`
   - `coopname`, `username`
   - `active_component_path` (опционально)
   - `default_language`
   - опционально для git монорепо: `monorepo_root`, `active_component_git_slug`, `results_commits_log`, `last_merge_to_dev_commit_hash`

---

## Путь к `results_commits.yaml` (журнал merge → dev для взносов)

Файл **только** в **репозитории результатов**, не в монорепозитории кода.

1. `projectRoot = {results_root}/{active_project_slug}`.
2. Если в конфиге задан **`results_commits_log`**: абсолютный путь — использовать как есть; иначе **`{projectRoot}/{results_commits_log}`**.
3. Иначе: **`{projectRoot}/.c9s/results_commits.yaml`**.

См. [docs/GIT-COMMITS-POLICY.md](../docs/GIT-COMMITS-POLICY.md) §2.4.

---

## Разрешение корня активного проекта Capital

```
projectRoot = {results_root}/{active_project_slug}
```

Файл корневого проекта:

```
{projectRoot}/project.md
```

Если задан `active_component_path` (например `components/my-comp`):

```
componentRoot = {projectRoot}/{active_component_path}
```

Файл компонента:

```
{componentRoot}/component.md
```

**База для задач и требований** (`base`):

- без компонента: `base = projectRoot`
- с компонентом: `base = componentRoot`

Пути:

- задачи: `{base}/issues/{issueSlug}.md` — в **теле** задачи весь контекст для реализации (bmad-c9s: без подпапок `*-requirements/`). В frontmatter новой задачи **обязательно**: **`created_by`**, **`submaster`**, **`creators: ["<username>"]`** — тот же **`username`**, что в **`c9s-config.yaml`**; иначе **не будет учёта времени** в Capital (см. [TASKS-DOCUMENTS-TIME-POLICY §1](../docs/TASKS-DOCUMENTS-TIME-POLICY.md)).
- требования уровня проекта: `{base}/requirements/{storySlug}.md`

**Наименование требований:** в каждом `{base}/requirements/*.md` поле **`title`** в frontmatter — **только русский язык**, заголовок **чёткий и понятный** (см. [FORMAT §2.2](../docs/FORMAT-CAPITAL-GITHUB.md)).

---

## Чтение `hash` из `project.md` / `component.md`

1. Прочитать файл.
2. Распарсить frontmatter (строки между `---`).
3. Взять значение `hash` — использовать как `project_hash` для новых задач и для story в **`requirements/`**.

Новые story в **`requirements/`** не привязывать к задаче через **`issue_hash`** и не класть рядом с `issues/` в отдельные каталоги — связь задачи с продуктовым контекстом только **ссылками в markdown-теле** `issues/*.md`.

---

## Генерация нового hash (64 hex)

Подойдёт любой способ **32 байта случайных → hex**. Примеры для пользователя (выполняет человек или среда, если разрешено):

```bash
openssl rand -hex 32
```

Агент **не выдумывает** предсказуемые строки; для демо в тесте можно использовать уже сгенерированную hex-строку.

---

## Обновление `updated_at`

При каждом сохранении файла, который должен импортироваться в Capital:

1. Установить `updated_at` в текущее время UTC в формате ISO 8601 с миллисекундами и суффиксом `Z`, например: `2026-03-27T15:04:05.123Z`.
2. Не откатывать `updated_at` на более старое значение при редактировании.

---

## Slug заголовка

Правило должно совпадать с бэкендом: транслитерация кириллицы в латиницу, пробелы и спецсимволы — в дефисы, нижний регистр, схлопывание повторяющихся дефисов (как `generateSlug` в `FileFormatService`). При сомнении — ориентироваться на **уже существующие имена папок** в репозитории.

---

## Операционная папка `.c9s/`

Здесь **только** то, что не является сущностью Capital (project/issue/story): статусы воркфлоу BMAD, служебные YAML, напоминания. **Не** хранить здесь брифы, PRD, заметки аналитика — это всё оформляется как **требования (story)** в `{base}/requirements/*.md` по FORMAT.

Создавать при инициализации (пример):

```
{base}/.c9s/
  workflow-status.yaml   # статус фаз BMAD
  sprint-status.yaml     # опционально (спринт), см. scrum-master
  README.txt             # кратко: «.c9s — только операционка; артефакты — requirements/*.md»
```

При первой выдаче требований **создать** каталог `{base}/requirements/`, если его ещё нет.

Интеллектуальная продукция **уровня проекта** (бриф, PRD, исследование, техспека, мозговой штурм, UX и т.д.) — **story** под `{base}/requirements/`. То, что относится **к конкретной задаче**, — в **теле** соответствующего **`issues/{issueSlug}.md`**, без отдельных story-файлов «на задачу».

---

## Статусы воркфлоу (YAML)

Можно использовать упрощённый файл по мотивам `bmad-v6/templates/bmm-workflow-status.template.yaml`, но хранить его в **`.c9s/workflow-status.yaml`**, а не смешивать с Capital markdown сущностями.

---

## Ссылка на helpers v6 (англ.)

Детальные паттерны BMAD v6: `bmad-v6/utils/helpers.md` — для углублённых сценариев на английском.
