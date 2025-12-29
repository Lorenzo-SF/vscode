#!/bin/bash
# verify-all-warnings.sh - Verifica y completa todos los warnings pendientes

set -e

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASSED=0
FAILED=0
WARNINGS=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Verificación de Warnings v0${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Función para verificar
check() {
    local name="$1"
    shift
    
    echo -n "  Verificando: $name... "
    
    if "$@" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC}"
        ((FAILED++))
        return 1
    fi
}

# 1. Verificar que los temas tienen reglas Elixir (sin jq)
echo -e "${YELLOW}[1] Verificar reglas Elixir en temas (sin jq)${NC}"
check "Tema oscuro tiene 'Elixir Keywords'" grep -q '"name".*"Elixir Keywords"' extensions/theme-defaults/themes/elixide-dark.json
check "Tema oscuro tiene 'Elixir Functions'" grep -q '"name".*"Elixir Functions"' extensions/theme-defaults/themes/elixide-dark.json
check "Tema oscuro tiene 'Elixir Types'" grep -q '"name".*"Elixir Types"' extensions/theme-defaults/themes/elixide-dark.json
check "Tema claro tiene 'Elixir Keywords'" grep -q '"name".*"Elixir Keywords"' extensions/theme-defaults/themes/elixide-light.json
check "Tema claro tiene 'Elixir Functions'" grep -q '"name".*"Elixir Functions"' extensions/theme-defaults/themes/elixide-light.json
check "Tema claro tiene 'Elixir Types'" grep -q '"name".*"Elixir Types"' extensions/theme-defaults/themes/elixide-light.json
echo ""

# 2. Verificar colores de temas (sin jq)
echo -e "${YELLOW}[2] Verificar colores de temas (sin jq)${NC}"
check "Tema oscuro tiene editor.background #2D1B2E" grep -q '"editor.background".*"#2D1B2E"' extensions/theme-defaults/themes/elixide-dark.json
check "Tema claro tiene editor.background #F5F0E8" grep -q '"editor.background".*"#F5F0E8"' extensions/theme-defaults/themes/elixide-light.json
check "Tema oscuro tiene colors" grep -q '"colors".*{' extensions/theme-defaults/themes/elixide-dark.json
check "Tema claro tiene colors" grep -q '"colors".*{' extensions/theme-defaults/themes/elixide-light.json
echo ""

# 3. Verificar Prompts/assets/
echo -e "${YELLOW}[3] Verificar Prompts/assets/${NC}"
PROMPTS_ASSETS=""
if [ -d "$PROJECT_ROOT/../scripts_repo/Prompts/assets" ]; then
    PROMPTS_ASSETS="$PROJECT_ROOT/../scripts_repo/Prompts/assets"
elif [ -d "/mnt/c/Users/loren/Desktop/proyectos/scripts_repo/Prompts/assets" ]; then
    PROMPTS_ASSETS="/mnt/c/Users/loren/Desktop/proyectos/scripts_repo/Prompts/assets"
fi

if [ -n "$PROMPTS_ASSETS" ]; then
    check "Prompts/assets/ existe" test -d "$PROMPTS_ASSETS"
    check "Tema oscuro en Prompts/assets/" test -f "$PROMPTS_ASSETS/themes/elixide-dark.json" || test -f "$PROMPTS_ASSETS/themes/elix-dark.json"
    check "Tema claro en Prompts/assets/" test -f "$PROMPTS_ASSETS/themes/elixide-light.json" || test -f "$PROMPTS_ASSETS/themes/elix-light.json"
    check "README.md en Prompts/assets/" test -f "$PROMPTS_ASSETS/README.md"
    check "README.md en Prompts/assets/themes/" test -f "$PROMPTS_ASSETS/themes/README.md"
    check "README.md en Prompts/assets/icons/" test -f "$PROMPTS_ASSETS/icons/README.md"
else
    echo "  ⚠ Prompts/assets/ no encontrado en rutas estándar"
    echo "  Buscando en otras ubicaciones..."
    # Intentar otras rutas comunes
    if [ -d "C:/Users/loren/Desktop/proyectos/scripts_repo/Prompts/assets" ]; then
        PROMPTS_ASSETS="C:/Users/loren/Desktop/proyectos/scripts_repo/Prompts/assets"
        check "Prompts/assets/ encontrado" test -d "$PROMPTS_ASSETS"
    else
        echo "  ⊘ Prompts/assets/ no encontrado - WARNING"
        ((WARNINGS++))
    fi
fi
echo ""

# 4. Verificar estructura de JSON de temas (sin jq)
echo -e "${YELLOW}[4] Verificar estructura JSON de temas${NC}"
check "Tema oscuro es JSON válido (tiene { al inicio)" head -1 extensions/theme-defaults/themes/elixide-dark.json | grep -q '^{'
check "Tema oscuro es JSON válido (tiene } al final)" tail -1 extensions/theme-defaults/themes/elixide-dark.json | grep -q '^}'
check "Tema claro es JSON válido (tiene { al inicio)" head -1 extensions/theme-defaults/themes/elixide-light.json | grep -q '^{'
check "Tema claro es JSON válido (tiene } al final)" tail -1 extensions/theme-defaults/themes/elixide-light.json | grep -q '^}'
check "Tema oscuro tiene tokenColors" grep -q '"tokenColors"' extensions/theme-defaults/themes/elixide-dark.json
check "Tema claro tiene tokenColors" grep -q '"tokenColors"' extensions/theme-defaults/themes/elixide-light.json
echo ""

# 5. Verificar que los scripts de build existen
echo -e "${YELLOW}[5] Verificar scripts de build${NC}"
check "Script build darwin existe" test -f scripts/build/darwin.sh
check "Script build linux existe" test -f scripts/build/linux.sh
check "Script build win32 existe" test -f scripts/build/win32.ps1 || test -f scripts/build/win32.sh
echo ""

# 6. Verificar que product.json está correcto
echo -e "${YELLOW}[6] Verificar product.json${NC}"
check "product.json existe" test -f product.json
check "product.json tiene nameShort ElixIDE" grep -q '"nameShort".*"ElixIDE"' product.json
check "product.json tiene nameLong ElixIDE" grep -q '"nameLong".*"ElixIDE"' product.json
check "product.json tiene applicationName elixide" grep -q '"applicationName".*"elixide"' product.json
echo ""

# 7. Verificar que los parches existen
echo -e "${YELLOW}[7] Verificar parches${NC}"
check "Parche vscode-identity.patch existe" test -f patches/vscode-identity.patch
check "Parche vscode-actionbar-top.patch existe" test -f patches/vscode-actionbar-top.patch || echo "Parche implementado directamente en código"
echo ""

# 8. Verificar implementación del action bar
echo -e "${YELLOW}[8] Verificar implementación del action bar${NC}"
check "titlebarPart.ts tiene createTitlebarActivityBar" grep -q "createTitlebarActivityBar" src/vs/workbench/browser/parts/titlebar/titlebarPart.ts
check "titlebarPart.ts tiene titlebarActivityBarContainer" grep -q "titlebarActivityBarContainer" src/vs/workbench/browser/parts/titlebar/titlebarPart.ts
check "CSS tiene titlebar-activity-bar" grep -q "titlebar-activity-bar" src/vs/workbench/browser/parts/titlebar/media/titlebarpart.css
check "CSS oculta window-title" grep -q "window-title.*display.*none" src/vs/workbench/browser/parts/titlebar/media/titlebarpart.css
check "Activity bar oculta en sidebar" grep -q "\.activitybar.*display.*none" src/vs/workbench/browser/parts/activitybar/media/activitybarpart.css
check "ActivitybarPart tiene width 0" grep -q "maximumWidth.*0" src/vs/workbench/browser/parts/activitybar/activitybarPart.ts
echo ""

# 9. Verificar documentación
echo -e "${YELLOW}[9] Verificar documentación${NC}"
check "README.md principal existe" test -f README.md
check "Documentación de accesibilidad existe" test -f docs/accessibility/README.md
check "Documentación de i18n existe" test -f docs/i18n/README.md
check "Documentación de atajos existe" test -f docs/user-guide/keyboard-shortcuts.md
check "Documentación de arquitectura existe" test -f docs/architecture/README.md
check "Documentación de desarrollo existe" test -f docs/development/setup.md
echo ""

# Resumen
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Resumen${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}✓ Pasados: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}✗ Fallidos: $FAILED${NC}"
fi
if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠ Advertencias: $WARNINGS${NC}"
fi
echo ""

# Warnings que requieren ejecución manual
echo -e "${YELLOW}Warnings que requieren ejecución manual:${NC}"
echo "  ⚠ Compilación: Ejecutar 'npm run compile'"
echo "  ⚠ Ejecución: Ejecutar './scripts/code.sh'"
echo "  ⚠ Lint: Ejecutar 'npm run lint'"
echo "  ⚠ Verificación visual: Abrir ElixIDE y verificar action bar"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}¡Todas las verificaciones automáticas pasaron!${NC}"
    exit 0
else
    echo -e "${RED}Algunas verificaciones fallaron. Revisa los errores arriba.${NC}"
    exit 1
fi

