---
external help file: sthMailProfile.help.ps1xml
Module Name:
online version:
schema: 2.0.0
---

# Remove-sthMailProfile

## SYNOPSIS
Удаляет профили электронной почты.

## SYNTAX

### ProfileName
```
Remove-sthMailProfile [-ProfileName] <String> [<CommonParameters>]
```

### ProfileFilePath
```
Remove-sthMailProfile -ProfileFilePath <String> [<CommonParameters>]
```

## DESCRIPTION
Функция `Remove-sthMailProfile` удаляет указанные профили электронной почты.

Профиль - это файл xml, содержащий параметры электронной почты, такие как: From, To, Credential, SmtpServer, Port, UseSSL, Encoding, BodyAsHtml, CC, BCC, DeliveryNotificationOption, and Priority.

Вы можете создать профиль при помощи команды `New-sthMailProfile` с параметром **-ProfileName** или **-ProfileFilePath**.\
Параметр **-ProfileName** создает .xml файл с указанным именем в папке **Profiles**, расположенной в каталоге модуля.\
Параметр **-ProfileFilePath** принимает в качестве значения путь и имя файла, например C:\Folder\file.xml, и создает его в указанном расположении.

Профиль используется функцией `Send-sthMailMessage`.

## PARAMETERS

### -ProfileName
Указывает имя профиля для удаления.

Функция удаляет профиль с указанным именем из папки Profiles, расположенной в каталоге модуля.

Поддерживается использование символов подстановки.

```yaml
Type: String
Parameter Sets: ProfileName
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -ProfileFilePath
Указывает путь и имя файла профиля.

Этот параметр позволяет вам удалить файл профиля, расположенный в произвольной локации.

Значение должно содержать путь и имя файла с расширением .xml.

```yaml
Type: String
Parameter Sets: ProfileFilePath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## EXAMPLES

### Пример 1: Удаление профиля.
```powershell
Remove-sthMailProfile -ProfileName "MailProfile"
```

Команда удаляет профиль "MailProfile".

### Пример 2: Удаление профилей с использованием символов подстановки.
```powershell
Remove-sthMailProfile -ProfileName "Mail*"
```

Команда удаляет профили с именами, начинающимися с "Mail".

### Пример 3: Удаление всех профилей.
```powershell
Remove-sthMailProfile -ProfileName *
```

Команда удаляет все профили из папки Profiles, расположенной в каталоге модуля.

### Пример 4: Удаление файла профиля, расположенного по указанному пути.
```powershell
Remove-sthMailProfile -ProfileFilePath C:\Profiles\SomeProfile.xml
```

Команда удаляет файл профиля с именем SomeProfile.xml, расположенный в каталоге C:\Profiles.

## RELATED LINKS
