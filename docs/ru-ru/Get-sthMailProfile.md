---
external help file: sthMailProfile.help.ps1xml
Module Name:
online version:
schema: 2.0.0
---

# Get-sthMailProfile

## SYNOPSIS
Получает существующие профили электронной почты.

## SYNTAX

### ProfileName
```
Get-sthMailProfile [[-ProfileName] <String[]>] [-ShowPassword] [<CommonParameters>]
```

### ProfileFilePath
```
Get-sthMailProfile -ProfileFilePath <String[]> [-ShowPassword] [<CommonParameters>]
```

## DESCRIPTION
Функция `Get-sthMailProfile` получает существующие профили электронной почты и отображает их параметры.

Профиль - это файл xml, содержащий параметры электронной почты, такие как: From, To, Credential, SmtpServer, Port, UseSSL, Encoding, BodyAsHtml, CC, BCC, DeliveryNotificationOption, and Priority.

Вы можете создать профиль при помощи команды `New-sthMailProfile` с параметром **-ProfileNam**e или **-ProfileFilePath**.\
Параметр **-ProfileName** создает .xml файл с указанным именем в папке **Profiles**, расположенной в каталоге модуля.\
Параметр **-ProfileFilePath** принимает в качестве значения путь и имя файла, например C:\Folder\file.xml, и создает его в указанном расположении.

Профиль используется функцией `Send-sthMailMessage`.

## PARAMETERS

### -ProfileName
Указывает имя профиля.

Это имя профиля, созданного при помощи команды `New-sthMailProfile` с параметром **-ProfileName**, находящегося в папке **Profiles**, расположенной в каталоге модуля.

Если параметр отсутствует, команда выводит все профили, находящиеся в папке **Profiles**, расположенной в каталоге модуля.

Поддерживается использование символов подстановки.

```yaml
Type: String[]
Parameter Sets: ProfileName
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -ProfileFilePath
Указывает путь и имя файла профиля.

Это путь и имя файла .xml, созданного при помощи команды `New-sthMailProfile` с параметром **-ProfileFilePath**.

Этот параметр позволяет вам использовать файл профиля, расположенный в произвольной локации.

```yaml
Type: String[]
Parameter Sets: ProfileFilePath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -ShowPassword
Указвыает, что вывод команды должен включать в себя значение пароля.

По умолчанию пароли не отображаются.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Свойство **PasswordIs** может принимать одно из трех значений: **NotExist**, **PlainText** и **Secured**.\
**NotExist** означает, что профиль не содержит учетных данных.\
**PlainText** означает, что пароль хранится в профиле открытым текстом.\
**Secured** означает, что пароль хранится в зашифрованном виде.

Так как SecureString использует DPAPI, то, если вы создаете профиль, содержащий учетные данные (имя и пароль) без использования параметра **-StorePasswordInPlainText**, этот профиль может быть использован только на том компьютере, на котором он был создан и только под той пользовательской учетной записью, под которой он был создан.

## EXAMPLES

### Пример 1: Получение всех существующих профилей.
```powershell
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

Команда получает все существующие профили и отображает их параметры.

### Пример 2: Получение профиля с определенным именем.
```powershell
Get-sthMailProfile MailProfile

ProfileName : MailProfile
From        : source@domain.com
To          : {destination@domain.com}
PasswordIs  : NotExist
SmtpServer  : smtp.domain.com
```

Команда получает профиль "MailProfile" и отображает его параметры.

### Пример 3: Получение профилей с использованием символов подстановки.
```powershell
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

Команда получает профили с именами, начинающимися с "Mail" и отображает их параметры.

### Пример 4: Получение содержимого файла профиля, расположенного в указанном местоположении.
```powershell
Get-sthMailProfile -ProfileFilePath C:\Profiles\SomeProfile.xml
                
ProfileName : SomeProfile
From        : source@domain.com
To          : {destination@domain.com}
PasswordIs  : NotExist
SmtpServer  : smtp.domain.com
```

Команда отображает содержимое файла профиля с именем SomeProfile.xml, расположенного в папке C:\Profiles.

### Пример 5: Получение профилей и отображение их параметров, в том числе пароля.
```powershell
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

Команда получает существующие профили и отображает все их параметры, в том числе пароль.

## RELATED LINKS
