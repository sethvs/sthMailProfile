# sthMailProfile
[![Build Status](https://dev.azure.com/sethv/seth/_apis/build/status/sthMailProfile)](https://dev.azure.com/sethv/seth/_build/latest?definitionId=6)

**sthMailProfile** - is a module, containing four functions for creating mail profiles and using them to send mail messages.

It contains following functions:

[**Send-sthMailMessage**](#send-sthmailmessage) - Function sends mail message using settings from the profile specified.

[**New-sthMailProfile**](#new-sthmailprofile) - Function creates mail profile containing specified settings.

[**Get-sthMailProfile**](#get-sthmailprofile) - Function gets existing mail profiles and displays their settings.

[**Remove-sthMailProfile**](#remove-sthmailprofile) - Function removes specified profiles.


## What is the Mail Profile?

Profile is an xml file, containing settings, such as: From, To, Credential, SmtpServer, Port, UseSSL, Encoding, BodyAsHtml, CC, BCC, DeliveryNotificationOption, and Priority.

You can create the profile by using the New-sthMailProfile function with the -ProfileName or -ProfileFilePath parameter.

-ProfileName parameter creates an .xml file with the specified name under the Profiles folder in the module's directory.

-ProfileFilePath parameter accepts path and name of the file, i.e. C:\Folder\file.xml, and creates it in the specified location.

## How to install it?

You can install sthMailProfile module from PowerShell Gallery:

```
Install-Module sthMailProfile
```

## How to use it?

### Send-sthMailMessage

#### Example 1: Send mail message using previously created profile

The commands send mail message using previously created profile.

The first command gets the result of the Get-Process cmdlet and assigns it to the $ps variable.

The second command sends it using previously created profile "MailProfile".

```
$ps = Get-Process
Send-sthMailMessage -ProfileName "MailProfile" -Subject "Process List" -Message $ps
```

---

#### Example 2: Send mail message using positional parameters

The first command gets the result of the Get-Process cmdlet and assigns it to the $ps variable.

The second command sends it using previously created profile "MailProfile".

The command uses positional parameters.

```
$ps = Get-Process
Send-sthMailMessage "MailProfile" "Process List" $ps
```

---

#### Example 3: Send mail message using profile file at the path specified

The commands send mail message using profile file at the path specified.

The first command gets the result of the Get-Process cmdlet and assigns it to the $ps variable.

The second command sends it using previously created profile file SomeProfile.xml located in the C:\Profiles directory.

```
$ps = Get-Process
Send-sthMailMessage -ProfileFilePath C:\Profiles\SomeProfile.xml -Subject "Process List" -Message $ps
```

---

#### Example 4: Send mail message using pipeline and previously created profile

The command gets the result of the Get-Process cmdlet and sends it using previously created profile "MailProfile".

It uses pipeline for sending message content to the function.

```
Get-Process | Send-sthMailMessage -ProfileName "MailProfile" -Subject "Process List"
```

---

#### Example 5: Send mail message with attachments using pipeline and previously created profile

The command gets the result of the Get-Process cmdlet and sends it with specified files as attachments using previously created profile "MailProfile".

It uses pipeline for sending message content to the function.

```
Get-Process | Send-sthMailMessage -ProfileName "MailProfile" -Subject "Process List" -Attachments "file1.txt, file2.txt"
```

### New-sthMailProfile

#### Example 1: Create a new profile

The command creates mail profile with name "MailProfile", which contains settings: From, To and SmtpServer.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com
```

---

#### Example 2: Create a new profile using positional parameters

The command creates mail profile with name "MailProfile", which contains settings: From, To and SmtpServer using positional parameters.

```
New-sthMailProfile "MailProfile" source@domain.com destination@domain.com smtp.domain.com
```

---

#### Example 3: Create a new profile file at the specified path

The command creates the profile file with the name SomeProfile.xml in the C:\Profiles directory.

```
New-sthMailProfile -ProfileFilePath "C:\Profiles\SomeProfile.xml" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com
```

---

#### Example 4: Create a new profile with credential

The command creates mail profile with name "MailProfile" and settings: From, To, SmtpServer, UserName and Password.

The -Password parameter is not used, so the command requests for it.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com
Type the password:
```

Since SecureString uses DPAPI, if you create mail profile containing credential without -StorePasswordInPlainText parameter, it can only be used on the computer it was created on and by the user account that created it.

---

#### Example 5: Create a new profile by specifying the password as string

The command creates mail profile with name "MailProfile" and settings: From, To, SmtpServer, UserName and Password.

Password is specified as string.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com -Password 'password'
```

Since SecureString uses DPAPI, if you create mail profile containing credential without -StorePasswordInPlainText parameter, it can only be used on the computer it was created on and by the user account that created it.

---

#### Example 6: Create a new profile with credential by specifying password as secure string

The commands create a new profile with credential by specifying password as secure string.

The first command creates secure string from plain text password and assigns it to the $Password variable.

The second command creates mail profile with name "MailProfile" and settings: From, To, SmtpServer, UserName and Password.

Password is specified as secure string.

```
$Password = ConvertTo-SecureString -String 'password' -AsPlainText -Force
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com -Password $Password
```

Since SecureString uses DPAPI, if you create mail profile containing credential without -StorePasswordInPlainText parameter, it can only be used on the computer it was created on and by the user account that created it.

---

#### Example 7: Create a new profile by specifying credential as PSCredential object

The commands create a new profile by specifying credential as PSCredential object.

The first command creates secure string from plain text password and assigns it to the $Password variable.

The second command creates PSCredential object using 'UserName' and previously created password as arguments.

The third command creates mail profile with name "MailProfile" and settings: From, To, SmtpServer and Credential.

```
$Password = ConvertTo-SecureString -String 'password' -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'UserName', $Password
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -Credential $Credential
```

Since SecureString uses DPAPI, if you create mail profile containing credential without -StorePasswordInPlainText parameter, it can only be used on the computer it was created on and by the user account that created it.

---

#### Example 8: Create a new profile by specifying credential as an array of two elements.

The command creates mail profile with name "MailProfile" and settings: From, To, SmtpServer and Credential.

Credential parameter value is specified as an array of two elements.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -Credential @('UserName', 'password')
```

Since SecureString uses DPAPI, if you create mail profile containing credential without **-StorePasswordInPlainText** parameter, it can only be used on the computer it was created on and by the user account that created it.

---

#### Example 9: Create a new profile object and store password in plain text

The command creates mail profile with name "MailProfile" and settings: From, To, SmtpServer, UserName and Password.

Since the -StorePasswordInPlainText parameter is used, password will be stored in plain text.

It allows you to use the profile on computers other than one it was created on, and under different user accounts, other than it was created by.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com -Password 'password' -StorePasswordInPlainText
```

### Get-sthMailProfile

#### Example 1: Get all profiles

The command gets all profiles and displays their settings.

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

#### Example 2: Get profile by name

The command gets profile "MailProfile" and displays its settings.

```
Get-sthMailProfile MailProfile

ProfileName : MailProfile
From        : source@domain.com
To          : {destination@domain.com}
PasswordIs  : NotExist
SmtpServer  : smtp.domain.com
```

---

#### Example 3: Get profiles by using wildcards

The command gets profiles which name starts with "Mail" and displays their settings.

```
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

---

#### Example 4: Get profile content from the profile file in alternate location

The command gets settings from the profile file located at C:\Profiles\SomeProfile.xml.

```
Get-sthMailProfile -ProfileFilePath C:\Profiles\SomeProfile.xml

ProfileName : SomeProfile
From        : source@domain.com
To          : {destination@domain.com}
PasswordIs  : NotExist
SmtpServer  : smtp.domain.com
```

---

#### Example 5: Get profiles and display their settings including password

The command gets all profiles and displays their settings including password.

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

#### Example 1: Remove a profile

The command removes the profile "MailProfile".

```
Remove-sthMailProfile -ProfileName "MailProfile"
```

---

#### Example 2: Remove profiles by using wildcards

The command removes the profiles which name starts with "Mail".

```
Remove-sthMailProfile -ProfileName "Mail*"
```

---

#### Example 3: Remove all profiles

The command removes all profiles.

```
Remove-sthMailProfile -ProfileName *
```

---

#### Example 4: Remove profiles file at the specified path

The command removes the profile file with the name SomeProfile.xml in the C:\Profiles directory.

```
Remove-sthMailProfile -ProfileFilePath C:\Profiles\SomeProfile.xml
```