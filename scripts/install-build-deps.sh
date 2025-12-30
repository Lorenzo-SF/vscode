#!/bin/bash
# ElixIDE: Instalar dependencias del sistema para compilar modulos nativos

echo "=== Instalando dependencias del sistema para compilacion ==="

sudo apt-get update

# Herramientas de compilacion basicas
sudo apt-get install -y \
	build-essential \
	python3 \
	python3-dev \
	pkg-config

# Dependencias para modulos nativos de Node.js
sudo apt-get install -y \
	libsecret-1-dev \
	libx11-dev \
	libxkbfile-dev \
	libxss1 \
	libasound2-dev \
	libnss3-dev \
	libgtk-3-dev \
	libxrandr2 \
	libxinerama1 \
	libxcursor1 \
	libxdamage1 \
	libxi6 \
	libxtst6 \
	libxcomposite1 \
	libxext6 \
	libxfixes3 \
	libxrender1 \
	libxcb1 \
	libxkbcommon-dev \
	libgbm-dev \
	libxshmfence1 \
	libdrm2 \
	libpangocairo-1.0-0 \
	libatk1.0-0 \
	libcairo-gobject2 \
	libgtk-3-0 \
	libgdk-pixbuf2.0-0 \
	libkrb5-dev \
	krb5-multidev \
	libgssapi-krb5-2

echo ""
echo "Dependencias del sistema instaladas"
echo ""
echo "Ahora puedes ejecutar:"
echo "  source scripts/init-env.sh"
echo "  npm install"
