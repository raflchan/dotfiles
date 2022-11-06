function powershell
    sudo docker run -it quickbreach/powershell-ntlm -Command Write-Host -NoNewline "Enter Target Address: "\;\$target=Read-Host\;\$creds=Get-Credential\;Enter-PSSession -ComputerName \$target -Authentication Negotiate -Credential \$creds
end
