$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Compiler = Get-ChildItem "D:\" -Recurse -Filter "armclang.exe" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like "*ARMCLANG*" } |
    Select-Object -First 1 -ExpandProperty FullName

if (-not $Compiler) {
    throw "Could not find armclang.exe under D:\"
}
$BuildDir = Join-Path $Root "build"
$LogPath = Join-Path $Root "armclang_build_log.txt"

New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
Remove-Item -Path (Join-Path $BuildDir "*.o") -Force -ErrorAction SilentlyContinue

$IncludeArgs = @(
    "-I", (Join-Path $Root "include"),
    "-I", (Join-Path $Root "src"),
    "-I", (Join-Path $Root "drivers"),
    "-I", (Join-Path $Root "platform")
)

$Sources = @(
    "src\main.c",
    "src\app_state_machine.c",
    "drivers\sensor_driver.c",
    "drivers\power_monitor.c"
)

$Lines = New-Object System.Collections.Generic.List[string]
$Lines.Add("ARMCLANG firmware source build")
$Lines.Add("Compiler: $Compiler")
$Lines.Add("Started: $(Get-Date -Format s)")

foreach ($Source in $Sources) {
    $SourcePath = Join-Path $Root $Source
    $ObjectPath = Join-Path $BuildDir ([IO.Path]::GetFileNameWithoutExtension($Source) + ".o")
    $Args = @(
        "--target=arm-arm-none-eabi",
        "-mcpu=cortex-m3",
        "-mthumb",
        "-std=c99",
        "-Wall",
        "-Wextra",
        "-DKEIL_UVISION_CONCEPT_BUILD",
        "-c",
        $SourcePath,
        "-o",
        $ObjectPath
    ) + $IncludeArgs

    $Lines.Add("Compiling: $Source")
    $Output = & $Compiler @Args 2>&1
    if ($LASTEXITCODE -ne 0) {
        $Lines.AddRange($Output)
        $Lines | Set-Content -Path $LogPath -Encoding ASCII
        throw "ARMCLANG compile failed for $Source"
    }
    if ($Output) {
        $Lines.AddRange($Output)
    }
    $Lines.Add("OK: $ObjectPath")
}

$Lines.Add("Completed: $(Get-Date -Format s)")
$Lines | Set-Content -Path $LogPath -Encoding ASCII
Get-Content $LogPath
