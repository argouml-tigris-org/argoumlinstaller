@echo off
::
:: Script for launching makensis to create the ArgoUML windows installer.
:: .bat file version.
::
:: It assumes that the working directory when this script is called
:: is the same directory as where this file resides.
::
:: The work is done by tools/makensis.exe, which takes a .nsi file, and builds
:: a windows installer (.exe). makensis is part of the Nullsoft Scriptable
:: Installer System (NSIS), http://nsis.sourceforge.net/Main_Page
::
:: If the environment variable %RELEASENAME% has already been defined, this 
:: is used as the release name, if not, a prompt is given to enter it.
:: 
:: The script assumes an eclipse style directory structure built from the 
:: command line, where the pre-built argouml .jar files are in the directory 
:: ../../build relative to this file.
::
:: This .bat version of the build process is only for those who are curious
:: and don't have cygwin.  Offical releases should be created using doit.sh
:: which is called via ../official.sh.
::
:: The resulting installer is generated in the same directory as this file, 
:: named ArgoUML-{RELEASENAME}-setup.exe.  This script will only build the 
:: installer, and does not do all of the copying to release directories like 
:: doit.sh does.
::
:: In short: don't use this file.  Get cygwin and use official.sh to call 
:: doit.sh.
::
:: $Id$
::
SETLOCAL ENABLEEXTENSIONS

set MAKENSIS=".\tools\makensis.exe"

if not exist %MAKENSIS% goto no_makensis

if defined RELEASENAME goto checks_complete

SET /P RELEASENAME="Please give the name of the release (e.g. X.Y.Z)."

:checks_complete
%MAKENSIS% /DRELEASENAME=%RELEASENAME% installer_config.nsi
if errorlevel 1 goto endfail
goto endnormal
goto EOF

:no_makensis
echo Could not find makensis.exe at location %MAKENSIS%.
goto endfail

:endfail
echo Failed to create windows installer.
pause

:endnormal
echo "Windows installer created successfully."
ENDLOCAL
:EOF