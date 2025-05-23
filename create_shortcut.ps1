$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Git Projects Monitor.lnk")
$Shortcut.TargetPath = "C:\cursor projetos\start_git_monitor.bat"
$Shortcut.WorkingDirectory = "C:\cursor projetos"
$Shortcut.Description = "Monitor automático de projetos Git"
$Shortcut.Save() 