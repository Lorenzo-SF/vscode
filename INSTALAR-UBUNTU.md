# Instrucciones para Instalar Ubuntu en WSL2

## Pasos Manuales (Primera Vez)

1. **Instalar Ubuntu desde PowerShell (como administrador):**
   ```powershell
   wsl --install -d Ubuntu-22.04
   ```

2. **Cuando Ubuntu se abra por primera vez**, te pedirá crear un usuario:
   - **Username**: `merendandum`
   - **Password**: `0000` (escribirás dos veces)
   - Presiona Enter después de cada entrada

3. **Después de crear el usuario**, cierra Ubuntu.

4. **Verificar instalación:**
   ```powershell
   wsl -l -v
   ```
   Debe mostrar Ubuntu-22.04 con estado "Running" o "Stopped"

## Alternativa: Si ya tienes Ubuntu instalado con otro usuario

Si Ubuntu ya está instalado pero con otro usuario, puedes:

1. **Abrir Ubuntu como root:**
   ```powershell
   wsl -d Ubuntu-22.04 -u root
   ```

2. **Dentro de Ubuntu, ejecutar:**
   ```bash
   # Copiar el script de configuración
   cp /mnt/c/Users/loren/Desktop/proyectos/ElixIDE/setup-ubuntu-user.sh /tmp/
   chmod +x /tmp/setup-ubuntu-user.sh
   
   # Ejecutar como root
   /tmp/setup-ubuntu-user.sh
   ```

3. **O crear el usuario manualmente:**
   ```bash
   useradd -m -s /bin/bash merendandum
   echo "merendandum:0000" | chpasswd
   usermod -aG sudo merendandum
   ```

## Después de la Instalación

Una vez que Ubuntu esté instalado con el usuario `merendandum`, ejecuta:

```powershell
.\setup-yarn.ps1
```

Este script continuará con la configuración del entorno de desarrollo.

