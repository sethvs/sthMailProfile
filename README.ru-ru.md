# sthMailProfile

**sthMailProfile** - это модуль, содержащий четыре функции, предназначенные для создания профилей электронной почты и отправки сообщений с их помощью.

В модуль входят следующие функции:

[**Send-sthMailMessage**](#send-sthmailmessage) - Функция  отправляет сообщение по электронной почте с использованием настроек, заданных в указанном профиле.

[**New-sthMailProfile**](#new-sthmailprofile) - Функция создает профиль электронной почты, содержащий указанные параметры.

[**Get-sthMailProfile**](#get-sthmailprofile) - Функция получает существующие профили электронной почты и отображает их параметры.

[**Remove-sthMailProfile**](#remove-sthmailprofile) - Функция удаляет указанные профили электронной почты.

Профиль - это файл xml, расположенный в каталоге "Profiles", находящемся в папке модуля и содержащий параметры электронной почты, такие как: From, To, Credential, SmtpServer, Port, UseSSL, Encoding, BodyAsHtml, CC, BCC, DeliveryNotificationOption, и Priority.

Вы можете установить модуль sthMailProfile из PowerShell Gallery:

```
Install-Module sthMailProfile
```

## Как с этим работать?

### Send-sthMailMessage

Команды отправляют сообщение электронной почты с использованием ранее созданного профиля.

Первая команда получает результаты выполнения командлета Get-Process и сохраняет их в переменной $ps.

Вторая команда отправляет их по электронной почте с использованием ранее созданного профиля с именем "MailProfile".

```
$ps = Get-Process
Send-sthMailMessage -Message $ps -Subject "Process List" -ProfileName "MailProfile"
```

---

Команда получает результаты выполнения командлета Get-Process по конвейеру и отправляет их по электронной почте с использованием ранее созданного профиля с именем "MailProfile".

```
Get-Process | Send-sthMailMessage -Subject "Process List" -ProfileName "MailProfile"
```

---

Команда получает результаты выполнения командлета Get-Process по конвейеру и отправляет их вместе с приложенными файлами по электронной почте с использованием ранее созданного профиля с именем "MailProfile".

```
Get-Process | Send-sthMailMessage -Subject "Process List" -ProfileName "MailProfile" -Attachments "file1.txt, file2.txt"
```

### New-sthMailProfile

Команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To и SmtpServer.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com
```

---

Команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To, SmtpServer, UserName и Password.

Так как параметр -Password указан не был, функция запрашивает его значение.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com
Type the password:
```

Так как SecureString использует DPAPI, то, если вы создаете профиль, содержащий учетные данные (имя и пароль) без использования параметра -StorePasswordInPlainText, этот профиль может быть использован только на том компьютере, на котором он был создан и только под той пользовательской учетной записью, под которой он был создан.

---

Команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To, SmtpServer, UserName и Password.

Пароль указывается в виде строки.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com -Password 'password'
```

Так как SecureString использует DPAPI, то, если вы создаете профиль, содержащий учетные данные (имя и пароль) без использования параметра -StorePasswordInPlainText, этот профиль может быть использован только на том компьютере, на котором он был создан и только под той пользовательской учетной записью, под которой он был создан.

---

Команды создают новый профиль с указанием пароля в качестве объекта SecureString.

Первая команда создает объект SecureString из строки и назначает его переменной $Password.

Вторая команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To, SmtpServer, UserName и Password.

Пароль указывается в виде объекта SecureString.

```
$Password = ConvertTo-SecureString -String 'password' -AsPlainText -Force
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com -Password $Password
```

Так как SecureString использует DPAPI, то, если вы создаете профиль, содержащий учетные данные (имя и пароль) без использования параметра -StorePasswordInPlainText, этот профиль может быть использован только на том компьютере, на котором он был создан и только под той пользовательской учетной записью, под которой он был создан.

---

Команды создают новый профиль с использованием объекта PSCredential.

Первая команда создает объект SecureString из строки и назначает его переменной $Password.

Вторая команда создает объект PSCredential, используя 'UserName' и соданный ранее пароль в качестве аргументов.

Третья команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To, SmtpServer и Credential.

```
$Password = ConvertTo-SecureString -String 'password' -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'UserName', $Password
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -Credential $Credential
```

Так как SecureString использует DPAPI, то, если вы создаете профиль, содержащий учетные данные (имя и пароль) без использования параметра -StorePasswordInPlainText, этот профиль может быть использован только на том компьютере, на котором он был создан и только под той пользовательской учетной записью, под которой он был создан.

---

Команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To, SmtpServer, UserName и Password.

Так как указан параметр -StorePasswordInPlainText, пароль будет храниться в профиле открытым текстом.

Это позволяет вам использовать профиль на других компьютерах, а не только на том, где он был создан, а также под иными пользовательскими учетными записями, отличными от той, под которой он был создан.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com -Password 'password' -StorePasswordInPlainText
```

### Get-sthMailProfile

Команда получает все существующие профили и отображает их параметры.

```
Get-sthMailProfile
                
ProfileName : MailProfile
From        : source@domain.com
To          : {destination@domain.com}
PasswordIs  : NotExist
SmtpServer  : smtp.domain.com

ProfileName : MailProfile2
From        : source@domain.com
To          : {destination@domain.com}
UserName    : user@domain.com
PasswordIs  : PlainText
SmtpServer  : smtp.domain.com

ProfileName : MailProfile3
From        : source@domain.com
To          : {destination@domain.com}
UserName    : user@domain.com
PasswordIs  : Secured
SmtpServer  : smtp.domain.com
```

---

Команда получает профиль "MailProfile" и отображает его параметры.

```
Get-sthMailProfile MailProfile

ProfileName : MailProfile
From        : source@domain.com
To          : {destination@domain.com}
PasswordIs  : NotExist
SmtpServer  : smtp.domain.com
```

---

Команда получает профили с именами, начинающимися с "Mail" и отображает их параметры.

```
Get-sthMailProfile -ProfileName "Mail*"
                
ProfileName : MailProfile
From        : source@domain.com
To          : {destination@domain.com}
PasswordIs  : NotExist
SmtpServer  : smtp.domain.com

ProfileName : MailProfile2
From        : source@domain.com
To          : {destination@domain.com}
UserName    : user@domain.com
PasswordIs  : PlainText
SmtpServer  : smtp.domain.com

ProfileName : MailProfile3
From        : source@domain.com
To          : {destination@domain.com}
UserName    : user@domain.com
PasswordIs  : Secured
SmtpServer  : smtp.domain.com
```

---

Команда получает существующие профили и отображает все их параметры, в том числе пароль.

```
Get-sthMailProfile -ShowPassword
                
ProfileName : MailProfile
From        : source@domain.com
To          : {destination@domain.com}
PasswordIs  : NotExist
SmtpServer  : smtp.domain.com

ProfileName : MailProfile2
From        : source@domain.com
To          : {destination@domain.com}
UserName    : user@domain.com
Password    : password
PasswordIs  : PlainText
SmtpServer  : smtp.domain.com

ProfileName : MailProfile3
From        : source@domain.com
To          : {destination@domain.com}
UserName    : user@domain.com
Password    : password
PasswordIs  : Secured
SmtpServer  : smtp.domain.com
```

### Remove-sthMailProfile

Команда удаляет профиль "MailProfile".

```
Remove-sthMailProfile -ProfileName "MailProfile"
```

---

Команда удаляет профили с именами, начинающимися с "Mail".

```
Remove-sthMailProfile -ProfileName "Mail*"
```

---

Команда удаляет все профили.

```
Remove-sthMailProfile -ProfileName *
```