#!/bin/bash
# verify-integrity.sh - Verifica integridad completa del proyecto
# Especificación: v0.md sección 6.3

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

PASSED=0
FAILED=0
WARNINGS=0

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
            echo -e "${YELLOW}⚠${NC}"
            ((WARNINGS++))
            return 0
        fi
    fi
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Verificación de Integridad del Proyecto${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 1. Estructura de directorios
echo -e "${YELLOW}[1/6] Estructura de directorios${NC}"
check "Directorio modules/ existe" true test -d modules
check "Directorio assets/ existe" true test -d assets
check "Directorio patches/ existe" true test -d patches
check "Directorio scripts/ existe" true test -d scripts
check "Directorio docs/ existe" true test -d docs
echo ""

# 2. Archivos de configuración
echo -e "${YELLOW}[2/6] Archivos de configuración${NC}"
check "package.json existe" true test -f package.json
check "product.json existe" true test -f product.json
check ".nvmrc existe" true test -f .nvmrc
check ".python-version existe" true test -f .python-version
check "tsconfig.json existe" true test -f tsconfig.json
echo ""

# 3. Parches
echo -e "${YELLOW}[3/6] Parches${NC}"
check "Parche vscode-identity.patch existe" true test -f patches/vscode-identity.patch
check "Parche vscode-actionbar-top.patch existe" true test -f patches/vscode-actionbar-top.patch
echo ""

# 4. Assets
echo -e "${YELLOW}[4/6] Assets${NC}"
check "Tema oscuro en assets/" true test -f assets/themes/elixide-dark.json || test -f assets/themes/elix-dark.json
check "Tema claro en assets/" true test -f assets/themes/elixide-light.json || test -f assets/themes/elix-light.json
check "Tema oscuro en submódulo" true test -f extensions/theme-defaults/themes/elixide-dark.json
check "Tema claro en submódulo" true test -f extensions/theme-defaults/themes/elixide-light.json
echo ""

# 5. Código fuente
echo -e "${YELLOW}[5/6] Código fuente${NC}"
check "bootstrap.ts existe" true test -f src/bootstrap.ts
check "extension.ts existe" true test -f src/extension.ts
check "Sistema de logging existe" true test -f src/utils/logger.ts
check "Sistema de telemetría existe" true test -f src/utils/telemetry.ts
check "Manejo de errores existe" true test -f src/utils/errorHandler.ts
echo ""

# 6. Scripts
echo -e "${YELLOW}[6/6] Scripts${NC}"
check "Script sync-assets.sh existe" true test -f scripts/assets/sync-assets.sh
check "Script verify-assets.sh existe" true test -f scripts/assets/verify-assets.sh
check "Script export-assets.sh existe" true test -f scripts/assets/export-assets.sh
check "Script recover-submodule.sh existe" true test -f scripts/recovery/recover-submodule.sh
check "Script recover-assets.sh existe" true test -f scripts/recovery/recover-assets.sh
check "Script recover-build.sh existe" true test -f scripts/recovery/recover-build.sh
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

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}¡Integridad del proyecto verificada!${NC}"
    exit 0
else
    echo -e "${RED}Se encontraron problemas de integridad. Revisa los errores arriba.${NC}"
    exit 1
fi

