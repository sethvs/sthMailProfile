---
external help file: sthMailProfile.help.ps1xml
Module Name:
online version:
schema: 2.0.0
---

# Send-sthMailMessage

## SYNOPSIS
Sends mail message using profile specified.

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
The `Send-sthMailMessage` function sends mail message using settings from the profile specified.

Profile is an xml file, containing settings, such as: From, To, Credential, SmtpServer, Port, UseSSL, Encoding, BodyAsHtml, CC, BCC, DeliveryNotificationOption, and Priority.

You can create the profile by using the `New-sthMailProfile` function with the **-ProfileName** or **-ProfileFilePath** parameter.\
**-ProfileName** parameter creates an .xml file with the specified name under the **Profiles** folder in the module's directory.\
**-ProfileFilePath** parameter accepts path and name of the file, i.e. C:\Folder\file.xml, and creates it in the specified location.

## PARAMETERS

### -ProfileName
Specifies profile name.

Profiles contain mail settings.\
You can create profile by using the New-sthMailProfile function.

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
Specifies profile file path.

This parameter allows you to use profile file, created in an alternate location.

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
Specifies mail message subject.

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
Specifies mail message body.

You can pipe results of another function or cmdlet to this function.

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
Specifies paths to mail message attachments, if any.

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

Since SecureString uses DPAPI, if you create mail profile containing credential without **-StorePasswordInPlainText** parameter, it can only be used on the computer it was created on and by the user account that created it.

## EXAMPLES

### Example 1: Send mail message using previously created profile.
```powershell
$ps = Get-Process
Send-sthMailMessage -ProfileName "MailProfile" -Subject "Process List" -Message $ps
```

The first command gets the result of the Get-Process cmdlet and assigns it to the $ps variable.
The second command sends it using previously created profile "MailProfile".

### Example 2: Send mail message using positional parameters.
```powershell
$ps = Get-Process
Send-sthMailMessage "MailProfile" "Process List" $ps
```

The first command gets the result of the Get-Process cmdlet and assigns it to the $ps variable.\
The second command sends it using previously created profile "MailProfile".\
The command uses positional parameters.

### Example 3: Send mail message using profile file at the path specified.
```powershell
$ps = Get-Process
Send-sthMailMessage -ProfileFilePath C:\Profiles\SomeProfile.xml -Subject "Process List" -Message $ps
```

The first command gets the result of the Get-Process cmdlet and assigns it to the $ps variable.\
The second command sends it using previously created profile file SomeProfile.xml located in the C:\Profiles directory.

### Example 4: Send mail message using pipeline and previously created profile.
```powershell
Get-Process | Send-sthMailMessage -ProfileName "MailProfile" -Subject "Process List"
```

This command gets the result of the Get-Process cmdlet and sends it using previously created profile "MailProfile".\
It uses pipeline for sending message content to the function.

### Example 5: Send mail message with attachments using pipeline and previously created profile.
```powershell
Get-Process | Send-sthMailMessage -ProfileName "MailProfile" -Subject "Process List" -Attachments "file1.txt, file2.txt"
```

This command gets the result of the Get-Process cmdlet and sends it with specified files as attachments using previously created profile "MailProfile".\
It uses pipeline for sending message content to the function.

## RELATED LINKS
