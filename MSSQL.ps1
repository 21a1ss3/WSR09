param(  [Byte]$usrCount=0,
        [Byte]$pwdType=255,
        [string]$pwdTemplate=$null,
        [string]$csvFilename=$null,
        [string]$csvSeparator=$null)



if ($usrCount -eq 0)
{
    do
    {
        Write-Host 
        $usrCountStr = Read-Host -Prompt "Enter users count"
    }
    while (-Not [System.Byte]::TryParse($usrCountStr, [ref] $usrCount))
}

while (-Not (($pwdType -eq 1) -or ($pwdType -eq 2) -or ($pwdType -eq 3)))
{
    do
    {    
        Write-Host 
        Write-Host "Select password source type: "
        Write-Host "`t1. Use password template;"
        Write-Host "`t2. Use console input;"
        Write-Host "`t3. Use CSV file (Password column);"

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
    $pwdList = New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList @($usrCount)

    for ($i=1; $i -le $usrCount; $i++)
    {
        $cPwd = $null
        do
        {
            $cPwd = Read-Host -Prompt "Password [$i]"
        } while ([System.String]::IsNullOrWhiteSpace($cPwd))

        $cUserRec = @{
            Username = "user$i" 
            Password = $cPwd
            }

        $pwdList.Add($cUserRec)
    }
}
elseif ($pwdType -eq 3)
{
    $repCsvFN = [System.String]::IsNullOrWhiteSpace($csvFilename)
    $usersFromCsv = $null

    do
    {
        if ($repCsvFN)
        {
            $csvFilename = Read-Host -Prompt "CSV password file name"
            $csvSeparator = Read-Host -Prompt "CSV separator (';' default, if empty)"
        }

        $repCsvFN = $false;
        if (-Not [System.String]::IsNullOrWhiteSpace($csvFilename))
        {
            if (-Not [System.IO.File]::Exists($csvFilename))
            {
                $repCsvFN = $true;
                Write-Host "PWD: File not found"
            }
            else
            {
                if ([System.String]::IsNullOrWhiteSpace($csvSeparator))
                {
                    $csvSeparator = ";"
                }
                $usersFromCsv = Import-Csv -Path $csvFilename -Delimiter $csvSeparator

                if ($usersFromCsv.Length -lt $usrCount)
                {
                    Write-Host "PWD: Users count does not match"
                    $repCsvFN = $true;
                    continue
                }                

                $pwdList = New-Object -TypeName 'System.Collections.Generic.List[System.Object]' -ArgumentList @($usrCount)

                for ($i=0; $i -lt $usrCount; $i++)
                {
                    if ([System.String]::IsNullOrWhiteSpace($usersFromCsv[$i].Username))
                    {
                        Write-Host "PWD: Not all records are containing username"
                        $repCsvFN = $true;
                        continue
                    }
                    if ([System.String]::IsNullOrWhiteSpace($usersFromCsv[$i].Password))
                    {
                        Write-Host "PWD: Not all records are containing password"
                        $repCsvFN = $true;
                        continue
                    }

                    $cUserRec = @{
                        Username = $usersFromCsv[$i].Username
                        Password = $usersFromCsv[$i].Password
                        }

                    $pwdList.Add($cUserRec)
                }
            }
        }
        else
        {
            $repCsvFN = $true;
        }
    } while($repCsvFN);
}


Write-Host 
Write-Host 
Write-Host '############################ BEGIN SCRIPT ############################'
Write-Host 
Write-Host 

for($i=1; $i -le $usrCount; $i++)
{
    $cUsername = "user$i";

    if ($pwdType -eq 1)
    {
        $cPwd = [System.String]::Format($pwdTemplate, $i);
    }
    elseif (($pwdType -eq 2) -or ($pwdType -eq 3))
    {
        $cUsername = $pwdList[$i-1].Username;
        $cPwd = $pwdList[$i-1].Password;
    }
        
    
    Write-Host 'use [master]'
    Write-Host 'GO'

    #If you want to change password for existing accounts please uncomment section (1) and comment section (2) below:
    #Если вам необходимо изменение пароля для существующих учетных записей раскомментируйте (1) и закомментируйте (2) ниже:
    #(1):  
    #Write-Host "ALTER LOGIN [$cUsername] WITH PASSWORD=N'$cPwd'"
    #Write-Host 'GO'

    #If you want to create new accounts please comment section above (1) and uncomment setcion (2) below:
    #CHECK_EXPIRATION=OFF and CHECK_POLICY=OFF prevents password expiration policy and use of strong password policy
    #Если вам необходимо создать новые учетные записи закомментируйте выше (1) и раскомментируйте (2) ниже:
    #CHECK_EXPIRATION=OFF и CHECK_POLICY=OFF отключают политики истечение срока действия пароля и требования к его сложности
    #(2):
    #Write-Host "DROP LOGIN [$cUsername]" # Uncomment in case of removing existing accounts
    #Write-Host 'GO'
    Write-Host "CREATE LOGIN [$cUsername] WITH PASSWORD=N'$cPwd', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF"
    Write-Host 'GO'

    #Allow user to create new database
    #Разрешает создавать новую базу данных
    #Write-Host "ALTER SERVER ROLE [dbcreator] ADD MEMBER [$cUsername]"
    #Write-Host 'GO'

    #Deny user to view db from another user
    #Предотвращает просмотр чужих баз данных пользователем
    Write-Host "DENY VIEW ANY DATABASE TO [$cUsername]"
    Write-Host 'GO'

    #Uncomment below for create new database for each users
    #Раскомментируйте ниже чтобы создавать базу данных для каждого участника
    Write-Host "DROP DATABASE IF EXISTS [$cUsername]"
    Write-Host 'GO'
    
    Write-Host "CREATE DATABASE [$cUsername]"
    Write-Host 'GO'
    
    Write-Host "ALTER AUTHORIZATION ON DATABASE::[$cUsername] TO [$cUsername]"
    Write-Host 'GO'

    Write-Host 
    Write-Host 
}