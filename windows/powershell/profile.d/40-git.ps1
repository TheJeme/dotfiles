function gs { git status --short }
function gd { git diff }
function gl { git log --oneline --decorate --graph -20 }
function gco { param([string]$Branch) git checkout $Branch }
function gcmsg { param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Message) git commit -m ($Message -join ' ') }

function Get-GitBranchName {
    if (-not (Test-Command -Name 'git')) {
        return $null
    }

    $branch = git branch --show-current 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
        return $null
    }

    return $branch.Trim()
}

function Get-GitStatusSummary {
    if (-not (Test-Command -Name 'git')) {
        return $null
    }

    $statusLines = git status --porcelain=v1 --branch 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $statusLines) {
        return $null
    }

    $summary = [ordered]@{
        Branch    = $null
        Ahead     = 0
        Behind    = 0
        Staged    = 0
        Modified  = 0
        Untracked = 0
    }

    foreach ($line in $statusLines) {
        if ($line -like '## *') {
            $branchInfo = $line.Substring(3)
            $summary.Branch = ($branchInfo -split '\.\.\.')[0]

            if ($branchInfo -match 'ahead (\d+)') {
                $summary.Ahead = [int]$matches[1]
            }

            if ($branchInfo -match 'behind (\d+)') {
                $summary.Behind = [int]$matches[1]
            }

            continue
        }

        if ($line -like '??*') {
            $summary.Untracked++
            continue
        }

        $indexStatus = $line[0]
        $workTreeStatus = $line[1]

        if ($indexStatus -ne ' ') {
            $summary.Staged++
        }

        if ($workTreeStatus -ne ' ') {
            $summary.Modified++
        }
    }

    return [pscustomobject]$summary
}

function gst {
    $summary = Get-GitStatusSummary
    if ($null -eq $summary) {
        Write-Error 'Not inside a Git repository.'
        return
    }

    $parts = @("branch=$($summary.Branch)")

    if ($summary.Ahead -gt 0) {
        $parts += "ahead=$($summary.Ahead)"
    }

    if ($summary.Behind -gt 0) {
        $parts += "behind=$($summary.Behind)"
    }

    if ($summary.Staged -gt 0) {
        $parts += "staged=$($summary.Staged)"
    }

    if ($summary.Modified -gt 0) {
        $parts += "modified=$($summary.Modified)"
    }

    if ($summary.Untracked -gt 0) {
        $parts += "untracked=$($summary.Untracked)"
    }

    Write-Host ($parts -join '  ')
}

function groot {
    croot
}

function gbd {
    git branch --sort=-committerdate
}

function gwl {
    git worktree list
}

function gwr {
    if (-not (Test-Command -Name 'git')) {
        Write-Error 'git is not installed.'
        return
    }

    if (-not (Test-Command -Name 'fzf')) {
        Write-Error 'fzf is not installed.'
        return
    }

    $selection = git worktree list --porcelain 2>$null |
        Where-Object { $_ -like 'worktree *' } |
        ForEach-Object { $_.Substring(9) } |
        fzf

    if (-not [string]::IsNullOrWhiteSpace($selection)) {
        Set-Location $selection
    }
}

function gwt {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Branch
    )

    git worktree add $Path $Branch
}

function kctx {
    if (-not (Test-Command -Name 'kubectl')) {
        Write-Error 'kubectl is not installed.'
        return
    }

    kubectl config current-context
}

function kns {
    param([string]$Namespace)

    if (-not (Test-Command -Name 'kubectl')) {
        Write-Error 'kubectl is not installed.'
        return
    }

    if ([string]::IsNullOrWhiteSpace($Namespace)) {
        kubectl config view --minify --output 'jsonpath={..namespace}'
        return
    }

    kubectl config set-context --current --namespace=$Namespace
}

function kpods {
    param([string]$Namespace)

    if (-not (Test-Command -Name 'kubectl')) {
        Write-Error 'kubectl is not installed.'
        return
    }

    if ([string]::IsNullOrWhiteSpace($Namespace)) {
        kubectl get pods
    }
    else {
        kubectl get pods -n $Namespace
    }
}

function dps {
    if (-not (Test-Command -Name 'docker')) {
        Write-Error 'docker is not installed.'
        return
    }

    docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
}

function Select-DockerContainer {
    param(
        [switch]$IncludeStopped
    )

    if (-not (Test-Command -Name 'docker')) {
        Write-Error 'docker is not installed.'
        return $null
    }

    if (-not (Test-Command -Name 'fzf')) {
        Write-Error 'fzf is not installed.'
        return $null
    }

    $args = @('ps', '--format', '{{.Names}}' + "`t" + '{{.Image}}' + "`t" + '{{.Status}}')
    if ($IncludeStopped) {
        $args = @('ps', '-a', '--format', '{{.Names}}' + "`t" + '{{.Image}}' + "`t" + '{{.Status}}')
    }

    $selection = docker @args 2>$null | fzf --delimiter "`t"
    if ([string]::IsNullOrWhiteSpace($selection)) {
        return $null
    }

    return ($selection -split "`t")[0]
}

function dlog {
    param(
        [string]$Container,
        [int]$Tail = 100
    )

    if (-not (Test-Command -Name 'docker')) {
        Write-Error 'docker is not installed.'
        return
    }

    if ([string]::IsNullOrWhiteSpace($Container)) {
        $Container = Select-DockerContainer
        if ([string]::IsNullOrWhiteSpace($Container)) {
            return
        }
    }

    docker logs --tail $Tail -f $Container
}

function dexec {
    param(
        [string]$Container,
        [string]$Shell = 'sh'
    )

    if (-not (Test-Command -Name 'docker')) {
        Write-Error 'docker is not installed.'
        return
    }

    if ([string]::IsNullOrWhiteSpace($Container)) {
        $Container = Select-DockerContainer
        if ([string]::IsNullOrWhiteSpace($Container)) {
            return
        }
    }

    docker exec -it $Container $Shell
}

function dstop {
    param([string]$Container)

    if (-not (Test-Command -Name 'docker')) {
        Write-Error 'docker is not installed.'
        return
    }

    if ([string]::IsNullOrWhiteSpace($Container)) {
        $Container = Select-DockerContainer
        if ([string]::IsNullOrWhiteSpace($Container)) {
            return
        }
    }

    docker stop $Container
}

function drm {
    param([string]$Container)

    if (-not (Test-Command -Name 'docker')) {
        Write-Error 'docker is not installed.'
        return
    }

    if ([string]::IsNullOrWhiteSpace($Container)) {
        $Container = Select-DockerContainer -IncludeStopped
        if ([string]::IsNullOrWhiteSpace($Container)) {
            return
        }
    }

    docker rm $Container
}
