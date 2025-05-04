if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"  `"$($MyInvocation.MyCommand.UnboundArguments)`""
 Exit
} # https://stackoverflow.com/a/63344749

# Create a list of options
$options = @("Manage printer", "Clean Windows")

# Display the menu
Write-Host "Select an option:"
for ($i = 0; $i -lt $options.Count; $i++) {
    Write-Host "$($i + 1). $($options[$i])"
}

# Get user input
$userInput = Read-Host "Enter the number of your choice"

# Use switch to handle input
switch ($userInput) {
    "1" {
        # $service = "wuauserv"; # - WindowsUpdate
		# $service = "TabletInputService";
		$service = "Spooler"; # - "Print Spooler" - Help reduce one's attack surface as a result of the various CVE's assoicated with running the printing 	service that are to this day (2023-04-26) seemingly only somewhat resolved via Windows patches.
		$previousState = Get-Service $service | Select -expand Status
		switch ($previousState) {
			Stopped {Set-Service -Name $service -StartupType Manual; Start-Service $service}
			Running {Stop-Service $service; Set-Service -Name $service -StartupType Disabled}
		}
		$newState = Get-Service $service | Select -expand Status
		Write-Output "${service}, ${previousState} -> ${newState}"
    }
    "2" {
        Net Stop WUAUSERV
		Remove-Item %windir%\softwaredistribution\downloads\* -Force -Recurse -Confirm # /F /Q
		Remove-Item C:\Windows\SoftwareDistribution\Download\* -Force -Recurse -Confirm # /F /Q
		Net Start WUAUSERV

		Delete-DeliveryOptimizationCache -IncludePinnedFiles -Force
		Remove-Item "C:\Users\J\AppData\Local\Microsoft\Windows Media"\*cache* -Force -Recurse -Confirm # /F /Q
		Remove-Item C:\Windows\Installer\* -Force -Recurse -Confirm # /F /Q
		Remove-Item C:\Windows\SoftwareDistribution -Force -Recurse -Confirm # /F /Q
		Remove-Item C:\ProgramData\Microsoft\MapData -Force -Recurse -Confirm # /F /Q 
		Remove-Item C:\ProgramData\Microsoft\EdgeUpdate -Force -Recurse -Confirm # /F /Q
		Remove-Item "C:\ProgramData\Microsoft\User Account Pictures" -Force -Recurse -Confirm # /F /Q
		Remove-Item "C:\ProgramData\Package Cache" -Force -Recurse -Confirm # /F /Q
		Remove-Item "C:\ProgramData\Ubisoft\Ubisoft Game Launcher\patch" -Force -Recurse -Confirm # /F /Q
		Remove-Item C:\Temp -Force -Recurse -Confirm # /F /Q
		Remove-Item I:\TEMP\* -Force -Recurse -Confirm
		dism /online /Cleanup-Image /StartComponentCleanup /NoRestart /ResetBase
    }
    default {
        Write-Host "Invalid selection. Please try again."
    }
}
# Switch statement via Chat GPT
pause