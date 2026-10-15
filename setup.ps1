$ErrorActionPreference = "Stop"
$ProjectDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$EnvironmentFile = Join-Path $ProjectDirectory ".env"

if (Test-Path $EnvironmentFile) {
    Write-Host ".env zaten mevcut; değiştirilmedi."
    exit 0
}

$Bytes = New-Object byte[] 32
$Random = [Security.Cryptography.RandomNumberGenerator]::Create()
try {
    $Random.GetBytes($Bytes)
} finally {
    $Random.Dispose()
}
$ApiKey = -join ($Bytes | ForEach-Object { $_.ToString("x2") })

@"
MODEL_NAME=hadad/qwen3-4bd:Q8_0
API_KEY=$ApiKey
OLLAMA_KEEP_ALIVE=10m
"@ | Set-Content -Encoding utf8 $EnvironmentFile

Write-Host ".env oluşturuldu. API anahtarınız: $ApiKey"
Write-Host "Bu anahtarı güvenli bir yerde saklayın."

