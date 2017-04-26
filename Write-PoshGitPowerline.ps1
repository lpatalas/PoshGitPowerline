$Glyphs = @{
    Branch = [char]0xE0A0
    Line = [char]0xE0A1
    ClosedPadlock = [char]0xE0A2
    RightwardsBlackArrowhead = [char]0xE0B0
    RightwardsArrowhead = [char]0xE0B1
    LeftwardsBlackArrowhead = [char]0xE0B2
    LeftwardsArrowhead = [char]0xE0B3
    UpArrow = [char]0x25B2
    DownArrow = [char]0x25BC
}

function NewSegment($text, $foregroundColor, $backgroundColor) {
    if (-not $foregroundColor) { $foregroundColor = [ConsoleColor]::White }
    if (-not $backgroundColor) { $backgroundColor = [ConsoleColor]::Black }

    New-Object PSObject `
        | Add-Member Text $text -MemberType NoteProperty -PassThru `
        | Add-Member ForegroundColor $foregroundColor -MemberType NoteProperty -PassThru `
        | Add-Member BackgroundColor $backgroundColor -MemberType NoteProperty -PassThru
}

function GetBareOrGitDirSegment($status) {
    if ($status.Branch -ilike 'BARE:*') {
        return NewSegment 'BARE' White DarkMagenta
    }
    elseif ($status.Branch -eq 'GIT_DIR!') {
        return NewSegment 'GIT_DIR' White DarkMagenta
    }
}

function GetRebaseProgress($operation) {
    if ($operation -ilike 'REBASE') {
        $gitDir = Get-GitDirectory
        $rebaseInfoDir = ''

        if ($operation -match 'REBASE-[im]') {
            $rebaseInfoDir = "$gitDir\rebase-merge"
        }
        else {
            $rebaseInfoDir = "$gitDir\rebase-apply"
        }
        
        $current = Get-Content "$rebaseInfoDir\msgnum" -ErrorAction SilentlyContinue
        $total = Get-Content "$gitDir\rebase-merge\end" -ErrorAction SilentlyContinue

        if ($current -and $total) {
            return "$current/$total"
        }
    }
}

function GetStateSegment($status) {
    if ($status.Branch -like '*|*') {
        $operation = ($status.Branch -split '\|')[1]
        if ($operation -ilike 'REBASE*') {
            $progress = GetRebaseProgress $operation
            if ($progress) {
                $operation += " ($progress)"
            }
        }

        return NewSegment $operation White Red
    }
}

function FormatAheadBehind($status) {
    $result = ''

    if ($status.AheadBy -gt 0) {
        $result += $Glyphs.UpArrow + $status.AheadBy
    }
    if ($status.BehindBy -gt 0) {
        $result += $Glyphs.DownArrow + $status.BehindBy
    }

    return $result
}

function GetBranchNameSegment($status) {
    if ($status.Branch -and ($status.Branch -ne 'GIT_DIR!')) {
        $branchName = $status.Branch
        if ($branchName -match '^(BARE:)?(?<name>[^\|]+)|.*') {
            $branchName = $matches['name']
        }

        $branchName = $Glyphs.Branch + ' ' + $branchName
        $aheadBehind = FormatAheadBehind $status

        if (($gitStatus.AheadBy -gt 0) -and ($gitStatus.BehindBy -gt 0)) {
            return NewSegment "$branchName $aheadBehind" White DarkYellow
        }
        elseif ($gitStatus.AheadBy -gt 0) {
            return NewSegment "$branchName $aheadBehind" White DarkGreen
        }
        elseif ($gitStatus.BehindBy -gt 0) {
            return NewSegment "$branchName $aheadBehind" White DarkRed
        }
        else {
            return NewSegment "$branchName" White DarkCyan
        }
    }
}

function GetFileStateSegment($status, $foregroundColor, $backgroundColor) {
    $a = $status.Added.Count
    $m = $status.Modified.Count
    $d = $status.Deleted.Count
    $u = $status.Unmerged.Count

    $result = "+$a ~$m -$d"
    if ($u -gt 0) {
        $result += " !$u"
    }

    return NewSegment $result $foregroundColor $backgroundColor
}

function GetIndexStateSegment($status) {
    if ($status.HasIndex) {
        return GetFileStateSegment $status.Index Green DarkBlue
    }
}

function GetWorkingCopyStateSegment($status) {
    if ($status.HasWorking) {
        return GetFileStateSegment $status.Working Red Blue
    }
}

function WriteSegment {
    param(
        $text,
        $foregroundColor,
        $backgroundColor,
        $previousBackgroundColor
    )

    if ($previousBackgroundColor) {
        Write-Host $Glyphs.RightwardsBlackArrowhead `
            -ForegroundColor:$previousBackgroundColor `
            -BackgroundColor:$backgroundColor `
            -NoNewline
    }
    
    Write-Host " $text " `
        -ForegroundColor:$foregroundColor `
        -BackgroundColor:$backgroundColor `
        -NoNewline
}

function WriteSegments($segments) {
    $previousBackgroundColor = $null
    $nonNullSegments = $segments | Where-Object { [bool]$_ }

    foreach ($segment in $nonNullSegments) {
        WriteSegment `
            $segment.Text `
            $segment.ForegroundColor `
            $segment.BackgroundColor `
            $previousBackgroundColor

        $previousBackgroundColor = $segment.BackgroundColor
    }
}

function Write-PoshGitPowerline {
    param(
        $gitStatus,
        [switch] $stretchToWidth
    )
    
    $bare = GetBareOrGitDirSegment $gitStatus
    $state = GetStateSegment $gitStatus
    $branchName = GetBranchNameSegment $gitStatus
    $index = GetIndexStateSegment $gitStatus
    $working = GetWorkingCopyStateSegment $gitStatus
    $currentDir = NewSegment (Get-Location).Path White DarkGray

    WriteSegments @(
        $bare
        $state
        $branchName
        $index
        $working
        $currentDir
    )

    if ($stretchToWidth) {
        $x = $Host.UI.RawUI.CursorPosition.X
        $w = $Host.UI.RawUI.WindowSize.Width
        $s = ' ' * ($w - $x)
        Write-Host $s -BackgroundColor DarkGray -NoNewline
    }
    else {
        Write-Host $Glyphs.RightwardsBlackArrowhead `
            -ForegroundColor:DarkGray `
            -BackgroundColor:Black
    }
}