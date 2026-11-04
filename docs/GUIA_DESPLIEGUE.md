# 🏨 Guía Maestra de Despliegue: Mesa de Ayuda Hotelera en Windows 10 (Hyper-V)

Esta solución proporciona una plataforma completa de **Mesa de Ayuda (Ticketing) + Gestión de Inventario TI (ITAM)** basada en **GLPI**, optimizada para el departamento de informática de un hotel y empaquetada para correr en una máquina virtual de **Windows 10 Pro / Enterprise sobre Hyper-V**.

---

## 🛠️ Paso 1: Crear la Máquina Virtual en el Servidor Host con Hyper-V

1. En el equipo anfitrión que tiene Hyper-V (Windows 10/11 Pro o Windows Server), abre **PowerShell como Administrador**.
2. Dirígete a la carpeta `scripts`:
   ```powershell
   cd \ruta\a\HELPHOTELDESK\scripts
   ```
3. Ejecuta el script de aprovisionamiento de la VM:
   ```powershell
   .\Setup-HyperV-VM.ps1 -VMName "HotelDesk-VM" -MemoryStartupBytes 4GB -CPUCount 2 -ISODetectionPath "C:\ISOs\Windows10.iso"
   ```
4. **Configuración de Red en Hyper-V (Muy Importante):**
   - Asegúrate de que el conmutador virtual de la VM esté en modo **Externo** (External Virtual Switch) para que la máquina virtual tenga una dirección IP real dentro de la misma red local del hotel (ej. `192.168.1.X` o `10.0.X.X`).
   - De este modo, los recepcionistas, administración y técnicos podrán abrir la mesa de ayuda desde sus propias computadoras.

---

## 💻 Paso 2: Instalación del Sistema en la VM (Windows 10)

1. Inicia la máquina virtual e instala Windows 10.
2. Copia la carpeta del proyecto a la VM (o descárgala allí).
3. Abre **PowerShell como Administrador** dentro de la máquina virtual Windows 10.
4. Ejecuta el instalador automático:
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope Process -Force
   .\Install-GLPI-Windows.ps1
   ```
5. El script realizará automáticamente:
   - Apertura de puertos en el Firewall de Windows (80 HTTP y 443 HTTPS).
   - Descarga e instalación silenciosa del entorno (Apache + PHP 8.2 + MariaDB).
   - Descarga y extracción de GLPI en `C:\xampp\htdocs\glpi`.
   - Habilitación de extensiones PHP críticas (`ldap`, `gd`, `intl`, `mysqli`, `curl`, etc.).
   - Inicio de los servicios del servidor.

---

## ⚙️ Paso 3: Asistente Web Inicial de GLPI (Solo 2 minutos)

1. En el navegador de la VM entra a: `http://localhost/glpi`
2. Selecciona **Español** -> **Instalar**.
3. En la prueba de entorno, verás que todas las extensiones requeridas están en verde. Haz clic en **Continuar**.
4. **Base de Datos:**
   - Servidor: `localhost`
   - Usuario: `root`
   - Contraseña: (déjala en blanco por defecto en XAMPP)
5. Selecciona **Crear una nueva base de datos** y escribe `glpi`.
6. Haz clic en continuar hasta finalizar.
7. **Credenciales predeterminadas para iniciar sesión:**
   - **Administrador:** `glpi` / `glpi`
   - **Técnico de informática:** `tech` / `tech`
   - **Usuario normal (Recepción/Pisos):** `normal` / `normal`
   *(Cambia estas contraseñas inmediatamente tras iniciar sesión).*

---

## 🎛️ Paso 4: Panel de Control y Personalización HotelDesk

Dentro de la VM, puedes ejecutar el panel gráfico de administración en cualquier momento:

```powershell
powershell -WindowStyle Hidden -File .\scripts\HotelDesk-Manager.ps1
```

*(O haz clic derecho en `HotelDesk-Manager.ps1` -> **Ejecutar con PowerShell**)*

### ¿Qué te permite este panel?
- **Monitoreo en tiempo real:** Muestra el estado de Apache, MySQL y la IP que deben usar los usuarios del hotel.
- **Personalización del Hotel:** Configurar el nombre del hotel/resort, mensaje de bienvenida del portal de tickets y cantidad de pisos/habitaciones.
- **Botón de Copia de Seguridad:** Genera un volcado `.sql` automático de la base de datos de tickets e inventario con un solo clic en `C:\HotelDesk\Backups`.
- **Acceso rápido al agente de inventario:** Enlace directo para descargar el agente de Windows para auditar las PCs de recepción y oficinas.

---

## 🛎️ Paso 5: Buenas Prácticas para el Hotel

1. **Catálogo de Servicios y Ubicaciones:**
   - En GLPI ve a **Administración -> Ubicaciones** y carga la estructura:
     - *Edificio A -> Piso 1 -> Recepción / Hab 101 - 120*
     - *Edificio A -> Piso 2 -> Hab 201 - 220*
     - *Área Restaurante -> Terminal POS 1, Impresora Cocina*
2. **Prioridades y SLA:**
   - Asigna **Urgente / Alta** a categorías que detengan la operación del huésped (caída del PMS, falla en cerraduras de habitación o terminales de pago).
