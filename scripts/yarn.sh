#!/bin/bash
# ElixIDE: Wrapper para yarn que carga el entorno

cd ~/proyectos/ElixIDE
source scripts/init-env.sh

# Ejecutar yarn con los argumentos pasados
yarn "$@"

