#!/usr/bin/env bash
###############################################################################
# BMAD-c9s (Coopenomics) — установка скиллов и команд для Claude Code
#
# Источник: каталог bmad-c9s/ (русские скиллы, Capital/GitHub results).
# Каталог bmad-v6/ в репозитории не изменяется; при наличии v6 копируется
# helpers.md как опциональный англоязычный справочник (helpers-bmad-v6-en.md).
#
# Usage: ./install-v6.sh
###############################################################################

set -euo pipefail

# Configuration
C9S_VERSION="1.0.0"
CLAUDE_DIR="${HOME}/.claude"
BMAD_CONFIG_DIR="${CLAUDE_DIR}/config/bmad"
BMAD_SKILLS_DIR="${CLAUDE_DIR}/skills/bmad"
BMAD_COMMANDS_DIR="${CLAUDE_DIR}/commands/bmad"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BMAD_C9S_DIR="${SCRIPT_DIR}/bmad-c9s"
BMAD_V6_DIR="${SCRIPT_DIR}/bmad-v6"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo ""
}

###############################################################################
# Installation Functions
###############################################################################

create_directories() {
    log_info "Creating directory structure..."

    mkdir -p "${BMAD_SKILLS_DIR}"/{core,bmm,bmb,cis}
    mkdir -p "${BMAD_COMMANDS_DIR}"
    mkdir -p "${BMAD_CONFIG_DIR}"/{agents,templates}

    log_success "Directories created"
}

install_skills() {
    log_info "Installing BMAD-c9s skills from ${BMAD_C9S_DIR}/skills..."

    if [ ! -d "${BMAD_C9S_DIR}/skills" ]; then
        echo "✗ Directory not found: ${BMAD_C9S_DIR}/skills"
        exit 1
    fi

    if [ -d "${BMAD_C9S_DIR}/skills/core" ]; then
        cp -r "${BMAD_C9S_DIR}/skills/core"/* "${BMAD_SKILLS_DIR}/core/"
        log_success "Core skills (c9s) installed"
    fi

    if [ -d "${BMAD_C9S_DIR}/skills/bmm" ]; then
        cp -r "${BMAD_C9S_DIR}/skills/bmm"/* "${BMAD_SKILLS_DIR}/bmm/" 2>/dev/null || true
        log_success "BMM skills (c9s) installed"
    fi

    if [ -d "${BMAD_C9S_DIR}/skills/bmb" ]; then
        cp -r "${BMAD_C9S_DIR}/skills/bmb"/* "${BMAD_SKILLS_DIR}/bmb/" 2>/dev/null || true
        log_success "BMB skills (c9s) installed"
    fi

    if [ -d "${BMAD_C9S_DIR}/skills/cis" ]; then
        cp -r "${BMAD_C9S_DIR}/skills/cis"/* "${BMAD_SKILLS_DIR}/cis/" 2>/dev/null || true
        log_success "CIS skills (c9s) installed"
    fi
}

install_config() {
    log_info "Installing BMAD-c9s configuration template..."

    if [ -f "${BMAD_C9S_DIR}/config/c9s-config.template.yaml" ]; then
        cp "${BMAD_C9S_DIR}/config/c9s-config.template.yaml" \
           "${BMAD_CONFIG_DIR}/c9s-config.template.yaml"
        log_success "c9s-config.template.yaml installed (copy to your results repo as c9s-config.yaml)"
    else
        echo "⚠ c9s-config.template.yaml not found"
    fi
}

install_templates() {
    log_info "Installing BMAD-c9s templates..."

    if [ -d "${BMAD_C9S_DIR}/templates" ]; then
        cp "${BMAD_C9S_DIR}/templates"/* \
           "${BMAD_CONFIG_DIR}/templates/" 2>/dev/null || true
        log_success "Templates (c9s) installed"
    fi
}

install_docs_and_helpers() {
    log_info "Installing docs and helpers (c9s)..."

    if [ -f "${BMAD_C9S_DIR}/utils/helpers-ru.md" ]; then
        cp "${BMAD_C9S_DIR}/utils/helpers-ru.md" \
           "${BMAD_CONFIG_DIR}/helpers-ru.md"
        log_success "helpers-ru.md installed → ${BMAD_CONFIG_DIR}/helpers-ru.md"
    fi

    if [ -f "${BMAD_C9S_DIR}/docs/FORMAT-CAPITAL-GITHUB.md" ]; then
        cp "${BMAD_C9S_DIR}/docs/FORMAT-CAPITAL-GITHUB.md" \
           "${BMAD_CONFIG_DIR}/FORMAT-CAPITAL-GITHUB.md"
        log_success "FORMAT-CAPITAL-GITHUB.md installed"
    fi

    if [ -f "${BMAD_C9S_DIR}/CLAUDE.md" ]; then
        cp "${BMAD_C9S_DIR}/CLAUDE.md" \
           "${BMAD_CONFIG_DIR}/CLAUDE-bmad-c9s.md"
        log_success "CLAUDE-bmad-c9s.md installed (обзор пакета)"
    fi

    # Опционально: англ. helpers из неизменяемого bmad-v6 (справка)
    if [ -f "${BMAD_V6_DIR}/utils/helpers.md" ]; then
        cp "${BMAD_V6_DIR}/utils/helpers.md" \
           "${BMAD_CONFIG_DIR}/helpers-bmad-v6-en.md"
        log_success "helpers-bmad-v6-en.md (справка BMAD v6, EN) установлен"
    else
        log_info "bmad-v6/utils/helpers.md не найден — пропуск англ. справки"
    fi
}

install_commands() {
    log_info "Installing slash commands (c9s)..."

    if [ -d "${BMAD_C9S_DIR}/commands" ]; then
        local command_count
        command_count=$(find "${BMAD_C9S_DIR}/commands" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

        if [ "${command_count}" -gt 0 ]; then
            cp "${BMAD_C9S_DIR}/commands"/*.md \
               "${BMAD_COMMANDS_DIR}/" 2>/dev/null || true
            log_success "Slash commands installed (${command_count} files)"
        else
            echo "⚠ No command files found in bmad-c9s/commands"
        fi
    else
        echo "⚠ Commands directory not found: ${BMAD_C9S_DIR}/commands"
    fi
}

verify_installation() {
    log_info "Verifying installation..."

    local errors=0

    if [ -f "${BMAD_SKILLS_DIR}/core/bmad-master-c9s/SKILL.md" ]; then
        log_success "bmad-master-c9s skill verified"
    else
        echo "✗ bmad-master-c9s skill missing"
        errors=$((errors + 1))
    fi

    if [ -f "${BMAD_CONFIG_DIR}/c9s-config.template.yaml" ]; then
        log_success "c9s config template verified"
    else
        echo "✗ c9s-config.template.yaml missing"
        errors=$((errors + 1))
    fi

    if [ -f "${BMAD_CONFIG_DIR}/helpers-ru.md" ]; then
        log_success "helpers-ru.md verified"
    else
        echo "✗ helpers-ru.md missing"
        errors=$((errors + 1))
    fi

    if [ -f "${BMAD_COMMANDS_DIR}/c9s-init.md" ]; then
        log_success "Slash commands (c9s-init) verified"
    else
        echo "✗ c9s-init.md missing"
        errors=$((errors + 1))
    fi

    if [ $errors -eq 0 ]; then
        log_success "Installation verified successfully"
        return 0
    else
        echo "✗ Installation verification failed: $errors error(s)"
        return 1
    fi
}

print_next_steps() {
    log_header "Установка завершена"

    cat << EOF
📦 BMAD-c9s v${C9S_VERSION} (Coopenomics) установлен.

Каталоги:
  Скиллы:   ${BMAD_SKILLS_DIR}
  Команды:  ${BMAD_COMMANDS_DIR}
  Конфиг:   ${BMAD_CONFIG_DIR}

Что установлено:
  • Скиллы из bmad-c9s/ (оркестратор bmad-master-c9s, роли BMM, CIS, builder, c9s-master-review)
  • Команды из bmad-c9s/commands/ (/c9s-init, /c9s-status, /prd, …)
  • Шаблон c9s-config.template.yaml, helpers-ru.md, FORMAT-CAPITAL-GITHUB.md, CLAUDE-bmad-c9s.md
  • При наличии репозитория: helpers-bmad-v6-en.md (оригинал BMAD v6, только справка)

Исходники v6 (bmad-v6/) в репозитории не изменяются и не копируются как основные скиллы.

📋 Дальше:

1️⃣  ${BLUE}Перезапустите Claude Code${NC}

2️⃣  ${BLUE}Скопируйте${NC} ${BMAD_CONFIG_DIR}/c9s-config.template.yaml
    в корень репозитория результатов как c9s-config.yaml и заполните пути.

3️⃣  ${BLUE}Инициализация:${NC} /c9s-init (скилл bmad-master-c9s)

4️⃣  ${BLUE}Статус:${NC} /c9s-status

📚 Документация после установки:
   ${BMAD_CONFIG_DIR}/CLAUDE-bmad-c9s.md
   ${BMAD_CONFIG_DIR}/FORMAT-CAPITAL-GITHUB.md
   ${BMAD_CONFIG_DIR}/helpers-ru.md

📚 Исходники пакета в репозитории:
   ${BMAD_C9S_DIR}/

Проверка:
   ls -la ~/.claude/skills/bmad/core/bmad-master-c9s/SKILL.md
   ls -la ~/.claude/commands/bmad/c9s-init.md

${GREEN}✓ BMAD-c9s готов.${NC}
EOF
}

###############################################################################
# Main Installation
###############################################################################

main() {
    log_header "BMAD-c9s v${C9S_VERSION} — установщик"

    if [ ! -d "${BMAD_C9S_DIR}" ]; then
        echo "✗ Каталог bmad-c9s не найден: ${BMAD_C9S_DIR}"
        echo "  Запускайте скрипт из корня репозитория claude-code-bmad-skills."
        exit 1
    fi

    if [ ! -d "${CLAUDE_DIR}" ]; then
        log_info "Creating Claude Code directory: ${CLAUDE_DIR}"
        mkdir -p "${CLAUDE_DIR}"
    fi

    create_directories
    install_skills
    install_config
    install_templates
    install_docs_and_helpers
    install_commands

    if verify_installation; then
        print_next_steps
        exit 0
    else
        echo "Installation failed"
        exit 1
    fi
}

main "$@"
