#!/bin/bash
# v0-complete-check.sh - Verificación completa de implementación de v0.md
# Especificación: v0.md sección 16 (Autochequeo)

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Contadores
PASSED=0
FAILED=0
WARNINGS=0

# Función para verificar
check() {
    local name="$1"
    local command="$2"
    local required="${3:-true}"
    
    echo -n "  Verificando $name... "
    
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        if [ "$required" = "true" ]; then
            echo -e "${RED}✗${NC}"
            FAILED=$((FAILED + 1))
            return 1
        else
            echo -e "${YELLOW}⚠${NC}"
            WARNINGS=$((WARNINGS + 1))
            return 0
        fi
    fi
}

# Función para verificar archivo
check_file() {
    local name="$1"
    local file="$2"
    local required="${3:-true}"
    
    check "$name" "[ -f \"$file\" ]" "$required"
}

# Función para verificar directorio
check_dir() {
    local name="$1"
    local dir="$2"
    local required="${3:-true}"
    
    if [ -d "$dir" ]; then
        echo -e "  Verificando $name... ${GREEN}✓${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        if [ "$required" = "true" ]; then
            echo -e "  Verificando $name... ${RED}✗${NC}"
            FAILED=$((FAILED + 1))
            return 1
        else
            echo -e "  Verificando $name... ${YELLOW}⚠${NC}"
            WARNINGS=$((WARNINGS + 1))
            return 0
        fi
    fi
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Verificación Completa de v0.md${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${YELLOW}[1/10] Estructura de Directorios${NC}"
check_dir "modules/" "$PROJECT_ROOT/modules"
check_dir "assets/" "assets"
check_dir "assets/themes/" "assets/themes"
check_dir "assets/icons/" "assets/icons"
check_dir "patches/" "patches"
check_dir "scripts/" "scripts"
check_dir "scripts/assets/" "scripts/assets"
check_dir "scripts/build/" "scripts/build"
check_dir "docs/" "docs"
check_dir "docs/architecture/" "docs/architecture"
check_dir "src/" "src"
echo ""

echo -e "${YELLOW}[2/10] Archivos de Configuración${NC}"
check_file ".nvmrc" ".nvmrc"
check_file ".python-version" ".python-version"
check_file "package.json" "package.json"
check_file "product.json" "product.json"
check_file "tsconfig.json" "tsconfig.json"
echo ""

echo -e "${YELLOW}[3/10] Parches${NC}"
check_file "vscode-identity.patch" "patches/vscode-identity.patch"
check_file "vscode-actionbar-top.patch" "patches/vscode-actionbar-top.patch"
echo ""

echo -e "${YELLOW}[4/10] Scripts de Assets${NC}"
check_file "sync-assets.sh" "scripts/assets/sync-assets.sh"
check_file "verify-assets.sh" "scripts/assets/verify-assets.sh"
check_file "export-assets.sh" "scripts/assets/export-assets.sh"
check "Scripts ejecutables" "[ -x \"scripts/assets/sync-assets.sh\" ] && [ -x \"scripts/assets/verify-assets.sh\" ] && [ -x \"scripts/assets/export-assets.sh\" ]"
echo ""

echo -e "${YELLOW}[5/10] Temas ElixIDE${NC}"
check_file "elixide-dark.json (assets)" "assets/themes/elixide-dark.json"
check_file "elixide-light.json (assets)" "assets/themes/elixide-light.json"
check_file "elixide-dark.json (extensions)" "extensions/theme-defaults/themes/elixide-dark.json"
check_file "elixide-light.json (extensions)" "extensions/theme-defaults/themes/elixide-light.json"
check "Temas registrados en package.json" "grep -q 'elixide-dark' extensions/theme-defaults/package.json && grep -q 'elixide-light' extensions/theme-defaults/package.json"
check "Etiquetas en package.nls.json" "grep -q 'elixideDarkColorThemeLabel' extensions/theme-defaults/package.nls.json && grep -q 'elixideLightColorThemeLabel' extensions/theme-defaults/package.nls.json"
echo ""

echo -e "${YELLOW}[6/10] Modificaciones de Activity Bar${NC}"
check "Activity bar oculta (CSS)" "grep -q 'display: none' src/vs/workbench/browser/parts/activitybar/media/activitybarpart.css"
check "Activity bar en titlebar (CSS)" "grep -q 'titlebar-activity-bar' src/vs/workbench/browser/parts/titlebar/media/titlebarpart.css"
check "Activity bar oculta (TypeScript)" "grep -q 'minimumWidth.*0' src/vs/workbench/browser/parts/activitybar/activitybarPart.ts"
check "Activity bar en titlebar (TypeScript)" "grep -q 'titlebarActivityBar' src/vs/workbench/browser/parts/titlebar/titlebarPart.ts"
echo ""

echo -e "${YELLOW}[7/10] Product.json Branding${NC}"
check "nameShort = ElixIDE" "grep -q '\"nameShort\": \"ElixIDE\"' product.json"
check "nameLong contiene ElixIDE" "grep -q 'ElixIDE' product.json"
check "applicationName = elixide" "grep -q '\"applicationName\": \"elixide\"' product.json"
echo ""

echo -e "${YELLOW}[8/10] Sistema de Bootstrap${NC}"
check_file "bootstrap.ts" "src/bootstrap.ts"
check_file "extension.ts" "src/extension.ts"
check "Bootstrap carga módulos" "grep -q 'loadModules' src/bootstrap.ts"
echo ""

echo -e "${YELLOW}[9/10] Documentación${NC}"
check_file "actionbar-relocation.md" "docs/architecture/actionbar-relocation.md"
check_file "README.md (architecture)" "docs/architecture/README.md"
check_file "setup.md" "docs/development/setup.md"
echo ""

echo -e "${YELLOW}[10/10] Compilación${NC}"
if command -v npm >/dev/null 2>&1; then
    echo "  Compilando proyecto..."
    if npm run compile > /tmp/elixide-compile.log 2>&1; then
        echo -e "  ${GREEN}✓ Compilación exitosa${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "  ${RED}✗ Errores de compilación (ver /tmp/elixide-compile.log)${NC}"
        FAILED=$((FAILED + 1))
    fi
else
    echo -e "  ${YELLOW}⚠ npm no disponible, saltando compilación${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Resumen${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Pasados: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}✗ Fallados: $FAILED${NC}"
fi
if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠ Advertencias: $WARNINGS${NC}"
fi
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ v0.md COMPLETADO AL 100%${NC}"
    echo -e "${GREEN}========================================${NC}"
    exit 0
else
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}✗ v0.md INCOMPLETO ($FAILED error(es))${NC}"
    echo -e "${RED}========================================${NC}"
    exit 1
fi

