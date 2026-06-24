$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$VenvPython = Join-Path $ProjectRoot ".venv\Scripts\python.exe"
$BundledPython = "C:\Users\98286\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"

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

if ($env:AMAP_KEY) {
    & $VenvPython (Join-Path $ProjectRoot "tools\fetch_traffic_status_circle.py") `
        --location "121.439175,31.235771" `
        --radius 3000 `
        --level 5 `
        --output (Join-Path $ProjectRoot "data\amap_shanghai_fire_base\traffic_status_circle.csv")
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Shanghai fire traffic status fetch failed. OSM network will still be generated without fresh traffic matching."
    }
} else {
    Write-Warning "AMAP_KEY is unavailable. OSM network will be generated without fresh AMap traffic status."
}

& $VenvPython (Join-Path $ProjectRoot "tools\create_osm_shanghai_fire_network.py")
if ($LASTEXITCODE -ne 0) {
    throw "OSM Shanghai fire network creation failed."
}

& $VenvPython (Join-Path $ProjectRoot "src\rescue_planner.py") --data-dir (Join-Path $ProjectRoot "data\osm_shanghai_fire") --output-dir (Join-Path $ProjectRoot "outputs\osm_shanghai_fire")
if ($LASTEXITCODE -ne 0) {
    throw "OSM Shanghai fire route planning failed."
}

& $VenvPython (Join-Path $ProjectRoot "tools\create_abstract_route_maps.py")
if ($LASTEXITCODE -ne 0) {
    throw "Abstract route map generation failed."
}

Write-Host ""
Write-Host "OSM Shanghai fire data generated in: $(Join-Path $ProjectRoot 'data\osm_shanghai_fire')"
Write-Host "OSM Shanghai fire outputs generated in: $(Join-Path $ProjectRoot 'outputs\osm_shanghai_fire')"
Write-Host "Abstract route map:"
Write-Host "  $(Join-Path $ProjectRoot 'outputs\osm_shanghai_fire\route_map_abstract.png')"
