# Script para monitorar múltiplos projetos Git
$projectsPath = "C:/cursor projetos" # Caminho base dos seus projetos
$timeInterval = 30 # Intervalo em minutos para verificar alterações

function Show-Notification {
    param($Message)
    Add-Type -AssemblyName System.Windows.Forms
    $global:balloon = New-Object System.Windows.Forms.NotifyIcon
    $path = (Get-Process -id $pid).Path
    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
    $balloon.BalloonTipText = $Message
    $balloon.BalloonTipTitle = "Git Projects Monitor"
    $balloon.Visible = $true
    $balloon.ShowBalloonTip(5000)
}

function Get-GitStatus {
    param($Directory)
    Push-Location $Directory
    $status = git status --porcelain
    Pop-Location
    return $status
}

function Invoke-GitCommit {
    param($Directory)
    Push-Location $Directory
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $message = "Auto commit: Alterações em $timestamp"
    
    # Adiciona todas as alterações
    git add .
    
    # Faz o commit
    git commit -m $message
    
    # Faz o push
    git push
    Pop-Location
    
    Show-Notification "Commit e push realizados com sucesso em $(Split-Path $Directory -Leaf)!"
}

function Initialize-GitRepository {
    param($Directory)
    if (-not (Test-Path "$Directory/.git")) {
        Push-Location $Directory
        git init
        git add .
        git commit -m "Commit inicial: Novo projeto criado"
        
        # Tenta criar o repositório no GitHub e fazer push
        try {
            $repoName = Split-Path $Directory -Leaf
            gh repo create $repoName --private --source=. --remote=origin
            git push -u origin main
            Show-Notification "Novo repositório criado para $repoName"
        } catch {
            Write-Host "Não foi possível criar o repositório no GitHub automaticamente"
        }
        Pop-Location
    }
}

function Start-ProjectsMonitor {
    while ($true) {
        # Procura por novos diretórios e inicializa Git se necessário
        Get-ChildItem -Path $projectsPath -Directory | ForEach-Object {
            Initialize-GitRepository $_.FullName
        }

        # Verifica alterações em todos os projetos Git
        Get-ChildItem -Path $projectsPath -Directory | ForEach-Object {
            if (Test-Path "$($_.FullName)/.git") {
                $changes = Get-GitStatus $_.FullName
                if ($changes) {
                    Invoke-GitCommit $_.FullName
                }
            }
        }
        
        # Aguarda o intervalo definido
        Start-Sleep -Seconds ($timeInterval * 60)
    }
}

# Inicia o monitoramento
Write-Host "Monitorando projetos em $projectsPath a cada $timeInterval minutos..."
Write-Host "Pressione Ctrl+C para parar."
Start-ProjectsMonitor 