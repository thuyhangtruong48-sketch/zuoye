$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$VenvPython = Join-Path $ProjectRoot ".venv\Scripts\python.exe"
$BundledPython = "C:\Users\98286\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
$Config = Join-Path $ProjectRoot "data\amap_request_beijing_fire.json"

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
    throw "Beijing fire AMap data fetch failed."
}

& $VenvPython (Join-Path $ProjectRoot "tools\fetch_beijing_fire_traffic_status.py") --output (Join-Path $ProjectRoot "data\amap_fire_base\traffic_status_circle.csv")
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Beijing fire traffic status fetch failed. Falling back to route-planning tmcs traffic values."
}

& $VenvPython (Join-Path $ProjectRoot "tools\create_beijing_fire_scenario.py")
if ($LASTEXITCODE -ne 0) {
    throw "Beijing fire scenario creation failed."
}

& $VenvPython (Join-Path $ProjectRoot "src\rescue_planner.py") --data-dir (Join-Path $ProjectRoot "data\amap_fire") --output-dir (Join-Path $ProjectRoot "outputs\amap_fire")
if ($LASTEXITCODE -ne 0) {
    throw "Beijing fire route planning failed."
}

& $VenvPython (Join-Path $ProjectRoot "tools\create_abstract_route_maps.py")
if ($LASTEXITCODE -ne 0) {
    throw "Abstract route map generation failed."
}

Write-Host ""
Write-Host "Beijing fire data generated in: $(Join-Path $ProjectRoot 'data\amap_fire')"
Write-Host "Beijing fire outputs generated in: $(Join-Path $ProjectRoot 'outputs\amap_fire')"
Write-Host "Abstract route map:"
Write-Host "  $(Join-Path $ProjectRoot 'outputs\amap_fire\route_map_abstract.png')"
