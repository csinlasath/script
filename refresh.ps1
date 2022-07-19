# Change back to default DIR
Set-Location -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ProgramFilesDir" -Value "C:\Program Files" -PropertyType String -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ProgramFilesDir (x86)" -Value "C:\Program Files (x86)" -PropertyType String -Force

# Do Last
RefreshEnv.cmd
Set-Location -Path $BASE_DIR
node -v
java --version
