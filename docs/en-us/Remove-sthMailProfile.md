---
external help file: sthMailProfile.help.ps1xml
Module Name:
online version:
schema: 2.0.0
---

# Remove-sthMailProfile

## SYNOPSIS
Removes mail profiles.

## SYNTAX

### ProfileName
```
Remove-sthMailProfile [-ProfileName] <String[]> [<CommonParameters>]
```

### ProfileFilePath
```
Remove-sthMailProfile -ProfileFilePath <String> [<CommonParameters>]
```

## DESCRIPTION
The `Remove-sthMailProfile` function removes specified profiles.

Profile is an xml file, containing settings, such as: From, To, Credential, SmtpServer, Port, UseSSL, Encoding, BodyAsHtml, CC, BCC, DeliveryNotificationOption, and Priority.

You can create the profile by using the `New-sthMailProfile` function with the **-ProfileName** or **-ProfileFilePath** parameter.\
**-ProfileName** parameter creates an .xml file with the specified name under the **Profiles** folder in the module's directory.\
**-ProfileFilePath** parameter accepts path and name of the file, i.e. C:\Folder\file.xml, and creates it in the specified location.

Profile can be used by the `Send-sthMailMessage` function.


## PARAMETERS

### -ProfileName
Specifies the name of the profile to remove.

Function removes the profile with the name specified under the Profiles folder in the module's directory.

Wildcards are permitted.

```yaml
Type: String[]
Parameter Sets: ProfileName
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -ProfileFilePath
Specifies profile file path.

This parameter allows you to remove profile file, created in an alternate location.

Value should contain path and file name with .xml extension.

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

### Example 1: Remove a profile.
```powershell
Remove-sthMailProfile -ProfileName "MailProfile"
```

The command removes the profile "MailProfile".

### Example 2: Remove profiles by using wildcards.
```powershell
Remove-sthMailProfile -ProfileName "Mail*"
```

The command removes the profiles which name starts with "Mail".

### Example 3: Remove all profiles.
```powershell
Remove-sthMailProfile -ProfileName *
```

The command removes all profiles from the Profiles folder in the module's directory.

### Example 4: Remove profiles file at the specified path.
```powershell
Remove-sthMailProfile -ProfileFilePath C:\Profiles\SomeProfile.xml
```

This command removes the profile file with the name SomeProfile.xml in the C:\Profiles directory.

## RELATED LINKS
