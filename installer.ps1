
$PythonExe = Join-Path $PSScriptRoot 'py/python.exe'
$GetPip = Join-Path $PSScriptRoot './get-pip.py'
$PackageFolder = Join-Path $PSScriptRoot './pip-packages'
$Requirements = Join-Path $PSScriptRoot './requirements.txt'


Invoke-Expression "${PythonExe} ${GetPip} --no-index --find-links=${PackageFolder} --no-warn-script-location"
Invoke-Expression "${PythonExe} -m pip install -r ${Requirements} --no-index --find-links ${PackageFolder}"
