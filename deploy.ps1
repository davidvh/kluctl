[CmdletBinding(DefaultParameterSetName = 'Deploy', SupportsShouldProcess = $true)]
param (
    [switch] $NoPrune,

    [switch] $SkipConfirmAfterDiff,

    [Parameter(ParameterSetName = 'Bootstrap')]
    [string] $BootstrapFile,

    [Parameter(ParameterSetName = 'Deploy')]
    [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
            $targets = Get-ChildItem -Path $PSScriptRoot -Recurse -Include @(".kluctl.yml", 'deploy.seq') |
                ForEach-Object { $_.Directory.FullName.Substring($PSScriptRoot.Length + 1) } |
                Select-Object -Unique
            $targets = $targets | Where-Object { $_ -ine 'bootstrap' }
            
            return $targets | Where-Object { $_ -like "*$wordToComplete*" }
        })]
    [string[]] $Targets
)

$ErrorActionPreference = 'Stop'

if ($PSCmdlet.ParameterSetName -ieq 'Bootstrap') {
    $BootstrapFile = Resolve-Path -Path $BootstrapFile
    if (-not (Test-Path -Path $BootstrapFile)) {
        Write-Error "Bootstrap file not found: $BootstrapFile"
        return
    }

    $kluctlArgs = @("deploy", "-t", "local", "--args-from-file", "$BootstrapFile")
    if (-not $NoPrune) {
        $kluctlArgs += "--prune"
    }
    if ($SkipConfirmAfterDiff) {
        $kluctlArgs += "--yes"
    }
    Start-Process -FilePath kluctl -NoNewWindow -Wait -ArgumentList $kluctlArgs -WorkingDirectory (Join-Path $PSScriptRoot "bootstrap")
}
else {
    $expandedTargets = $Targets
    do
    {
        $expandedTargets = $Targets
        $Targets = $expandedTargets | ForEach-Object {
            $target = $_
            $directory = Join-Path $PSScriptRoot $target
            if (-not (Test-Path -PathType Container -Path $directory)) {
                Write-Error "Target directory not found: $directory"
                return
            }
            $kluctlFile = Join-Path $directory ".kluctl.yml"
            $seqFile = Join-Path $directory "deploy.seq"
            if (Test-Path -PathType Leaf -Path $kluctlFile) {
                return $_
            } elseif (Test-Path -PathType Leaf -Path $seqFile) {
                $seq = Get-Content -Path $seqFile
                return $seq | Where-Object { $_ -notin $expandedTargets } |
                    ForEach-Object { Join-Path $target $_ }
            } else {
                Write-Error "No .kluctl.yml or deploy.seq file found in: $directory"
                return
            }
        }
    } while ($Targets.Count -ine $expandedTargets.Count);
    $expandedTargets = $Targets | ForEach-Object {
        $directory = Join-Path $PSScriptRoot $_
        if (-not (Test-Path -PathType Container -Path $directory)) {
            Write-Error "Target directory not found: $directory"
            return
        }
        $kluctlFile = Join-Path $directory ".kluctl.yml"
        $seqFile = Join-Path $directory "deploy.seq"
        if (Test-Path -PathType Leaf -Path $kluctlFile) {
            return $_
        } elseif (Test-Path -PathType Leaf -Path $seqFile) {
            $seq = Get-Content -Path $seqFile

            
        } else {
            Write-Error "No .kluctl.yml or deploy.seq file found in: $directory"
            return
        }

    }

    $kluctlArgs = @("deploy", "-t", "local")
    if (-not $NoPrune) {
        $kluctlArgs += "--prune"
    }
    if ($SkipConfirmAfterDiff) {
        $kluctlArgs += "--yes"
    }

    
    foreach ($target in $Targets) {
        Write-Host "Deploying target: $target"
        $targetPath = Join-Path $PSScriptRoot $target
        if (-not (Test-Path -Path $targetPath)) {
            Write-Error "Target directory not found: $targetPath"
            return
        }

        Start-Process -FilePath kluctl -NoNewWindow -Wait -ArgumentList $kluctlArgs -WorkingDirectory $targetPath
    }
}