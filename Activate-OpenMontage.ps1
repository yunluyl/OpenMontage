# Dot-source this file before working with OpenMontage:
# . .\Activate-OpenMontage.ps1
$openMontageRoot = $PSScriptRoot
$openMontageNode = Join-Path $openMontageRoot '.runtime\node-v24.21.0-win-x64'
$openMontageFfmpeg = Join-Path $openMontageRoot '.runtime\ffmpeg'
& (Join-Path $openMontageRoot '.venv\Scripts\Activate.ps1')
$env:PATH = "$openMontageNode;$openMontageFfmpeg;$env:PATH"
$env:PYTHONUTF8 = '1'
$env:PYTHONIOENCODING = 'utf-8'
$env:HYPERFRAMES_BROWSER_PATH = Join-Path $openMontageRoot '.remotion\chrome-headless-shell\win64\chrome-headless-shell-win64\chrome-headless-shell.exe'
Set-Location -LiteralPath $openMontageRoot
