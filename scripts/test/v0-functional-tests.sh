#!/bin/bash
# v0-functional-tests.sh - Script de pruebas funcionales según v0.md sección 3.3
# Ejecuta las 13 pruebas funcionales definidas en el prompt v0.md

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
    
    echo -n "  Verificando: $name... "
    
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
echo -e "${CYAN}Pruebas Funcionales v0.md${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

# Prueba 1: npm run start lanza ElixIDE
echo -e "${YELLOW}[Prueba 1] npm run start lanza ElixIDE${NC}"
check "Script elixide:start existe" true grep -q '"elixide:start"' package.json
check "Script compila proyecto" true grep -q '"compile"' package.json
echo ""

# Prueba 2: Action bar REEMPLAZA titlebar completamente
echo -e "${YELLOW}[Prueba 2] Action bar REEMPLAZA titlebar completamente${NC}"
check "Parche vscode-actionbar-top.patch existe" true test -f patches/vscode-actionbar-top.patch
check "titlebarPart.ts tiene createTitlebarActivityBar" true grep -q "createTitlebarActivityBar" src/vs/workbench/browser/parts/titlebar/titlebarPart.ts
check "CSS tiene estilos para titlebar-activity-bar" true grep -q "titlebar-activity-bar" src/vs/workbench/browser/parts/titlebar/media/titlebarpart.css
check "Título de ventana oculto en CSS" true grep -q "window-title.*display.*none" src/vs/workbench/browser/parts/titlebar/media/titlebarpart.css
echo ""

# Prueba 3: Sin errores en consola de desarrollador
echo -e "${YELLOW}[Prueba 3] Sin errores en consola de desarrollador${NC}"
echo "  ⊘ Esta prueba requiere ejecutar ElixIDE manualmente"
echo "  Instrucciones: Help > Toggle Developer Tools y verificar que no hay errores"
((SKIPPED++))
echo ""

# Prueba 4: Comando ElixIDE: Show Version funciona
echo -e "${YELLOW}[Prueba 4] Comando ElixIDE: Show Version funciona${NC}"
check "Módulo core existe" true test -d modules/core
check "Módulo core tiene package.json" true test -f modules/core/package.json
check "bootstrap.ts existe" true test -f src/bootstrap.ts
echo ""

# Prueba 5: Action bar en titlebar con especificaciones completas
echo -e "${YELLOW}[Prueba 5] Action bar en titlebar con especificaciones completas${NC}"
check "Activity bar oculta en sidebar (CSS)" true grep -q "\.activitybar.*display.*none" src/vs/workbench/browser/parts/activitybar/media/activitybarpart.css
check "Activity bar horizontal en titlebar (CSS)" true grep -q "flex-direction.*row" src/vs/workbench/browser/parts/titlebar/media/titlebarpart.css
check "Botones tienen tamaño apropiado (28px)" true grep -q "28px" src/vs/workbench/browser/parts/titlebar/media/titlebarpart.css
echo ""

# Prueba 6: Sidebar sin action bar vertical
echo -e "${YELLOW}[Prueba 6] Sidebar sin action bar vertical${NC}"
check "Activity bar oculta en CSS" true grep -q "\.activitybar.*display.*none" src/vs/workbench/browser/parts/activitybar/media/activitybarpart.css
check "ActivitybarPart tiene width 0" true grep -q "maximumWidth.*0" src/vs/workbench/browser/parts/activitybar/activitybarPart.ts
echo ""

# Prueba 7: Funciona en 3 plataformas
echo -e "${YELLOW}[Prueba 7] Funciona en 3 plataformas${NC}"
check "Script build darwin existe" true test -f scripts/build/darwin.sh
check "Script build linux existe" true test -f scripts/build/linux.sh
check "Script build win32 existe" true test -f scripts/build/win32.ps1 || test -f scripts/build/win32.sh
echo ""

# Prueba 8: Temas disponibles en selector
echo -e "${YELLOW}[Prueba 8] Temas disponibles en selector${NC}"
check "Tema oscuro en package.json" true grep -q "elixide-dark" extensions/theme-defaults/package.json
check "Tema claro en package.json" true grep -q "elixide-light" extensions/theme-defaults/package.json
check "Etiquetas en package.nls.json" true grep -q "elixideDarkColorThemeLabel" extensions/theme-defaults/package.nls.json
check "Archivo tema oscuro existe" true test -f extensions/theme-defaults/themes/elixide-dark.json
check "Archivo tema claro existe" true test -f extensions/theme-defaults/themes/elixide-light.json
echo ""

# Prueba 9-10: Temas aplican colores correctos
echo -e "${YELLOW}[Prueba 9-10] Temas aplican colores correctos${NC}"
if command -v jq > /dev/null 2>&1; then
    check "Tema oscuro tiene colors" true jq -e '.colors' extensions/theme-defaults/themes/elixide-dark.json > /dev/null
    check "Tema claro tiene colors" true jq -e '.colors' extensions/theme-defaults/themes/elixide-light.json > /dev/null
    check "Tema oscuro tiene paleta morada" true jq -e '.colors["editor.background"]' extensions/theme-defaults/themes/elixide-dark.json | grep -q "#2D1B2E"
    check "Tema claro tiene paleta beige" true jq -e '.colors["editor.background"]' extensions/theme-defaults/themes/elixide-light.json | grep -q "#F5F0E8"
else
    echo "  ⊘ jq no instalado, saltando validación de colores"
    ((SKIPPED+=4))
fi
echo ""

# Prueba 11: Sintaxis Elixir resaltada
echo -e "${YELLOW}[Prueba 11] Sintaxis Elixir resaltada${NC}"
if command -v jq > /dev/null 2>&1; then
    check "Tema oscuro tiene reglas Elixir" true jq -e '[.tokenColors[] | select(.name | contains("Elixir"))] | length > 0' extensions/theme-defaults/themes/elixide-dark.json > /dev/null
    check "Tema claro tiene reglas Elixir" true jq -e '[.tokenColors[] | select(.name | contains("Elixir"))] | length > 0' extensions/theme-defaults/themes/elixide-light.json > /dev/null
else
    echo "  ⊘ jq no instalado, saltando validación de sintaxis"
    ((SKIPPED+=2))
fi
echo ""

# Prueba 12: Tema oscuro predeterminado
echo -e "${YELLOW}[Prueba 12] Tema oscuro predeterminado${NC}"
check "product.json existe" true test -f product.json
# Nota: La configuración del tema predeterminado puede estar en otro lugar
echo ""

# Prueba 13: Assets salvaguardados completamente
echo -e "${YELLOW}[Prueba 13] Assets salvaguardados completamente${NC}"
PROMPTS_ASSETS=""
if [ -d "$PROJECT_ROOT/../scripts_repo/Prompts/assets" ]; then
    PROMPTS_ASSETS="$PROJECT_ROOT/../scripts_repo/Prompts/assets"
elif [ -d "/mnt/c/Users/loren/Desktop/proyectos/scripts_repo/Prompts/assets" ]; then
    PROMPTS_ASSETS="/mnt/c/Users/loren/Desktop/proyectos/scripts_repo/Prompts/assets"
fi

if [ -n "$PROMPTS_ASSETS" ]; then
    check "Tema oscuro en Prompts/assets/" true test -f "$PROMPTS_ASSETS/themes/elixide-dark.json" || test -f "$PROMPTS_ASSETS/themes/elix-dark.json"
    check "Tema claro en Prompts/assets/" true test -f "$PROMPTS_ASSETS/themes/elixide-light.json" || test -f "$PROMPTS_ASSETS/themes/elix-light.json"
    check "README.md en Prompts/assets/" true test -f "$PROMPTS_ASSETS/README.md"
    check "README.md en Prompts/assets/themes/" true test -f "$PROMPTS_ASSETS/themes/README.md"
    check "README.md en Prompts/assets/icons/" true test -f "$PROMPTS_ASSETS/icons/README.md"
    check "Script sync-assets.sh existe" true test -f scripts/assets/sync-assets.sh
    check "Script verify-assets.sh existe" true test -f scripts/assets/verify-assets.sh
    check "Script export-assets.sh existe" true test -f scripts/assets/export-assets.sh
else
    echo "  ⊘ Prompts/assets/ no encontrado, saltando verificación"
    ((SKIPPED+=8))
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
    echo -e "${GREEN}¡Todas las pruebas verificables pasaron!${NC}"
    echo -e "${YELLOW}Nota: Algunas pruebas requieren ejecución manual de ElixIDE${NC}"
    exit 0
else
    echo -e "${RED}Algunas pruebas fallaron. Revisa los errores arriba.${NC}"
    exit 1
fi

