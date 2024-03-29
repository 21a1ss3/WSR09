# WSR09
WorldSkills Russia  - IT Software Solutions for Business

## Использование
Данные скрипты созданы для автоматизации развёртывания серверной части. 
Скрипты написаны на PowerShell (Встроен в Windows, достпен на Linux).
*Необходима версия PowerShell не ниже 5.0 (встроена в Windows 10 и новые Server'а с 2012, доступна для Windows 7)*

### Назначение скриптов
Скрипты по работе с Windows (применимо только для Windows)
- Windows-LocalUser-Create.ps1
Создаёт локальные (не доменные) учётные записи в Windows
- Windows-LocalUser-ChangePwd.ps1
Изменяет пароль локальных (не доменных) учётных записей Windows
- Windows-LocalUser-Remove.ps1
Удаляет локальные (не доменные) учётные записи в Windows

Скрипты по работе с СУБД
- MSSQL.ps1
Создаёт SQL скрипт по автоматическому созданию пользователей и их БД для Microsoft SQL Server
- MySQL.ps1
Создаёт SQL скрипт по автоматическому созданию пользователей и их БД для MySQL

### Особенности запуска
Для корректного запуска скриптов необходимо изменить политику выполнения скриптов на ByPass, иначе в целях безопастности PS отклонит их запуск (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies).

Но вместо изменения политики на всём компьютере можно запустить PowerShell с изменённой политикой:
*(вводить в командной строке или окне выполнить)*
```
powershell -ExecutionPolicy ByPass
```

### Параметры и работа
Скрипты написаны таким образом, что указание параметров с командной строки необязательно, но возможно.
В случае если какой-либо параметр не указан/некорректен скрипт переспросит его интерактивно.

Также рекомендую открыть и посмотреть содержимое скриптов, поскольку в некоторых из них есть опциональные закомментированные команды, которые могут быть вам полезны в вашем развёртывании.

На текущий момент скрипты поддерживают следующий список способов генерации/получения имён пользователей и паролей:
1. По шаблону (только пароль, имя пользователя имеет фиксированный шаблон)
2. Ввод паролей с консоли (только пароль, имя пользователя имеет фиксированный шаблон)
3. Из CSV файла (на текущий момент поддерживается только скриптами СУБД)

Для CSV файла используются следующий столбцы (обязательны к указанию):
- Username: имя пользователя
- Password: пароль пользователя

Список параметров скриптов:
- usrCount: Количество создаваемых пользователей. Обязательно к указанию
- pwdType: Тип источника (1-3, см. выше)
- pwdTemplate: Шаблон пароля. Используется и обязателен для первого типа источника. Доступен только маркер `{0}`, содержащий порядковый номер пользователя
- csvFilename: Имя файла (путь) CSV. Используется и обязателен для третьего типа источника
- csvSeparator: Разделитель CSV. Используется и обязателен для третьего типа источника. Если не указан или пустой используется `;`

По итогам выполнения скриптов вы получите:
- Для Windows-LocalUser-* скриптов -> измёниния в ОС по части пользователей
- Для скриптов СУБД: SQL скрипт в консоли, который необходимо выполнить в оснастке СУБД

### Примеры запуска

```
.\MSSQL.ps1 -usrCount 2 -pwdType 3 -csvFilename demo.csv -csvSeparator ";"
```
```
.\MySQL.ps1 -usrCount 2 -pwdType 3 -csvFilename demo.csv -csvSeparator ";"
```
