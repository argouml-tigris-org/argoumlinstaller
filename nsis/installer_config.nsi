#
# This file configures the creation of windows installers for the ArgoUML project 
# The installers are genenerated using Nullsoft Scriptable Install System (NSIS).
#
# There are two usage scenarios for using this file:
#
# RUNNING VIA OFFICIAL RELEASE BUILD SCRIPT (argoumlinstaller/official.sh)
# 1) NSIS does not need to be installed if running on Cygwin/Windows (nsis
#    binaries are included in the SVN checkout).
# 2) Build the required release (build-release.sh).
# 3) Run ./official.sh, which in turn calls argoumlinstaller/nsis/doit.sh
# 4) ArgoUML-xxxx-setup.exe will be created in the directory specified by 
#    doit.sh.
# This script assumes that RELEASENAME, BUILDDIR and OUTPUTDIR are all
# specified on the command line, e.g. 
# $MAKENSIS /DRELEASENAME=$releasename /DBUILDDIR=../$directory/argouml/build \
#    /DOUTPUTDIR=../$directory/DIST nsis/installer_config.nsi  
#
# RUNNING FROM ECLIPSE
# 1) Install NSIS (http://nsis.sourceforge.net/)
# 2) Install EclipseNSIS (http://eclipsensis.sourceforge.net/)
# 3) Open this .nsi file within Eclipse.
# 4) RELEASENAME, BUILDDIR and OUTPUTDIR are specified via 
#    EclipseNSIS > Preferences > Defined Symbols, if you don't set them, a 
#    dummy release name will be used (X.X.X), and suitable directories will be 
#    guessed (this script will assume that 'argoumlinstaller' is checked out 
#    into the same directory as the eclipse projects).
#    Example settings
# BUILDDIR "..\build\VERSION_0_25_4\argouml\build"
# RELEASENAME 0.25.4
# 5) Complile script using EclipseNSIS > Compile Script
#
# In general, EclipseNSIS can be used to edit/develop this script, but the 
# official builds should always be done using official.sh
# 
# $Id$

; TODO
;Make the installer show the correct version number on the unopenned installer
; (currently shows as 0.0.0.0).
;apply i18n to installation strings
;Set up argo.user.properties with the correct language, based on install.
;(maybe) Set up ArgoUML with windows look and feel
;(maybe) Allow manual entry of java path if no JRE detected through registry?
;(maybe) Provide alternate .exe with JRE bundled?

# Defines
!define NAME "ArgoUML"
!define REGKEY "SOFTWARE\$(^Name)"
!ifndef RELEASENAME
  !define RELEASENAME X.X.X
!endif
; If BUILDDIR not defined, assume we are running in eclipse style layout.
!ifndef BUILDDIR
  !define BUILDDIR "..\..\argouml-build\build"
!endif

!ifndef OUTPUTDIR                      ; Where to put the generated installer(s).
  !define OUTPUTDIR "."                ; if unspecified, use script location.
!endif
!define COMPANY ""
!define URL "http://argouml.tigris.org"
!define URL_HELP "http://argouml.tigris.org/documentation"
!define URL_UPDATES "http://argouml-downloads.tigris.org/"
!define JRE_REQUIRED_VERSION "1.5"
!define JRE_URL "http://javadl.sun.com/webapps/download/AutoDL?BundleId=11292"

!define ARGO_FILE_EXT ".zargo"
!define ARGO_FILE_DESC "ArgoUML Project File"
!define ARGO_FILE_KEYNAME "ArgoUML.Project"
!define ARGO_JVM_ARGS "-Xms64m -Xmx512m"

Name ${NAME}

# MUI defines
!define MUI_ICON ${BUILDDIR}\ArgoUML.ico
!define MUI_FINISHPAGE_RUN "$JavaHome\bin\javaw.exe"
!define MUI_FINISHPAGE_RUN_PARAMETERS "${ARGO_JVM_ARGS} -jar $\"$INSTDIR\argouml.jar$\""
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_STARTMENUPAGE_REGISTRY_ROOT HKLM
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_REGISTRY_KEY ${REGKEY}
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME StartMenuGroup
!define MUI_STARTMENUPAGE_DEFAULTFOLDER ArgoUML
!define MUI_LANGDLL_REGISTRY_ROOT "HKLM" 
!define MUI_LANGDLL_REGISTRY_KEY "${REGKEY}" 
!define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
!define MUI_UNFINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_LINK ${URL}
!define MUI_FINISHPAGE_LINK_LOCATION ${URL}

# Included files
!include "Sections.nsh"
!include "MUI.nsh"
!include "LogicLib.nsh"                ; for If, Else, etc used in DetectJRE
!include "WordFunc.nsh"                ; For VersionCompare used in DetectJRE
!include "registerExtension.nsh"       ; for registering file extensions.
!include "FileFunc.nsh"
!insertmacro RefreshShellIcons
!insertmacro VersionCompare
!insertmacro DirState
# Variables
Var StartMenuGroup
Var JavaHome

# Installer pages
!insertmacro MUI_PAGE_WELCOME
!define MUI_PAGE_CUSTOMFUNCTION_PRE DetectJRE
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuGroup
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

# Installer languages
!insertmacro MUI_LANGUAGE English
!insertmacro MUI_LANGUAGE French
!insertmacro MUI_LANGUAGE German
!insertmacro MUI_LANGUAGE Spanish
!insertmacro MUI_LANGUAGE Italian
!insertmacro MUI_LANGUAGE Norwegian
!insertmacro MUI_LANGUAGE Portuguese
!insertmacro MUI_LANGUAGE PortugueseBR
!insertmacro MUI_LANGUAGE Russian
!insertmacro MUI_LANGUAGE TradChinese

# Installer attributes
OutFile ${OUTPUTDIR}\${NAME}-${RELEASENAME}-setup.exe
Caption "${NAME} ${RELEASENAME} Setup"
InstallDir $PROGRAMFILES\ArgoUML
CRCCheck on
XPStyle on
ShowInstDetails hide
VIProductVersion 0.0.0.0
VIAddVersionKey /LANG=${LANG_ENGLISH} ProductName "${NAME}"
VIAddVersionKey /LANG=${LANG_ENGLISH} ProductVersion 0.0.0.0
VIAddVersionKey /LANG=${LANG_ENGLISH} CompanyWebsite "${URL}"
VIAddVersionKey /LANG=${LANG_ENGLISH} FileVersion "${RELEASENAME}"
VIAddVersionKey /LANG=${LANG_ENGLISH} FileDescription ""
VIAddVersionKey /LANG=${LANG_ENGLISH} LegalCopyright ""
InstallDirRegKey HKLM "${REGKEY}" Path
ShowUninstDetails hide
BrandingText " "    ;Removes Nullsoft Install System vX.XX from UI.

# Installer sections
Section /o JRE SEC0000
    AddSize 84566
    StrCpy $2 "$TEMP\JRE-installer.exe"
    DetailPrint "Downloading from ${JRE_URL}."
    nsisdl::download /TIMEOUT=30000 ${JRE_URL} $2
    Pop $R0 ;Get the return value
    StrCmp $R0 "success" +4
    MessageBox MB_OK "Download failed: $R0"
    DetailPrint "Download failed: $R0"
    Quit
    ExecWait $2
    Delete $2
    MessageBox MB_OK "JRE Installation completed"
    DetailPrint "JRE Installation completed"
    WriteRegStr HKLM "${REGKEY}\Components" JRE 1
SectionEnd

Section ArgoUML SEC0001
    ReadRegStr $2 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" \
             "CurrentVersion"
    ReadRegStr $JavaHome HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\$2" \
             "JavaHome"
    ${If} $JavaHome == ""
      MessageBox MB_OK|MB_ICONEXCLAMATION \
              "Setup detected that Java has not been correctly installed on this system, please reinstall the Java runtime enviroment, then try again."
      Quit
    ${EndIf}

    ${DirState} "$INSTDIR" $R0
    IntCmp $R0 1 rmfilesask
    Goto rmfilesdone    
rmfilesask:
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
            "Contents of '$INSTDIR' will be deleted." \
            /SD IDOK \
            IDOK rmfiles
    Abort
    
rmfiles:
    RMDir /r $INSTDIR\*.*
rmfilesdone:
                        
    SetOutPath $INSTDIR
    SetOverwrite on
    File "${BUILDDIR}\*.jar"
    File /nonfatal "${BUILDDIR}\*.bat"
    File "${BUILDDIR}\ArgoUML.ico"
    File "${BUILDDIR}\ArgoUMLdoc.ico"
    SetOutPath $INSTDIR\ext"
    File /nonfatal "${BUILDDIR}\ext\*.jar"      
    ; Extra file for argouml-sql
    File /nonfatal "${BUILDDIR}\ext\domainmapping.xml"
    SetOutPath "$SMPROGRAMS\$StartMenuGroup"    ;Create folder on start menu. 
    SetOutPath $INSTDIR
    CreateShortcut "$DESKTOP\ArgoUML.lnk"  \
        "$JavaHome\bin\javaw.exe" \
        "${ARGO_JVM_ARGS} -jar $\"$INSTDIR\argouml.jar$\""\
        "$INSTDIR\ArgoUML.ico" 0 SW_SHOWNORMAL \
        "" "$(^Name) ${RELEASENAME} - UML Modelling tool"
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\ArgoUML.lnk" \
        "$JavaHome\bin\javaw.exe" \
        "${ARGO_JVM_ARGS} -jar $\"$INSTDIR\argouml.jar$\""\
        "$INSTDIR\ArgoUML.ico" 0 SW_SHOWNORMAL \
        "" "$(^Name) ${RELEASENAME} - UML Modelling tool"
    WriteRegStr HKLM "${REGKEY}\Components" ArgoUML 1
    
    ${registerExtension} \
        '$\"$JavaHome\bin\javaw.exe$\" ${ARGO_JVM_ARGS} -jar $\"$INSTDIR\argouml.jar$\"' \ 
        "${ARGO_FILE_EXT}" \
        "${ARGO_FILE_KEYNAME}" \
        "${ARGO_FILE_DESC}" \
        "$INSTDIR\ArgoUMLdoc.ico"
    ${RefreshShellIcons}
SectionEnd

Section -post SEC0002
    WriteRegStr HKLM "${REGKEY}" Path $INSTDIR
    SetOutPath $INSTDIR
    WriteUninstaller $INSTDIR\uninstall.exe
    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    SetOutPath $SMPROGRAMS\$StartMenuGroup
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\$(^UninstallLink).lnk" $INSTDIR\uninstall.exe
    !insertmacro MUI_STARTMENU_WRITE_END
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayName "$(^Name) ${RELEASENAME}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayVersion "${RELEASENAME}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" URLInfoAbout "${URL}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" URLUpdateInfo "${URL_UPDATES}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" HelpLink "${URL_HELP}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayIcon $INSTDIR\ArgoUML.ico
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" UninstallString $INSTDIR\uninstall.exe
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoModify 1
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoRepair 1
SectionEnd

# Macro for selecting uninstaller sections
!macro SELECT_UNSECTION SECTION_NAME UNSECTION_ID
    Push $R0
    ReadRegStr $R0 HKLM "${REGKEY}\Components" "${SECTION_NAME}"
    StrCmp $R0 1 0 next${UNSECTION_ID}
    !insertmacro SelectSection "${UNSECTION_ID}"
    GoTo done${UNSECTION_ID}
next${UNSECTION_ID}:
    !insertmacro UnselectSection "${UNSECTION_ID}"
done${UNSECTION_ID}:
    Pop $R0
!macroend

# Uninstaller sections
Section /o -un.ArgoUML UNSEC0000
    MessageBox MB_OK "During the installation of ${NAME}, the Java Runtime \ 
      Environment was installed. \
      If you wish to uninstall the Java Runtime Environment, please use \
      Add/Remove Programs in the Control Panel." 
    DeleteRegValue HKLM "${REGKEY}\Components" JRE
SectionEnd

Section /o -un.ArgoUML UNSEC0001
    Delete /REBOOTOK $DESKTOP\ArgoUML.lnk
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\ArgoUML.lnk"
    RmDir /r /REBOOTOK $INSTDIR
    DeleteRegValue HKLM "${REGKEY}\Components" ArgoUML
    ${unregisterExtension} \
            "${ARGO_FILE_EXT}" \
            "${ARGO_FILE_KEYNAME}" \
            "${ARGO_FILE_DESC}"
SectionEnd

Section -un.post UNSEC0002
    DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\$(^UninstallLink).lnk"
    Delete /REBOOTOK $INSTDIR\uninstall.exe
    DeleteRegValue HKLM "${REGKEY}" StartMenuGroup
    DeleteRegValue HKLM "${REGKEY}" Path
    DeleteRegKey /IfEmpty HKLM "${REGKEY}\Components"
    DeleteRegKey /IfEmpty HKLM "${REGKEY}"
    RmDir /REBOOTOK $SMPROGRAMS\$StartMenuGroup
    RmDir /REBOOTOK $INSTDIR
SectionEnd

# Installer functions
Function .onInit
    InitPluginsDir
    System::Call 'kernel32::GetUserDefaultUILanguage() i.r10'
    ${Switch} $R0    ; If english PC, don't bother with language selection. 
      ${Case} '0409' ; en-us
        Goto langok
        ${Break}
      ${Case} '0809' ;en-uk
        Goto langok
        ${Break}
      ${Case} '1033' ;also en-uk
        Goto langok
        ${Break}
    ${EndSwitch}
!insertmacro MUI_LANGDLL_DISPLAY
langok:
  ReadRegStr $R0 HKLM \
  "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" \
  "UninstallString"
  StrCmp $R0 "" uninstdone
 
  MessageBox MB_OKCANCEL|MB_ICONQUESTION \
            "Remove existing installation of ${NAME} first?" \
            /SD IDOK \
            IDOK uninst
  Abort
 
;Run the uninstaller
uninst:
  ClearErrors
  ExecWait '$R0 /S _?=$INSTDIR' ;Do not copy the uninstaller to a temp file
  IfErrors no_remove_uninstaller
    Delete /REBOOTOK $R0
   no_remove_uninstaller:
uninstdone:

    StrCpy $StartMenuGroup "$(^Name)"
FunctionEnd

Function DetectJRE
  ReadRegStr $2 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" \
             "CurrentVersion"
  ${VersionCompare} "$2" "${JRE_REQUIRED_VERSION}" $3
${If} $2 == ""
  MessageBox MB_ICONINFORMATION "No Java Runtime Environment could be found.  \
    Setup will automatically download a suitable JRE from sun.com." \
    /SD IDOK 
  DetailPrint "No JRE found, setting option to auto download"
  SectionGetFlags SEC0000 $0
  IntOp $0 $0 | ${SF_SELECTED}
  SectionSetFlags SEC0000 $0
${ElseIf} $3 == 2 
  MessageBox MB_ICONINFORMATION "Your current Java Runtime Environment is \
    out of date, and will be automatically updated from sun.com.  \
    (Required JRE${JRE_REQUIRED_VERSION}, found JRE$2)." \
     /SD IDOK     
  DetailPrint "DetectJRE: Required: [${JRE_REQUIRED_VERSION}], \
    Found [$2].  Setting option to auto download." 
  SectionGetFlags SEC0000 $0
  IntOp $0 $0 | ${SF_SELECTED}
  SectionSetFlags SEC0000 $0
${Else}
  DetailPrint "Found Java Runtime Environment $2, \
    (>=${JRE_REQUIRED_VERSION} required), OK"
${EndIf}

FunctionEnd

# Uninstaller functions
Function un.onInit
    ReadRegStr $INSTDIR HKLM "${REGKEY}" Path
    !insertmacro MUI_UNGETLANGUAGE
    !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuGroup
    !insertmacro SELECT_UNSECTION JRE ${UNSEC0000}
    !insertmacro SELECT_UNSECTION ArgoUML ${UNSEC0001}
FunctionEnd

# Section Descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SEC0000} $(SEC0000_DESC)
!insertmacro MUI_DESCRIPTION_TEXT ${SEC0001} $(SEC0001_DESC)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

# Installer Language Strings
# TODO Update the Language Strings with the appropriate translations.
LangString ^UninstallLink ${LANG_ENGLISH} "Uninstall $(^Name)"
LangString ^UninstallLink ${LANG_FRENCH} "Uninstall $(^Name)"
LangString ^UninstallLink ${LANG_GERMAN} "Uninstall $(^Name)"
LangString ^UninstallLink ${LANG_SPANISH} "Uninstall $(^Name)"
LangString ^UninstallLink ${LANG_ITALIAN} "Uninstall $(^Name)"
LangString ^UninstallLink ${LANG_NORWEGIAN} "Uninstall $(^Name)"
LangString ^UninstallLink ${LANG_PORTUGUESE} "Uninstall $(^Name)"
LangString ^UninstallLink ${LANG_PORTUGUESEBR} "Uninstall $(^Name)"
LangString ^UninstallLink ${LANG_RUSSIAN} "Uninstall $(^Name)"
LangString ^UninstallLink ${LANG_TRADCHINESE} "Uninstall $(^Name)"

LangString SEC0000_DESC ${LANG_ENGLISH} "Java Runtime Environment (download from sun.com)"
LangString SEC0000_DESC ${LANG_FRENCH} "Java Runtime Environment (download from sun.com)"
LangString SEC0000_DESC ${LANG_GERMAN} "Java Runtime Environment (download from sun.com)"
LangString SEC0000_DESC ${LANG_SPANISH} "Java Runtime Environment (download from sun.com)"
LangString SEC0000_DESC ${LANG_ITALIAN} "Java Runtime Environment (download from sun.com)"
LangString SEC0000_DESC ${LANG_NORWEGIAN} "Java Runtime Environment (download from sun.com)"
LangString SEC0000_DESC ${LANG_PORTUGUESE} "Java Runtime Environment (download from sun.com)"
LangString SEC0000_DESC ${LANG_PORTUGUESEBR} "Java Runtime Environment (download from sun.com)"
LangString SEC0000_DESC ${LANG_RUSSIAN} "Java Runtime Environment (download from sun.com)"
LangString SEC0000_DESC ${LANG_TRADCHINESE} "Java Runtime Environment (download from sun.com)"

LangString SEC0001_DESC ${LANG_ENGLISH} "The ArgoUML application itself (required)."
LangString SEC0001_DESC ${LANG_FRENCH} "The ArgoUML application itself (required)."
LangString SEC0001_DESC ${LANG_GERMAN} "The ArgoUML application itself (required)."
LangString SEC0001_DESC ${LANG_SPANISH} "The ArgoUML application itself (required)."
LangString SEC0001_DESC ${LANG_ITALIAN} "The ArgoUML application itself (required)."
LangString SEC0001_DESC ${LANG_NORWEGIAN} "The ArgoUML application itself (required)."
LangString SEC0001_DESC ${LANG_PORTUGUESE} "The ArgoUML application itself (required)."
LangString SEC0001_DESC ${LANG_PORTUGUESEBR} "The ArgoUML application itself (required)."
LangString SEC0001_DESC ${LANG_RUSSIAN} "The ArgoUML application itself (required)."
LangString SEC0001_DESC ${LANG_TRADCHINESE} "The ArgoUML application itself (required)."

