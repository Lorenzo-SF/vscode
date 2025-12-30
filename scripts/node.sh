#!/bin/bash
# ElixIDE: Wrapper para node que carga el entorno

cd ~/proyectos/ElixIDE
source scripts/init-env.sh

# Ejecutar node con los argumentos pasados
node "$@"

