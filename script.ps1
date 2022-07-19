$BASE_DIR = "C:\Devsw"
$DOWNLOAD_DIR = "$BASE_DIR\downloads"
if(!(Test-Path -Path $DOWNLOAD_DIR)) {
    New-Item $DOWNLOAD_DIR -itemType Directory
}

$PROGRAMS_DIR = "$BASE_DIR\programs"
if(!(Test-Path -Path $PROGRAMS_DIR)) {
    New-Item $PROGRAMS_DIR -itemType Directory
}

$CHOCO_DIR="$PROGRAMS_DIR\chocoportable"
$env:ChocolateyInstall="$CHOCO_DIR"
Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

Start-Sleep 60

Set-Location -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ProgramFilesDir" -Value "C:\sw-dir\programs" -PropertyType String -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ProgramFilesDir (x86)" -Value "C:\sw-dir\programs" -PropertyType String -Force
Start-Sleep 10

function Add-AppToPath {
    param([string]$APP_DIR, [string]$SUB_DIR)

    Write-Host "`n`n`n========================================================================================"
    Write-Host " Adding $APP_DIR to Path..."

    $EXISTING_PATH_VARS = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
    $PATH_WITH_APP = "$EXISTING_PATH_VARS;$PROGRAMS_DIR\$APP_DIR$SUB_DIR"
    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $PATH_WITH_APP
    Write-Host "========================================================================================"
    Write-Host " Added $APP_DIR to Path!"
    Write-Host "========================================================================================`n`n`n"
    Start-Sleep 10
}

choco uninstall vscode.install -a -y -f
choco uninstall vscode -a -y -f
choco install vscode -y
Add-AppToPath -APP_DIR "Microsoft VS Code"

choco uninstall git -a -y
choco install git -y --params "/NoAutoCrlf /WindowsTerminal /NoCredentialManager /DefaultBranchName:main /Editor:VisualStudioCode /GitAndUnixToolsOnPath /NoGitLfs"
Add-AppToPath -APP_DIR "Git"
Add-AppToPath -APP_DIR "Git" -SUB_DIR "\bin"

choco uninstall nodejs-lts -y
choco install nodejs-lts -ia "INSTALLDIR=$PROGRAMS_DIR\Node" -y
Add-AppToPath -APP_DIR "Node"

choco uninstall Temurin11 -y
choco install Temurin11 --params="/ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /INSTALLDIR=$PROGRAMS_DIR\temurin\ /quiet" -y
Add-AppToPath -APP_DIR "temurin" -SUB_DIR "\bin"

choco uninstall mariadb -y
choco install mariadb --params="/INSTALLDIR=$PROGRAMS_DIR\MariaDB 10.9\ /quiet" -y
Add-AppToPath -APP_DIR "MariaDB 10.9" -SUB_DIR "\bin"

choco uninstall googlechrome -a -y -f
choco install googlechrome --params="/INSTALLDIR=$PROGRAMS_DIR\chrome\ /quiet" -y

choco uninstall postman -a -y -f
choco install postman -y --params="/INSTALLDIR=$PROGRAMS_DIR\postman\ /quiet" -y

# Putty Is inside chocoportable/lib/putty
choco uninstall putty -a -y -f
choco install putty --params="/INSTALLDIR=$PROGRAMS_DIR\putty\ /quiet" -y

# Might have to do this one by hand
choco uninstall maven -a -y -f
choco install maven --params="/INSTALLDIR=$PROGRAMS_DIR\maven\ /quiet" -y

$WORKBENCH_PATH = (-join($DOWNLOAD_DIR,"\MYSQLWORKBENCH.msi"))
Write-Host "========================================================================================"
Write-Host "Downloading MySQL Workbench"
Write-Host "========================================================================================"
Invoke-WebRequest -Uri "https://cdn.mysql.com/Downloads/MySQLGUITools/mysql-workbench-community-8.0.29-winx64.msi" -OutFile $WORKBENCH_PATH
Start-Process -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/i $WORKBENCH_PATH INSTALLDIR='$PROGRAMS_DIR\WORKBENCH' /quiet"
Write-Host "========================================================================================"
Write-Host "MySQL Workbench Manual Installation Required"
Write-Host "========================================================================================"

# Change back to default DIR
# Set-Location -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
# New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ProgramFilesDir" -Value "C:\Program Files" -PropertyType String -Force
# New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ProgramFilesDir (x86)" -Value "C:\Program Files (x86)" -PropertyType String -Force

choco uninstall intellijidea-community -a -y -f
choco install intellijidea-community --params="/INSTALLDIR=$PROGRAMS_DIR\intellij\ /quiet" -y

# Do Last
RefreshEnv.cmd
Set-Location -Path $BASE_DIR
node -v
java --version
