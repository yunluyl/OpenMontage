# Start once per production run; reuse this shell for all ElevenLabs commands.
$ErrorActionPreference = 'Stop'
$activationScript = Join-Path $PSScriptRoot '..\Activate-OpenMontage.ps1'
. $activationScript
$savedElevenLabsKey = $env:ELEVENLABS_API_KEY
$savedOpIntegration = $env:OP_BIOMETRIC_UNLOCK_ENABLED
try {
    $env:ELEVENLABS_API_KEY = 'op://Private/ElevenLabs API Key/credential'
    $env:OP_BIOMETRIC_UNLOCK_ENABLED = 'true'
    & op run -- powershell -NoLogo -NoProfile -NoExit -File $activationScript
    if ($LASTEXITCODE -ne 0) { throw "ElevenLabs session exited with code $LASTEXITCODE" }
} finally {
    $env:ELEVENLABS_API_KEY = $savedElevenLabsKey
    $env:OP_BIOMETRIC_UNLOCK_ENABLED = $savedOpIntegration
}
