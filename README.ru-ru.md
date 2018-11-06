# sthMailProfile

**sthMailProfile** - это модуль, содержащий четыре функции, предназначенные для создания профилей электронной почты и отправки сообщений с их помощью.

В модуль входят следующие функции:

[**Send-sthMailMessage**](#send-sthmailmessage) - Функция  отправляет сообщение по электронной почте с использованием настроек, заданных в указанном профиле.

[**New-sthMailProfile**](#new-sthmailprofile) - Функция создает профиль электронной почты, содержащий указанные параметры.

[**Get-sthMailProfile**](#get-sthmailprofile) - Функция получает существующие профили электронной почты и отображает их параметры.

[**Remove-sthMailProfile**](#remove-sthmailprofile) - Функция удаляет указанные профили электронной почты.

## Что такое профиль?

Профиль - это файл xml, содержащий параметры электронной почты, такие как: From, To, Credential, SmtpServer, Port, UseSSL, Encoding, BodyAsHtml, CC, BCC, DeliveryNotificationOption, and Priority.

Вы можете создать профиль при помощи команды New-sthMailProfile с параметром -ProfileName или -ProfileFilePath.

Параметр -ProfileName создает .xml файл с указанным именем в папке Profiles, расположенной в каталоге модуля.

Параметр -ProfileFilePath принимает в качестве значения путь и имя файла, например C:\Folder\file.xml, и создает его в указанном расположении.

## Как его установить?

Вы можете установить модуль sthMailProfile из PowerShell Gallery:

```
Install-Module sthMailProfile
```

## Как с этим работать?

### Send-sthMailMessage

#### Пример 1: Отправка сообщения электронной почты с использованием ранее созданного профиля

Команды отправляют сообщение электронной почты с использованием ранее созданного профиля.

Первая команда получает результаты выполнения командлета Get-Process и сохраняет их в переменной $ps.

Вторая команда отправляет их по электронной почте с использованием ранее созданного профиля с именем "MailProfile".

```
$ps = Get-Process
Send-sthMailMessage -ProfileName "MailProfile" -Subject "Process List" -Message $ps
```

---

#### Пример 2: Отправка сообщения электронной почты с использованием позиционных параметров

Первая команда получает результаты выполнения командлета Get-Process и сохраняет их в переменной $ps.

Вторая команда отправляет их по электронной почте с использованием ранее созданного профиля с именем "MailProfile".

Команда использует позиционные параметры.

```
$ps = Get-Process
Send-sthMailMessage "MailProfile" "Process List" $ps
```

---

#### Пример 3: Отправка сообщения электронной почты с использованием файла профиля, расположенного по указанному пути

Команды отправляют сообщение электронной почты с использованием файла профиля, расположенного по указанному пути.

Первая команда получает результаты выполнения командлета Get-Process и сохраняет их в переменной $ps.

Вторая команда отправляет их по электронной почте с использованием ранее созданного файла профиля SomeProfile.xml, расположенного в каталоге C:\Profiles.

```
$ps = Get-Process
Send-sthMailMessage -ProfileFilePath C:\Profiles\SomeProfile.xml -Subject "Process List" -Message $ps
```

---

#### Пример 4: Отправка сообщения электронной почты с использованием конвейера и ранее созданного профиля

Команда получает результаты выполнения командлета Get-Process по конвейеру и отправляет их по электронной почте с использованием ранее созданного профиля с именем "MailProfile".

```
Get-Process | Send-sthMailMessage -ProfileName "MailProfile" -Subject "Process List"
```

---

#### Пример 5: Отправка сообщения электронной почты, содержащего прикрепленные файлы, с использованием ранее созданного профиля

Команда получает результаты выполнения командлета Get-Process по конвейеру и отправляет их вместе с приложенными файлами по электронной почте с использованием ранее созданного профиля с именем "MailProfile".

```
Get-Process | Send-sthMailMessage -ProfileName "MailProfile" -Subject "Process List" -Attachments "file1.txt, file2.txt"
```

### New-sthMailProfile

#### Пример 1: Создание нового профиля

Команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To и SmtpServer.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com
```

---

#### Пример 2: Создание нового профиля с использованием позиционных параметров

Команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To и SmtpServer с использованием позиционных параметров.

```
New-sthMailProfile "MailProfile" source@domain.com destination@domain.com smtp.domain.com
```

---

#### Пример 3: Создание профиля с указанием пути и имени файла

Команда создает файл профиля с именем SomeProfile.xml, расположенный в каталоге C:\Profiles.

```
New-sthMailProfile -ProfileFilePath "C:\Profiles\SomeProfile.xml" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com
```

---

#### Пример 4: Создание нового профиля, содержащего учетные данные

Команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To, SmtpServer, UserName и Password.

Так как параметр -Password указан не был, функция запрашивает его значение.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com
Type the password:
```

Так как SecureString использует DPAPI, то, если вы создаете профиль, содержащий учетные данные (имя и пароль) без использования параметра -StorePasswordInPlainText, этот профиль может быть использован только на том компьютере, на котором он был создан и только под той пользовательской учетной записью, под которой он был создан.

---

#### Пример 5: Создание нового профиля с указанием пароля в качестве строки

Команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To, SmtpServer, UserName и Password.

Пароль указывается в виде строки.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com -Password 'password'
```

Так как SecureString использует DPAPI, то, если вы создаете профиль, содержащий учетные данные (имя и пароль) без использования параметра -StorePasswordInPlainText, этот профиль может быть использован только на том компьютере, на котором он был создан и только под той пользовательской учетной записью, под которой он был создан.

---

#### Пример 6: Создание нового профиля с указанием пароля в качестве объекта SecureString

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

#### Пример 7: Создание нового профиля с использованием объекта PSCredential

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

#### Пример 8: Создание нового профиля, хранящего пароль открытым текстом

Команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To, SmtpServer, UserName и Password.

Так как указан параметр -StorePasswordInPlainText, пароль будет храниться в профиле открытым текстом.

Это позволяет вам использовать профиль на других компьютерах, а не только на том, где он был создан, а также под иными пользовательскими учетными записями, отличными от той, под которой он был создан.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com -Password 'password' -StorePasswordInPlainText
```

### Get-sthMailProfile

#### Пример 1: Получение всех существующих профилей

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

#### Пример 2: Получение профиля с определенным именем

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

#### Пример 3: Получение профилей с использованием символов подстановки

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

#### Пример 4: Получение содержимого файла профиля, расположенного в указанном местоположении

Команда отображает содержимое файла профиля с именем SomeProfile.xml, расположенного в папке C:\Profiles.

```
Get-sthMailProfile -ProfileFilePath C:\Profiles\SomeProfile.xml

ProfileName : SomeProfile
From        : source@domain.com
To          : {destination@domain.com}
PasswordIs  : NotExist
SmtpServer  : smtp.domain.com
```

---

#### Пример 5: Получение профилей и отображение их параметров, в том числе пароля

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

#### Пример 1: Удаление профиля

Команда удаляет профиль "MailProfile".

```
Remove-sthMailProfile -ProfileName "MailProfile"
```

---

#### Пример 2: Удаление профилей с использованием символов подстановки

Команда удаляет профили с именами, начинающимися с "Mail".

```
Remove-sthMailProfile -ProfileName "Mail*"
```

---

#### Пример 3: Удаление всех профилей

Команда удаляет все профили.

```
Remove-sthMailProfile -ProfileName *
```

---

#### Пример 4: Удаление файла профиля, расположенного по указанному пути

Команда удаляет файл профиля с именем SomeProfile.xml, расположенный в каталоге C:\Profiles.

```
Remove-sthMailProfile -ProfileFilePath C:\Profiles\SomeProfile.xml
```