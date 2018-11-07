---
external help file: sthMailProfile.help.ps1xml
Module Name:
online version:
schema: 2.0.0
---

# Send-sthMailMessage

## SYNOPSIS

Отправляет сообщение по электронной почте с использованием указанного профиля.

## SYNTAX

### ProfileName
```
Send-sthMailMessage [-ProfileName] <String> [-Subject] <String> [[-Message] <Object[]>]
 [-Attachments <String[]>] [<CommonParameters>]
```

### ProfileFilePath
```
Send-sthMailMessage -ProfileFilePath <String> [-Subject] <String> [[-Message] <Object[]>]
 [-Attachments <String[]>] [<CommonParameters>]
```

## DESCRIPTION

Функция `Send-sthMailMessage` отправляет сообщение по электронной почте с использованием настроек, заданных в указанном профиле.

Профиль - это файл xml, содержащий параметры электронной почты, такие как: From, To, Credential, SmtpServer, Port, UseSSL, Encoding, BodyAsHtml, CC, BCC, DeliveryNotificationOption, and Priority.

Вы можете создать профиль при помощи команды `New-sthMailProfile` с параметром **-ProfileName** или **-ProfileFilePath**.\
Параметр **-ProfileName** создает .xml файл с указанным именем в папке **Profiles**, расположенной в каталоге модуля.\
Параметр **-ProfileFilePath** принимает в качестве значения путь и имя файла, например C:\Folder\file.xml, и создает его в указанном расположении.


## PARAMETERS

### -ProfileName
Указывает имя профиля.

Профили содержат настройки для отправки сообщений электронной почты.\
Вы можете создать профиль при помощи функции New-sthMailProfile.

```yaml
Type: String
Parameter Sets: ProfileName
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileFilePath
Указывает путь и имя файла профиля.

Этот параметр позволяет вам использовать файл профиля, расположенный в произвольной локации.

```yaml
Type: String
Parameter Sets: ProfileFilePath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Subject
Указывает тему сообщения электронной почты.

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

### -Message
Задает тело сообщения электронной почты.

Вы можете передать функции Send-sthMailMessage результаты выполнения какой либо другой функции или командлета по конвейеру.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Attachments
Указывает пути к файлам, которые нужно прикрепить к сообщению электронной почты.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Так как SecureString использует DPAPI, то, если вы создаете профиль, содержащий учетные данные (имя и пароль) без использования параметра **-StorePasswordInPlainText**, этот профиль может быть использован только на том компьютере, на котором он был создан и только под той пользовательской учетной записью, под которой он был создан.


## EXAMPLES

### Пример 1: Отправка сообщения электронной почты с использованием ранее созданного профиля.
```powershell
$ps = Get-Process
Send-sthMailMessage -ProfileName "MailProfile" -Subject "Process List" -Message $ps
```

Первая команда получает результаты выполнения командлета Get-Process и сохраняет их в переменной $ps.\
Вторая команда отправляет их по электронной почте с использованием ранее созданного профиля с именем "MailProfile".

### Пример 2: Отправка сообщения электронной почты с использованием позиционных параметров.
```powershell
$ps = Get-Process
Send-sthMailMessage "MailProfile" "Process List" $ps
```

Первая команда получает результаты выполнения командлета Get-Process и сохраняет их в переменной $ps.\
Вторая команда отправляет их по электронной почте с использованием ранее созданного профиля с именем "MailProfile".\
Команда использует позиционные параметры.

### Пример 3: Отправка сообщения электронной почты с использованием файла профиля, расположенного по указанному пути.
```powershell
$ps = Get-Process
Send-sthMailMessage -ProfileFilePath C:\Profiles\SomeProfile.xml -Subject "Process List" -Message $ps
```

Первая команда получает результаты выполнения командлета Get-Process и сохраняет их в переменной $ps.\
Вторая команда отправляет их по электронной почте с использованием ранее созданного файла профиля SomeProfile.xml, расположенного в каталоге C:\Profiles.

### Пример 4: Отправка сообщения электронной почты с использованием конвейера и ранее созданного профиля.
```powershell
Get-Process | Send-sthMailMessage -ProfileName "MailProfile" -Subject "Process List"
```

Команда получает результаты выполнения командлета Get-Process по конвейеру и отправляет их по электронной почте с использованием ранее созданного профиля с именем "MailProfile".

### Пример 5: Отправка сообщения электронной почты, содержащего прикрепленные файлы, с использованием ранее созданного профиля.
```powershell
Get-Process | Send-sthMailMessage -ProfileName "MailProfile" -Subject "Process List" -Attachments "file1.txt, file2.txt"
```

Команда получает результаты выполнения командлета Get-Process по конвейеру и отправляет их вместе с приложенными файлами по электронной почте с использованием ранее созданного профиля с именем "MailProfile".

## RELATED LINKS
