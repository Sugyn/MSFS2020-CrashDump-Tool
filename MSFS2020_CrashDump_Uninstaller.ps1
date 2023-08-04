# Define the path where Procdump is installed
$procdumpPath = "C:\Program Files\Windows Kits\10\Debuggers\x64\procdump.exe"

# Check if Procdump is installed
if (Test-Path $procdumpPath) {
    # Prompt user to confirm uninstallation
    $uninstallPrompt = "Procdump is currently installed on your system. Uninstalling Procdump will permanently remove it from your system. Do you want to proceed with the uninstallation? (Yes/No)"
    $userResponse = Read-Host -Prompt $uninstallPrompt

    if ($userResponse -eq "Yes") {
        # Procdump is installed and user confirmed, proceed with uninstallation

        # Remove Procdump executable
        Remove-Item -Path $procdumpPath -Force

        # Remove Procdump folder (Optional)
        $procdumpFolder = "C:\Program Files\Windows Kits\10\Debuggers\x64"
        if (Test-Path $procdumpFolder) {
            Remove-Item -Path $procdumpFolder -Force -Recurse
        }

        Write-Host "Procdump has been successfully uninstalled from your system."
    } else {
        # User chose not to proceed with the uninstallation
        Write-Host "Procdump uninstallation cancelled. Procdump will remain installed on your system."
    }
} else {
    # Procdump is not installed
    Write-Host "Procdump is not installed on your system. There is nothing to uninstall."
}
