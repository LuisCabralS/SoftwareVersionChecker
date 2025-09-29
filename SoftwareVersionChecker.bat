@echo off
setlocal enabledelayedexpansion

REM IPs or host
set /p HOSTS=Ingrese las direcciones IP o nombres de host separados por comas:

REM output folder
set "OUTPUT_FOLDER=%USERPROFILE%\Desktop\SoftwareVersion"
if not exist "!OUTPUT_FOLDER!" mkdir "!OUTPUT_FOLDER!"

REM Nombre del software buscar
set "NAME="

REM Limpiar CSV anterior si existe
set "CSV_FILE=!OUTPUT_FOLDER!\SoftwareVersion.csv"
if exist "!CSV_FILE!" del /f /q "!CSV_FILE!"

REM Iterar sobre cada equipo
for %%H in (%HOSTS:,= %) do (
    set "HOST=%%H"
    echo Consultando en !HOST!...

    set "TEMP_FILE=!OUTPUT_FOLDER!\!HOST!_temp.txt"
    set "OUTPUT_FILE=!OUTPUT_FOLDER!\!HOST!_Software.txt"

    REM Eliminar temp si existe de antes
    if exist "!TEMP_FILE!" del /f /q "!TEMP_FILE!"

    REM Ejecutar PowerShell para buscar la versión del antivirus
    powershell -nologo -noprofile -command ^
        "$programa = '%NAME%';" ^
        "$paths = @(" ^
        "'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'," ^
        "'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'" ^
        ");" ^
        "$result = @();" ^
        "foreach ($path in $paths) {" ^
        "try {" ^
        "$apps = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like '*'+$programa+'*' };" ^
        "foreach ($app in $apps) { $result += '{0},{1},{2}' -f '%HOST%', $app.DisplayName, $app.DisplayVersion }" ^
        "} catch {}" ^
        "};" ^
        "$result | Set-Content -Path '!TEMP_FILE!' -Encoding UTF8"

    REM Verificar si se creó y copiar resultados
    if exist "!TEMP_FILE!" (
        type "!TEMP_FILE!" > "!OUTPUT_FILE!"
        type "!TEMP_FILE!" >> "!CSV_FILE!"
        del /f /q "!TEMP_FILE!"
    ) else (
        echo !HOST!,No encontrado > "!OUTPUT_FILE!"
        echo !HOST!,No encontrado >> "!CSV_FILE!"
    )
)

echo.
echo Complete. Check: !OUTPUT_FOLDER!
pause
