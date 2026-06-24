$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$VenvPython = Join-Path $ProjectRoot ".venv\Scripts\python.exe"
$BundledPython = "C:\Users\98286\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
$AmapConfig = Join-Path $ProjectRoot "data\amap_request.json"
$AmapExample = Join-Path $ProjectRoot "data\amap_request.example.json"

if (-not (Test-Path $VenvPython)) {
    if (Test-Path $BundledPython) {
        & $BundledPython -m venv --system-site-packages (Join-Path $ProjectRoot ".venv")
    } else {
        throw "Virtual environment not found and bundled Python is unavailable."
    }
}

if (-not (Test-Path $AmapConfig)) {
    Copy-Item $AmapExample $AmapConfig
    throw "Created data\amap_request.json from the example. Edit it and set AMAP_KEY, then rerun this script."
}

& $VenvPython (Join-Path $ProjectRoot "src\amap_fetcher.py") --config $AmapConfig
if ($LASTEXITCODE -ne 0) {
    throw "AMap data fetch failed."
}
& $VenvPython (Join-Path $ProjectRoot "src\rescue_planner.py") --data-dir (Join-Path $ProjectRoot "data\amap") --output-dir (Join-Path $ProjectRoot "outputs\amap")
if ($LASTEXITCODE -ne 0) {
    throw "Route planning failed."
}

& $VenvPython (Join-Path $ProjectRoot "tools\create_disaster_scenarios.py")
if ($LASTEXITCODE -ne 0) {
    throw "Historical disaster scenario creation failed."
}

& $VenvPython (Join-Path $ProjectRoot "src\rescue_planner.py") --data-dir (Join-Path $ProjectRoot "data\amap_earthquake") --output-dir (Join-Path $ProjectRoot "outputs\amap_earthquake")
if ($LASTEXITCODE -ne 0) {
    throw "Earthquake route planning failed."
}

& $VenvPython (Join-Path $ProjectRoot "src\rescue_planner.py") --data-dir (Join-Path $ProjectRoot "data\amap_flood") --output-dir (Join-Path $ProjectRoot "outputs\amap_flood")
if ($LASTEXITCODE -ne 0) {
    throw "Flood route planning failed."
}

& $VenvPython (Join-Path $ProjectRoot "tools\create_amap_static_visuals.py")
if ($LASTEXITCODE -ne 0) {
    throw "AMap static map visualization failed."
}

& $VenvPython (Join-Path $ProjectRoot "tools\create_abstract_route_maps.py")
if ($LASTEXITCODE -ne 0) {
    throw "Abstract route map visualization failed."
}

Write-Host ""
Write-Host "AMap outputs generated in: $(Join-Path $ProjectRoot 'outputs\amap')"
Write-Host "Earthquake outputs generated in: $(Join-Path $ProjectRoot 'outputs\amap_earthquake')"
Write-Host "Flood outputs generated in: $(Join-Path $ProjectRoot 'outputs\amap_flood')"
Write-Host "Static basemap images:"
Write-Host "  $(Join-Path $ProjectRoot 'outputs\amap_earthquake\route_map_amap_static.png')"
Write-Host "  $(Join-Path $ProjectRoot 'outputs\amap_flood\route_map_amap_static.png')"
Write-Host "Abstract route maps:"
Write-Host "  $(Join-Path $ProjectRoot 'outputs\amap_earthquake\route_map_abstract.png')"
Write-Host "  $(Join-Path $ProjectRoot 'outputs\amap_flood\route_map_abstract.png')"
