@echo off
title HotelDesk Suite - Compilador de Instalador EXE
color 0b
echo ==========================================================
echo    COMPILANDO HOTELDESKSETUP.EXE EN WINDOWS
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
echo Compilando codigo C# a HotelDeskSetup.exe...
echo.

"%CSC%" /target:winexe /platform:anycpu /out:"%~dp0..\HotelDeskSetup.exe" "%~dp0HotelDeskSetup.cs" /reference:System.Windows.Forms.dll,System.Drawing.dll,System.IO.Compression.dll,System.IO.Compression.FileSystem.dll

if exist "%~dp0..\HotelDeskSetup.exe" (
    echo.
    echo ==========================================================
    echo  [EXITO] El archivo HotelDeskSetup.exe ha sido creado!
    echo  Ubicacion: %~dp0..\HotelDeskSetup.exe
    echo ==========================================================
    echo.
) else (
    echo.
    echo [ERROR] Hubo un error al compilar el ejecutable.
    echo.
)

pause
