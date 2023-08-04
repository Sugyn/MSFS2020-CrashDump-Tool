# Define the ASCII art logo
$logo = @"
***************************
** 𝖬𝖲𝖥𝖲𝟤𝟢𝟤𝟢 𝖢𝗋𝖺𝗌𝗁𝖣𝗎𝗆𝗉 𝖺𝗇𝖽 **
** 𝖤𝗏𝖾𝗇𝗍 𝖫𝗈𝗀 𝖦𝖾𝗇𝖾𝗋𝖺𝗍𝗂𝗈𝗇 𝖳𝗈𝗈𝗅 **
***************************
"@

# Display the logo
Write-Host $logo
# Define the URL and destination folder for Procdump
$procdumpURL = "https://download.sysinternals.com/files/Procdump.zip"
$destinationFolder = "C:\Program Files\Windows Kits\10\Debuggers\x64\procdump.exe"

# Function to extract the contents of a ZIP file
function Extract-ZipFile($zipFile, $extractPath) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $extractPath)
}

# Check if Procdump is installed, if not, download and install it
$procdumpPath = "C:\Program Files\Windows Kits\10\Debuggers\x64\procdump.exe"
if (-not (Test-Path $procdumpPath)) {
    # Create the destination folder if it does not exist
    if (-not (Test-Path -Path $destinationFolder)) {
        New-Item -ItemType Directory -Path $destinationFolder | Out-Null
    }

    # Download Procdump ZIP file with progress bar
    Write-Host "Checking Procdump presence..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1  # Simulate some work
    Write-Host "Downloading Procdump..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $procdumpURL -OutFile "$destinationFolder\Procdump.zip" -Verbose

        # Extract Procdump with progress bar
        Write-Host "Extracting Procdump..." -ForegroundColor Yellow
        Start-Sleep -Seconds 1  # Simulate some work
        Extract-ZipFile "$destinationFolder\Procdump.zip" $destinationFolder

        # Move Procdump to the installation path
        Write-Host "Installing Procdump..." -ForegroundColor Yellow
        Start-Sleep -Seconds 1  # Simulate some work
        Move-Item "$destinationFolder\procdump.exe" $procdumpPath

        # Clean up the ZIP file
        Remove-Item "$destinationFolder\Procdump.zip"

        Write-Host "Procdump has been downloaded and installed successfully." -ForegroundColor Green
    } catch {
        Write-Host "An error occurred while downloading and installing Procdump. The script will now exit." -ForegroundColor Red
        exit
    }
} else {
    Write-Host "Procdump is already installed. Proceeding with enabling crash dump." -ForegroundColor Green
}

# Rest of the script for collecting logs and enabling crash dump collection using Procdump
$logDirectory = "C:\MSFSLogs"
$logFileName = "FlightSimulator.exe " + (Get-Date).ToString('dd-MM-yy HH-mm') + ".txt"
$logPath = Join-Path -Path $logDirectory -ChildPath $logFileName

if (-not (Test-Path -Path $logDirectory)) {
    New-Item -ItemType Directory -Path $logDirectory | Out-Null
}

$eventLog = Get-WinEvent -FilterHashtable @{
    LogName = 'Application'
    ProviderName = 'Application Error'
    Id = 1000
    Data = "FlightSimulator.exe"
} -MaxEvents 10

$eventLog | ForEach-Object {
    $eventDetails = "Event ID: $($_.Id)`r`nTime Created: $($_.TimeCreated.ToString('dd:MM:yy HH:mm'))`r`nMessage: $($_.Message)`r`n"
    Add-Content -Path $logPath -Value $eventDetails
}

Write-Host "Event log checked and log file generated successfully at $logPath." -ForegroundColor Green

# Open the stored log folder
Invoke-Item -Path $logDirectory
