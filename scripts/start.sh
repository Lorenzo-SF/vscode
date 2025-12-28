#!/bin/bash
# ElixIDE: Script para iniciar ElixIDE
# Este script carga el entorno y ejecuta ElixIDE

cd ~/proyectos/ElixIDE

# Cargar entorno
source scripts/init-env.sh

# Verificar que las dependencias están instaladas
if [ ! -d "node_modules" ] || [ -z "$(ls -A node_modules 2>/dev/null)" ]; then
    echo "⚠️  Las dependencias no están instaladas."
    echo "Instalando dependencias (esto puede tardar varios minutos)..."
    yarn install
fi

# Verificar que el proyecto está compilado
if [ ! -d "out" ] || [ -z "$(ls -A out 2>/dev/null)" ]; then
    echo "⚠️  El proyecto no está compilado."
    echo "Ejecutando compilación..."
    yarn compile
fi

# Iniciar ElixIDE usando el script code.sh
echo "🚀 Iniciando ElixIDE..."
./scripts/code.sh

