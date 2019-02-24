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


Write-Host 
Write-Host 
Write-Host '############################ BEGIN SCRIPT ############################'
Write-Host 
Write-Host 

for($i=1; $i -le $usrCount; $i++)
{
    if ($pwdType -eq 1)
    {
        $cPwd = [System.String]::Format($pwdTemplate, $i);
    }
    elseif ($pwdType -eq 2)
    {
        $cPwd = $pwdList[$i-1];
    }
        
    
    Write-Host 'use [master]'
    Write-Host 'GO'

    #If you need to change password for existing account uncomment (1) and comment (2) below:
    #Если вам необходимо изменение пароля для существующих учетных записей раскомментируйте (1) и закомментируйте (2) ниже:
    #(1):  
    #Write-Host "ALTER LOGIN [user$i] WITH PASSWORD=N'$cPwd'"
    #Write-Host 'GO'

    #If you need to create new accounts comment above (1) and uncomment (2) below:
    #CHECK_EXPIRATION=OFF and CHECK_POLICY=OFF prevent password expiration and strong password policy requirements
    #Если вам необходимо создать новые учетные записи закомментируйте выше (1) и раскомментируйте (2) ниже:
    #CHECK_EXPIRATION=OFF и CHECK_POLICY=OFF отключают политики истечение срока действия пароля и требования к его сложности
    #(2):
    #Write-Host "DROP LOGIN [user$i]" # If you need to remove old accounts
    #Write-Host 'GO'
    Write-Host "CREATE LOGIN [user$i] WITH PASSWORD=N'$cPwd', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF"
    Write-Host 'GO'

    #Allow user to create new database
    #Разрешает создавать новую базу данных
    Write-Host "ALTER SERVER ROLE [dbcreator] ADD MEMBER [user$i]"
    Write-Host 'GO'

    #Deny user to view db from another user
    #Предотвращает просмотр чужих баз данных пользователем
    Write-Host "DENY VIEW ANY DATABASE TO [user$i]"
    Write-Host 'GO'

    #Uncomment below for create new database for each users
    #Раскомментируйте ниже чтобы создавать базу данных для каждого участника
    #Write-Host "DROP DATABASE IF EXISTS [user$i]"
    #Write-Host 'GO'
    #
    #Write-Host "CREATE DATABASE [user$i]"
    #Write-Host 'GO'
    #
    #Write-Host "ALTER AUTHORIZATION ON DATABASE::[user$i] TO [user$i]"
    #Write-Host 'GO'

    Write-Host 
    Write-Host 
}