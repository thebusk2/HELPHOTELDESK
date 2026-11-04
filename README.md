# 🏨 HELPHOTELDESK - Mesa de Ayuda e Inventario TI para Hoteles

<p align="center">
  <img src="assets/icon.svg" width="120" height="120" alt="HELPHOTELDESK Logo">
  <br>
  <b>Sistema de Mesa de Ayuda (Ticketing), Inventario de Activos (ITAM) y Generación de Reportes para el Departamento de TI en Hotelería</b>
  <br>
  <i>Optimizado para Servidor Local sobre Windows 10 en Hyper-V</i>
</p>

---

## 🌟 Características Principales

- **Gestión Hotelera Especializada:** Plantillas de departamentos y criticidades predefinidas (Sistemas PMS Opera/Sihot, Terminales de Pago POS, Cerraduras de Tarjetas RFID, Wi-Fi Huéspedes y Telefonía PBX).
- **Control de Activos e Inventario (ITAM):** Rastreo de computadoras, switches de piso, impresoras de comandas y garantías.
- **Módulo de Reportes & Estadísticas:** Métricas de cumplimiento de SLA, tiempo de respuesta (MTTR), incidencias por piso/área y exportación a PDF, Excel o Power BI.
- **Instalador Gráfico Todo en Uno (`HELPHOTELDESK.exe`):** Script compilador en C# nativo para generar el ejecutable con icono en 3 segundos sin software adicional.
- **Panel de Control y Personalización:** Interfaz gráfica para configurar nombre del hotel, pisos, habitaciones y realizar copias de seguridad de la base de datos con un solo clic.

---

## 📁 Estructura del Repositorio

```text
HELPHOTELDESK/
├── assets/
│   ├── app.ico                   # Icono de la aplicación de escritorio
│   └── icon.svg                  # Icono vectorial oficial
├── scripts/
│   ├── Setup-HyperV-VM.ps1       # Creación de la Máquina Virtual en Hyper-V (Host)
│   ├── Compilar-EXE.bat          # Compilador con 1 clic (usa csc.exe nativo de Windows)
│   ├── Build-EXE.ps1             # Compilador en PowerShell
│   ├── HotelDeskSetup.cs         # Código fuente en C# del instalador todo en uno
│   ├── Install-GLPI-Windows.ps1  # Instalador automatizado del servidor web, PHP 8.2 y GLPI
│   └── HotelDesk-Manager.ps1     # Panel de gestión y personalización del hotel
├── config/
│   └── hotel_departments.json    # Matriz de áreas, prioridades y SLAs hoteleros
├── docs/
│   ├── GUIA_DESPLIEGUE.md        # Instructivo paso a paso detallado
│   ├── COMPILACION_EXE.md        # Guía técnica del instalador .exe
│   └── REPORTES_Y_ESTADISTICAS.md# Manual del módulo de reportes y BI
└── README.md
```

---

## 🚀 Guía Rápida de Instalación Paso a Paso

### 1. En el Servidor Host (Hyper-V)
Abre PowerShell como Administrador y aprovisiona la máquina virtual:
```powershell
cd scripts
.\Setup-HyperV-VM.ps1 -VMName "HELPHOTELDESK-VM" -MemoryStartupBytes 4GB -CPUCount 2
```
> **Nota de red:** Asigna a la VM un conmutador virtual de tipo **Externo** para que obtenga una dirección IP dentro de la red del hotel y todos los puestos de trabajo puedan conectarse.

---

### 2. En la Máquina Virtual (Windows 10)

#### Opción A: Usando el Instalador Gráfico `.EXE` (Recomendado)
1. Entra a la carpeta `scripts/`.
2. Haz doble clic en `Compilar-EXE.bat` (creará de inmediato `HELPHOTELDESK.exe` con su icono en la raíz).
3. Abre **`HELPHOTELDESK.exe`**.
4. Escribe el nombre de tu hotel y presiona **"Iniciar Instalación Completa"**.

#### Opción B: Mediante PowerShell
Abre PowerShell como Administrador y ejecuta:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
.\scripts\Install-GLPI-Windows.ps1
```

---

### 3. Asistente Web Inicial (2 minutos)
1. Abre el navegador en: `http://localhost/glpi`
2. Selecciona **Español** -> **Instalar**.
3. Servidor de Base de Datos: `localhost` | Usuario: `root` | Contraseña: *(vacía)*.
4. Selecciona **Crear nueva base de datos** -> `glpi`.
5. Inicia sesión:
   - **Administrador:** `glpi` / `glpi`
   - **Técnico:** `tech` / `tech`
   *(Cambia las contraseñas al ingresar)*.

---

### 4. Panel de Gestión y Respaldo
Ejecuta el panel administrativo en cualquier momento desde la VM:
```powershell
powershell -WindowStyle Hidden -File .\scripts\HotelDesk-Manager.ps1
```
Permite monitorear Apache/MySQL, cambiar la identidad del hotel y hacer copias de seguridad de la base de datos con un clic en `C:\HotelDesk\Backups`.

---

## 📄 Licencia
Este proyecto recopila y automatiza herramientas de código abierto bajo licencia **GPL v3** y scripts de utilidad pública para administración de sistemas en entornos hoteleros.
