#
# NSIS Support funciton script used for registering file extensions.
# Adapted from http://nsis.sourceforge.net/File_Association 
#
# $Id$

!define registerExtension "!insertmacro registerExtension"
!define unregisterExtension "!insertmacro unregisterExtension"
 
!macro registerExtension executable extension keyname description icofile
       Push "${executable}"  ; "full path to my.exe"
       Push "${extension}"   ;  ".mkv"
       Push "${keyname}"     ;  "MKV.File"
       Push "${description}" ;  "MKV File"
       Push "${icofile}"     ;  "Document icon file"
       Call registerExtension
!macroend
 
; back up old value of .opt
Function registerExtension
!define Index "Line${__LINE__}"
  pop $R0 ; icon
  pop $R1 ; description
  pop $R2 ; key name
  pop $R3 ; extension
  pop $R4 ; executable
  push $1
  push $0
  ReadRegStr $1 HKCR $R3 ""
  StrCmp $1 "" "${Index}-NoBackup"
    StrCmp $1 "OptionsFile" "${Index}-NoBackup"
    WriteRegStr HKCR $R3 "backup_val" $1
"${Index}-NoBackup:"
  WriteRegStr HKCR $R3 "" $R2
  ReadRegStr $0 HKCR $R2 ""
  StrCmp $0 "" 0 "${Index}-Skip"
	WriteRegStr HKCR $R2 "" $R1
	#WriteRegStr HKCR "$R2\shell" "" "open"
	WriteRegStr HKCR "$R2\DefaultIcon" "" "$R0,0"
"${Index}-Skip:"
  WriteRegStr HKCR "$R2\shell\open\command" "" '$R4 "%1"'
  #WriteRegStr HKCR "$R2\shell\edit" "" "Edit $R1"
  #WriteRegStr HKCR "$R2\shell\edit\command" "" '$R4 "%1"'
  pop $0
  pop $1
!undef Index
FunctionEnd
 
!macro unregisterExtension extension keyname description
       Push "${extension}"   ;  ".mkv"
       Push "${keyname}"     ;  "MKV.File"
       Push "${description}"   ;  "MKV File"
       Call un.unregisterExtension
!macroend
 
Function un.unregisterExtension
  pop $R2 ; description
  pop $R1 ; key name
  pop $R0 ; extension
!define Index "Line${__LINE__}"
  ReadRegStr $1 HKCR $R0 ""
  StrCmp $1 $R1 0 "${Index}-NoOwn" ; only do this if we own it
  ReadRegStr $1 HKCR $R0 "backup_val"
  StrCmp $1 "" 0 "${Index}-Restore" ; if backup="" then delete the whole key
  DeleteRegKey HKCR $R0
  Goto "${Index}-NoOwn"
"${Index}-Restore:"
  WriteRegStr HKCR $R0 "" $1
  DeleteRegValue HKCR $R0 "backup_val"
"${Index}-NoOwn:"
!undef Index
  DeleteRegKey HKCR $R1 ;Delete key with association name settings
FunctionEnd