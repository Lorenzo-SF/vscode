#!/bin/bash
# v0-validations-checklist.sh - Checklist completo de validaciones obligatorias según v0.md sección 15.9

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

check() {
    local name="$1"
    local required="${2:-true}"
    shift 2
    
    echo -n "  [ ] $name... "
    
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
            echo -e "${YELLOW}⚠${NC} (opcional)"
            ((WARNINGS++))
            return 0
        fi
    fi
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Validaciones Obligatorias v0.md${NC}"
echo -e "${CYAN}Sección 15.9${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 1. Fork de VSCode configurado
echo -e "${YELLOW}[1] Fork de VSCode configurado${NC}"
check "Repositorio Git inicializado" true test -d .git
check "Submódulo vscode-original existe" true test -d vscode-original || test -d src/vscode-original
check "Archivo .gitmodules existe" true test -f .gitmodules
echo ""

# 2. Estructura de directorios creada
echo -e "${YELLOW}[2] Estructura de directorios creada${NC}"
check "Directorio modules/ existe" true test -d modules
check "Directorio assets/ existe" true test -d assets
check "Directorio patches/ existe" true test -d patches
check "Directorio scripts/ existe" true test -d scripts
check "Directorio docs/ existe" true test -d docs
check "Directorio assets/themes/ existe" true test -d assets/themes
check "Directorio assets/icons/ existe" true test -d assets/icons
check "Directorio scripts/assets/ existe" true test -d scripts/assets
check "Directorio scripts/recovery/ existe" true test -d scripts/recovery
echo ""

# 3. Parche vscode-actionbar-top.patch aplicado correctamente
echo -e "${YELLOW}[3] Parche vscode-actionbar-top.patch aplicado correctamente${NC}"
check "Parche vscode-actionbar-top.patch existe" true test -f patches/vscode-actionbar-top.patch
check "titlebarPart.ts tiene createTitlebarActivityBar" true grep -q "createTitlebarActivityBar" src/vs/workbench/browser/parts/titlebar/titlebarPart.ts
check "CSS tiene estilos para titlebar-activity-bar" true grep -q "titlebar-activity-bar" src/vs/workbench/browser/parts/titlebar/media/titlebarpart.css
check "Activity bar oculta en sidebar (CSS)" true grep -q "\.activitybar.*display.*none" src/vs/workbench/browser/parts/activitybar/media/activitybarpart.css
echo ""

# 4. Action bar visible en titlebar, ocupa 100% ancho
echo -e "${YELLOW}[4] Action bar visible en titlebar, ocupa 100% ancho${NC}"
check "CSS tiene flex-grow: 1 en titlebar-center" true grep -q "flex-grow.*1" src/vs/workbench/browser/parts/titlebar/media/titlebarpart.css
check "CSS tiene width: 100% en titlebar-activity-bar" true grep -q "width.*100%" src/vs/workbench/browser/parts/titlebar/media/titlebarpart.css
check "Título de ventana oculto" true grep -q "window-title.*display.*none" src/vs/workbench/browser/parts/titlebar/media/titlebarpart.css
echo ""

# 5. Controles de ventana integrados correctamente
echo -e "${YELLOW}[5] Controles de ventana integrados correctamente${NC}"
check "Window controls container existe en código" true grep -q "windowControlsContainer" src/vs/workbench/browser/parts/titlebar/titlebarPart.ts
check "CSS para window-controls-container existe" true grep -q "window-controls-container" src/vs/workbench/browser/parts/titlebar/media/titlebarpart.css
echo ""

# 6. Sidebar sin action bar (oculta)
echo -e "${YELLOW}[6] Sidebar sin action bar (oculta)${NC}"
check "ActivitybarPart tiene width 0" true grep -q "maximumWidth.*0" src/vs/workbench/browser/parts/activitybar/activitybarPart.ts
check "Activity bar oculta en CSS" true grep -q "\.activitybar.*display.*none" src/vs/workbench/browser/parts/activitybar/media/activitybarpart.css
echo ""

# 7. Temas creados y registrados
echo -e "${YELLOW}[7] Temas creados y registrados${NC}"
check "Tema oscuro en assets/themes/" true test -f assets/themes/elixide-dark.json || test -f assets/themes/elix-dark.json
check "Tema claro en assets/themes/" true test -f assets/themes/elixide-light.json || test -f assets/themes/elix-light.json
check "Tema oscuro en extensions/theme-defaults/themes/" true test -f extensions/theme-defaults/themes/elixide-dark.json
check "Tema claro en extensions/theme-defaults/themes/" true test -f extensions/theme-defaults/themes/elixide-light.json
check "Temas registrados en package.json" true grep -q "elixide-dark" extensions/theme-defaults/package.json
check "Etiquetas en package.nls.json" true grep -q "elixideDarkColorThemeLabel" extensions/theme-defaults/package.nls.json
echo ""

# 8. Temas aparecen en selector
echo -e "${YELLOW}[8] Temas aparecen en selector${NC}"
check "Temas tienen estructura correcta (JSON válido)" true command -v jq > /dev/null && (jq empty extensions/theme-defaults/themes/elixide-dark.json 2>/dev/null && jq empty extensions/theme-defaults/themes/elixide-light.json 2>/dev/null) || echo "jq no disponible"
echo ""

# 9. Temas aplican colores correctos
echo -e "${YELLOW}[9] Temas aplican colores correctos${NC}"
if command -v jq > /dev/null 2>&1; then
    check "Tema oscuro tiene colors" true jq -e '.colors' extensions/theme-defaults/themes/elixide-dark.json > /dev/null
    check "Tema claro tiene colors" true jq -e '.colors' extensions/theme-defaults/themes/elixide-light.json > /dev/null
else
    echo "  ⊘ jq no instalado, saltando validación de colores"
    ((WARNINGS++))
fi
echo ""

# 10. Sintaxis Elixir resaltada
echo -e "${YELLOW}[10] Sintaxis Elixir resaltada${NC}"
if command -v jq > /dev/null 2>&1; then
    check "Tema oscuro tiene reglas Elixir" true jq -e '[.tokenColors[] | select(.name | contains("Elixir"))] | length > 0' extensions/theme-defaults/themes/elixide-dark.json > /dev/null
    check "Tema claro tiene reglas Elixir" true jq -e '[.tokenColors[] | select(.name | contains("Elixir"))] | length > 0' extensions/theme-defaults/themes/elixide-light.json > /dev/null
else
    echo "  ⊘ jq no instalado, saltando validación de sintaxis"
    ((WARNINGS++))
fi
echo ""

# 11. Assets sincronizados desde Prompts/assets/
echo -e "${YELLOW}[11] Assets sincronizados desde Prompts/assets/${NC}"
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
else
    echo "  ⊘ Prompts/assets/ no encontrado"
    ((WARNINGS++))
fi
echo ""

# 12. Scripts de sincronización funcionan
echo -e "${YELLOW}[12] Scripts de sincronización funcionan${NC}"
check "Script sync-assets.sh existe" true test -f scripts/assets/sync-assets.sh
check "Script verify-assets.sh existe" true test -f scripts/assets/verify-assets.sh
check "Script export-assets.sh existe" true test -f scripts/assets/export-assets.sh
echo ""

# 13. Parche vscode-identity.patch aplicado
echo -e "${YELLOW}[13] Parche vscode-identity.patch aplicado${NC}"
check "Parche vscode-identity.patch existe" true test -f patches/vscode-identity.patch
echo ""

# 14. Product.json modificado
echo -e "${YELLOW}[14] Product.json modificado${NC}"
check "product.json existe" true test -f product.json
check "product.json tiene nameShort ElixIDE" true grep -q '"nameShort".*"ElixIDE"' product.json
check "product.json tiene nameLong ElixIDE" true grep -q '"nameLong".*"ElixIDE"' product.json
echo ""

# 15. Proyecto compila sin errores
echo -e "${YELLOW}[15] Proyecto compila sin errores${NC}"
echo "  ⊘ Esta validación requiere ejecutar 'npm run compile' manualmente"
echo "  Instrucciones: cd $PROJECT_ROOT && npm run compile"
((WARNINGS++))
echo ""

# 16. ElixIDE ejecuta correctamente
echo -e "${YELLOW}[16] ElixIDE ejecuta correctamente${NC}"
echo "  ⊘ Esta validación requiere ejecutar 'npm run elixide:start' manualmente"
echo "  Instrucciones: cd $PROJECT_ROOT && npm run elixide:start"
((WARNINGS++))
echo ""

# 17. Funciona en 3 plataformas
echo -e "${YELLOW}[17] Funciona en 3 plataformas${NC}"
check "Script build darwin existe" true test -f scripts/build/darwin.sh
check "Script build linux existe" true test -f scripts/build/linux.sh
check "Script build win32 existe" true test -f scripts/build/win32.ps1 || test -f scripts/build/win32.sh
echo ""

# 18. Auditorías TypeScript/JavaScript pasan
echo -e "${YELLOW}[18] Auditorías TypeScript/JavaScript pasan${NC}"
echo "  ⊘ Esta validación requiere ejecutar 'npm run lint' manualmente"
echo "  Instrucciones: cd $PROJECT_ROOT && npm run lint"
((WARNINGS++))
echo ""

# 19. Documentación completa
echo -e "${YELLOW}[19] Documentación completa${NC}"
check "README.md principal existe" true test -f README.md
check "Documentación de accesibilidad existe" true test -f docs/accessibility/README.md
check "Documentación de i18n existe" true test -f docs/i18n/README.md
check "Documentación de atajos de teclado existe" true test -f docs/user-guide/keyboard-shortcuts.md
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
    echo -e "${YELLOW}⚠ Advertencias/Omitidos: $WARNINGS${NC}"
fi
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}¡Todas las validaciones verificables pasaron!${NC}"
    echo -e "${YELLOW}Nota: Algunas validaciones requieren ejecución manual${NC}"
    exit 0
else
    echo -e "${RED}Algunas validaciones fallaron. Revisa los errores arriba.${NC}"
    exit 1
fi

