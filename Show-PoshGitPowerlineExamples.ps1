function Show-PoshGitPowerlineExamples {
    $testStatuses = @(
        @{
            Branch = 'master'
            HasIndex = $false
            HasWorking = $false
        }

        @{
            Branch = 'master'
            AheadBy = 2
            HasIndex = $true
            Index = @{
                Added = 4
                Modified = 3
                Deleted = 5
                Unmerged = 6
            }
            HasWorking = $true
            Working = @{
                Added = 1
                Modified = 2
                Deleted = 2
                Unmerged = 0
            }
        }

        @{
            Branch = 'master'
            BehindBy = 5
            HasIndex = $true
            Index = @{
                Added = 4
                Modified = 3
                Deleted = 5
                Unmerged = 6
            }
            HasWorking = $true
            Working = @{
                Added = 1
                Modified = 2
                Deleted = 2
                Unmerged = 0
            }
        }
        
        @{
            Branch = 'master'
            AheadBy = 2
            BehindBy = 5
            HasIndex = $true
            Index = @{
                Added = 4
                Modified = 3
                Deleted = 5
                Unmerged = 6
            }
            HasWorking = $true
            Working = @{
                Added = 1
                Modified = 2
                Deleted = 2
                Unmerged = 0
            }
        }

        @{
            Branch = 'feature/new-feature|REBASE-i'
            AheadBy = 2
            HasIndex = $true
            Index = @{
                Added = 4
                Modified = 3
                Deleted = 5
                Unmerged = 6
            }
            HasWorking = $true
            Working = @{
                Added = 1
                Modified = 2
                Deleted = 2
                Unmerged = 0
            }
        }
        
        @{
            Branch = 'feature/new-feature|REBASE-i'
            BehindBy = 5
            HasIndex = $true
            Index = @{
                Added = 4
                Modified = 3
                Deleted = 5
                Unmerged = 6
            }
            HasWorking = $true
            Working = @{
                Added = 1
                Modified = 2
                Deleted = 2
                Unmerged = 0
            }
        }
        
        @{
            Branch = 'feature/new-feature|REBASE-i'
            AheadBy = 2
            BehindBy = 5
            HasIndex = $true
            Index = @{
                Added = 4
                Modified = 3
                Deleted = 5
                Unmerged = 6
            }
            HasWorking = $true
            Working = @{
                Added = 1
                Modified = 2
                Deleted = 2
                Unmerged = 0
            }
        }
        
        @{
            Branch = 'GIT_DIR!'
            HasIndex = $false
            HasWorking = $false
        }
        
        @{
            Branch = 'BARE:master'
            HasIndex = $false
            HasWorking = $false
        }
    )

    foreach ($status in $testStatuses) {
        Write-PoshGitPowerline $status
    }
}