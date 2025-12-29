#!/bin/bash
# export-assets.sh - Script para exportar todos los assets desde Prompts/assets/
# Genera un archivo comprimido con todos los assets para backup
# Especificación: v0.md sección 1.7

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Rutas
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROMPTS_ASSETS=""

# Detectar ubicación de Prompts/assets/
if [ -d "$PROJECT_ROOT/../scripts_repo/Prompts/assets" ]; then
    PROMPTS_ASSETS="$PROJECT_ROOT/../scripts_repo/Prompts/assets"
elif [ -d "/mnt/c/Users/loren/Desktop/proyectos/scripts_repo/Prompts/assets" ]; then
    PROMPTS_ASSETS="/mnt/c/Users/loren/Desktop/proyectos/scripts_repo/Prompts/assets"
elif [ -n "$PROMPTS_ASSETS_PATH" ]; then
    PROMPTS_ASSETS="$PROMPTS_ASSETS_PATH"
else
    echo -e "${RED}ERROR: No se encontró Prompts/assets/${NC}"
    exit 1
fi

# Crear directorio temporal
TEMP_DIR=$(mktemp -d)
EXPORT_DIR="$TEMP_DIR/elixide-assets-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$EXPORT_DIR"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Exportación de Assets ElixIDE${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Origen: $PROMPTS_ASSETS"
echo "Exportando a: $EXPORT_DIR"
echo ""

# Copiar todos los assets
echo -e "${YELLOW}[1/3] Copiando assets...${NC}"
cp -r "$PROMPTS_ASSETS"/* "$EXPORT_DIR/" 2>/dev/null || {
    echo -e "${RED}Error al copiar assets${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
}
echo "  ✓ Assets copiados"

# Generar metadatos
echo -e "${YELLOW}[2/3] Generando metadatos...${NC}"
METADATA_FILE="$EXPORT_DIR/METADATA.txt"
{
    echo "ElixIDE Assets Export"
    echo "===================="
    echo ""
    echo "Fecha de exportación: $(date)"
    echo "Origen: $PROMPTS_ASSETS"
    echo ""
    echo "Contenido:"
    echo "----------"
    find "$EXPORT_DIR" -type f -not -name "METADATA.txt" -not -name "CHECKSUMS.txt" | sort
    echo ""
    echo "Estructura:"
    echo "----------"
    tree -L 3 "$EXPORT_DIR" 2>/dev/null || find "$EXPORT_DIR" -type d | sort
} > "$METADATA_FILE"
echo "  ✓ Metadatos generados"

# Generar checksums
echo -e "${YELLOW}[3/3] Generando checksums...${NC}"
CHECKSUMS_FILE="$EXPORT_DIR/CHECKSUMS.txt"
{
    echo "ElixIDE Assets Checksums"
    echo "========================"
    echo ""
    echo "Fecha: $(date)"
    echo ""
    echo "SHA256 Checksums:"
    echo "-----------------"
    find "$EXPORT_DIR" -type f -not -name "CHECKSUMS.txt" -not -name "METADATA.txt" -exec sha256sum {} \; | sort
} > "$CHECKSUMS_FILE"
echo "  ✓ Checksums generados"

# Comprimir
echo -e "${YELLOW}Comprimiendo...${NC}"
OUTPUT_FILE="$PROJECT_ROOT/elixide-assets-$(date +%Y%m%d-%H%M%S).tar.gz"
cd "$TEMP_DIR"
tar -czf "$OUTPUT_FILE" "$(basename "$EXPORT_DIR")" 2>/dev/null || {
    echo -e "${RED}Error al comprimir${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
}

# Limpiar
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Exportación completada${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Archivo generado: $OUTPUT_FILE"
echo ""
echo "Para restaurar:"
echo "  tar -xzf $OUTPUT_FILE"
echo "  cp -r elixide-assets-*/assets/* /ruta/destino/"

