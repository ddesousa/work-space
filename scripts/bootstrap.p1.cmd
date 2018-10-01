@echo off

SETLOCAL

set TOOLS_DRIVE=""

REM REVISIT (ddesousa): Need to pull this value out of the environment rather than hard-coding it
set TOOLS_FOLDER=\\absfs3\DEV\Tools
set BOOTSTRAP_TEMP_FOLDER=%TEMP%\DevEnvironmentBootStrap

REM The version number in wget makes this code brittle
set WGET_ROOT_FOLDER=%BOOTSTRAP_TEMP_FOLDER%\wget\wget-1.11.4-1-bin\bin
set WGET=%WGET_ROOT_FOLDER%\wget.exe

REM Count the number of arguments that were passed in
set ARG_COUNT=0
set ARGS_EXPECTED=1

for %%A in (%*) do set /A ARG_COUNT+=1
if NOT %ARG_COUNT% == %ARGS_EXPECTED% (
    goto Usage
)

set CYGWIN_FOLDER=%1

if "%CYGWIN_FOLDER%" == "" (
    goto Usage
)

REM Map the tools directory to a drive
for %%D in (M N O P Q R S T U V W X Y Z) do (
    if NOT EXIST %%D: (
        set TOOLS_DRIVE=%%D:
        net use %%D: %TOOLS_FOLDER%
        goto Break
    )
)
:Break

if "%TOOLS_DRIVE%" == "" (
    echo "Error mapping tools drive"
    goto Exit
)

REM Copy the bootstrap tools
if exist %BOOTSTRAP_TEMP_FOLDER% (
    rd /S /Q %BOOTSTRAP_TEMP_FOLDER%
)

mkdir %BOOTSTRAP_TEMP_FOLDER%
pushd %BOOTSTRAP_TEMP_FOLDER%

REM Get the unzip and wget tools
for %%F in (%TOOLS_DRIVE%\GnuWin32\unzip.exe ^
            %TOOLS_DRIVE%\GnuWin32\unzip32.dll ^
            %TOOLS_DRIVE%\GnuWin32\wget* ^
            %TOOLS_DRIVE%\BootStrap\create_workspace.sh) do (
    if exist %%F (
        copy %%F %BOOTSTRAP_TEMP_FOLDER%
    )
)

REM Unzip wget
unzip -o -d wget wget*.zip

REM Fetch the cygwin setup executable from the cygwin site
if exist %WGET% (
    %WGET% http://cygwin.com/setup-x86.exe
    copy %BOOTSTRAP_TEMP_FOLDER%\setup-x86.exe %USERPROFILE%\Downloads\setup-x86.exe
)

if not %ERRORLEVEL% == 0 (
    echo "Error: Could not download or copy cygwin setup binary"
    goto Exit
)
popd

REM Copy the Cygwin packages from network shared folder
xcopy /S /E /Y %TOOLS_DRIVE%\Cygwin\packages %USERPROFILE%\Downloads\packages\
if not %ERRORLEVEL% == 0 (
    echo "Error: Could not copy local cygwin packages"
    goto Exit
)

copy /Y %TOOLS_DRIVE%\Cygwin\packages.txt %USERPROFILE%\Downloads\packages.txt
if not %ERRORLEVEL% == 0 (
    echo "Error: Could not copy local cygwin packages list"
    goto Exit
)

REM Run the cygwin installer
%USERPROFILE%\Downloads\setup-x86.exe --wait ^
--no-shortcuts ^
--no-startmenu ^
--quiet-mode ^
--local-install ^
--local-package-dir %USERPROFILE%\Downloads\packages ^
--root %CYGWIN_FOLDER% ^
--packages dos2unix

copy /Y %TOOLS_DRIVE%\BootStrap\BootStrap.p2.sh %CYGWIN_FOLDER%\tmp
if not %ERRORLEVEL% == 0 (
    echo "Error: Could not copy local cygwin packages list"
    goto Exit
)

cd /D %CYGWIN_FOLDER%\bin

set BOOTSTRAP_FOLDER=%CYGWIN_FOLDER%\tmp\bootstrap.sh

echo #/bin/bash> %BOOTSTRAP_FOLDER%
echo export SETUP_X86=`cygpath -u "%USERPROFILE%\Downloads\setup-x86.exe"`>> %BOOTSTRAP_FOLDER%
echo export PACKAGES_FOLDER="%USERPROFILE%\Downloads\packages">> %BOOTSTRAP_FOLDER%
echo export PACKAGES_TXT="%USERPROFILE%\Downloads\packages.txt">> %BOOTSTRAP_FOLDER%
echo export CYGWIN_FOLDER="%CYGWIN_FOLDER%">> %BOOTSTRAP_FOLDER%

copy /Y %BOOTSTRAP_TEMP_FOLDER%\create_workspace.sh %CYGWIN_FOLDER%\tmp

start /wait %CYGWIN_FOLDER%\bin\bash --login -i /tmp/BootStrap.p2.sh /tmp/bootstrap.sh

del /F /Q %CYGWIN_FOLDER%\tmp\BootStrap.p2.sh
del /F /Q %CYGWIN_FOLDER%\tmp\bootstrap.sh

rd /S /Q %BOOTSTRAP_TEMP_FOLDER%

start %CYGWIN_FOLDER%\bin\bash --login

popd

goto Exit

:Usage

echo Usage:
echo ------
echo BootStrap.p1.cmd [Cygwin Folder]
echo Cygwin Folder:        "C:\cygwin"

:Exit

if exist %TOOLS_DRIVE% (
    net use /delete %TOOLS_DRIVE%
)

ENDLOCAL
