# 🚀 Cómo generar y usar HotelDeskSetup.exe

El instalador unificado ha sido diseñado en C# nativo (`HotelDeskSetup.cs`) para aprovechar el compilador incorporado de Windows (`csc.exe`), lo que significa que **no necesitas instalar Visual Studio ni herramientas pesadas** para compilarlo o usarlo.

---

## ⚡ Paso 1: Generar el archivo `.exe` con 1 solo clic

1. Copia la carpeta `HELPHOTELDESK` a tu máquina con Windows (o dentro de la VM con Windows 10).
2. Entra a la carpeta `scripts/`.
3. Haz doble clic en:
   👉 **`Compilar-EXE.bat`** (o ejecuta `Build-EXE.ps1` en PowerShell).
4. El script compilará el código en menos de 3 segundos y dejará el archivo listo en la raíz:
   📁 `HELPHOTELDESK/HotelDeskSetup.exe`

---

## 🖥️ Paso 2: Ejecutar `HotelDeskSetup.exe`

Al abrir **`HotelDeskSetup.exe`** en Windows 10, verás una interfaz gráfica que realiza todo el proceso:

1. **Panel de Identidad:**
   - Permite escribir el **Nombre del Hotel** (ej. *Gran Hotel Resort*) y el **Correo de TI / Mesa de Ayuda**.
2. **Botón "Iniciar Instalación Completa":**
   - Configura las reglas del Firewall de Windows para HTTP/HTTPS.
   - Instala de manera desatendida el stack web (Apache + MariaDB + PHP 8.2).
   - Descarga e instala GLPI v10 con soporte completo de tickets e inventario de hardware.
   - Habilita las extensiones PHP necesarias (`ldap`, `intl`, `mysqli`, `gd`, `zip`).
   - Inicia los servicios locales automáticamente.
3. **Botón "Abrir Mesa de Ayuda":**
   - Se activa al terminar y te lleva directo a `http://localhost/glpi` para comenzar a atender los tickets del hotel.
