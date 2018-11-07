---
external help file: sthMailProfile.help.ps1xml
Module Name:
online version:
schema: 2.0.0
---

# Get-sthMailProfile

## SYNOPSIS
Gets mail profiles.

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
The `Get-sthMailProfile` function gets existing mail profiles and displays their settings.

Profile is an xml file, containing settings, such as: From, To, Credential, SmtpServer, Port, UseSSL, Encoding, BodyAsHtml, CC, BCC, DeliveryNotificationOption, and Priority.

You can create the profile by using the `New-sthMailProfile` function with the **-ProfileName** or **-ProfileFilePath** parameter.\
**-ProfileName** parameter creates an .xml file with the specified name under the **Profiles** folder in the module's directory.\
**-ProfileFilePath** parameter accepts path and name of the file, i.e. C:\Folder\file.xml, and creates it in the specified location.

Profile can be used by the `Send-sthMailMessage` function.

## PARAMETERS

### -ProfileName
Specifies the name of the profile.

This is the profile, created by the New-sthMailProfile function with the -ProfileName parameter and located under the Profiles folder in the module's directory.

If omitted, returns all the profiles from the Profiles folder in the module's directory.

Wildcards are permitted.

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
Specifies the profile file path.

It is the path to .xml file, created by the New-sthMailProfile function with the -ProfileFilePath parameter.

This parameter allows you to use profile file, created in an alternate location.

Wildcards are permitted.

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
Specifies that the password should be displayed in the command output.

By default passwords are not shown.

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
**PasswordIs** property can have one of three values: **NotExist**, **PlainText** and **Secured**.\
**NotExist** means, that the profile doesn't contain credential.\
**PlaintText** means that the profile stores the password in plain text.\
**Secured** means, that the password is stored in encrypted form.

Since SecureString uses DPAPI, if you create mail profile containing credential without **-StorePasswordInPlainText** parameter, it can only be used on the computer it was created on and by the user account that created it.


## EXAMPLES

### Example 1: Get all profiles.
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

The command gets all profiles and displays their settings.

### Example 2: Get profile by name.
```powershell
Get-sthMailProfile MailProfile

ProfileName : MailProfile
From        : source@domain.com
To          : {destination@domain.com}
PasswordIs  : NotExist
SmtpServer  : smtp.domain.com
```

The command gets profile "MailProfile" and displays its settings.

### Example 3: Get profiles by using wildcards.
```powershell
Get-sthMailProfile -ProfileName Mail*
                
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

The command gets profiles which name starts with "Mail" and displays their settings.

### Example 4: Get profile content from the profile file in alternate location.
```powershell
Get-sthMailProfile -ProfileFilePath C:\Profiles\SomeProfile.xml
                
ProfileName : SomeProfile
From        : source@domain.com
To          : {destination@domain.com}
PasswordIs  : NotExist
SmtpServer  : smtp.domain.com
```

This command gets settings from the profile file located at C:\Profiles\SomeProfile.xml.

### Example 5: Get profiles and display their settings including password.
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

The command gets all profiles and displays their settings including password.

## RELATED LINKS
