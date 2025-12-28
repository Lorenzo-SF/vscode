#!/bin/bash
# ElixIDE: Script para iniciar ElixIDE
# Este script carga el entorno y ejecuta yarn start

cd ~/proyectos/ElixIDE

# Cargar entorno
source scripts/init-env.sh

# Verificar que el proyecto está compilado
if [ ! -d "out" ] || [ -z "$(ls -A out 2>/dev/null)" ]; then
    echo "⚠️  El proyecto no está compilado."
    echo "Ejecutando compilación..."
    yarn compile
fi

# Iniciar ElixIDE
echo "🚀 Iniciando ElixIDE..."
yarn start

