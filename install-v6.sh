#!/usr/bin/env bash
###############################################################################
# BMAD v6 + BMAD-c9s (Coopenomics) — установка для Claude Code
#
# • BMAD v6 (оригинал): скиллы → ~/.claude/skills/bmad/, config.yaml, шаблоны v6,
#   зеркало команд/шаблонов → ~/.claude/config/bmad/bmad-v6-bundle/
# • BMAD-c9s: скиллы → ~/.claude/skills/bmad-c9s/; slash-команды → ~/.claude/commands/bmad/;
#   ~/.claude/config/bmad/templates/: сначала v6, затем файлы c9s с перезаписью (одно имя = правила c9s).
#   Хелперы: основной helpers.md = helpers-ru (c9s); v6 EN только helpers-bmad-v6-en.md (справка по методологии).
#
# Usage: ./install-v6.sh
###############################################################################

set -euo pipefail

C9S_VERSION="1.1.0"
CLAUDE_DIR="${HOME}/.claude"
BMAD_CONFIG_DIR="${CLAUDE_DIR}/config/bmad"
BMAD_V6_BUNDLE_DIR="${BMAD_CONFIG_DIR}/bmad-v6-bundle"
BMAD_SKILLS_V6_DIR="${CLAUDE_DIR}/skills/bmad"
BMAD_SKILLS_C9S_DIR="${CLAUDE_DIR}/skills/bmad-c9s"
BMAD_COMMANDS_DIR="${CLAUDE_DIR}/commands/bmad"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BMAD_C9S_DIR="${SCRIPT_DIR}/bmad-c9s"
BMAD_V6_DIR="${SCRIPT_DIR}/bmad-v6"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo ""
}

create_directories() {
    log_info "Создание каталогов..."
    mkdir -p "${BMAD_SKILLS_V6_DIR}"/{core,bmm,bmb,cis}
    mkdir -p "${BMAD_SKILLS_C9S_DIR}"/{core,bmm,bmb,cis}
    mkdir -p "${BMAD_COMMANDS_DIR}"
    mkdir -p "${BMAD_CONFIG_DIR}"/{agents,templates}
    mkdir -p "${BMAD_V6_BUNDLE_DIR}"/{commands,templates,utils}
    log_success "Каталоги созданы"
}

install_v6_skills() {
    log_info "Скиллы BMAD v6 → ${BMAD_SKILLS_V6_DIR}..."
    if [ ! -d "${BMAD_V6_DIR}/skills" ]; then
        echo "✗ Нет каталога ${BMAD_V6_DIR}/skills"
        exit 1
    fi
    for sub in core bmm bmb cis; do
        if [ -d "${BMAD_V6_DIR}/skills/${sub}" ]; then
            cp -r "${BMAD_V6_DIR}/skills/${sub}"/* "${BMAD_SKILLS_V6_DIR}/${sub}/" 2>/dev/null || true
        fi
    done
    log_success "Скиллы v6 установлены (bmad-master, BMM, …)"
}

install_c9s_skills() {
    log_info "Скиллы BMAD-c9s → ${BMAD_SKILLS_C9S_DIR}..."
    if [ ! -d "${BMAD_C9S_DIR}/skills" ]; then
        echo "✗ Нет ${BMAD_C9S_DIR}/skills"
        exit 1
    fi
    for sub in core bmm bmb cis; do
        if [ -d "${BMAD_C9S_DIR}/skills/${sub}" ]; then
            cp -r "${BMAD_C9S_DIR}/skills/${sub}"/* "${BMAD_SKILLS_C9S_DIR}/${sub}/" 2>/dev/null || true
        fi
    done
    log_success "Скиллы c9s установлены (bmad-master-c9s, …)"
}

install_v6_bundle() {
    log_info "Зеркало v6 (команды, шаблоны, utils) → ${BMAD_V6_BUNDLE_DIR}..."
    if [ -d "${BMAD_V6_DIR}/commands" ]; then
        cp "${BMAD_V6_DIR}/commands"/*.md "${BMAD_V6_BUNDLE_DIR}/commands/" 2>/dev/null || true
    fi
    if [ -d "${BMAD_V6_DIR}/templates" ]; then
        cp "${BMAD_V6_DIR}/templates"/* "${BMAD_V6_BUNDLE_DIR}/templates/" 2>/dev/null || true
    fi
    if [ -f "${BMAD_V6_DIR}/utils/helpers.md" ]; then
        cp "${BMAD_V6_DIR}/utils/helpers.md" "${BMAD_V6_BUNDLE_DIR}/utils/helpers.md"
    fi
    log_success "bmad-v6-bundle обновлён"
}

install_v6_config() {
    log_info "Глобальный config BMAD v6 (config.yaml)..."
    if [ -f "${BMAD_V6_DIR}/config/config.template.yaml" ]; then
        if [ ! -f "${BMAD_CONFIG_DIR}/config.yaml" ]; then
            sed "s/{{USER_NAME}}/${USER}/g" \
                "${BMAD_V6_DIR}/config/config.template.yaml" \
                > "${BMAD_CONFIG_DIR}/config.yaml"
            log_success "config.yaml создан"
        else
            log_info "config.yaml уже есть — не перезаписываем"
        fi
    fi
    if [ -f "${BMAD_V6_DIR}/config/project-config.template.yaml" ]; then
        cp "${BMAD_V6_DIR}/config/project-config.template.yaml" \
           "${BMAD_CONFIG_DIR}/project-config.template.yaml"
    fi
}

install_c9s_config_template() {
    log_info "Шаблон c9s-config..."
    if [ -f "${BMAD_C9S_DIR}/config/c9s-config.template.yaml" ]; then
        cp "${BMAD_C9S_DIR}/config/c9s-config.template.yaml" \
           "${BMAD_CONFIG_DIR}/c9s-config.template.yaml"
        log_success "c9s-config.template.yaml"
    fi
}

install_templates() {
    log_info "Шаблоны в config/bmad/templates/: база v6, затем c9s перезаписывает одноимённые файлы..."
    if [ -d "${BMAD_V6_DIR}/templates" ]; then
        cp "${BMAD_V6_DIR}/templates"/* "${BMAD_CONFIG_DIR}/templates/" 2>/dev/null || true
    fi
    if [ -d "${BMAD_C9S_DIR}/templates" ]; then
        cp -f "${BMAD_C9S_DIR}/templates"/* "${BMAD_CONFIG_DIR}/templates/" 2>/dev/null || true
    fi
    log_success "templates/ — приоритет у c9s при совпадении имён; чисто v6 остаётся только в bmad-v6-bundle/templates/"
}

install_helpers_and_docs() {
    log_info "helpers: основной текст — c9s; v6 EN — отдельный файл для методологии..."
    if [ -f "${BMAD_V6_DIR}/utils/helpers.md" ]; then
        cp "${BMAD_V6_DIR}/utils/helpers.md" "${BMAD_CONFIG_DIR}/helpers-bmad-v6-en.md"
        log_success "helpers-bmad-v6-en.md (справка BMAD v6, не рабочие правила)"
    fi
    if [ -f "${BMAD_C9S_DIR}/utils/helpers-ru.md" ]; then
        cp "${BMAD_C9S_DIR}/utils/helpers-ru.md" "${BMAD_CONFIG_DIR}/helpers-ru.md"
        cp -f "${BMAD_C9S_DIR}/utils/helpers-ru.md" "${BMAD_CONFIG_DIR}/helpers.md"
        log_success "helpers.md и helpers-ru.md — правила c9s"
    fi
    if [ -f "${BMAD_C9S_DIR}/docs/FORMAT-CAPITAL-GITHUB.md" ]; then
        cp "${BMAD_C9S_DIR}/docs/FORMAT-CAPITAL-GITHUB.md" "${BMAD_CONFIG_DIR}/FORMAT-CAPITAL-GITHUB.md"
    fi
    for _c9s_doc in TASKS-DOCUMENTS-TIME-POLICY.md GIT-COMMITS-POLICY.md; do
        if [ -f "${BMAD_C9S_DIR}/docs/${_c9s_doc}" ]; then
            cp "${BMAD_C9S_DIR}/docs/${_c9s_doc}" "${BMAD_CONFIG_DIR}/${_c9s_doc}"
        fi
    done
    if [ -f "${BMAD_C9S_DIR}/CLAUDE.md" ]; then
        cp "${BMAD_C9S_DIR}/CLAUDE.md" "${BMAD_CONFIG_DIR}/CLAUDE-bmad-c9s.md"
        log_success "CLAUDE-bmad-c9s.md"
    fi
}

install_commands_c9s() {
    log_info "Slash-команды (обёртки c9s) → ${BMAD_COMMANDS_DIR}..."
    if [ -d "${BMAD_C9S_DIR}/commands" ]; then
        local n
        n=$(find "${BMAD_C9S_DIR}/commands" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
        if [ "${n}" -gt 0 ]; then
            cp "${BMAD_C9S_DIR}/commands"/*.md "${BMAD_COMMANDS_DIR}/" 2>/dev/null || true
            log_success "Команд: ${n}"
        fi
    fi
}

verify_installation() {
    log_info "Проверка..."
    local errors=0
    if [ ! -f "${BMAD_SKILLS_V6_DIR}/core/bmad-master/SKILL.md" ]; then
        echo "✗ v6: bmad-master отсутствует"
        errors=$((errors + 1))
    else
        log_success "v6 bmad-master"
    fi
    if [ ! -f "${BMAD_SKILLS_C9S_DIR}/core/bmad-master-c9s/SKILL.md" ]; then
        echo "✗ c9s: bmad-master-c9s отсутствует"
        errors=$((errors + 1))
    else
        log_success "c9s bmad-master-c9s"
    fi
    if [ ! -f "${BMAD_V6_BUNDLE_DIR}/commands/create-story.md" ]; then
        echo "✗ bmad-v6-bundle/commands/create-story.md"
        errors=$((errors + 1))
    else
        log_success "bmad-v6-bundle (команды)"
    fi
    if [ ! -f "${BMAD_CONFIG_DIR}/c9s-config.template.yaml" ]; then
        echo "✗ c9s-config.template.yaml"
        errors=$((errors + 1))
    fi
    if [ ! -f "${BMAD_COMMANDS_DIR}/c9s-init.md" ]; then
        echo "✗ c9s-init.md"
        errors=$((errors + 1))
    fi
    if [ $errors -eq 0 ]; then
        log_success "Проверка пройдена"
        return 0
    fi
    echo "✗ Ошибок: ${errors}"
    return 1
}

print_next_steps() {
    log_header "Установка завершена"

    cat << EOF
📦 BMAD v6 + BMAD-c9s v${C9S_VERSION}

Скиллы (два пространства имён):
  v6 (оригинал):   ${BMAD_SKILLS_V6_DIR}
  c9s (Coopenomics): ${BMAD_SKILLS_C9S_DIR}

Команды в UI: обёртки c9s → ${BMAD_COMMANDS_DIR}
Канон v6 для «Детали» в обёртках → ${BMAD_V6_BUNDLE_DIR}/commands/
Конфиг: ${BMAD_CONFIG_DIR}/config.yaml (v6) + c9s-config.template.yaml + templates/ (одно имя файла — версия c9s) + helpers.md (= правила c9s, см. helpers-ru)

Приоритет: артефакты и хелперы — c9s; методология (пошаговые команды v6, EN-хелпер) — bmad-v6-bundle/ и helpers-bmad-v6-en.md; обзор c9s — [CLAUDE-bmad-c9s.md](${BMAD_CONFIG_DIR}/CLAUDE-bmad-c9s.md).

Дальше:
  1. Перезапустите Claude Code
  2. Для Capital: скопируйте c9s-config.template.yaml в репозиторий результатов как c9s-config.yaml
  3. /c9s-init — инициализация c9s (скилл из bmad-c9s)
  4. Оригинальный оркестратор v6: скилл bmad-master в skills/bmad

Проверка:
  ls ${BMAD_SKILLS_V6_DIR}/core/bmad-master/SKILL.md
  ls ${BMAD_SKILLS_C9S_DIR}/core/bmad-master-c9s/SKILL.md
  ls ${BMAD_V6_BUNDLE_DIR}/commands/prd.md

${GREEN}✓ Готово.${NC}
EOF
}

main() {
    log_header "BMAD v6 + BMAD-c9s — установщик"

    if [ ! -d "${BMAD_C9S_DIR}" ]; then
        echo "✗ Нет ${BMAD_C9S_DIR}"
        exit 1
    fi
    if [ ! -d "${BMAD_V6_DIR}/skills" ]; then
        echo "✗ Нет ${BMAD_V6_DIR}/skills (нужен полный репозиторий claude-code-bmad-skills)"
        exit 1
    fi

    if [ ! -d "${CLAUDE_DIR}" ]; then
        mkdir -p "${CLAUDE_DIR}"
    fi

    create_directories
    install_v6_skills
    install_c9s_skills
    install_v6_bundle
    install_v6_config
    install_c9s_config_template
    install_templates
    install_helpers_and_docs
    install_commands_c9s

    if verify_installation; then
        print_next_steps
        exit 0
    fi
    exit 1
}

main "$@"
