#!/bin/bash
# ElixIDE: Script para mergear feature branch a develop
# Uso: ./scripts/git/merge-feature.sh v{N} "descripcion"
# Ejemplo: ./scripts/git/merge-feature.sh v0 "base-ui-modifications"
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

echo "Mergeando feature branch: $BRANCH a develop"

# Asegurarse de estar en develop y actualizado
git checkout develop
git pull origin develop

# Mergear feature branch con --no-ff para preservar historial
git merge --no-ff "$BRANCH"

# Push a develop
git push origin develop

echo "Feature $BRANCH merged to develop."

