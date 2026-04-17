#k::
projectsDir := A_MyDocuments . "\KOODAUS"
if FileExist(projectsDir)
    Run % projectsDir
return

#c::
codePath := A_LocalAppData . "\Programs\Microsoft VS Code\Code.exe"
if FileExist(codePath) {
    Run % codePath
} else {
    Run code
}
return

#space::Click
