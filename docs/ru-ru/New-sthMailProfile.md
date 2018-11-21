---
external help file: sthMailProfile.help.ps1xml
Module Name:
online version:
schema: 2.0.0
---

# New-sthMailProfile

## SYNOPSIS
Создает профиль электронной почты.

## SYNTAX

### ProfileNamePassword
```
New-sthMailProfile [-ProfileName] <String> [-From] <String> [-To] <String[]> [-SmtpServer] <String>
 [-UserName <String>] [-Password <String or SecureString>] [-StorePasswordInPlainText] [-Port <Int32>]
 [-UseSSL] [-Encoding <String>] [-BodyAsHTML] [-CC <String[]>] [-BCC <String[]>]
 [-DeliveryNotificationOption <String[]>] [-Priority <String>] [<CommonParameters>]
```

### ProfileFilePathPassword
```
New-sthMailProfile -ProfileFilePath <String> [-From] <String> [-To] <String[]> [-SmtpServer] <String>
 [-UserName <String>] [-Password <String or SecureString>] [-StorePasswordInPlainText] [-Port <Int32>]
 [-UseSSL] [-Encoding <String>] [-BodyAsHTML] [-CC <String[]>] [-BCC <String[]>]
 [-DeliveryNotificationOption <String[]>] [-Priority <String>] [<CommonParameters>]
```

### ProfileNameCredential
```
New-sthMailProfile [-ProfileName] <String> [-From] <String> [-To] <String[]> [-SmtpServer] <String>
 [-Credential <PSCredential>] [-StorePasswordInPlainText] [-Port <Int32>] [-UseSSL] [-Encoding <String>]
 [-BodyAsHTML] [-CC <String[]>] [-BCC <String[]>] [-DeliveryNotificationOption <String[]>] [-Priority <String>]
 [<CommonParameters>]
```

### ProfileFilePathCredential
```
New-sthMailProfile -ProfileFilePath <String> [-From] <String> [-To] <String[]> [-SmtpServer] <String>
 [-Credential <PSCredential>] [-StorePasswordInPlainText] [-Port <Int32>] [-UseSSL] [-Encoding <String>]
 [-BodyAsHTML] [-CC <String[]>] [-BCC <String[]>] [-DeliveryNotificationOption <String[]>] [-Priority <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Функция `New-sthMailProfile` создает профиль электронной почты, содержащий указанные параметры.

Профиль - это файл xml, содержащий параметры электронной почты, такие как: From, To, Credential, SmtpServer, Port, UseSSL, Encoding, BodyAsHtml, CC, BCC, DeliveryNotificationOption, and Priority.

Вы можете создать профиль при помощи параметров **-ProfileName** или **-ProfileFilePath**.\
Параметр **-ProfileName** создает .xml файл с указанным именем в папке **Profiles**, расположенной в каталоге модуля.\
Параметр **-ProfileFilePath** принимает в качестве значения путь и имя файла, например C:\Folder\file.xml, и создает его в указанном расположении.

Профиль используется функцией `Send-sthMailMessage`.

## PARAMETERS

### -ProfileName
Задает имя профиля.

Функция создает профиль с указанным именем в папке **Profiles**, расположенной в каталоге модуля.

```yaml
Type: String
Parameter Sets: ProfileNamePassword, ProfileNameCredential
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileFilePath
Задает путь и имя файла профиля.

Этот параметр позволяет вам создать файл профиля, расположенный в произвольной локации.

Значение должно содержать путь и имя файла с расширением .xml.

```yaml
Type: String
Parameter Sets: ProfileFilePathPassword, ProfileFilePathCredential
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -From
Указывает адрес отправителя.

Введите имя (не обязательно) и адрес электронной почты, например: Отправитель \<someone@example.com\>.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -To
Указывает адрес получателя.

Введите имена (не обязательно) и адреса электронной почты, например: Получатель \<someone@example.com\>.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SmtpServer
Указывает имя SMTP-сервера, через который будет отправлено сообщение электронной почты.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
Указывает имя пользователя, обладающего правами на отправку электронной почты.

```yaml
Type: String
Parameter Sets: ProfileNamePassword, ProfileFilePathPassword
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Password
Указывает пароль пользователя, имя которого было задано параметром **-UserName**.

Значение параметра может быть строкой или объектом **SecureString**.

Если параметр **-UserName** был указан, а параметр **-Password** - нет, то функция запросит его значение.

```yaml
Type: String or SecureString
Parameter Sets: ProfileNamePassword, ProfileFilePathPassword
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Указывает учетные данные пользователя, обладающего правами на отправку электронной почты.

Значением может быть как объект PSCredential, так и массив, состоящий из двух элементов, где первый элемент - это имя пользователя, а второй - пароль, к примеру - @('UserName','Password').

Если значение представлено в виде массива, оно будет преобразовано в объект PSCredential.

```yaml
Type: PSCredential
Parameter Sets: ProfileNameCredential, ProfileFilePathCredential
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StorePasswordInPlainText
Указывает, что пароль будет храниться открытым текстом.

По умолчанию, пароль шифруется при помощи DPAPI, что означает, что профиль может быть использован только на том компьютере, на котором он был создан и только под той пользовательской учетной записью, под которой он был создан.

Если же использован параметр **-StorePasswordInPlainText**, пароль будет храниться открытым текстом, что позволяет использовать профиль на других компьютерах, а не только на том, где он был создан, а также под иными пользовательскими учетными записями, отличными от той, под которой он был создан.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Port
Указывает порт SMTP-сервера.

По умолчанию используется порт 25.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseSSL
Указывает, что для подключения к SMTP-серверу будет использоваться протокол Secure Sockets Layer (SSL).

По умолчанию SSL не используется.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Encoding
Указывает кодировку сообщения электронной почты.

Вы можете указать как имя кодовой страницы, например 'unicode', так и ее числовое значение, например '1200'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BodyAsHTML
Указывает, что содержимое сообщения представляет из себя HTML.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CC
Указывает адреса электронной почты, на которые будет отправлена копия сообщения.

Введите имена (не обязательно) и адреса электронной почты, например: Получатель \<someone@example.com\>.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BCC
Указывает адреса электронной почты, которые получат копию сообщения, однако не будут отображены в качестве получателей.

Введите имена (не обязательно) и адреса электронной почты, например: Получатель \<someone@example.com\>.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeliveryNotificationOption
Задает опции уведомления о доставке для сообщения электронной почты.
Вы можете указать несколько значений.
Значение по умолчанию - **None**.

Опции уведомления о доставке отправляются в сообщении, отсылаемом на адрес, указанный в значении параметра **-To**.

Допустимые значения параметра:
- **None**.
Без уведомления.
- **OnSuccess**.
Уведомить в случае успешной доставки.
- **OnFailure**.
Уведомить в случае если доставка не удалась.
- **Delay**.
Уведомить, если доставка задерживается.
- **Never**.
Никогда не уведомлять.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Priority
Указывает приоритет сообщения электронной почты.

Значение по умолчанию - **Normal**.

Допустимые значения параметра:
- **Normal**
- **High**
- **Low**

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Так как SecureString использует DPAPI, то, если вы создаете профиль, содержащий учетные данные (имя и пароль) без использования параметра **-StorePasswordInPlainText**, этот профиль может быть использован только на том компьютере, на котором он был создан и только под той пользовательской учетной записью, под которой он был создан.

## EXAMPLES

### Пример 1: Создание нового профиля.
```powershell
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com
```

Команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To и SmtpServer.

### Пример 2: Создание нового профиля с использованием позиционных параметров.
```powershell
New-sthMailProfile "MailProfile" source@domain.com destination@domain.com smtp.domain.com
```

Команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To и SmtpServer с использованием позиционных параметров.

### Пример 3: Создание профиля с указанием пути и имени файла.
```powershell
New-sthMailProfile -ProfileFilePath "C:\Profiles\SomeProfile.xml" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com
```

Команда создает файл профиля с именем SomeProfile.xml, расположенный в каталоге C:\Profiles.

### Пример 4: Создание нового профиля, содержащего учетные данные.
```powershell
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com
Type the password:
```

Команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To, SmtpServer, UserName и Password.\
Так как параметр -Password указан не был, функция запрашивает его значение.

Так как SecureString использует DPAPI, то, если вы создаете профиль, содержащий учетные данные (имя и пароль) без использования параметра **-StorePasswordInPlainText**, этот профиль может быть использован только на том компьютере, на котором он был создан и только под той пользовательской учетной записью, под которой он был создан.

### Пример 5: Создание нового профиля с указанием пароля в качестве строки.
```powershell
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com -Password 'password'
```

Команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To, SmtpServer, UserName и Password.\
Пароль указывается в виде строки.

Так как SecureString использует DPAPI, то, если вы создаете профиль, содержащий учетные данные (имя и пароль) без использования параметра **-StorePasswordInPlainText**, этот профиль может быть использован только на том компьютере, на котором он был создан и только под той пользовательской учетной записью, под которой он был создан.

### Пример 6: Создание нового профиля с указанием пароля в качестве объекта SecureString.
```powershell
$Password = ConvertTo-SecureString -String 'password' -AsPlainText -Force
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com -Password $Password
```

Первая команда создает объект SecureString из строки и назначает его переменной $Password.\
Вторая команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To, SmtpServer, UserName и Password.\
Пароль указывается в виде объекта SecureString.

Так как SecureString использует DPAPI, то, если вы создаете профиль, содержащий учетные данные (имя и пароль) без использования параметра **-StorePasswordInPlainText**, этот профиль может быть использован только на том компьютере, на котором он был создан и только под той пользовательской учетной записью, под которой он был создан.

### Пример 7: Создание нового профиля с использованием объекта PSCredential.
```
$Password = ConvertTo-SecureString -String 'password' -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'UserName', $Password
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -Credential $Credential
```

Первая команда создает объект SecureString из строки и назначает его переменной $Password.\
Вторая команда создает объект PSCredential, используя 'UserName' и соданный ранее пароль в качестве аргументов.\
Третья команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To, SmtpServer и Credential.

Так как SecureString использует DPAPI, то, если вы создаете профиль, содержащий учетные данные (имя и пароль) без использования параметра **-StorePasswordInPlainText**, этот профиль может быть использован только на том компьютере, на котором он был создан и только под той пользовательской учетной записью, под которой он был создан.

### Пример 8: Создание нового профиля с использованием массива в качестве значения параметра Credential.
```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -Credential @('UserName', 'password')
```

Команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To, SmtpServer и Credential.\
Параметр Credential задан в виде массива, состоящего из двух элементов.

Так как SecureString использует DPAPI, то, если вы создаете профиль, содержащий учетные данные (имя и пароль) без использования параметра **-StorePasswordInPlainText**, этот профиль может быть использован только на том компьютере, на котором он был создан и только под той пользовательской учетной записью, под которой он был создан.

### Пример 9: Создание нового профиля, хранящего пароль открытым текстом.
```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com -Password 'password' -StorePasswordInPlainText
```

Команда создает профиль электронной почты с именем "MailProfile" и параметрами From, To, SmtpServer, UserName и Password.

Так как указан параметр -StorePasswordInPlainText, пароль будет храниться в профиле открытым текстом.\
Это позволяет вам использовать профиль на других компьютерах, а не только на том, где он был создан, а также под иными пользовательскими учетными записями, отличными от той, под которой он был создан.

## RELATED LINKS
