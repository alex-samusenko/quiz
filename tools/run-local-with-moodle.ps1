$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$secretFile = Join-Path $projectRoot ".moodle-service.env"
if (-not (Test-Path -LiteralPath $secretFile)) {
    throw "Не найден $secretFile. Скопируйте защищённый файл сервиса Moodle в корень проекта."
}

$secretValues = @{}
Get-Content -LiteralPath $secretFile | ForEach-Object {
    if ($_ -match '^([^#=]+)=(.*)$') {
        $secretValues[$matches[1].Trim()] = $matches[2].Trim().Trim('"').Trim("'")
    }
}
if (-not $secretValues.ContainsKey("TOKEN")) {
    throw "В $secretFile отсутствует TOKEN."
}

$env:MOODLE_INTEGRATION_ENABLED = "true"
$env:MOODLE_BASE_URL = "https://oldlms.galaktika.ru"
$env:MOODLE_TOKEN = $secretValues["TOKEN"]

Push-Location $projectRoot
try {
    & mvn spring-boot:run
} finally {
    Pop-Location
    Remove-Item Env:MOODLE_TOKEN -ErrorAction SilentlyContinue
}
