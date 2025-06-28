# This script is designed to help a none technical WFH user to reassign the default printer within a RDP session to a local printer attached via USB.
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.1
# Undefined
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Get-WmiObject Win32_Printer | write-host
# Read-Host -Prompt 'Printer name'
# $printer = Get-WmiObject Win32_Printer | write-host | Read-Host -Prompt 'Printer name'
# https://mcpmag.com/articles/2012/10/02/pshell-values-variables.aspx
$printer = Get-WmiObject Win32_Printer | Where-Object {$_.Name -Match "redirected"} | Select -expand name
(New-Object -ComObject Wscript.Network).setDefaultPrinter("$printer")