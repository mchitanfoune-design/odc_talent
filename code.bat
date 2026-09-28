@echo off
chcp 65001 >nul
echo Yoooooooooooo hoooooo

mkdir lib\core\constants 2>nul
mkdir lib\core\errors 2>nul
mkdir lib\core\network 2>nul
mkdir lib\core\router 2>nul
mkdir lib\core\theme 2>nul

call :CreateFeature auth
call :CreateFeature talents
call :CreateFeature missions
call :CreateFeature messages
call :CreateFeature subscriptions
call :CreateFeature dashboard

echo.
echo Creer hoooo
pause
exit /b

:CreateFeature
set "feature=%~1"
echo [+] Création de la feature : %feature%
mkdir lib\features\%feature%\data\datasources 2>nul
mkdir lib\features\%feature%\data\models 2>nul
mkdir lib\features\%feature%\data\repositories 2>nul
mkdir lib\features\%feature%\domain\entities 2>nul
mkdir lib\features\%feature%\domain\repositories 2>nul
mkdir lib\features\%feature%\domain\usecases 2>nul
mkdir lib\features\%feature%\presentation\bloc 2>nul
mkdir lib\features\%feature%\presentation\screens 2>nul
mkdir lib\features\%feature%\presentation\widgets 2>nul
goto :eof