#!/bin/bash
# darwin.sh - Script de build para macOS
# Especificación: v0.md sección 1.4, Tarea 3

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMON_SCRIPT="$SCRIPT_DIR/common.sh"

# Cargar funciones comunes
source "$COMMON_SCRIPT"

log_info "=========================================="
log_info "Build de ElixIDE para macOS"
log_info "=========================================="
echo ""

# Verificar que estamos en macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
	log_error "Este script debe ejecutarse en macOS"
	exit 1
fi

# Verificar comandos requeridos
check_command node
check_command npm
check_command yarn

# Verificar versiones
check_node_version
check_python_version

# Cambiar al directorio del proyecto
cd "$PROJECT_ROOT"

# Aplicar parches
apply_patches "$PROJECT_ROOT/patches" "$PROJECT_ROOT"

# Sincronizar assets
sync_assets "$PROJECT_ROOT"

# Instalar dependencias
log_info "Instalando dependencias..."
npm install || {
	log_error "Error al instalar dependencias"
	exit 1
}

# Compilar
log_info "Compilando proyecto..."
npm run compile || {
	log_error "Error al compilar"
	exit 1
}

# Verificar compilación
check_compiled "$PROJECT_ROOT/out"

# Build para macOS
ARCH="${1:-arm64}"  # Por defecto ARM64, puede ser x64

log_info "Construyendo para macOS $ARCH..."

if [ "$ARCH" = "arm64" ]; then
	npm run gulp vscode-darwin-arm64-min || {
		log_error "Error al construir para macOS ARM64"
		exit 1
	}
elif [ "$ARCH" = "x64" ]; then
	npm run gulp vscode-darwin-x64-min || {
		log_error "Error al construir para macOS x64"
		exit 1
	}
else
	log_error "Arquitectura no soportada: $ARCH (usar arm64 o x64)"
	exit 1
fi

log_info "=========================================="
log_info "✓ Build completado exitosamente"
log_info "=========================================="
log_info "Bundle generado en: ../VSCode-darwin-$ARCH/"

