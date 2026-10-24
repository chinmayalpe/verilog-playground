#Requires -Version 5.1
<#
.SYNOPSIS
    Build and run a Verilog project with Icarus Verilog -- the no-make path on Windows.

.EXAMPLE
    .\run.ps1 01-hello-world
.EXAMPLE
    .\run.ps1 02-counter -Wave
.EXAMPLE
    .\run.ps1 -List
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Project = '01-hello-world',

    [switch]$Wave,
    [switch]$List,
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$projectsDir = Join-Path $root 'projects'

if ($List) {
    Get-ChildItem $projectsDir -Directory |
        Where-Object { $_.Name -notlike '_*' } |
        Select-Object -ExpandProperty Name
    return
}

$projDir = Join-Path $projectsDir $Project
if (-not (Test-Path $projDir)) {
    Write-Error "No project '$Project' under projects\. Run '.\run.ps1 -List' to see what's there."
}

$buildDir = Join-Path (Join-Path $root 'build') $Project

if ($Clean) {
    if (Test-Path $buildDir) {
        Remove-Item $buildDir -Recurse -Force
        Write-Host "Removed $buildDir"
    }
    else {
        Write-Host "Nothing to clean for $Project"
    }
    return
}

if (-not (Get-Command iverilog -ErrorAction SilentlyContinue)) {
    Write-Error "iverilog not found on PATH. Install it with 'winget install Icarus.Verilog', then add C:\iverilog\bin to PATH and reopen the shell."
}

# The outer @(...) is load-bearing: a project with a single .v file would
# otherwise leave $sources a bare string, and passing a string where an argument
# array is expected feeds the command one character at a time.
$sources = @(
    @(
        (Join-Path $projDir 'src'),
        (Join-Path $projDir 'tb')
    ) | Where-Object { Test-Path $_ } |
        ForEach-Object { Get-ChildItem $_ -Filter *.v -File } |
        Select-Object -ExpandProperty FullName
)

if ($sources.Count -eq 0) {
    Write-Error "No .v files under $projDir\{src,tb}."
}

if (-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
}
$vvpOut = Join-Path $buildDir 'sim.vvp'

Write-Host "Compiling $Project ($($sources.Count) file(s))..." -ForegroundColor Cyan
& iverilog -g2012 -Wall -o $vvpOut $sources
if ($LASTEXITCODE -ne 0) { Write-Error "iverilog failed with exit code $LASTEXITCODE" }

# Run from the build dir so any $dumpfile output lands there, not in the repo root.
Write-Host "Running $Project..." -ForegroundColor Cyan
Push-Location $buildDir
try {
    & vvp 'sim.vvp'
    $simExit = $LASTEXITCODE
}
finally {
    Pop-Location
}
if ($simExit -ne 0) { Write-Error "Simulation failed with exit code $simExit" }

if ($Wave) {
    $vcd = Join-Path $buildDir 'wave.vcd'
    if (Test-Path $vcd) {
        if (Get-Command gtkwave -ErrorAction SilentlyContinue) {
            & gtkwave $vcd
        }
        else {
            Write-Host "gtkwave not on PATH. Waveform is at $vcd" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "No wave.vcd produced. Add `$dumpfile(`"wave.vcd`"); and `$dumpvars; to the testbench." -ForegroundColor Yellow
    }
}
