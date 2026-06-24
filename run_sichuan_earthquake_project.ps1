$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$VenvPython = Join-Path $ProjectRoot ".venv\Scripts\python.exe"
$BundledPython = "C:\Users\98286\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
$Config = Join-Path $ProjectRoot "data\amap_request_sichuan_earthquake.json"

if (-not (Test-Path $VenvPython)) {
    if (Test-Path $BundledPython) {
        & $BundledPython -m venv --system-site-packages (Join-Path $ProjectRoot ".venv")
    } else {
        throw "Virtual environment not found and bundled Python is unavailable."
    }
}

if (-not $env:AMAP_KEY) {
    $UserKey = [Environment]::GetEnvironmentVariable("AMAP_KEY", "User")
    if ($UserKey) {
        $env:AMAP_KEY = $UserKey
    }
}

if (-not $env:AMAP_KEY) {
    throw "Missing AMAP_KEY. Set it in the current PowerShell or as a User environment variable."
}

& $VenvPython (Join-Path $ProjectRoot "src\amap_fetcher.py") --config $Config
if ($LASTEXITCODE -ne 0) {
    throw "Sichuan AMap data fetch failed."
}

& $VenvPython (Join-Path $ProjectRoot "tools\create_sichuan_earthquake_scenario.py")
if ($LASTEXITCODE -ne 0) {
    throw "Sichuan earthquake scenario creation failed."
}

& $VenvPython (Join-Path $ProjectRoot "src\rescue_planner.py") --data-dir (Join-Path $ProjectRoot "data\province_sichuan_earthquake") --output-dir (Join-Path $ProjectRoot "outputs\province_sichuan_earthquake")
if ($LASTEXITCODE -ne 0) {
    throw "Sichuan earthquake route planning failed."
}

& $VenvPython (Join-Path $ProjectRoot "tools\create_abstract_route_maps.py")
if ($LASTEXITCODE -ne 0) {
    throw "Sichuan abstract route map generation failed."
}

Write-Host ""
Write-Host "Sichuan earthquake data generated in: $(Join-Path $ProjectRoot 'data\province_sichuan_earthquake')"
Write-Host "Sichuan earthquake outputs generated in: $(Join-Path $ProjectRoot 'outputs\province_sichuan_earthquake')"
Write-Host "Abstract route map:"
Write-Host "  $(Join-Path $ProjectRoot 'outputs\province_sichuan_earthquake\route_map_abstract.png')"
