# sthMailProfile
[![Build Status](https://dev.azure.com/sethv/seth/_apis/build/status/sthMailProfile)](https://dev.azure.com/sethv/seth/_build/latest?definitionId=6)

**sthMailProfile** - is a module, containing four functions for creating mail profiles and using them to send mail messages.

It contains following functions:

[**Send-sthMailMessage**](#send-sthmailmessage) - Function sends mail message using settings from the profile specified.

[**New-sthMailProfile**](#new-sthmailprofile) - Function creates mail profile containing specified settings.

[**Get-sthMailProfile**](#get-sthmailprofile) - Function gets existing mail profiles and displays their settings.

[**Remove-sthMailProfile**](#remove-sthmailprofile) - Function removes specified profiles.

Profile is an xml file, located in the "Profiles" directory in the module's folder and containing settings, such as: From, To, Credential, SmtpServer, Port, UseSSL, Encoding, BodyAsHtml, CC, BCC, DeliveryNotificationOption, and Priority.

You can install sthMailProfile module from PowerShell Gallery:

```
Install-Module sthMailProfile
```

## How to use it?

### Send-sthMailMessage

The commands send mail message using previously created profile.

The first command gets the result of the Get-Process cmdlet and assigns it to the $ps variable.

The second command sends it using previously created profile "MailProfile".

```
$ps = Get-Process
Send-sthMailMessage -Message $ps -Subject "Process List" -ProfileName "MailProfile"
```

---

The command gets the result of the Get-Process cmdlet and sends it using previously created profile "MailProfile".

It uses pipeline for sending message content to the function.

```
Get-Process | Send-sthMailMessage -Subject "Process List" -ProfileName "MailProfile"
```

---

The command gets the result of the Get-Process cmdlet and sends it with specified files as attachments using previously created profile "MailProfile".

It uses pipeline for sending message content to the function.

```
Get-Process | Send-sthMailMessage -Subject "Process List" -ProfileName "MailProfile" -Attachments "file1.txt, file2.txt"
```

### New-sthMailProfile

The command creates mail profile with name "MailProfile", which contains settings: From, To and SmtpServer.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com
```

---

The command creates mail profile with name "MailProfile" and settings: From, To, SmtpServer, UserName and Password.

The -Password parameter is not used, so the command requests for it.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com
Type the password:
```

Since SecureString uses DPAPI, if you create mail profile containing credential without -StorePasswordInPlainText parameter, it can only be used on the computer it was created on and by the user account that created it.

---

The command creates mail profile with name "MailProfile" and settings: From, To, SmtpServer, UserName and Password.

Password is specified as string.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com -Password 'password'
```

Since SecureString uses DPAPI, if you create mail profile containing credential without -StorePasswordInPlainText parameter, it can only be used on the computer it was created on and by the user account that created it.

---

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

The command creates mail profile with name "MailProfile" and settings: From, To, SmtpServer, UserName and Password.

Since the -StorePasswordInPlainText parameter is used, password will be stored in plain text.

It allows you to use the profile on computers other than one it was created on, and under different user accounts, other than it was created by.

```
New-sthMailProfile -ProfileName "MailProfile" -From source@domain.com -To destination@domain.com -SmtpServer smtp.domain.com -UserName user@domain.com -Password 'password' -StorePasswordInPlainText
```

### Get-sthMailProfile

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

The command removes the profile "MailProfile".

```
Remove-sthMailProfile -ProfileName "MailProfile"
```

---

The command removes the profiles which name starts with "Mail".

```
Remove-sthMailProfile -ProfileName "Mail*"
```

---

The command removes all profiles.

```
Remove-sthMailProfile -ProfileName *
```