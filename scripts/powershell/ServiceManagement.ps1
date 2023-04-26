# $service = "wuauserv"; - WindowsUpdate
# $service = "TabletInputService";
# $service = "Spooler"; - "Print Spooler" - Help reduce one's attack surface as a result of the various CVE's assoicated with running the printing service that are to this day (2023-04-26) seemingly only somewhat resolved via Windows patches.
$previousState = Get-Service $service | Select -expand Status
switch ($previousState) {
	Stopped {Set-Service -Name $service -StartupType Manual; Start-Service $service}
	Running {Stop-Service $service; Set-Service -Name $service -StartupType Disabled}
}
$newState = Get-Service $service | Select -expand Status
Write-Output "${service}, ${previousState} -> ${newState}"
pause