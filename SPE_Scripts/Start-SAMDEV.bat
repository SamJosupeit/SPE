"C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe" /ExecutionPolicy ByPass /NoProfile /command "& {cd c:\SPE_Scripts;C:\SPE_Scripts\Start-SAMDEV.ps1}"
netsh interface set interface "vEthernet (VLAN Intern)" admin=disable
timeout /T 5
netsh interface set interface "vEthernet (VLAN Intern)" admin=enable