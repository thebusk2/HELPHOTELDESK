@echo off
title HELPHOTELDESK - Compilador de Instalador EXE
color 0b
echo ==========================================================
echo    COMPILANDO HELPHOTELDESK.EXE CON ICONO NATIVO
echo ==========================================================
echo.

set CSC=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe
if not exist "%CSC%" (
    set CSC=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe
)

if not exist "%CSC%" (
    echo [ERROR] No se encontro el compilador .NET (csc.exe).
    echo Asegurate de ejecutar esto en Windows 10 con .NET Framework.
    pause
    exit /b 1
)

echo Usando compilador: %CSC%
echo Compilando codigo C# a HELPHOTELDESK.exe...
echo.

set ICON_PARAM=
if exist "%~dp0..\assets\app.ico" (
    set ICON_PARAM=/win32icon:"%~dp0..\assets\app.ico"
)

"%CSC%" /target:winexe /platform:anycpu %ICON_PARAM% /out:"%~dp0..\HELPHOTELDESK.exe" "%~dp0HotelDeskSetup.cs" /reference:System.Windows.Forms.dll,System.Drawing.dll,System.IO.Compression.dll,System.IO.Compression.FileSystem.dll

if exist "%~dp0..\HELPHOTELDESK.exe" (
    echo.
    echo ==========================================================
    echo  [EXITO] El archivo HELPHOTELDESK.exe ha sido creado!
    echo  Ubicacion: %~dp0..\HELPHOTELDESK.exe
    echo ==========================================================
    echo.
) else (
    echo.
    echo [ERROR] Hubo un error al compilar el ejecutable.
    echo.
)

pause
