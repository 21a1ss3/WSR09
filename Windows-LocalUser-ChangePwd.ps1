param(  [Byte]$usrCount=0,
        [Byte]$pwdType=255,
        [string]$pwdTemplate=$null)



if($usrCount -eq 0)
{
    do
    {
        Write-Host 
        $usrCountStr = Read-Host -Prompt "Enter users count"
    }
    while (-Not [System.Byte]::TryParse($usrCountStr, [ref] $usrCount))
}

while(-Not (($pwdType -eq 1) -or ($pwdType -eq 2)))
{
    do
    {    
        Write-Host 
        Write-Host "Select password source type: "
        Write-Host "`t1. Use password template;"
        Write-Host "`t2. Use console input;"

        $pwdTypeStr = Read-Host -Prompt "Enter type"
    }
    while (-Not [System.Byte]::TryParse($pwdTypeStr, [ref] $pwdType))
}


if ($pwdType -eq 1)
{
    while ([System.String]::IsNullOrWhiteSpace($pwdTemplate))
    {
        $pwdTemplate = Read-Host -Prompt "Specify template string (parts: {0} - user index)"
    }
}
elseif ($pwdType -eq 2)
{
    $pwdList = New-Object -TypeName 'System.Collections.Generic.List[System.String]' -ArgumentList @($usrCount)

    for($i=1; $i -le $usrCount; $i++)
    {
        $cPwd = $null
        do
        {
            $cPwd = Read-Host -Prompt "Password [$i]"
        } while ([System.String]::IsNullOrWhiteSpace($cPwd))

        $pwdList.Add($cPwd)
    }
}


for ($i=1; $i -le $usrCount; $i++)
{
    if ($pwdType -eq 1)
    {
        $pwd = [System.String]::Format($pwdTemplate, $i);
    }
    elseif ($pwdType -eq 2)
    {
        $pwd = $pwdList[$i-1];
    }

    $secPwd = New-Object -TypeName System.Security.SecureString

    foreach ($pwdChar in $pwd.ToCharArray())
    {
        $secPwd.AppendChar($pwdChar);
    }

    Set-LocalUser -Name "user$i" -Password $secPwd
}

