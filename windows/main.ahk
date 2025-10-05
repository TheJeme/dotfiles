#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

::ej@@::eemelijoonatan@gmail.com

::em@@::eemelijoonatan@gmail.com
::num##::0445259110

#k::Run "C:\Users\eemel\Documents\KOODAUS"
#c::Run "C:\Users\eemel\AppData\Local\Programs\Microsoft VS Code\code.exe"
#space::Click

#Up:: MouseMove, 0, -20,67,R
return
#Down:: MouseMove, 0, 20,67,R
return
#Left:: MouseMove, -20, 0,67,R
return
#Right:: MouseMove, 20, 0,67,R
return


~LWin::return
~RWin::return

#WheelUp::
Send {Volume_Up}
Return

#WheelDown::
Send {Volume_Down}
Return

#MButton::
Send {Media_Play_Pause}
Return

^#WheelDown::
Send {Media_Prev}
Return

^#WheelUp::
Send {Media_Next}
Return