---
name: c9s-monorepo-component-git
description: |
  Монорепозиторий кода: только ветки component/ от dev, коммиты только в них.
  По команде — merge в dev и запись в results_commits.yaml (SHA, username, merge_title, дата) в репозитории результатов (.c9s/ проекта, см. GIT-COMMITS-POLICY §2.4), не в монорепо.
  Прямые коммиты в dev и прочие ветки запрещены. Активируй при старте работы над компонентом
  или при «смерджи компонент в dev», «зафиксируй merge для взноса».
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
---

# Git монорепозитория: ветки компонентов и учёт merge (c9s-monorepo-component-git)

## Назначение

**Единственный** скилл, который задаёт **обязательные** правила `git` для **монорепозитория кода** (например Coopenomics `monocoop`).

### Жёсткие правила (без исключений)

1. **Запрещены** коммиты **напрямую в `dev`** и в **любую** ветку, кроме **ветки компонента** по соглашению ниже.
2. **Разрешены** коммиты **только** в ветке вида **`component/<component_slug>-<work_slug>`**, созданной от **актуального `dev`**.
3. **`component_slug`** — имя каталога компонента под `components/` (например `desktop`, `controller`), либо значение **`active_component_git_slug`** из `c9s-config.yaml`.
4. **`work_slug`** — краткий slug от **русского или рабочего названия** задачи/результата (транслит, дефисы, нижний регистр); если одна долгая линия работы на компонент — допустимо **`component/<component_slug>`** без суффикса **только** если так согласовано с пользователем.
5. **Merge в `dev`** — **только** по **явной команде** пользователя в конце работы (не по собственной инициативе агента).
6. После успешного merge — записать в **`results_commits.yaml`** (путь по [GIT-COMMITS-POLICY §2.4](../../../docs/GIT-COMMITS-POLICY.md)) **полный SHA**, **`username`** и **`merge_title`** (первая строка merge-коммита), плюс остальные поля по шаблону. Новая запись — **в начало** `commits`. Затем **commit + push** в **git репозитория результатов** для этого файла. При необходимости обновить **`last_merge_to_dev_commit_hash`** в `c9s-config.yaml`.

Остальные скиллы (developer, bmad-master-c9s и т.д.) **не отменяют** эти правила.

---

## Обязательные ссылки

- [docs/GIT-COMMITS-POLICY.md](../../../docs/GIT-COMMITS-POLICY.md)
- [templates/results_commits.template.yaml](../../../templates/results_commits.template.yaml)
- [config/c9s-config.template.yaml](../../../config/c9s-config.template.yaml) — поля `monorepo_root`, `active_component_git_slug`, `results_commits_log`

---

## Сценарий A: начало работы над компонентом

1. Определить **`monorepo_root`** (корень git монорепозитория) — из `c9s-config.yaml` или путь от пользователя.
2. **`git fetch`**.
3. **`git checkout dev`** → **`git pull`** (или эквивалент обновления `dev`).
4. Согласовать с пользователем **`component_slug`** и краткое **название работы** для **`work_slug`**.
5. **`git checkout -b component/<component_slug>-<work_slug>`** от текущего `dev`.
6. Дальнейшие коммиты **только** в этой ветке (осмысленные сообщения; по желанию команды — на русском).

Если ветка уже существует локально — можно `checkout` и продолжить, не нарушая запрет на коммиты в `dev`.

---

## Сценарий B: промежуточные коммиты

- Выполнять **`git add` / `git commit`** **только** на **ветке компонента**.
- **Не** переключаться на `dev` для коммита правок.

---

## Сценарий C: завершение — merge в `dev` и учёт хэша

Только по команде пользователя («смерджи ветку компонента в dev», «зафиксируй merge для паевого взноса» и т.п.):

1. Убедиться, что нет незакоммиченных изменений (или закоммитить их **в ветке компонента**).
2. **`git checkout dev`** → **`git pull`**.
3. **`git merge`** ветку компонента (предпочтительно **`--no-ff`**, чтобы на `dev` появился **отдельный merge-коммит** — его SHA проще однозначно использовать для взноса; если политика команды — только FF, зафиксировать SHA того коммита, на который указывает `dev` после merge).
4. Получить SHA и заголовок merge: **`git rev-parse HEAD`**; первая строка сообщения коммита — **`git log -1 --format=%s HEAD`** (для поля **`merge_title`** в журнале).
5. **`git push origin dev`** — если пользователь просил отправить (и это разрешено политикой).

### Запись в `results_commits.yaml`

1. Прочитать `c9s-config.yaml`: **`results_root`**, **`active_project_slug`**, **`username`** (для записи в журнале), опционально **`active_component_path`**, **`results_commits_log`**. Если **`username`** пуст — **уточнить у оператора**, не подставлять выдуманное значение.
2. Вычислить **`projectRoot`** = `{results_root}/{active_project_slug}`. Путь к журналу:
   - если задан **`results_commits_log`**: при абсолютном пути — как есть; иначе **`{projectRoot}/{results_commits_log}`**;
   - иначе **`{projectRoot}/.c9s/results_commits.yaml`**.
3. Убедиться, что каталог (например `.c9s/`) существует; если файла нет — создать из [templates/results_commits.template.yaml](../../../templates/results_commits.template.yaml).
4. Добавить **в начало** массива **`commits`** элемент:

```yaml
- status: pending
  username: "<из c9s-config.yaml username>"
  merge_title: "<первая строка merge-коммита: git log -1 --format=%s; при необходимости кратко по-русски по смыслу>"
  component: "<component_slug>"
  merge_commit_hash: "<полный SHA>"
  recorded_at_utc: "<ISO 8601 Z>"
  note: ""
```

- **`status: pending`** — пока оператор не отметит паевой взнос; затем вручную сменить на **`contributed`**.
5. Сохранить YAML (существующие записи не удалять).
6. В **корне git репозитория результатов** (`results_root` — корень клона): `git add` на путь к `results_commits.yaml` → `git commit` (кратко, по-русски: учёт merge компонента в dev) → `git push`, если удалённый репозиторий настроен.

### Опционально: `c9s-config.yaml`

Если есть **`last_merge_to_dev_commit_hash`** — обновить тем же SHA (дубль; канон — `results_commits.yaml`).

---

## Сценарий D: репозиторий результатов

- **Не использовать** этот скилл для `git` в **results_root** — только [c9s-results-push](../c9s-results-push/SKILL.md).

---

## Заметки для LLM

- При любой неоднозначности (имя ветки, FF vs merge commit) — **спросить пользователя**, не нарушая запрет на коммиты в `dev`.
- Не выполнять `git push --force` на общие ветки без явного указания.
- Путь к монорепо может отличаться от `results_root`; не путать каталоги.
