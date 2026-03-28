###############################################################################
# BMAD v6 + BMAD-c9s (Coopenomics) — PowerShell installer
#
# Соответствует install-v6.sh: v6 → skills/bmad, c9s → skills/bmad-c9s,
# bmad-v6-bundle в config/bmad, команды c9s → commands/bmad.
#
# Supports: PowerShell 5.1+ (Windows default) and PowerShell 6+ (Core)
#
# Usage:
#   .\install-v6.ps1              # Standard installation
#   .\install-v6.ps1 -Verbose     # Detailed diagnostic output
#   .\install-v6.ps1 -WhatIf      # Dry-run (show what would be installed)
#   .\install-v6.ps1 -Force       # Force reinstall over existing
#   .\install-v6.ps1 -Uninstall   # Remove BMAD-c9s from ~/.claude/.../bmad
###############################################################################

<#
.SYNOPSIS
    Installs BMAD-c9s (Coopenomics) for Claude Code.

.DESCRIPTION
    Installs skills and slash commands from bmad-c9s/ into the Claude Code
    directory (~/.claude/). It includes:
    - Core orchestration (bmad-master-c9s, c9s-master-review)
    - BMM role skills (analyst, pm, architect, scrum-master, developer, ux-designer)
    - BMB builder skill
    - CIS creative-intelligence skill
    - Configuration templates
    - Utility helpers

    The installer is compatible with PowerShell 5.1 (Windows default) and
    PowerShell 6+ (Core) on Windows, Linux, and macOS.

.PARAMETER Help
    Display this help information.

.PARAMETER Verbose
    Display detailed diagnostic information during installation.

.PARAMETER WhatIf
    Show what would be installed without actually installing (dry-run).

.PARAMETER Force
    Force reinstallation even if BMAD-c9s is already installed.

.PARAMETER Uninstall
    Remove BMAD-c9s installation from ~/.claude/skills/bmad, commands/bmad, config/bmad.

.EXAMPLE
    .\install-v6.ps1

    Installs BMAD-c9s with standard output.

.EXAMPLE
    .\install-v6.ps1 -Verbose

    Installs BMAD-c9s with detailed diagnostic output.

.EXAMPLE
    .\install-v6.ps1 -WhatIf

    Shows what would be installed without actually installing.

.EXAMPLE
    .\install-v6.ps1 -Uninstall

    Removes BMAD-c9s from ~/.claude/.../bmad.

.NOTES
    Version: 1.0.0 (BMAD-c9s)
    Requires: PowerShell 5.1+
    Updated: 2025-03-27
    Changes: Fixed PowerShell function scoping issues for WSL compatibility by making all
             functions globally scoped. This resolves "Write-Success is not recognized" errors
             when running in WSL PowerShell environments.
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [switch]$Help = $false,
    [switch]$Force = $false,
    [switch]$Uninstall = $false
)

# Exit on any error
$ErrorActionPreference = "Stop"

###############################################################################
# Configuration
###############################################################################

$BmadVersion = "1.1.0"

# PowerShell version detection
$PSVersion = $PSVersionTable.PSVersion.Major
$IsPowerShell5 = $PSVersion -lt 6

###############################################################################
# Helper Functions
###############################################################################

function global:Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function global:Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function global:Write-ErrorMsg {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function global:Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Blue
    Write-Host "  $Message" -ForegroundColor Blue
    Write-Host "===============================================" -ForegroundColor Blue
    Write-Host ""
}

function global:Join-PathCompat {
    <#
    .SYNOPSIS
    Join-Path that works in both PowerShell 5.1 and PowerShell 6+

    .DESCRIPTION
    PowerShell 5.1 only accepts 2 arguments to Join-Path
    PowerShell 6+ accepts multiple path segments
    This function provides compatibility for both
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
        [string[]]$ChildPath
    )

    # Validate inputs
    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw "Path parameter cannot be null or empty"
    }

    if ($IsPowerShell5) {
        # PowerShell 5.1: Chain Join-Path calls
        $result = $Path
        foreach ($segment in $ChildPath) {
            if (-not [string]::IsNullOrWhiteSpace($segment)) {
                $result = Join-Path $result $segment
            }
        }
        return $result
    } else {
        # PowerShell 6+: Use native multiple-argument support
        # Filter out null/empty segments
        $validSegments = $ChildPath | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        return Join-Path $Path $validSegments
    }
}

function global:Copy-ItemSafe {
    <#
    .SYNOPSIS
    Safely copy items ensuring destination directory exists

    .DESCRIPTION
    Wraps Copy-Item with proper error handling and destination directory creation
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$SourcePath,

        [Parameter(Mandatory=$true)]
        [string]$DestinationPath,

        [switch]$Recurse,
        [switch]$Force,
        [string]$ErrorContext = "file operation"
    )

    try {
        # Ensure destination parent directory exists
        $destParent = Split-Path $DestinationPath -Parent
        if ($destParent -and -not (Test-Path $destParent)) {
            Write-Verbose "Creating destination directory: $destParent"
            New-Item -ItemType Directory -Force -Path $destParent -ErrorAction Stop | Out-Null
        }

        # Ensure destination directory exists if copying with wildcard
        if ($SourcePath -match '\*' -and -not (Test-Path $DestinationPath)) {
            Write-Verbose "Creating destination directory: $DestinationPath"
            New-Item -ItemType Directory -Force -Path $DestinationPath -ErrorAction Stop | Out-Null
        }

        # Perform copy
        $copyParams = @{
            Path = $SourcePath
            Destination = $DestinationPath
            Force = $Force
            ErrorAction = 'Stop'
        }

        if ($Recurse) {
            $copyParams['Recurse'] = $true
        }

        Copy-Item @copyParams
        Write-Verbose "Copied: $SourcePath -> $DestinationPath"
    }
    catch {
        Write-ErrorMsg "Failed during $ErrorContext"
        Write-ErrorMsg "  Source: $SourcePath"
        Write-ErrorMsg "  Destination: $DestinationPath"
        Write-ErrorMsg "  Reason: $($_.Exception.Message)"
        throw
    }
}

###############################################################################
# Directory Configuration
###############################################################################

# Cross-platform home directory detection
if ($IsWindows -or $env:OS -match "Windows" -or (-not (Test-Path variable:IsWindows))) {
    # Windows (PowerShell 5.1 or PowerShell 7+ on Windows)
    $HomeDir = $env:USERPROFILE
} else {
    # Linux/macOS (PowerShell Core)
    $HomeDir = $env:HOME
}

$ClaudeDir = Join-Path $HomeDir ".claude"
$BmadConfigDir = Join-PathCompat $ClaudeDir "config" "bmad"
$BmadV6BundleDir = Join-PathCompat $BmadConfigDir "bmad-v6-bundle"
$BmadSkillsDir = Join-PathCompat $ClaudeDir "skills" "bmad"
$BmadC9sSkillsDir = Join-PathCompat $ClaudeDir "skills" "bmad-c9s"
$BmadCommandsDir = Join-PathCompat $ClaudeDir "commands" "bmad"
$ScriptDir = $PSScriptRoot

# Source directories
$SourceBmadC9sDir = Join-Path $ScriptDir "bmad-c9s"
$SourceBmadV6Dir = Join-Path $ScriptDir "bmad-v6"
$SourceV6SkillsDir = Join-PathCompat $SourceBmadV6Dir "skills"
$SourceSkillsDir = Join-PathCompat $SourceBmadC9sDir "skills"
$SourceConfigDir = Join-PathCompat $SourceBmadC9sDir "config"
$SourceTemplatesDir = Join-PathCompat $SourceBmadC9sDir "templates"
$SourceUtilsDir = Join-PathCompat $SourceBmadC9sDir "utils"
$SourceCommandsDir = Join-PathCompat $SourceBmadC9sDir "commands"
$SourceC9sDocsDir = Join-PathCompat $SourceBmadC9sDir "docs"

###############################################################################
# Pre-Flight Validation
###############################################################################

function global:Test-Prerequisites {
    Write-Info "Running pre-flight checks..."
    $errors = @()

    # Check PowerShell version
    if ($PSVersion -eq 5 -and $PSVersionTable.PSVersion.Minor -eq 0) {
        Write-Warning "PowerShell 5.0 detected. PowerShell 5.1 or newer recommended."
        Write-Host "  Download: https://aka.ms/wmf5download" -ForegroundColor Yellow
    }

    Write-Verbose "PowerShell version: $($PSVersionTable.PSVersion)"
    if ($IsPowerShell5) {
        Write-Verbose "Running in compatibility mode (PowerShell 5.1)"
    } else {
        Write-Verbose "Running in native mode (PowerShell $PSVersion)"
    }

    # Check if script directory is valid
    if ([string]::IsNullOrWhiteSpace($ScriptDir)) {
        $errors += "Cannot determine script directory (PSScriptRoot is empty)"
    } elseif (-not (Test-Path $ScriptDir)) {
        $errors += "Script directory not found: $ScriptDir"
    }

    # Check if bmad-c9s source directory exists
    if (-not (Test-Path $SourceBmadC9sDir)) {
        $errors += "Source directory not found: $SourceBmadC9sDir"
        $errors += "Run this script from the claude-code-bmad-skills repository root"
    } else {
        Write-Success "Found source directory: $SourceBmadC9sDir"
    }

    if (-not (Test-Path $SourceV6SkillsDir)) {
        $errors += "BMAD v6 skills not found: $SourceV6SkillsDir (required for combined install)"
    }

    # Check required source subdirectories
    $requiredDirs = @{
        "skills" = $SourceSkillsDir
        "config" = $SourceConfigDir
        "templates" = $SourceTemplatesDir
        "utils" = $SourceUtilsDir
        "commands" = $SourceCommandsDir
    }

    foreach ($dirName in $requiredDirs.Keys) {
        $dirPath = $requiredDirs[$dirName]
        if (-not (Test-Path $dirPath)) {
            $errors += "Required source directory not found: $dirPath"
        } else {
            Write-Verbose "Found $dirName directory: $dirPath"
        }
    }

    # Check write permissions to home directory
    try {
        $testFile = Join-Path $HomeDir ".bmad-install-test-$(Get-Date -Format 'yyyyMMddHHmmss')"
        Set-Content -Path $testFile -Value "test" -ErrorAction Stop
        Remove-Item $testFile -ErrorAction SilentlyContinue
        Write-Success "Write permissions verified for: $HomeDir"
    }
    catch {
        $errors += "No write permission to home directory: $HomeDir"
        $errors += "  Reason: $($_.Exception.Message)"
    }

    # Check if already installed
    $bmadMasterPath = Join-PathCompat $BmadC9sSkillsDir "core" "bmad-master-c9s" "SKILL.md"
    if ((Test-Path $bmadMasterPath) -and -not $Force) {
        Write-Warning "BMAD-c9s is already installed at: $BmadC9sSkillsDir"
        Write-Host ""
        Write-Host "Options:" -ForegroundColor Yellow
        Write-Host "  1. Run with -Force to reinstall"
        Write-Host "  2. Run with -Uninstall to remove first"
        Write-Host "  3. Cancel installation (Ctrl+C)"
        Write-Host ""

        if (-not $WhatIfPreference) {
            $response = Read-Host "Reinstall over existing installation? (y/N)"
            if ($response -ne 'y' -and $response -ne 'Y') {
                Write-Info "Installation cancelled by user"
                exit 0
            }
        }
    }

    # Report errors
    if ($errors.Count -gt 0) {
        Write-ErrorMsg "Pre-flight checks failed with $($errors.Count) error(s):"
        foreach ($error in $errors) {
            Write-Host "  - $error" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "Installation cannot proceed. Please fix the errors above." -ForegroundColor Yellow
        return $false
    }

    Write-Success "All pre-flight checks passed"
    return $true
}

###############################################################################
# Uninstall Function
###############################################################################

function global:Uninstall-BmadV6 {
    Write-Header "BMAD v6 + c9s v$BmadVersion — удаление"

    Write-Info "Checking for BMAD installation..."

    $dirsToRemove = @(
        $BmadSkillsDir,
        $BmadC9sSkillsDir,
        $BmadCommandsDir,
        $BmadConfigDir
    )

    $found = $false
    foreach ($dir in $dirsToRemove) {
        if (Test-Path $dir) {
            $found = $true
            Write-Info "Found: $dir"
        }
    }

    if (-not $found) {
        Write-Warning "BMAD installation not found under ~/.claude (skills/bmad, skills/bmad-c9s, config/bmad)"
        Write-Host "Nothing to uninstall."
        exit 0
    }

    Write-Host ""
    Write-Warning "This will remove BMAD-c9s from your system:"
    foreach ($dir in $dirsToRemove) {
        if (Test-Path $dir) {
            Write-Host "  - $dir" -ForegroundColor Yellow
        }
    }
    Write-Host ""

    if (-not $WhatIfPreference) {
        $response = Read-Host "Continue with uninstall? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Info "Uninstall cancelled"
            exit 0
        }
    }

    Write-Info "Uninstalling BMAD-c9s..."

    try {
        foreach ($dir in $dirsToRemove) {
            if (Test-Path $dir) {
                if ($PSCmdlet.ShouldProcess($dir, "Remove directory")) {
                    Remove-Item -Path $dir -Recurse -Force -ErrorAction Stop
                    Write-Success "Removed: $dir"
                }
            }
        }

        Write-Host ""
        Write-Success "BMAD-c9s has been uninstalled successfully!"
        Write-Host ""
        exit 0
    }
    catch {
        Write-ErrorMsg "Uninstall failed: $($_.Exception.Message)"
        exit 1
    }
}

###############################################################################
# Installation Functions
###############################################################################

function global:New-Directories {
    Write-Progress -Activity "Installing BMAD v6 + c9s" -Status "Creating directory structure..." -PercentComplete 0
    Write-Info "Creating directory structure..."

    try {
        @("core", "bmm", "bmb", "cis") | ForEach-Object {
            $skillDir = Join-Path $BmadSkillsDir $_
            if ($PSCmdlet.ShouldProcess($skillDir, "Create v6 skill directory")) {
                New-Item -ItemType Directory -Force -Path $skillDir -ErrorAction Stop | Out-Null
            }
            $c9sDir = Join-Path $BmadC9sSkillsDir $_
            if ($PSCmdlet.ShouldProcess($c9sDir, "Create c9s skill directory")) {
                New-Item -ItemType Directory -Force -Path $c9sDir -ErrorAction Stop | Out-Null
            }
        }

        @("agents", "templates") | ForEach-Object {
            $configDir = Join-Path $BmadConfigDir $_
            if ($PSCmdlet.ShouldProcess($configDir, "Create config directory")) {
                New-Item -ItemType Directory -Force -Path $configDir -ErrorAction Stop | Out-Null
            }
        }

        @("commands", "templates", "utils") | ForEach-Object {
            $bundleSub = Join-Path $BmadV6BundleDir $_
            if ($PSCmdlet.ShouldProcess($bundleSub, "Create bmad-v6-bundle subdirectory")) {
                New-Item -ItemType Directory -Force -Path $bundleSub -ErrorAction Stop | Out-Null
            }
        }

        Write-Success "Directory structure created"
        Write-Verbose "  Skills v6: $BmadSkillsDir"
        Write-Verbose "  Skills c9s: $BmadC9sSkillsDir"
        Write-Verbose "  Config: $BmadConfigDir"
    }
    catch {
        Write-ErrorMsg "Failed to create directory structure"
        Write-ErrorMsg "  Reason: $($_.Exception.Message)"
        throw
    }
}

function global:Install-Skills {
    Write-Progress -Activity "Installing BMAD v6 + c9s" -Status "Installing skills..." -PercentComplete 20
    Write-Info "Installing BMAD v6 skills → $BmadSkillsDir ..."

    $v6Components = @(
        @{ Name = "v6 Core"; Sub = "core"; Required = $true }
        @{ Name = "v6 BMM"; Sub = "bmm"; Required = $true }
        @{ Name = "v6 BMB"; Sub = "bmb"; Required = $false }
        @{ Name = "v6 CIS"; Sub = "cis"; Required = $false }
    )
    foreach ($c in $v6Components) {
        $sourcePath = Join-PathCompat $SourceV6SkillsDir $c.Sub
        $destPath = Join-Path $BmadSkillsDir $c.Sub
        if (Test-Path $sourcePath) {
            $sourcePattern = Join-Path $sourcePath "*"
            if ($PSCmdlet.ShouldProcess($destPath, "Copy $($c.Name)")) {
                Copy-ItemSafe -SourcePath $sourcePattern -DestinationPath $destPath -Recurse -Force -ErrorContext "$($c.Name) installation"
                Write-Success "$($c.Name) installed"
            }
        } elseif ($c.Required) {
            throw "Required v6 skills missing: $sourcePath"
        }
    }

    Write-Info "Installing BMAD-c9s skills → $BmadC9sSkillsDir ..."
    $c9sComponents = @(
        @{ Name = "c9s Core"; Sub = "core"; Required = $true }
        @{ Name = "c9s BMM"; Sub = "bmm"; Required = $true }
        @{ Name = "c9s BMB"; Sub = "bmb"; Required = $false }
        @{ Name = "c9s CIS"; Sub = "cis"; Required = $false }
    )
    foreach ($c in $c9sComponents) {
        $sourcePath = Join-PathCompat $SourceSkillsDir $c.Sub
        $destPath = Join-Path $BmadC9sSkillsDir $c.Sub
        if (Test-Path $sourcePath) {
            $sourcePattern = Join-Path $sourcePath "*"
            if ($PSCmdlet.ShouldProcess($destPath, "Copy $($c.Name)")) {
                Copy-ItemSafe -SourcePath $sourcePattern -DestinationPath $destPath -Recurse -Force -ErrorContext "$($c.Name) installation"
                Write-Success "$($c.Name) installed"
            }
        } elseif ($c.Required) {
            throw "Required c9s skills missing: $sourcePath"
        }
    }
}

function global:Install-V6Bundle {
    Write-Progress -Activity "Installing BMAD v6 + c9s" -Status "bmad-v6-bundle..." -PercentComplete 32
    Write-Info "Copying BMAD v6 commands/templates/utils → bmad-v6-bundle..."
    $v6Cmd = Join-Path $SourceBmadV6Dir "commands"
    if (Test-Path $v6Cmd) {
        $pattern = Join-Path $v6Cmd "*.md"
        Copy-ItemSafe -SourcePath $pattern -DestinationPath (Join-Path $BmadV6BundleDir "commands") -Force -ErrorContext "v6 bundle commands"
    }
    $v6Tpl = Join-Path $SourceBmadV6Dir "templates"
    if (Test-Path $v6Tpl) {
        $pattern = Join-Path $v6Tpl "*"
        Copy-ItemSafe -SourcePath $pattern -DestinationPath (Join-Path $BmadV6BundleDir "templates") -Force -ErrorContext "v6 bundle templates"
    }
    $v6Helpers = Join-PathCompat $SourceBmadV6Dir "utils" "helpers.md"
    if (Test-Path $v6Helpers) {
        Copy-ItemSafe -SourcePath $v6Helpers -DestinationPath (Join-Path $BmadV6BundleDir "utils" "helpers.md") -Force -ErrorContext "v6 bundle helpers"
    }
    Write-Success "bmad-v6-bundle updated"
}

function global:Install-Config {
    Write-Progress -Activity "Installing BMAD v6 + c9s" -Status "Installing configuration..." -PercentComplete 40
    Write-Info "Installing configuration (v6 + c9s)..."

    try {
        $V6ConfigTemplate = Join-PathCompat $SourceBmadV6Dir "config" "config.template.yaml"
        $V6ConfigDest = Join-Path $BmadConfigDir "config.yaml"
        if ((Test-Path $V6ConfigTemplate) -and -not (Test-Path $V6ConfigDest)) {
            $raw = Get-Content -Path $V6ConfigTemplate -Raw -ErrorAction Stop
            $userName = if ($env:USERNAME) { $env:USERNAME } else { $env:USER }
            $raw = $raw -replace '\{\{USER_NAME\}\}', $userName
            if ($PSCmdlet.ShouldProcess($V6ConfigDest, "Write BMAD v6 config.yaml")) {
                Set-Content -Path $V6ConfigDest -Value $raw -Encoding UTF8 -ErrorAction Stop
                Write-Success "config.yaml created (BMAD v6)"
            }
        } elseif (Test-Path $V6ConfigDest) {
            Write-Verbose "config.yaml exists — not overwriting"
        }

        $V6ProjectTpl = Join-PathCompat $SourceBmadV6Dir "config" "project-config.template.yaml"
        if (Test-Path $V6ProjectTpl) {
            Copy-ItemSafe -SourcePath $V6ProjectTpl -DestinationPath (Join-Path $BmadConfigDir "project-config.template.yaml") -Force -ErrorContext "v6 project-config template"
        }

        $C9sConfigTemplatePath = Join-PathCompat $SourceConfigDir "c9s-config.template.yaml"
        $C9sConfigDestPath = Join-Path $BmadConfigDir "c9s-config.template.yaml"
        if (Test-Path $C9sConfigTemplatePath) {
            if ($PSCmdlet.ShouldProcess($C9sConfigDestPath, "Copy c9s config template")) {
                Copy-ItemSafe -SourcePath $C9sConfigTemplatePath -DestinationPath $C9sConfigDestPath -Force -ErrorContext "c9s config template"
                Write-Success "c9s-config.template.yaml installed"
            }
        } else {
            Write-Warning "c9s-config.template.yaml not found at: $C9sConfigTemplatePath"
        }
    }
    catch {
        Write-ErrorMsg "Failed to install configuration"
        throw
    }
}

function global:Install-Templates {
    Write-Progress -Activity "Installing BMAD v6 + c9s" -Status "Installing templates..." -PercentComplete 60
    Write-Info "templates/: v6 base, then c9s overwrites same filenames..."

    try {
        $TemplatesDestPath = Join-Path $BmadConfigDir "templates"
        $V6Templates = Join-Path $SourceBmadV6Dir "templates"
        if (Test-Path $V6Templates) {
            $templatePattern = Join-Path $V6Templates "*"
            if ($PSCmdlet.ShouldProcess($TemplatesDestPath, "Copy v6 templates")) {
                Copy-ItemSafe -SourcePath $templatePattern -DestinationPath $TemplatesDestPath -Force -ErrorContext "v6 templates"
                Write-Success "v6 templates copied (base)"
            }
        }
        if (Test-Path $SourceTemplatesDir) {
            $templatePattern = Join-Path $SourceTemplatesDir "*"
            if ($PSCmdlet.ShouldProcess($TemplatesDestPath, "Copy c9s templates (overwrite)")) {
                Copy-ItemSafe -SourcePath $templatePattern -DestinationPath $TemplatesDestPath -Force -ErrorContext "c9s templates"
                Write-Success "c9s templates applied (overwrite matching names)"
            }
        }
    }
    catch {
        Write-ErrorMsg "Failed to install templates"
        throw
    }
}

function global:Install-Utils {
    Write-Progress -Activity "Installing BMAD v6 + c9s" -Status "Installing docs and helpers..." -PercentComplete 70
    Write-Info "Installing helpers and c9s docs..."

    try {
        $V6Helpers = Join-PathCompat $SourceBmadV6Dir "utils" "helpers.md"
        $V6HelpersRef = Join-Path $BmadConfigDir "helpers-bmad-v6-en.md"
        if (Test-Path $V6Helpers) {
            if ($PSCmdlet.ShouldProcess($V6HelpersRef, "Copy BMAD v6 helpers (reference EN)")) {
                Copy-ItemSafe -SourcePath $V6Helpers -DestinationPath $V6HelpersRef -Force -ErrorContext "v6 helpers EN ref"
                Write-Success "helpers-bmad-v6-en.md (methodology reference)"
            }
        }

        $HelpersRuPath = Join-PathCompat $SourceUtilsDir "helpers-ru.md"
        $HelpersRuDest = Join-Path $BmadConfigDir "helpers-ru.md"
        $HelpersPrimary = Join-Path $BmadConfigDir "helpers.md"
        if (Test-Path $HelpersRuPath) {
            if ($PSCmdlet.ShouldProcess($HelpersRuDest, "Copy helpers-ru.md")) {
                Copy-ItemSafe -SourcePath $HelpersRuPath -DestinationPath $HelpersRuDest -Force -ErrorContext "helpers-ru"
                Write-Success "helpers-ru.md installed"
            }
            if ($PSCmdlet.ShouldProcess($HelpersPrimary, "Copy helpers.md from c9s helpers-ru")) {
                Copy-ItemSafe -SourcePath $HelpersRuPath -DestinationPath $HelpersPrimary -Force -ErrorContext "helpers primary"
                Write-Success "helpers.md = c9s rules (copy of helpers-ru)"
            }
        } else {
            Write-Warning "helpers-ru.md not found at: $HelpersRuPath"
        }

        $FormatPath = Join-PathCompat $SourceC9sDocsDir "FORMAT-CAPITAL-GITHUB.md"
        $FormatDest = Join-Path $BmadConfigDir "FORMAT-CAPITAL-GITHUB.md"
        if (Test-Path $FormatPath) {
            if ($PSCmdlet.ShouldProcess($FormatDest, "Copy FORMAT-CAPITAL-GITHUB.md")) {
                Copy-ItemSafe -SourcePath $FormatPath -DestinationPath $FormatDest -Force -ErrorContext "FORMAT doc"
                Write-Success "FORMAT-CAPITAL-GITHUB.md installed"
            }
        }

        foreach ($docName in @("TASKS-DOCUMENTS-TIME-POLICY.md", "GIT-COMMITS-POLICY.md")) {
            $srcDoc = Join-PathCompat $SourceC9sDocsDir $docName
            $dstDoc = Join-Path $BmadConfigDir $docName
            if (Test-Path $srcDoc) {
                if ($PSCmdlet.ShouldProcess($dstDoc, "Copy $docName")) {
                    Copy-ItemSafe -SourcePath $srcDoc -DestinationPath $dstDoc -Force -ErrorContext "c9s doc $docName"
                    Write-Success "$docName installed"
                }
            }
        }

        $ClaudeSrc = Join-Path $SourceBmadC9sDir "CLAUDE.md"
        $ClaudeDest = Join-Path $BmadConfigDir "CLAUDE-bmad-c9s.md"
        if (Test-Path $ClaudeSrc) {
            if ($PSCmdlet.ShouldProcess($ClaudeDest, "Copy CLAUDE-bmad-c9s.md")) {
                Copy-ItemSafe -SourcePath $ClaudeSrc -DestinationPath $ClaudeDest -Force -ErrorContext "CLAUDE overview"
                Write-Success "CLAUDE-bmad-c9s.md installed"
            }
        }
    }
    catch {
        Write-ErrorMsg "Failed to install docs/helpers"
        throw
    }
}

function global:Install-Commands {
    Write-Progress -Activity "Installing BMAD v6 + c9s" -Status "Installing slash commands..." -PercentComplete 80
    Write-Info "Installing slash commands from bmad-c9s/commands..."

    try {
        Write-Verbose "Commands source: $SourceCommandsDir"
        Write-Verbose "Commands destination: $BmadCommandsDir"

        if (Test-Path $SourceCommandsDir) {
            # Count commands for user feedback
            $commandFiles = Get-ChildItem -Path $SourceCommandsDir -Filter "*.md" -ErrorAction SilentlyContinue
            $commandCount = $commandFiles.Count

            if ($commandCount -gt 0) {
                $commandPattern = Join-Path $SourceCommandsDir "*"
                if ($PSCmdlet.ShouldProcess($BmadCommandsDir, "Copy $commandCount slash commands")) {
                    Copy-ItemSafe -SourcePath $commandPattern -DestinationPath $BmadCommandsDir -Force -ErrorContext "slash commands"
                    Write-Success "Slash commands installed ($commandCount commands)"
                    Write-Verbose "  Commands:"
                    foreach ($cmd in $commandFiles) {
                        $cmdName = $cmd.BaseName
                        Write-Verbose "    /$cmdName"
                    }
                }
            } else {
                Write-Warning "No command files found in: $SourceCommandsDir"
            }
        } else {
            Write-Warning "Commands directory not found at: $SourceCommandsDir"
        }
    }
    catch {
        Write-ErrorMsg "Failed to install slash commands"
        throw
    }
}

function global:Test-Installation {
    Write-Progress -Activity "Installing BMAD v6 + c9s" -Status "Verifying installation..." -PercentComplete 90
    Write-Info "Verifying installation..."

    $errors = 0
    $checks = @(
        @{
            Name = "bmad-master (v6) skill"
            Path = Join-PathCompat $BmadSkillsDir "core" "bmad-master" "SKILL.md"
        },
        @{
            Name = "bmad-master-c9s skill"
            Path = Join-PathCompat $BmadC9sSkillsDir "core" "bmad-master-c9s" "SKILL.md"
        },
        @{
            Name = "bmad-v6-bundle create-story"
            Path = Join-PathCompat $BmadV6BundleDir "commands" "create-story.md"
        },
        @{
            Name = "c9s config template"
            Path = Join-Path $BmadConfigDir "c9s-config.template.yaml"
        },
        @{
            Name = "helpers-ru"
            Path = Join-Path $BmadConfigDir "helpers-ru.md"
        },
        @{
            Name = "Slash command c9s-init"
            Path = Join-Path $BmadCommandsDir "c9s-init.md"
        }
    )

    foreach ($check in $checks) {
        $path = $check.Path
        $name = $check.Name

        Write-Verbose "Checking: $name at $path"

        if (Test-Path $path) {
            # Verify file is not empty
            $fileInfo = Get-Item $path
            if ($fileInfo.Length -gt 0) {
                Write-Success "$name verified"
            } else {
                Write-ErrorMsg "$name exists but is empty: $path"
                $errors++
            }
        } else {
            Write-ErrorMsg "$name missing: $path"
            $errors++
        }
    }

    if ($errors -eq 0) {
        Write-Success "Installation verified successfully"
        return $true
    } else {
        Write-ErrorMsg "Installation verification failed: $errors error(s)"
        return $false
    }
}

function global:Show-NextSteps {
    Write-Header "BMAD v6 + BMAD-c9s — установка завершена"

    Write-Host "[SUCCESS] BMAD v6 + BMAD-c9s v$BmadVersion установлены." -ForegroundColor Green
    Write-Host ""
    Write-Host "Скиллы:"
    Write-Host "  v6:   $BmadSkillsDir"
    Write-Host "  c9s:  $BmadC9sSkillsDir"
    Write-Host "Команды (обёртки c9s): $BmadCommandsDir"
    Write-Host "Конфиг: $BmadConfigDir (в т.ч. bmad-v6-bundle/commands для полных текстов v6)"
    Write-Host ""
    Write-Host "Дальше:"
    Write-Host "  1. Перезапустите Claude Code"
    Write-Host "  2. Скопируйте c9s-config.template.yaml в репозиторий результатов как c9s-config.yaml"
    Write-Host "  3. Инициализация: /c9s-init (скилл bmad-master-c9s)"
    Write-Host "  4. Статус: /c9s-status"
    Write-Host ""
    Write-Host "Документация после установки:"
    Write-Host "  $BmadConfigDir\CLAUDE-bmad-c9s.md"
    Write-Host "  $BmadConfigDir\FORMAT-CAPITAL-GITHUB.md"
    Write-Host "  $BmadConfigDir\helpers-ru.md"
    Write-Host ""
    Write-Host "Проверка:"

    if ($IsWindows -or $env:OS -match "Windows" -or (-not (Test-Path variable:IsWindows))) {
        Write-Host "  dir `"$BmadSkillsDir\core\bmad-master\SKILL.md`""
        Write-Host "  dir `"$BmadC9sSkillsDir\core\bmad-master-c9s\SKILL.md`""
        Write-Host "  dir `"$BmadCommandsDir\c9s-init.md`""
    } else {
        Write-Host "  ls -la ~/.claude/skills/bmad/core/bmad-master/SKILL.md"
        Write-Host "  ls -la ~/.claude/skills/bmad-c9s/core/bmad-master-c9s/SKILL.md"
        Write-Host "  ls -la ~/.claude/commands/bmad/c9s-init.md"
    }

    Write-Host ""
    Write-Host "Исходники пакета: $SourceBmadC9sDir"
    Write-Host ""
    Write-Host "[OK] BMAD v6 + c9s готовы." -ForegroundColor Green
}

function global:Show-WhatIfSummary {
    Write-Header "Installation Summary (Dry-Run) — BMAD-c9s"

    Write-Host "Would install BMAD v6 + BMAD-c9s v$BmadVersion"
    Write-Host "  Skills v6: $BmadSkillsDir"
    Write-Host "  Skills c9s: $BmadC9sSkillsDir"
    Write-Host "  Commands: $BmadCommandsDir"
    Write-Host "  Config: $BmadConfigDir + bmad-v6-bundle"
    Write-Host ""
    Write-Host "Components:"
    Write-Host "  [*] Skills from bmad-v6/skills and bmad-c9s/skills"
    Write-Host "  [*] bmad-v6-bundle (commands, templates, utils)"
    Write-Host "  [*] config.yaml (v6), c9s-config.template.yaml, merged templates"
    Write-Host "  [*] helpers.md (v6), helpers-ru, slash commands from bmad-c9s/commands"
    Write-Host ""
    Write-Host "To perform actual installation, run without -WhatIf"
}

###############################################################################
# Main Installation
###############################################################################

function global:Main {
    # Show help
    if ($Help) {
        Get-Help $PSCommandPath -Detailed
        exit 0
    }

    # Handle uninstall
    if ($Uninstall) {
        Uninstall-BmadV6
        return
    }

    Write-Header "BMAD v6 + BMAD-c9s v$BmadVersion — installer"

    # Show version info
    if ($IsPowerShell5) {
        Write-Host "Detected: PowerShell $PSVersion (compatibility mode)" -ForegroundColor Yellow
    } else {
        Write-Host "Detected: PowerShell $PSVersion" -ForegroundColor Green
    }
    Write-Host ""

    # Pre-flight checks
    if (-not (Test-Prerequisites)) {
        exit 1
    }

    # WhatIf summary
    if ($WhatIfPreference) {
        Write-Host ""
        Show-WhatIfSummary
        exit 0
    }

    Write-Verbose "Installation started at: $(Get-Date)"
    Write-Verbose "Script directory: $ScriptDir"
    Write-Verbose "Target directory: $ClaudeDir"

    try {
        # Perform installation
        Write-Host ""
        Write-Info "Starting installation..."

        New-Directories
        Install-Skills
        Install-V6Bundle
        Install-Config
        Install-Templates
        Install-Utils
        Install-Commands

        # Verify
        Write-Host ""
        if (Test-Installation) {
            Write-Progress -Activity "Installing BMAD v6 + c9s" -Status "Complete!" -PercentComplete 100
            Write-Host ""
            Show-NextSteps
            Write-Progress -Activity "Installing BMAD v6 + c9s" -Completed
            Write-Verbose "Installation completed successfully at: $(Get-Date)"
            exit 0
        } else {
            Write-ErrorMsg "Installation verification failed"
            Write-Host ""
            Write-Host "Troubleshooting:" -ForegroundColor Yellow
            Write-Host "  1. Run with -Verbose flag for detailed diagnostics"
            Write-Host "  2. Check file permissions on: $ClaudeDir"
            Write-Host "  3. Verify source files exist in: $SourceBmadC9sDir"
            Write-Host "  4. Try running with -Force to reinstall"
            Write-Host ""
            exit 1
        }
    }
    catch {
        Write-Progress -Activity "Installing BMAD v6 + c9s" -Completed
        Write-Host ""
        Write-Host "===============================================" -ForegroundColor Red
        Write-Host "  Installation Failed" -ForegroundColor Red
        Write-Host "===============================================" -ForegroundColor Red
        Write-Host ""
        Write-ErrorMsg $_.Exception.Message
        Write-Host ""
        Write-Host "Troubleshooting:" -ForegroundColor Yellow
        Write-Host "  1. Run with -Verbose flag for detailed diagnostics:"
        Write-Host "     .\install-v6.ps1 -Verbose"
        Write-Host ""
        Write-Host "  2. Check if bmad-c9s/ directory exists:"
        Write-Host "     dir bmad-c9s\"
        Write-Host ""
        Write-Host "  3. Verify write permissions:"
        Write-Host "     Test writing to $ClaudeDir"
        Write-Host ""
        Write-Host "  4. Report issues:"
        Write-Host "     https://github.com/aj-geddes/claude-code-bmad-skills/issues"
        Write-Host ""
        Write-Verbose "Exception: $($_.Exception.Message)"
        Write-Verbose "Stack trace: $($_.ScriptStackTrace)"
        exit 1
    }
}

# Run installation
Main
