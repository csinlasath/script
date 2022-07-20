$BASE_DIR = "C:\Devsw"
$DESKTOP_DIR = [Environment]::GetFolderPath("Desktop")
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
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ProgramFilesDir" -Value $PROGRAMS_DIR -PropertyType String -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ProgramFilesDir (x86)" -Value $PROGRAMS_DIR -PropertyType String -Force
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

function Set-Shortcut {
    param ( [string]$APPLICATION_PATH, [string]$DESTINATION_DIR )
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($APPLICATION_PATH)
    $Shortcut.TargetPath = $DESTINATION_DIR
    $Shortcut.Save()
}

choco install vscode -y
Add-AppToPath -APP_DIR "Microsoft VS Code"

choco install git -y --params "/NoAutoCrlf /WindowsTerminal /NoCredentialManager /DefaultBranchName:main /Editor:VisualStudioCode /GitAndUnixToolsOnPath /NoGitLfs"
Add-AppToPath -APP_DIR "Git"
Add-AppToPath -APP_DIR "Git" -SUB_DIR "\bin"

choco install nodejs-lts -ia "INSTALLDIR=$PROGRAMS_DIR\Node" -y
Add-AppToPath -APP_DIR "Node"

choco install Temurin11 --params="/ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /INSTALLDIR=$PROGRAMS_DIR\temurin\ /quiet" -y
Add-AppToPath -APP_DIR "temurin" -SUB_DIR "\bin"

choco install mariadb --params="/INSTALLDIR=$PROGRAMS_DIR\MariaDB 10.9\ /quiet" -y
Add-AppToPath -APP_DIR "MariaDB 10.9" -SUB_DIR "\bin"

choco install postman -y --params="/INSTALLDIR=$PROGRAMS_DIR\postman\ /quiet" -y

# Putty Is inside chocoportable/lib/putty
choco install putty --params="/INSTALLDIR=$PROGRAMS_DIR\putty\ /quiet" -y

# Might have to do this one by hand
choco install maven --params="/INSTALLDIR=$PROGRAMS_DIR\maven\ /quiet" -y

$MARIADB_PATH = (-join($DOWNLOAD_DIR,"\MYSQLWORKBENCH.msi"))
Write-Host "========================================================================================"
Write-Host "Downloading MariaDB"
Write-Host "========================================================================================"
Invoke-WebRequest -Uri "https://mirrors.gigenet.com/mariadb//mariadb-10.8.3/winx64-packages/mariadb-10.8.3-winx64.msi" -OutFile $MARIADB_PATH
Start-Process -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/i $MARIADB_PATH INSTALLDIR='$PROGRAMS_DIR\mariadb' /quiet"
Write-Host "========================================================================================"
Write-Host "MariaDB may be for manual install required"
Write-Host "========================================================================================"

$WORKBENCH_PATH = (-join($DOWNLOAD_DIR,"\MYSQLWORKBENCH.msi"))
Write-Host "========================================================================================"
Write-Host "Downloading MySQL Workbench"
Write-Host "========================================================================================"
Invoke-WebRequest -Uri "https://cdn.mysql.com/Downloads/MySQLGUITools/mysql-workbench-community-8.0.29-winx64.msi" -OutFile $WORKBENCH_PATH
Start-Process -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/i $WORKBENCH_PATH INSTALLDIR='$PROGRAMS_DIR\WORKBENCH' /quiet"
Write-Host "========================================================================================"
Write-Host "MySQL Workbench Manual Installation Required"
Write-Host "========================================================================================"

$MAVEN_PATH = (-join($DOWNLOAD_DIR,"\maven.zip"))
Write-Host "========================================================================================"
Write-Host "Downloading Maven"
Write-Host "========================================================================================"
Invoke-WebRequest -Uri "https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.zip" -OutFile $MAVEN_PATH
Write-Host "========================================================================================"
Write-Host "Installing Maven"
Write-Host "========================================================================================"
Expand-Archive -LiteralPath $MAVEN_PATH -DestinationPath "$PROGRAMS_DIR\maven"
Add-AppToPath -APP_DIR "maven" -SUB_DIR "\bin"
Write-Host "========================================================================================"
Write-Host "Installed Maven"
Write-Host "========================================================================================"

choco install intellijidea-community --params="/INSTALLDIR=$PROGRAMS_DIR\intellij\ /quiet" -y

# Remove Bad Chrome Link
if (Test-Path "$DESKTOP_DIR\Google Chrome.lnk") {
    Remove-Item "$DESKTOP_DIR\Google Chrome.lnk"
}

# Add Chrome Link
Set-Shortcut -APPLICATION_PATH "C:\Program Files\Google\Chrome\Application\chrome.exe" -DESTINATION_DIR "$DESKTOP_DIR\Chrome.lnk"

# Change back to default DIR
Set-Location -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ProgramFilesDir" -Value "C:\Program Files" -PropertyType String -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ProgramFilesDir (x86)" -Value "C:\Program Files (x86)" -PropertyType String -Force

# Do Last
RefreshEnv.cmd
Set-Location -Path $BASE_DIR
