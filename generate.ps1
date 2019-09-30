$ErrorActionPreference = "Stop"

$ReleaseZip = Join-Path $PSScriptRoot './portable_python.zip'
$ReleaseFolder = Join-Path $PSScriptRoot './release'
$WorkRoot = Join-Path $PSScriptRoot './work'
$PythonZip = Join-Path $WorkRoot './python.zip'
$GetPip = Join-Path $WorkRoot './get-pip.py'
$PythonFolder = Join-Path $WorkRoot './tmp_py'
$PythonExe = Join-Path $PythonFolder 'python.exe'
$ReleasePythonFolder = Join-Path $WorkRoot './py'
$EmbedPythonUrl = 'https://www.python.org/ftp/python/3.6.8/python-3.6.8-embed-amd64.zip'
$GetPipUrl = 'https://bootstrap.pypa.io/get-pip.py'
$PackageFolder = Join-Path $WorkRoot './pip-packages'
$Requirements = Join-Path $PSScriptRoot './requirements.txt'
$Installer = Join-Path $PSScriptRoot './installer.ps1'
function Out-Log($Msg) {
   $TimeStr = '[' + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + '] '
   $LogText = "$TimeStr$Msg"
   Write-Host $LogText
}


Remove-Item -Path $WorkRoot -Recurse -ErrorAction Ignore
New-Item -Path $WorkRoot -ItemType Directory | Out-Null

Out-Log "Download python archive (${PythonZip})"
Invoke-WebRequest -Uri $EmbedPythonUrl -OutFile $PythonZip
Out-Log 'Download get-pip.py'
Invoke-WebRequest -Uri $GetPipUrl -OutFile $GetPip

Out-Log "Extract ${PythonZip} to ${PythonFolder}"
Expand-Archive -Path $PythonZip -DestinationPath $PythonFolder

Out-Log 'Search pythonXX._pth'
$PythonPth = (Get-ChildItem $PythonFolder | Where-Object { $_.Name -match 'python.*\._pth' }[0])

Out-Log ("Fix {0}." -f $PythonPth.FullName)
(Get-Content $PythonPth.FullName) |
ForEach-Object { $_ -replace '^#import', 'import' } |
Set-Content $PythonPth.FullName
Copy-Item -Path $PythonFolder -Destination $ReleasePythonFolder -Recurse

Out-Log "python --version"
Invoke-Expression "${PythonExe} --version"

Out-Log 'Run python get-pip.py'
Invoke-Expression "${PythonExe} ${GetPip} --no-warn-script-location"

Out-Log 'Download pip, wheel, setuptools'
Invoke-Expression "${PythonExe} -m pip wheel pip wheel setuptools --wheel-dir ${PackageFolder}"

Out-Log 'Download requirements'
Invoke-Expression "${PythonExe} -m pip wheel -r ${Requirements} --wheel-dir ${PackageFolder}"

Out-Log 'Release...'
Remove-Item -Path $ReleaseFolder -Recurse -ErrorAction Ignore
New-Item -Path $ReleaseFolder -ItemType Directory | Out-Null
$ReleaseTargets = @(
   , $GetPip
   , $PackageFolder
   , $Requirements
   , $ReleasePythonFolder
   , $Installer
)
foreach ($Target in $ReleaseTargets) {
   Write-Host $Target
   Copy-Item -Path $Target -Destination $ReleaseFolder -Recurse
}

Out-Log 'Compress releases'
Remove-Item -Path $ReleaseZip -ErrorAction Ignore
Compress-Archive -Path "${ReleaseFolder}/*" -DestinationPath $ReleaseZip
