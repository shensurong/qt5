. "$PSScriptRoot\helpers.ps1"

& pip install --upgrade conan==0.15.0

[Environment]::SetEnvironmentVariable("CI_CONAN_BUILDINFO_DIR", "C:\Utils\conanbuildinfos", "Machine")

function Start-Process-Logged
{
    Write-Host "Start-Process", $args
    Start-Process @args
}

function Run-Conan-Install
{
    Param (
        [string]$ConanfilesDir,
        [string]$BuildinfoDir,
        [string]$Arch,
        [string]$Compiler,
        [string]$CompilerVersion,
        [string]$CompilerRuntime,
        [string]$CompilerLibcxx
    )

    if ($CompilerRuntime) {
        $extraArgs = "-s compiler.runtime=$($CompilerRuntime)"
    }

    if ($CompilerLibcxx) {
        $extraArgs = "-s compiler.libcxx=$($CompilerLibcxx)"
    }

    Get-ChildItem -Path "$ConanfilesDir\*.txt" |
    ForEach-Object {
        $outpwd = "C:\Utils\conanbuildinfos\$($BuildinfoDir)\$($_.BaseName)"
        $manifestsDir = "$($_.DirectoryName)\$($_.BaseName).manifests"
        New-Item $outpwd -Type directory -Force
        Start-Process-Logged `
            conan `
            -WorkingDirectory $outpwd `
            -ArgumentList "install -f $($_.FullName) --verify $($manifestsDir)", `
                '-s', ('compiler="' + $Compiler + '"'), `
                "-s os=Windows -s arch=$($Arch) -s compiler.version=$($CompilerVersion) $($extraArgs)" `
            -NoNewWindow -Wait -Verbose
    }
}