if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine

    Set-PSReadLineOption `
        -EditMode Windows `
        -BellStyle None `
        -HistoryNoDuplicates `
        -HistorySearchCursorMovesToEnd `
        -MaximumHistoryCount 10000

    if ((Get-Command Set-PSReadLineOption).Parameters.ContainsKey('Colors')) {
        Set-PSReadLineOption -Colors @{
            Command   = [ConsoleColor]::Cyan
            Parameter = [ConsoleColor]::Gray
            Operator  = [ConsoleColor]::DarkGray
            Variable  = [ConsoleColor]::Green
            String    = [ConsoleColor]::Yellow
            Number    = [ConsoleColor]::Magenta
            Type      = [ConsoleColor]::DarkCyan
            Comment   = [ConsoleColor]::DarkGray
            Keyword   = [ConsoleColor]::Blue
            Member    = [ConsoleColor]::DarkYellow
        }
    }

    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -Function ReverseSearchHistory
    Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteCharOrExit
    Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardKillWord
    Set-PSReadLineKeyHandler -Chord 'Alt+d' -Function KillWord
}
