# Script para automatizar commits e pushes
$timeInterval = 30 # Intervalo em minutos para verificar alterações

function Show-Notification {
    param($Message)
    Add-Type -AssemblyName System.Windows.Forms
    $global:balloon = New-Object System.Windows.Forms.NotifyIcon
    $path = (Get-Process -id $pid).Path
    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
    $balloon.BalloonTipText = $Message
    $balloon.BalloonTipTitle = "Auto Commit"
    $balloon.Visible = $true
    $balloon.ShowBalloonTip(5000)
}

function Get-GitStatus {
    $status = git status --porcelain
    return $status
}

function Auto-Commit {
    while ($true) {
        $changes = Get-GitStatus
        if ($changes) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $message = "Auto commit: Alterações em $timestamp"
            
            # Adiciona todas as alterações
            git add .
            
            # Faz o commit
            git commit -m $message
            
            # Faz o push
            git push
            
            Show-Notification "Commit e push realizados com sucesso!"
        }
        
        # Aguarda o intervalo definido
        Start-Sleep -Seconds ($timeInterval * 60)
    }
}

# Verifica se está em um repositório Git
if (Test-Path .git) {
    Write-Host "Monitorando alterações a cada $timeInterval minutos..."
    Write-Host "Pressione Ctrl+C para parar."
    Auto-Commit
} else {
    Write-Host "Este diretório não é um repositório Git!"
} 