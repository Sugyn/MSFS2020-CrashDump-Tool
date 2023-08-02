# Define the path where Procdump will be installed
$procdumpPath = "C:\Program Files\Windows Kits\10\Debuggers\x64\procdump.exe"

# Function to enable crash dump collection using Procdump
function EnableProcdump($processName, $dumpPath) {
    $arguments = "-accepteula -ma $($processName) `"$($dumpPath)`""
    Start-Process -FilePath $procdumpPath -ArgumentList $arguments -Wait
}

# Function to collect event logs
function CollectEventLogs {
    # ... (same as before)
}

# Create the main form
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text = "Crash Dump Collection Tool For MSFS2020"
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Create labels
$label = New-Object System.Windows.Forms.Label
$label.Text = "This tool will collect Windows Event Logs and enable crash dump collection for FlightSimulator.exe."
$label.Location = New-Object System.Drawing.Point(10, 10)
$label.Size = New-Object System.Drawing.Size(380, 60)

# Check available disk space
$logDirectory = "C:\Logs"
$requiredSpaceThreshold = 10GB  # Adjust this value as needed
$availableSpaceBytes = (Get-PSDrive -Name 'C').Free
if ($availableSpaceBytes -lt $requiredSpaceThreshold) {
    $warningMessage = "Warning: There is low disk space available on the system drive. Proceed with caution."
    $label.Text += "`r`n`r`n$warningMessage"
}

# Create buttons
$buttonProceed = New-Object System.Windows.Forms.Button
$buttonProceed.Text = "Proceed"
$buttonProceed.Location = New-Object System.Drawing.Point(80, 100)
$buttonProceed.Size = New-Object System.Drawing.Size(100, 30)
$buttonProceed.Add_Click({
    # Call the CollectEventLogs function to proceed with log collection and crash dump enablement
    CollectEventLogs

    # Enable crash dump collection using Procdump
    $crashDumpFileName = "FlightSimulator.exe " + (Get-Date).ToString('dd-MM-yy HH-mm') + " crashdump.dmp"
    $crashDumpFilePath = Join-Path -Path $logDirectory -ChildPath $crashDumpFileName

    if (-not (Test-Path $procdumpPath)) {
        # Prompt user about Procdump requirement and download
        $procdumpExplanation = "This script requires Procdump to be installed. Procdump is a command-line utility that enables monitoring and creating crash dumps during application crashes. It helps diagnose and troubleshoot application issues."

        $procdumpDownloadPrompt = "Procdump is not installed on your system. $procdumpExplanation`r`n`r`nDo you want to continue and download Procdump now?"

        $downloadResult = [System.Windows.Forms.MessageBox]::Show($procdumpDownloadPrompt, "Procdump Installation", [System.Windows.Forms.MessageBoxButtons]::YesNo)

        if ($downloadResult -eq [System.Windows.Forms.DialogResult]::Yes) {
            # Download and install Procdump
            $procdumpDownloadURL = "https://download.sysinternals.com/files/Procdump.zip"
            $downloadPath = "$env:TEMP\Procdump.zip"

            try {
                # Download the Procdump ZIP file
                Invoke-WebRequest -Uri $procdumpDownloadURL -OutFile $downloadPath

                $procdumpDestination = Join-Path -Path $PSScriptRoot -ChildPath "Procdump"

                # Extract Procdump
                Expand-Archive -Path $downloadPath -DestinationPath $procdumpDestination -Force

                # Inform user about successful installation
                [System.Windows.Forms.MessageBox]::Show("Procdump has been downloaded and installed. You can now proceed with the script.")

                # Close the form after successful installation
                $form.Close()
            } catch {
                [System.Windows.Forms.MessageBox]::Show("An error occurred while downloading and installing Procdump. The script will now exit.")
                exit
            }
        }
        else {
            # User chose not to download and install Procdump, exit the script
            [System.Windows.Forms.MessageBox]::Show("Procdump is required for crash dump collection. The script will now exit.")
            exit
        }
    }

    # Proceed with enabling crash dump collection using Procdump
    EnableProcdump "FlightSimulator.exe" $crashDumpFilePath

    # Show message box to indicate successful completion
    [System.Windows.Forms.MessageBox]::Show("Crash dump collection enabled for FlightSimulator.exe. Logs are stored in $logDirectory.")

    # Open the log directory
    Invoke-Item -Path $logDirectory
    
    # Close the form after successful completion
    $form.Close()
})

$buttonCancel = New-Object System.Windows.Forms.Button
$buttonCancel.Text = "Cancel"
$buttonCancel.Location = New-Object System.Drawing.Point(220, 100)
$buttonCancel.Size = New-Object System.Drawing.Size(100, 30)
$buttonCancel.Add_Click({ $form.Close() })

# Add controls to the form
$form.Controls.Add($label)
$form.Controls.Add($buttonProceed)
$form.Controls.Add($buttonCancel)

# Show the form and capture user response
$result = $form.ShowDialog()

# Process user response
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    # User clicked "Proceed"
    # The CollectEventLogs function and crash dump collection will be executed
}
else {
    # User clicked "Cancel" or closed the form
    # No further action is needed
}

# Open the log directory
Invoke-Item -Path $logDirectory

# End of the script
