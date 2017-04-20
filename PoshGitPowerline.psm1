. "$PSScriptRoot\Write-PoshGitPowerline.ps1"
. "$PSScriptRoot\Show-PoshGitPowerlineExamples.ps1"

$exportedFunctions = @(
    'Write-PoshGitPowerline'
    'Show-PoshGitPowerlineExamples'
)

Export-ModuleMember -Function $exportedFunctions