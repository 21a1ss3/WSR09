param([Byte]$usrCount=0)



if($usrCount -eq 0)
{
    do
    {
        Write-Host 
        $usrCountStr = Read-Host -Prompt "Enter users count"
    }
    while (-Not [System.Byte]::TryParse($usrCountStr, [ref] $usrCount))
}

for ($i=1; $i -le $usrCount; $i++)
{
    Remove-LocalUser -Name "user$i"
}