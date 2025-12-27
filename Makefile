# Makefile para ElixIDE
# Comandos principales del proyecto

.PHONY: help setup compile start test clean

help:
	@echo "Comandos disponibles:"
	@echo "  make setup     - Configurar entorno de desarrollo"
	@echo "  make compile   - Compilar el proyecto"
	@echo "  make start     - Ejecutar ElixIDE"
	@echo "  make test      - Ejecutar tests"
	@echo "  make clean     - Limpiar archivos generados"

setup:
	@echo "Configurando entorno..."
	@./setup-yarn.sh || .\setup-yarn.ps1

compile:
	@echo "Compilando proyecto..."
	@npm run compile || yarn compile

start:
	@echo "Iniciando ElixIDE..."
	@npm run start || yarn start

test:
	@echo "Ejecutando tests..."
	@npm run test || yarn test

clean:
	@echo "Limpiando archivos generados..."
	@npm run clean || yarn clean

