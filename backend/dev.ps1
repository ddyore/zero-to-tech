# 启动 FastAPI 开发服务器。
# 为什么需要这个脚本：PowerShell 没有 source，激活脚本在 .venv\Scripts\ 而不是 bin/，
# 每次手打两条命令容易漏掉一步，出错时又只看到一个语焉不详的 CommandNotFound。
#
# 用法：.\dev.ps1          启动在 8000 端口
#       .\dev.ps1 8080     启动在指定端口

param([int]$Port = 8000)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $here

$python = Join-Path $here '.venv\Scripts\python.exe'
$activate = Join-Path $here '.venv\Scripts\Activate.ps1'

if (-not (Test-Path $python)) {
    Write-Host "找不到虚拟环境：$here\.venv" -ForegroundColor Red
    Write-Host "先重建环境，再运行本脚本：" -ForegroundColor Yellow
    Write-Host "  python -m venv .venv"
    Write-Host "  .\.venv\Scripts\python.exe -m pip install -r requirements.txt"
    exit 1
}

if (-not (Test-Path (Join-Path $here 'main.py'))) {
    Write-Host "找不到 main.py：$here" -ForegroundColor Red
    Write-Host "请在 backend 目录内运行本脚本。" -ForegroundColor Yellow
    exit 1
}

. $activate

$cli = Join-Path $here '.venv\Scripts\fastapi.exe'
if (-not (Test-Path $cli)) {
    Write-Host "缺少 fastapi-cli，回退到 uvicorn。" -ForegroundColor Yellow
    Write-Host "补装：.\.venv\Scripts\python.exe -m pip install --no-deps fastapi-cli" -ForegroundColor Yellow
    & $python -m uvicorn main:app --reload --port $Port
    exit $LASTEXITCODE
}

& $cli dev main.py --port $Port
exit $LASTEXITCODE
