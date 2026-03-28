---
name: bmad-master-c9s
description: |
  Оркестратор BMAD-c9s для Coopenomics: русский язык, репозиторий results, маршрутизация по фазам,
  инициализация .c9s/, запрет хранить итоги только в чате. Активируй при /c9s-status, /c9s-init,
  «статус bmad», «с чего начать coopenomics results», настройке пакета bmad-c9s.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
---

# BMAD Master c9s

**Роль:** точка входа в методологию **bmad-c9s** (адаптация BMAD v6 под Capital/GitHub и русский язык).

**Не делать:** создавать **новый корневой проект Capital** из скилла — корневой проект и репозиторий результатов задаёт пользователь. Скилл **инициализирует только** операционные файлы **`.c9s/`** и помогает с конфигом.

---

## Обязательные ссылки

- [CLAUDE.md](../../../CLAUDE.md) — обзор пакета
- [FORMAT-CAPITAL-GITHUB.md](~/.claude/config/bmad/FORMAT-CAPITAL-GITHUB.md) — канон путей и frontmatter
- [utils/helpers-ru.md](../../../utils/helpers-ru.md) — пути, `updated_at`, hash
- [GIT-COMMITS-POLICY.md](~/.claude/config/bmad/GIT-COMMITS-POLICY.md) — commit/push results и монорепо
- [TASKS-DOCUMENTS-TIME-POLICY.md](~/.claude/config/bmad/TASKS-DOCUMENTS-TIME-POLICY.md) — задачи под документы, `estimate`, `on_review` только по команде оператора
- Эталон v6 (англ., после install): `~/.claude/skills/bmad/core/bmad-master/SKILL.md` (в репозитории пакета: `bmad-v6/skills/core/bmad-master/SKILL.md`)

---

## Жёсткие правила

1. Итоги в **`results_root`** — только файлы `.md` в разрешённых путях (project/issue/story).
2. Продуктовый уровень (бриф, PRD, исследование, техспека, UX) — **story** в **`{base}/requirements/*.md`**. Контекст **конкретной** dev-задачи — **в теле** **`{base}/issues/*.md`** (без подпапок `*-requirements/`). В **`{base}/.c9s/`** — лишь **операционка** (например `workflow-status.yaml`, `sprint-status.yaml`).
3. Обычные роли **не** ставят задаче статус **`done`**. **`on_review`** — **только** по **явной команде оператора** ([c9s-submit-for-review](../c9s-submit-for-review/SKILL.md)); агент **не** переводит в ревью автоматически после своей работы.
4. Каждое изменение канонического файла — **новый `updated_at`** (см. FORMAT).
5. У **story** в **`requirements/*.md`** поле **`title`** — **только русский**, формулировка **чёткая и понятная** (см. [CLAUDE.md](../../../CLAUDE.md), [FORMAT §2.2](~/.claude/config/bmad/FORMAT-CAPITAL-GITHUB.md)).
6. **Репозиторий результатов:** после правок канонических файлов — **`git commit`** и **`git push`** (сообщения на русском), см. [GIT-COMMITS-POLICY.md](~/.claude/config/bmad/GIT-COMMITS-POLICY.md) §1. Скилл [c9s-results-push](../c9s-results-push/SKILL.md) — только для **явной** отдельной команды пользователя.
7. **Монорепозиторий кода:** не нарушать [c9s-monorepo-component-git](../c9s-monorepo-component-git/SKILL.md) — только ветки **`component/…`** от **`dev`**, merge по команде; журнал merge — **`results_commits.yaml` в репозитории результатов** (`.c9s/`), не в монорепо.
8. **Документы (PRD, архитектура, бриф, …):** сначала **`issues/*.md`**, затем **`requirements/*.md`** — [TASKS-DOCUMENTS-TIME-POLICY.md](~/.claude/config/bmad/TASKS-DOCUMENTS-TIME-POLICY.md).
9. **Задачи:** **`estimate: 0`** по умолчанию; в каждой новой **`issues/*.md`** — **`created_by`**, **`submaster`**, **`creators`** = **`username`** из **`c9s-config.yaml`** (без этого учёт времени в Capital не работает); старт — задача + push; **`on_review`** — только по команде оператора + push ([c9s-submit-for-review](../c9s-submit-for-review/SKILL.md)).

---

## /c9s-init (или «инициализируй bmad-c9s»)

1. Прочитать или предложить создать `c9s-config.yaml` из [config/c9s-config.template.yaml](../../../config/c9s-config.template.yaml).
2. Разрешить `base` по [helpers-ru.md](../../../utils/helpers-ru.md#Разрешение-корня-активного-проекта-capital).
3. Создать при отсутствии:
   - `{base}/.c9s/workflow-status.yaml` — из шаблона [templates/bmm-workflow-status.c9s.template.yaml](../../../templates/bmm-workflow-status.c9s.template.yaml) (заполнить метаданные).
   - `{base}/requirements/` — пустой каталог, если ещё нет (сюда пойдут все story: брифы, PRD и т.д.).
   - опционально `{base}/.c9s/README.txt` — одна строка: артефакты bmad-c9s — в `requirements/`, в `.c9s/` только YAML.
4. Кратко сообщить пользователю следующий шаг по фазе (см. таблицу ниже).

**Не создавать** `project.md`, если пользователь явно не просит задокументировать новый корень — это граница Capital.

---

## /c9s-status

1. Загрузить `c9s-config.yaml` и `project.md` (и `component.md`, если есть компонент).
2. Прочитать `.c9s/workflow-status.yaml`, если есть.
3. Вывести: активный `results_root`, slug проекта, фаза, что сделано / что дальше.
4. Рекомендовать **конкретный скилл** (analyst, pm, architect, …).

---

## Маршрутизация по фазам

| Фаза | Скилл | Триггеры |
|------|--------|----------|
| 1 Анализ | `c9s-bmm-analyst` | бриф, исследование, проблема |
| 1 Идеи | `c9s-creative-intelligence` | мозговой штурм, SWOT |
| 2 План | `c9s-bmm-pm` | PRD, tech spec, приоритеты |
| 2 UX | `c9s-bmm-ux-designer` | сценарии, доступность |
| 3 Архитектура | `c9s-bmm-architect` | архитектура, границы сервисов |
| 4 Спринт | `c9s-bmm-scrum-master` | истории, спринт |
| 4 Код | `c9s-bmm-developer` | реализация в монорепе |
| Мета | `c9s-bmb-builder` | новый скилл/шаблон |
| Ревью задач | `c9s-master-review` | только мастер, on_review → done |
| На ревью мастеру | `c9s-submit-for-review` | только по команде оператора → on_review + commit/push |
| Push results (явный) | `c9s-results-push` | опционально; базово — авто commit/push по GIT-COMMITS-POLICY |
| Git монорепо | `c9s-monorepo-component-git` | ветка компонента, merge в dev, хэш в results_commits.yaml (в results, .c9s/) |

---

## Подагенты

Для тяжёлых задач разбивай работу на параллельные подзадачи; продуктовый смысл — в **`requirements/*.md`**; каждая dev-задача — отдельный **`issues/*.md`** с полным телом на один сеанс выполнения. Не в чате и не в `.c9s/` (там только операционка).

---

## Заметки для LLM

- Используй **TodoWrite** для многошаговых сценариев.
- При сомнении в пути — перечитай **FORMAT-CAPITAL-GITHUB.md**.
- Не смешивай канон Capital: **story** уровня проекта — в `requirements/`; **задача** — один файл `issues/*.md` с полным описанием; **операционка BMAD** — в `.c9s/*.yaml`.
