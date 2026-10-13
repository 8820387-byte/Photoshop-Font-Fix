#requires -Version 5.1
<#
 Windows Photoshop font-recognition repair
 Mode 1: Rename ONLY Photoshop's CT Font Cache folders (reversible).
 Mode 2: Mode 1 + rebuild Windows FontCache *.dat files (admin required).
 Does not uninstall any fonts or reset Photoshop preferences.
#>
[CmdletBinding()]
param([switch]$Deep)

$ErrorActionPreference = 'Stop'

function Write-Line([string]$Text, [string]$Color = 'Gray') {
    Write-Host $Text -ForegroundColor $Color
}
function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
function Confirm-AppsClosed {
    $running = @(Get-Process -Name 'Photoshop', 'Creative Cloud' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ProcessName -Unique)
    if ($running.Count -gt 0) {
        Write-Line ('检测到以下程序仍在运行：' + ($running -join '、')) 'Yellow'
        Write-Line '请先保存文件，并完全退出 Photoshop 和 Adobe Creative Cloud，然后重新运行。' 'Yellow'
        return $false
    }
    return $true
}
function Reset-PhotoshopFontCaches {
    $adobePath = Join-Path $env:APPDATA 'Adobe'
    if (-not (Test-Path -LiteralPath $adobePath -PathType Container)) {
        Write-Line '未找到 Photoshop 用户配置目录，跳过 PS 字体缓存清理。' 'Yellow'
        return 0
    }
    $photoshopDirs = @(Get-ChildItem -LiteralPath $adobePath -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like 'Adobe Photoshop*' })
    $success = 0
    foreach ($dir in $photoshopDirs) {
        # Exact folder name only, in Photoshop's configuration tree.
        $caches = @(Get-ChildItem -LiteralPath $dir.FullName -Directory -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -eq 'CT Font Cache' })
        foreach ($cache in $caches) {
            $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
            $backupName = 'CT Font Cache.backup.' + $stamp + '.' + [Guid]::NewGuid().ToString('N').Substring(0,6)
            try {
                Rename-Item -LiteralPath $cache.FullName -NewName $backupName -ErrorAction Stop
                Write-Line ('已备份 PS 缓存：' + $cache.FullName) 'Green'
                $success++
            } catch {
                Write-Line ('无法重命名缓存：' + $cache.FullName + '。' + $_.Exception.Message) 'Yellow'
            }
        }
    }
    if ($success -eq 0) {
        Write-Line '未找到需要重建的 CT Font Cache（新安装或尚未生成缓存也属正常）。' 'Yellow'
    }
    return $success
}
function Reset-WindowsFontCache {
    if (-not (Test-IsAdministrator)) {
        Write-Line '深度修复需要管理员权限。请右键点击「启动修复.cmd」选择「以管理员身份运行」。' 'Yellow'
        return
    }
    $service = Get-Service -Name 'FontCache' -ErrorAction SilentlyContinue
    if (-not $service) {
        Write-Line '找不到 Windows FontCache 服务：已跳过系统级缓存清理。' 'Yellow'
        return
    }
    $wasRunning = $service.Status -eq 'Running'
    $serviceStopped = $service.Status -eq 'Stopped'
    try {
        if (-not $serviceStopped) {
            Write-Line '正在停止 Windows 字体缓存服务……' 'Cyan'
            Stop-Service -Name 'FontCache' -Force -ErrorAction Stop
            $service.WaitForStatus('Stopped', [TimeSpan]::FromSeconds(15))
            $serviceStopped = $true
        }
        if (-not $serviceStopped) {
            throw '字体缓存服务未停止，为避免文件占用，不执行系统级清理。'
        }
        $serviceLocal = Join-Path $env:windir 'ServiceProfiles\LocalService\AppData\Local'
        $locations = @((Join-Path $serviceLocal 'FontCache'), $serviceLocal)
        $deleted = 0
        foreach ($location in $locations) {
            if (-not (Test-Path -LiteralPath $location -PathType Container)) { continue }
            # Match FontCache*.dat only: do not touch other Windows data files or installed fonts.
            $files = @(Get-ChildItem -LiteralPath $location -File -Filter '*FontCache*.dat' -ErrorAction SilentlyContinue)
            foreach ($item in $files) {
                try {
                    Remove-Item -LiteralPath $item.FullName -Force -ErrorAction Stop
                    Write-Line ('已清理系统缓存：' + $item.Name) 'Green'
                    $deleted++
                } catch {
                    Write-Line ('无法删除缓存：' + $item.FullName + '。' + $_.Exception.Message) 'Yellow'
                }
            }
        }
        Write-Line ("已清理 $deleted 个 Windows 字体缓存文件。") 'Cyan'
    } catch {
        Write-Line ('系统级清理未完成：' + $_.Exception.Message) 'Yellow'
    } finally {
        if ($wasRunning) {
            try {
                Start-Service -Name 'FontCache' -ErrorAction Stop
                Write-Line '已重新启动 Windows 字体缓存服务。' 'Green'
            } catch {
                Write-Line '无法重新启动字体缓存服务，建议立即重启电脑。' 'Yellow'
            }
        }
    }
}

Write-Line ''
Write-Line '=========================================' 'Cyan'
Write-Line '    Photoshop 安装字体后不识别 - 修复脚本' 'Cyan'
Write-Line '=========================================' 'Cyan'
Write-Line '1 - 基础修复（推荐）：备份 PS 字体缓存，让 PS 下次启动重建'
Write-Line '2 - 深度修复：基础修复 + 清理 Windows 字体缓存（需管理员）'
Write-Line '0 - 退出'
Write-Line ''
if (-not $Deep) {
    $choice = Read-Host '请输入选项 [1/2/0]'
    if ($choice -eq '0') { exit 0 }
    if ($choice -notin @('1', '2')) {
        Write-Line '选项无效，未执行任何操作。' 'Yellow'
        exit 1
    }
    $Deep = ($choice -eq '2')
}
if (-not (Confirm-AppsClosed)) { exit 2 }
if ($Deep -and -not (Test-IsAdministrator)) {
    Write-Line '即将申请 Windows 管理员权限，用于深度修复。' 'Cyan'
    try {
        $arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $PSCommandPath + '" -Deep'
        Start-Process -FilePath 'powershell.exe' -ArgumentList $arguments -Verb RunAs -ErrorAction Stop
    } catch {
        Write-Line '未获得管理员权限，请右键以管理员身份启动，或使用基础修复。' 'Yellow'
    }
    exit 0
}
Write-Line ''
Write-Line '开始修复……' 'Cyan'
$updated = Reset-PhotoshopFontCaches
if ($Deep) { Reset-WindowsFontCache }
Write-Line ''
Write-Line '修复步骤执行完毕。没有卸载任何字体，也没有重置 PS 首选项。' 'Green'
Write-Line '请重启电脑后打开 Photoshop，选择文字工具，搜索字体的内部名称。'
Write-Line '若仍不识别：尝试右键字体文件 → 「为所有用户安装」（需要管理员权限）。' 'Yellow'
Write-Line '注意：安装字体时也可能是字体损坏、格式不兼容、名称不同或 PS 字体筛选问题。' 'Yellow'
Write-Line ''
Read-Host '按回车退出' | Out-Null
