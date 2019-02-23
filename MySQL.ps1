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

    #If you need to change password for existing account uncomment (1) and comment (2) below:
    #Если вам необходимо изменение пароля для существующих учетных записей расскомментируйте (1) и закомментируйте (2) ниже:
    #(1):
    #Write-Host "SET PASSWORD FOR user$i = '$cPwd';"


    #If you need to create new accounts comment above (1) and uncomment (2) below:
    #Если вам необходимо создать новые учетные записи закомментируйте выше (1) и раскомментируйте (2) ниже:
    #(2):
    Write-Host "DROP USER IF EXISTS user$i;"    #ONLY IF YOU NEED RECREATE ACCOUNT / ТОЛЬКО ДЛЯ ПЕРЕСОЗДАНИЯ УЧЕТНОЙ ЗАПИСИ
    Write-Host "CREATE USER 'user$i'@'%' IDENTIFIED BY '$cPwd';"

    #Recreate user database
    #Пересоздаем базу данных пользователя (удаляем старую и создаем новую)
    Write-Host "DROP DATABASE IF EXISTS user$i;"
    Write-Host "CREATE DATABASE user$i;"

    #Revoke privileges for prevent access user to another user database in this server
    #Than granting privileges to specified database 
    #And save privileges
    #Отзываем привелегии для предотвращения доступа пользователя к БД других пользователей на этом сервере
    #Затем даем привелении к указанной БД
    #И сохраняем привелегии
    Write-Host "REVOKE ALL PRIVILEGES, GRANT OPTION FROM user$i;"
    Write-Host "GRANT ALL PRIVILEGES ON `user$i`.* TO user$i;"
    Write-Host 'FLUSH PRIVILEGES;'
    
    Write-Host 
    Write-Host 
    Write-Host 
}