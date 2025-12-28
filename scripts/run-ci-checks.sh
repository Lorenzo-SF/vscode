#!/bin/bash
set -e

echo "=== ElixIDE: Checks de CI/CD ==="

# Cargar NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

cd ~/proyectos/ElixIDE
nvm use 22.21.1

# Verificar que el proyecto está compilado
if [ ! -d "out" ] || [ -z "$(ls -A out 2>/dev/null)" ]; then
    echo "ERROR: El proyecto no está compilado. Ejecuta primero: ./scripts/setup-and-compile.sh"
    exit 1
fi

echo ""
echo "=== Ejecutando checks de CI/CD ==="

# Lista de checks a ejecutar
CHECKS=(
    "compile-check-ts-native"
    "hygiene"
    "eslint"
    "stylelint"
    "valid-layers-check"
    "define-class-fields-check"
    "vscode-dts-compile-check"
    "tsec-compile-check"
    "core-ci"
    "extensions-ci"
)

FAILED_CHECKS=()
PASSED_CHECKS=()

for check in "${CHECKS[@]}"; do
    echo ""
    echo "--- Ejecutando: npm run $check ---"
    if npm run "$check" 2>&1 | tee "/tmp/ci-check-${check}.log"; then
        echo "✅ $check: PASSED"
        PASSED_CHECKS+=("$check")
    else
        echo "❌ $check: FAILED"
        FAILED_CHECKS+=("$check")
    fi
done

echo ""
echo "=== Resumen de Checks ==="
echo "✅ Pasados: ${#PASSED_CHECKS[@]}"
echo "❌ Fallidos: ${#FAILED_CHECKS[@]}"

if [ ${#FAILED_CHECKS[@]} -gt 0 ]; then
    echo ""
    echo "Checks fallidos:"
    for check in "${FAILED_CHECKS[@]}"; do
        echo "  - $check (ver /tmp/ci-check-${check}.log)"
    done
    exit 1
else
    echo ""
    echo "🎉 Todos los checks pasaron!"
    exit 0
fi

