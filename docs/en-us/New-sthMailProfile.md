---
external help file: sthMailProfile.help.ps1xml
Module Name:
online version:
schema: 2.0.0
---

# New-sthMailProfile

## SYNOPSIS
Creates mail profile.

## SYNTAX

### ProfileNamePassword
```
New-sthMailProfile [-ProfileName] <String> [-From] <String> [-To] <String[]> [-SmtpServer] <String>
 [-UserName <String>] [-Password <String or SecureString>] [-StorePasswordInPlainText] [-Subject <string>]
 [-Port <Int32>] [-UseSSL] [-Encoding <String>] [-BodyAsHTML] [-CC <String[]>] [-BCC <String[]>]
 [-DeliveryNotificationOption <String>] [-Priority <String>] [-DoNotSendIfMessageIsEmpty] [<CommonParameters>]
```

### ProfileFilePathPassword
```
New-sthMailProfile -ProfileFilePath <String> [-From] <String> [-To] <String[]> [-SmtpServer] <String>
 [-UserName <String>] [-Password <String or SecureString>] [-StorePasswordInPlainText] [-Subject <string>]
 [-Port <Int32>] [-UseSSL] [-Encoding <String>] [-BodyAsHTML] [-CC <String[]>] [-BCC <String[]>]
 [-DeliveryNotificationOption <String>] [-Priority <String>] [-DoNotSendIfMessageIsEmpty] [<CommonParameters>]
```

### ProfileNameCredential
```
New-sthMailProfile [-ProfileName] <String> [-From] <String> [-To] <String[]> [-SmtpServer] <String>
 [-Credential <PSCredential or two-element array>] [-StorePasswordInPlainText] [-Subject <string>]
 [-Port <Int32>] [-UseSSL] [-Encoding <String>] [-BodyAsHTML] [-CC <String[]>] [-BCC <String[]>]
 [-DeliveryNotificationOption <String>] [-Priority <String>] [-DoNotSendIfMessageIsEmpty] [<CommonParameters>]
```

### ProfileFilePathCredential
```
New-sthMailProfile -ProfileFilePath <String> [-From] <String> [-To] <String[]> [-SmtpServer] <String>
 [-Credential <PSCredential or two-element array>] [-StorePasswordInPlainText] [-Subject <string>]
 [-Port <Int32>] [-UseSSL] [-Encoding <String>] [-BodyAsHTML] [-CC <String[]>] [-BCC <String[]>]
 [-DeliveryNotificationOption <String>] [-Priority <String>] [-DoNotSendIfMessageIsEmpty] [<CommonParameters>]
```

## DESCRIPTION
The `New-sthMailProfile` function creates mail profile containing specified settings.

Profile is an xml file, containing settings, such as: From, To, Credential, SmtpServer, Subject, Port, UseSSL, Encoding, BodyAsHtml, CC, BCC, DeliveryNotificationOption, and Priority.

You can create the profile by using the **-ProfileName** or **-ProfileFilePath** parameter.\
**-ProfileName** parameter creates an .xml file with the specified name under the **Profiles** folder in the module's directory.\
**-ProfileFilePath** parameter accepts path and name of the file, i.e. C:\Folder\file.xml, and creates it in the specified location.

Profile can be used by the `Send-sthMailMessage` function.

## PARAMETERS

### -ProfileName
Specifies the name of the profile.

Function creates the profile with the name specified under the **Profiles** folder in the module's directory.

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
Specifies the profile file path.

This parameter allows you to create profile file in an alternate location.

Value should contain path and file name with .xml extension.

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
Specifies the address from which the mail is sent.

Enter a name (optional) and email address, such as Name \<someone@example.com\>.

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
Specifies the addresses to which the mail is sent.

Enter names (optional) and the email address, such as Name \<someone@example.com\>.

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
Specifies the name of the SMTP server that sends the email message.

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
Specifies UserName of the account that have permission to send the message.

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
Specifies password of the user account specified by **-UserName** parameter.

The value can be the **String** or **SecureString** object.

If the **-UserName** parameter is specified and the **-Password** parameter is not, you will be asked for password.

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
Specifies a credential of the user account that has permission to perform this action.

Value can be a PSCredential object, or an array of two elements, where the first element is username, and the second - is password, i.e. @('UserName','Password').

If value is in the form of array, it will be converted to PSCredential.

```yaml
Type: PSCredential or two-element array
Parameter Sets: ProfileNameCredential, ProfileFilePathCredential
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StorePasswordInPlainText
Specifies that the password should be stored in plain text.

By default password is encrypted by using DPAPI, which means that the profile can be used only on the computer it was created on, and under user account, that created it.

If the **StorePasswordInPlainText** parameter is used, the password will be stored in plain text, that allows to use the profile on computers other than one it was created on, and under different user accounts, other than it was created by.

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

### -Subject
Specifies mail message subject.

It can be redefined for specific message by `Send-sthMailMessage` **-Subject** parameter.

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

### -Port
Specifies an alternate port on the SMTP server.

The default value is 25, which is the default SMTP port.

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
Indicates that the cmdlet uses the Secure Sockets Layer (SSL) protocol to establish a connection to the remote computer to send mail.

By default, SSL is not used.

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
Specifies the encoding used for the body and subject.

You can specify encoding name, like 'unicode', or code page, like '1200'.

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
Indicates that the message content contains HTML.

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
Specifies the email addresses to which a carbon copy (CC) of the email message is sent.

Enter names (optional) and the email address, such as Name \<someone@example.com\>.

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
Specifies the email addresses that receive a copy of the mail but are not listed as recipients of the message.

Enter names (optional) and the email address, such as Name \<someone@example.com\>.

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
Specifies the delivery notification options for the email message.
You can specify multiple values.
**None** is the default value.

The delivery notifications are sent in an email message to the address specified in the value of the **To** parameter.

The acceptable values for this parameter are:
- **None**.
No notification.
- **OnSuccess**.
Notify if the delivery is successful.
- **OnFailure**.
Notify if the delivery is unsuccessful.
- **Delay**.
Notify if the delivery is delayed.
- **Never**.
Never notify.

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

### -Priority
Specifies the priority of the email message.

**Normal** is the default value.

The acceptable values for this parameter are:
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

### -DoNotSendIfMessageIsEmpty
Specifies that if message body is empty, the message is not sent.

By default empty messages are sent.

This parameter can be used in automation scenarions, when message should be sent only if there is some data.

Messages are send by the `Send-sthMailMessage` function.

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
Since SecureString uses DPAPI, if you create mail profile containing credential without **-StorePasswordInPlainText** parameter, it can only be used on the computer it was created on and by the user account that created it.

## EXAMPLES

### Example 1: Create a new profile.
```powershell
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com
```

The command creates mail profile with name "MailProfile", which contains settings: From, To and SmtpServer.

### Example 2: Create a new profile using positional parameters.
```powershell
New-sthMailProfile "MailProfile" source@domain.com destination@domain.com smtp.domain.com
```

The command creates mail profile with name "MailProfile", which contains settings: From, To and SmtpServer using positional parameters.

### Example 3: Create a new profile file at the specified path.
```powershell
New-sthMailProfile -ProfileFilePath "C:\Profiles\SomeProfile.xml" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com
```

This command creates the profile file with the name SomeProfile.xml in the C:\Profiles directory.

### Example 4: Create a new profile using additional parameters
```powershell
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -Subject "TheSubject" -Port 587 -UseSSL -Encoding UTF-8 -BodyAsHtml -CC cc@domain.com -BCC bcc@domain.com -DeliveryNotificationOption OnSuccess -Priority High
```

The command creates mail profile with name "SendEmpty" and settings: From, To, SmtpServer, Subject, Port, UseSSL, Encoding, BodyAsHtml, CC, BCC, DeliveryNotificationOption, and Priority.

### Example 5: Create a new profile with credential.
```powershell
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com
Type the password:
```

The command creates mail profile with name "MailProfile" and settings: From, To, SmtpServer, UserName and Password.\
The **-Password** parameter is not used, so the command requests for it.

Since SecureString uses DPAPI, if you create mail profile containing credential without **-StorePasswordInPlainText** parameter, it can only be used on the computer it was created on and by the user account that created it.

### Example 6: Create a new profile by specifying the password as string.
```powershell
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com -Password 'password'
```

The command creates mail profile with name "MailProfile" and settings: From, To, SmtpServer, UserName and Password.\
Password is specified as string.

Since SecureString uses DPAPI, if you create mail profile containing credential without **-StorePasswordInPlainText** parameter, it can only be used on the computer it was created on and by the user account that created it.

### Example 7: Create a new profile with credential by specifying password as secure string.
```powershell
$Password = ConvertTo-SecureString -String 'password' -AsPlainText -Force
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com -Password $Password
```

The first command creates secure string from plain text password and assigns it to the $Password variable.\
The second command creates mail profile with name "MailProfile" and settings: From, To, SmtpServer, UserName and Password.\
Password is specified as secure string.

Since SecureString uses DPAPI, if you create mail profile containing credential without **-StorePasswordInPlainText** parameter, it can only be used on the computer it was created on and by the user account that created it.

### Example 8: Create a new profile by specifying credential as PSCredential object.
```powershell
$Password = ConvertTo-SecureString -String 'password' -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'UserName', $Password
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -Credential $Credential
```

The first command creates secure string from plain text password and assigns it to the $Password variable.\
The second command creates PSCredential object using 'UserName' and previously created password as arguments.\
The third command creates mail profile with name "MailProfile" and settings: From, To, SmtpServer and Credential.

Since SecureString uses DPAPI, if you create mail profile containing credential without **-StorePasswordInPlainText** parameter, it can only be used on the computer it was created on and by the user account that created it.

### Example 9: Create a new profile by specifying credential as an array of two elements.
```powershell
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -Credential @('UserName', 'password')
```

The command creates mail profile with name "MailProfile" and settings: From, To, SmtpServer and Credential.\
Credential parameter value is specified as an array of two elements.

Since SecureString uses DPAPI, if you create mail profile containing credential without **-StorePasswordInPlainText** parameter, it can only be used on the computer it was created on and by the user account that created it.

### Example 10: Create a new profile and store password in plain text.
```powershell
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com -Password 'password' -StorePasswordInPlainText
```

The command creates mail profile with name "MailProfile" and settings: From, To, SmtpServer, UserName and Password.

Since the -StorePasswordInPlainText parameter is used, password will be stored in plain text.\
It allows you to use the profile on computers other than one it was created on, and under different user accounts, other than it was created by.

### Example 11: Create a new profile with subject
```powershell
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -Subject "TheSubject"
Send-sthMailMessage -ProfileName "MailProfile" -Message "TheMessage"
Send-sthMailMessage -ProfileName "MailProfile" -Subject "AnotherSubject" -Message "TheMessage" 
```

The first command creates mail profile with name "MailProfile" and settings: From, To, SmtpServer, and Subject.\
The second command sends mail message using subject from the profile.\
The third command sends mail message using subject defined by the Send-sthMailMessage -Subject parameter.

### Example 12: Create a new profile with -DoNotSendIfMessageIsEmpty parameter
```powershell
New-sthMailProfile -ProfileName "SendEmpty" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com
New-sthMailProfile -ProfileName "DoNotSendEmpty" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -DoNotSendIfMessageIsEmpty

'' | Send-sthMailMessage -ProfileName "SendEmpty" -Subject "TheSubject"
'' | Send-sthMailMessage -ProfileName "DoNotSendEmpty" -Subject "TheSubject"
```

The first command creates mail profile with name "SendEmpty" and settings: From, To, and SmtpServer.\
The second command creates mail profile with name "NoNotSendEmpty" and settings: From, To, SmtpServer, and DoNotSendIfMessageIsEmpty.

The third command tries to send mail message with empty body. The message will be sent.\
The fourth command tries to send mail message with empty body. The message will not be sent.


## RELATED LINKS
