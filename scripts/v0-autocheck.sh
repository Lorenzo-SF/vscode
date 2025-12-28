#!/bin/bash
# v0-autocheck.sh - Script de autochequeo completo para v0.md
# Verifica todos los puntos de la sección de autochequeo de v0.md

set -e

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASSED=0
FAILED=0
SKIPPED=0

# Función para verificar
check() {
    local name="$1"
    local required="${2:-true}"
    shift 2
    
    echo -n "Verificando: $name... "
    
    if "$@" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        ((PASSED++))
        return 0
    else
        if [ "$required" = "true" ]; then
            echo -e "${RED}✗${NC}"
            ((FAILED++))
            return 1
        else
            echo -e "${YELLOW}⊘${NC} (opcional)"
            ((SKIPPED++))
            return 0
        fi
    fi
}

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Autochequeo v0.md - ElixIDE${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

# 1. Fork y Repositorio
echo -e "${YELLOW}[1] Fork y Repositorio${NC}"
check "Fork de VSCode configurado" true sh -c "git remote -v | grep 'origin' | grep -q 'Lorenzo-SF'"
check "Remote upstream configurado" true sh -c "git remote -v | grep 'upstream' | grep -q 'microsoft/vscode'"
check "Branch develop existe" true sh -c "git branch | grep -q 'develop'"
check "Branch main existe" true sh -c "git branch | grep -q 'main'"
echo ""

# 2. Estructura de Directorios
echo -e "${YELLOW}[2] Estructura de Directorios${NC}"
check "Directorio modules/ existe" true test -d modules
check "Directorio assets/ existe" true test -d assets
check "Directorio assets/themes/ existe" true test -d assets/themes
check "Directorio assets/icons/ existe" true test -d assets/icons
check "Directorio patches/ existe" true test -d patches
check "Directorio scripts/ existe" true test -d scripts
check "Directorio scripts/assets/ existe" true test -d scripts/assets
check "Directorio docs/ existe" true test -d docs
echo ""

# 3. Archivos de Configuración
echo -e "${YELLOW}[3] Archivos de Configuración${NC}"
check ".nvmrc existe" true test -f .nvmrc
check ".nvmrc contiene 22.21.1" true grep -q '22.21.1' .nvmrc
check ".python-version existe" true test -f .python-version
check ".python-version contiene 3.9.0" true grep -q '3.9.0' .python-version
check "Makefile existe" true test -f Makefile
check "package.json existe" true test -f package.json
check "product.json existe" true test -f product.json
echo ""

# 4. Scripts
echo -e "${YELLOW}[4] Scripts${NC}"
check "sync-assets.sh existe" true test -f scripts/assets/sync-assets.sh
check "sync-assets.sh es ejecutable" true test -x scripts/assets/sync-assets.sh
echo ""

# 5. Temas ElixIDE
echo -e "${YELLOW}[5] Temas ElixIDE${NC}"
check "elixide-dark.json en assets/themes/" true test -f assets/themes/elixide-dark.json
check "elixide-light.json en assets/themes/" true test -f assets/themes/elixide-light.json
check "elixide-dark.json en extensions/theme-defaults/themes/" true test -f extensions/theme-defaults/themes/elixide-dark.json
check "elixide-light.json en extensions/theme-defaults/themes/" true test -f extensions/theme-defaults/themes/elixide-light.json
check "Temas registrados en package.json" true grep -q 'elixide-dark' extensions/theme-defaults/package.json
check "Etiquetas en package.nls.json" true grep -q 'elixideDarkColorThemeLabel' extensions/theme-defaults/package.nls.json
echo ""

# 6. Assets
echo -e "${YELLOW}[6] Assets${NC}"
check "Iconos SVG copiados" true test -f assets/icons/explorer.svg
check "Al menos 3 iconos SVG" true sh -c '[ $(ls assets/icons/*.svg 2>/dev/null | wc -l) -ge 3 ]'
echo ""

# 7. Branding (product.json)
echo -e "${YELLOW}[7] Branding${NC}"
check "nameShort es ElixIDE" true grep -q '"nameShort": "ElixIDE"' product.json
check "nameLong es ElixIDE" true grep -q '"nameLong": "ElixIDE"' product.json
check "applicationName es elixide" true grep -q '"applicationName": "elixide"' product.json
check "dataFolderName es .elixide" true grep -q '"dataFolderName": ".elixide"' product.json
echo ""

# 8. Git y Commits
echo -e "${YELLOW}[8] Git y Commits${NC}"
check "Git configurado (user.name)" true sh -c 'git config user.name | grep -q "."'
check "Git configurado (user.email)" true sh -c 'git config user.email | grep -q "@"'
check "Feature branch creada" true sh -c 'git branch | grep -q "feature/v0"'
check "Commits realizados" true sh -c '[ $(git log --oneline | wc -l) -ge 2 ]'
echo ""

# 9. Validación de Archivos JSON
echo -e "${YELLOW}[9] Validación de Archivos JSON${NC}"
if command -v jq > /dev/null 2>&1; then
    check "elixide-dark.json es JSON válido" true jq empty assets/themes/elixide-dark.json
    check "elixide-light.json es JSON válido" true jq empty assets/themes/elixide-light.json
    check "package.json es JSON válido" true jq empty package.json
    check "product.json es JSON válido" true jq empty product.json
else
    echo -e "${YELLOW}  ⊘ jq no instalado, saltando validación JSON${NC}"
    ((SKIPPED+=4))
fi
echo ""

# 10. Estructura de Temas
echo -e "${YELLOW}[10] Estructura de Temas${NC}"
if [ -f "assets/themes/elixide-dark.json" ]; then
    if command -v jq > /dev/null 2>&1; then
        check "Tema tiene \$schema" true jq -e '.\$schema' assets/themes/elixide-dark.json > /dev/null
        check "Tema tiene name" true jq -e '.name' assets/themes/elixide-dark.json > /dev/null
        check "Tema tiene colors" true jq -e '.colors' assets/themes/elixide-dark.json > /dev/null
        check "Tema tiene tokenColors" true jq -e '.tokenColors' assets/themes/elixide-dark.json > /dev/null
    else
        check "Tema contiene \$schema" true grep -q '\$schema' assets/themes/elixide-dark.json
        check "Tema contiene name" true grep -q '"name"' assets/themes/elixide-dark.json
        check "Tema contiene colors" true grep -q '"colors"' assets/themes/elixide-dark.json
    fi
fi
echo ""

# Resumen
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Resumen${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}✓ Pasados: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}✗ Fallidos: $FAILED${NC}"
fi
if [ $SKIPPED -gt 0 ]; then
    echo -e "${YELLOW}⊘ Omitidos: $SKIPPED${NC}"
fi
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}¡Todos los checks requeridos pasaron!${NC}"
    exit 0
else
    echo -e "${RED}Algunos checks fallaron. Revisa los errores arriba.${NC}"
    exit 1
fi
