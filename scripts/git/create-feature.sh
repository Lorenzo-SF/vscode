#!/bin/bash
# ElixIDE: Script para crear feature branch
# Uso: ./scripts/git/create-feature.sh v{N} "descripcion"
# Ejemplo: ./scripts/git/create-feature.sh v0 "base-ui-modifications"
# Especificación: Preprompt.md sección 14.6

set -e

VERSION=$1
DESC=$2

if [ -z "$VERSION" ] || [ -z "$DESC" ]; then
	echo "Error: Uso: $0 v{N} \"descripcion\""
	echo "Ejemplo: $0 v0 \"base-ui-modifications\""
	exit 1
fi

BRANCH="feature/v${VERSION}-${DESC}"

echo "Creando feature branch: $BRANCH"

# Asegurarse de estar en develop y actualizado
git checkout develop
git pull origin develop

# Crear nueva feature branch
git checkout -b "$BRANCH"

echo "Feature branch $BRANCH created. Ready for development."
