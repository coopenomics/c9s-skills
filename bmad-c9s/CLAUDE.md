# BMAD-c9s (Coopenomics) — руководство для проекта

Пакет **bmad-c9s** — адаптация идей **BMAD v6** под:

- **русский язык** общения и артефактов (по желанию команды — см. `default_language` в конфиге);
- **репозиторий результатов Capital**, синхронизируемый с БД через GitHub (`project` / `issue` / `story` в канонических путях);
- **разделение канона Capital и операционки BMAD**: в **`{base}/.c9s/`** — только статусы воркфлоу и служебные YAML; **вся** продуктовая проза (бриф, PRD, исследования, техспека, UX) — как **требования (story)** в **`{base}/requirements/*.md`** (см. FORMAT).

Источник методологии v6 (англ.): каталог `bmad-v6/` в этом репозитории — **не править** как эталон; для c9s используйте скиллы из `bmad-c9s/skills/`.

---

## Как подключать скиллы (Cursor / Claude Code)

Копируйте или симлинкуйте нужные `SKILL.md` в каталог скиллов редактора (см. документацию Cursor Skills). Минимальный набор:

| Скилл | Когда включать |
|--------|----------------|
| `bmad-master-c9s` | Старт сессии, маршрутизация по фазам, инициализация `.c9s/` |
| `c9s-master-review` | Только роль «мастер»: перевод задачи `on_review` → `done` |
| `c9s-submit-for-review` | **Только по команде оператора:** задача → `on_review` + commit/push в results |
| `c9s-results-push` | **Опционально:** явный commit/push; **базово** — автофиксация по [GIT-COMMITS-POLICY](docs/GIT-COMMITS-POLICY.md) |
| `c9s-monorepo-component-git` | Монорепо: ветки `component/…` от `dev`, merge в `dev` по команде; хэш в `results_commits.yaml` **в results** (`.c9s/`, см. GIT-COMMITS-POLICY §2.4) |
| Роли BMM / CIS / builder | По фазе задачи (см. таблицу ниже) |

Полные пути:

- `bmad-c9s/skills/core/bmad-master-c9s/SKILL.md`
- `bmad-c9s/skills/core/c9s-master-review/SKILL.md`
- `bmad-c9s/skills/core/c9s-submit-for-review/SKILL.md`
- `bmad-c9s/skills/core/c9s-results-push/SKILL.md`
- `bmad-c9s/skills/core/c9s-monorepo-component-git/SKILL.md`
- `bmad-c9s/skills/bmm/*/SKILL.md`
- `bmad-c9s/skills/cis/creative-intelligence/SKILL.md`
- `bmad-c9s/skills/bmb/builder/SKILL.md`

---

## Жёсткое правило: хранилище — файлы, не чат

1. **Канон Capital** (проект, компонент, задача, требование) — только **`.md`** под `results_root`, пути из [docs/FORMAT-CAPITAL-GITHUB.md](docs/FORMAT-CAPITAL-GITHUB.md).
2. **Бриф, PRD, исследование, техспека, мозговой штурм, UX на уровне продукта** — **story** в **`{base}/requirements/{slug}.md`** (`type: story`, `content_format`, `status`). Агент **ведёт** эти файлы при проработке сверху вниз.
3. **Задача** (`issues/{slug}.md`) — отдельная **dev-единица** после планирования: в **теле** файла весь контекст для **одного** сеанса выполнения (вводный промпт, краткое исследование, критерии, ссылки на `requirements/*.md` при необходимости). Подпапок `issues/…-requirements/` и отдельных story «на задачу» **нет**.
4. **`{base}/.c9s/`** — **не** для содержательных документов: только `workflow-status.yaml`, при необходимости `sprint-status.yaml` и т.п.
5. Длинные списки **не** оставлять только в чате — в **`requirements/`** или в **теле** нужного **`issues/*.md`**.
6. **Наименование требований (`requirements/*.md`) — обязательно:** поле **`title`** в frontmatter задаётся **только на русском языке**. Заголовок должен быть **чётким и понятным** (по нему сразу ясно, о чём документ). Не использовать английский как «замену смысла»: вместо голых `PRD`, `Tech spec`, `UX doc` — русские формулировки («Описание требований к …», «Техническое задание на …», «Сценарии и макеты …» и т.п.). Техническое имя файла (`storySlug`) — транслит от русского заголовка по правилам Capital (см. FORMAT).
7. **Документы и крупные шаги — только через задачи (`issues/*.md`), строго:** PRD, техспека, архитектурный документ, бриф, исследование, пакет UX и любой аналогичный шаг **не начинать** без создания **задачи** в момент старта работы; содержание — в **`requirements/*.md`** (story), процесс и критерии — в теле задачи. Подробно: [docs/TASKS-DOCUMENTS-TIME-POLICY.md](docs/TASKS-DOCUMENTS-TIME-POLICY.md).
8. **Учёт времени и `estimate`:** в задачах **`estimate: 0`**, если пользователь **явно** не указал иное. Задачу создаём и **пушим** при начале работы; в frontmatter новой задачи — **`created_by`**, **`submaster`**, **`creators`** по [TASKS-DOCUMENTS-TIME-POLICY.md](docs/TASKS-DOCUMENTS-TIME-POLICY.md) §1. Перевод в **`on_review`** — **только** по **явной команде оператора** (скилл **`c9s-submit-for-review`** или прямой запрос); агент **не** ставит **`on_review`** автоматически после своей работы. Тогда — **`updated_at`** + commit/push. Система считает фактическое время до **`on_review`**. Подробно: тот же документ §1–2.
9. **Git — репозиторий результатов:** после значимых правок агент **сам** делает **commit** и **push** (сообщения на русском). Скилл **`c9s-results-push`** — для явных отдельных операций; см. [docs/GIT-COMMITS-POLICY.md](docs/GIT-COMMITS-POLICY.md).
10. **Git — монорепозиторий кода:** без изменений — только скилл **`c9s-monorepo-component-git`**.

---

## Конфигурация

1. Скопируйте [config/c9s-config.template.yaml](config/c9s-config.template.yaml) в корень **активного** репозитория результатов как `c9s-config.yaml` (или задайте путь в глобальном конфиге редактора).
2. Ключевые поля: `results_root`, `active_project_slug` (slug корневого проекта = имя папки под `results_root`), `coopname`, `username`.
3. **Прод vs тест**: смените `results_root` на каталог с `results-test` или продовым `results`.

Подробности разрешения путей и обновления `updated_at`: [utils/helpers-ru.md](utils/helpers-ru.md).

---

## Фазы и роли (кратко)

| Фаза | Роли (скиллы) | Куда писать |
|------|----------------|-------------|
| 1 Анализ | analyst, creative-intelligence | Сначала **`issues/*.md`** на шаг, затем **`requirements/*.md`** (story); см. [TASKS-DOCUMENTS-TIME-POLICY](docs/TASKS-DOCUMENTS-TIME-POLICY.md); при необходимости — **`project.md`** / **`component.md`** + `updated_at` |
| 2 Планирование | pm, ux-designer | **`requirements/*.md`** + задачи **`issues/*.md`** на каждый оформляемый шаг (PRD, техспека, …) |
| 3 Архитектура | architect | Задача **`issues/*.md`**, затем **`requirements/*.md`** (story / диаграммы) |
| 4 Реализация | scrum-master, developer | **`issues/*.md`** (всё для задачи в теле файла), код в **монорепе**, не в results |
| Операционка | bmad-master-c9s, sm | **`.c9s/*.yaml`** (фазы, спринт), не смешивать с story |

---

## Статусы задач и роль мастера

- Обычные роли **не ставят** статус задачи **`done`**.
- **`on_review`** — **не** автоматически после работы агента: только когда **оператор** явно командует передать задачу мастеру (**`c9s-submit-for-review`** / «отправь на ревью»). До этого задача остаётся в **`in_progress`** (или **`todo`**).
- Скилл **`c9s-master-review`** может перевести **`on_review` → `done`** (и при необходимости откатить в `in_progress`).

Подробности и ограничения Capital при импорте: [docs/FORMAT-CAPITAL-GITHUB.md](docs/FORMAT-CAPITAL-GITHUB.md).

---

## Команды-обёртки

Каталог [commands/](commands/) — короткие сценарии на русском; полная логика в соответствующих скиллах и в `bmad-v6/commands/` (англ.) при необходимости детализации.

---

## Git (результаты и код)

- Коммиты/push, задачи и время: [docs/GIT-COMMITS-POLICY.md](docs/GIT-COMMITS-POLICY.md), [docs/TASKS-DOCUMENTS-TIME-POLICY.md](docs/TASKS-DOCUMENTS-TIME-POLICY.md)
- Журнал merge → `dev` для взносов (ручной учёт для кооператива): шаблон [templates/results_commits.template.yaml](templates/results_commits.template.yaml) → **`results_commits.yaml` в репозитории результатов** (по умолчанию **`.c9s/results_commits.yaml`** у активного проекта или путь **`results_commits_log`** в `c9s-config.yaml`); **не** в монорепозитории кода — см. [docs/GIT-COMMITS-POLICY.md](docs/GIT-COMMITS-POLICY.md) §2.4

## Ссылки на код монорепозитория (Coopenomics)

- Форматы файлов: `monocoop/components/controller/.../file-format.service.ts`
- Синхронизация GitHub: `github-sync.service.ts`
- Подготовка markdown (content_format, issue): план `capital-md-sync-bmad-prep` в `.cursor/plans/`
