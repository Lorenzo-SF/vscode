#!/bin/bash
# Script para configurar usuario merendandum en Ubuntu WSL2
# Este script debe ejecutarse como root dentro de Ubuntu

if [ "$EUID" -ne 0 ]; then 
    echo "Este script debe ejecutarse como root (usa sudo)"
    exit 1
fi

USERNAME="merendandum"
PASSWORD="0000"

# Crear usuario si no existe
if id "$USERNAME" &>/dev/null; then
    echo "Usuario $USERNAME ya existe"
else
    echo "Creando usuario $USERNAME..."
    useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
    
    # Añadir a grupo sudo
    usermod -aG sudo "$USERNAME"
    
    # Configurar sudo sin contraseña (opcional, para desarrollo)
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USERNAME
    
    echo "Usuario $USERNAME creado exitosamente"
fi

# Configurar directorio home
if [ -d "/home/$USERNAME" ]; then
    chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"
fi

echo "Configuración completada"

