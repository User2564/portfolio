# Allows the user to either enable / disable the printer service or clean up their Windows install.
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

# Use switch to handle input | Switch statement sourced via ChatGPT
switch ($userInput) {
    "1" {
        # $service = "wuauserv"; # - WindowsUpdate
		# $service = "TabletInputService";
		$service = "Spooler"; # - "Print Spooler" - Help reduce one's 
		# attack surface as a result of the various CVE's assoicated with
		# running the printing service that are to this day seemingly only
		# somewhat resolved via Windows patches.
		# Links / CVE's:
		# 2021-34527, CVE-2021-34481, 2024-21406
		# https://community.spiceworks.com/t/1169262
		# https://www.bleepingcomputer.com/news/microsoft/microsoft-fixes-windows-print-spooler-printnightmare-vulnerability/
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
		Remove-Item %windir%\SoftwareDistribution\Download\* -Force -Recurse
		Net Start WUAUSERV

		Delete-DeliveryOptimizationCache -IncludePinnedFiles -Force
		Remove-Item %windir%\Installer\* -Force -Recurse
		Remove-Item %windir%\SoftwareDistribution -Force -Recurse
		Remove-Item C:\ProgramData\Microsoft\MapData -Force -Recurse
		Remove-Item C:\ProgramData\Microsoft\EdgeUpdate -Force -Recurse
		Remove-Item "C:\ProgramData\Microsoft\User Account Pictures" -Force -Recurse
		Remove-Item "C:\ProgramData\Package Cache" -Force -Recurse
		Remove-Item "C:\ProgramData\Ubisoft\Ubisoft Game Launcher\patch" -Force -Recurse
		Remove-Item C:\AMD\* -Force -Recurse
		Remove-Item I:\TEMP\* -Force -Recurse
		Remove-Item C:\Users\Public\Desktop\*.lnk -Force
		dism /online /Cleanup-Image /StartComponentCleanup /NoRestart /ResetBase
    }
    default {
        Write-Host "Invalid selection. Please try again."
    }
}
pause