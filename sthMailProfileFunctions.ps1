$ProfileDirectory = 'Profiles'

# .ExternalHelp sthMailProfile.help.ps1xml
function Send-sthMailMessage
{
    Param(
        [Parameter(Mandatory,Position='0',ParameterSetName='ProfileName')]
        [string]$ProfileName,
        [Parameter(Mandatory,ParameterSetName='ProfileFilePath')]
        [string]$ProfileFilePath,
        [Parameter(Position='1')]
        [string]$Subject,
        [Parameter(Position='2',ValueFromPipeline)]
        $Message,
        [string[]]$Attachments
    )

    Begin
    {
        $Content = @()
    }

    Process
    {
        $Content += $Message
    }

    End
    {
        if ($PSCmdlet.ParameterSetName -eq 'ProfileName')
        {
            $MailProfile = Get-sthMailProfile -ProfileName $ProfileName
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
        {
            $MailProfile = Get-sthMailProfile -ProfileFilePath $ProfileFilePath
        }

        if ($MailProfile -and $MailProfile.Count -eq 1)
        {
            if ($Content -or -not $MailProfile.DoNotSendIfMessageIsEmpty)
            {
                if ($MailProfile.PasswordIs -eq 'PlainText')
                {
                    try
                    {
                        if ($PSCmdlet.ParameterSetName -eq 'ProfileName')
                        {
                            $Password = ConvertTo-SecureString -String (Get-sthMailProfile -ProfileName $ProfileName -ShowPassword | Select-Object -ExpandProperty Password) -AsPlainText -Force
                        }
                        elseif ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
                        {
                            $Password = ConvertTo-SecureString -String (Get-sthMailProfile -ProfileFilePath $ProfileFilePath -ShowPassword | Select-Object -ExpandProperty Password) -AsPlainText -Force
                        }
                    }
                    catch [System.Management.Automation.ParameterBindingException]
                    {
                        $Password = [System.Security.SecureString]::new()
                    }
                    
                    $MailProfile.Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $MailProfile.Credential.UserName, $Password
                }
                
                $Parameters = @{}
                
                foreach ($Property in $MailProfile.PSObject.Properties.Name | Where-Object -FilterScript {$_ -notin 'ProfileName', 'PasswordIs', 'UserName', 'Password', 'DoNotSendIfMessageIsEmpty'})
                {
                    if ($MailProfile.$Property)
                    {
                        $Parameters.Add($Property, $MailProfile.$Property)
                    }
                }

                if ($Subject)
                {
                    $Parameters.Subject = $Subject
                }
                elseif (-not $Parameters.Subject)
                {
                    inNoSubjectError
                }

                if ($Content)
                {
                    $Body = $Content | Out-String -Width 1000
                    $Parameters.Add("Body", $Body)
                }

                if ($Attachments)
                {
                    $Parameters.Add("Attachments", $Attachments)
                }

                Send-MailMessage @Parameters
            }
        }

        elseif ($MailProfile)
        {
            inProfileNameError -Value $($ProfileName + $ProfileFilePath) -ErrorType 'MultipleProfiles'
        }

        else
        {
            inProfileNameError -Value $($ProfileName + $ProfileFilePath) -ErrorType 'ProfileNotFound'
        }
    }
}

# .ExternalHelp sthMailProfile.help.ps1xml
function New-sthMailProfile
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword","")]
    [CmdletBinding(DefaultParameterSetName='ProfileName')]
    Param(
        [Parameter(Mandatory,Position='0',ParameterSetName='ProfileName')]
        [Parameter(Mandatory,Position='0',ParameterSetName='ProfileName-Password')]
        [Parameter(Mandatory,Position='0',ParameterSetName='ProfileName-Credential')]
        [string]$ProfileName,
        [Parameter(Mandatory,ParameterSetName='ProfileFilePath')]
        [Parameter(Mandatory,ParameterSetName='ProfileFilePath-Password')]
        [Parameter(Mandatory,ParameterSetName='ProfileFilePath-Credential')]
        [string]$ProfileFilePath,
        [Parameter(Mandatory,Position='1')]
        [string]$From,
        [Parameter(Mandatory,Position='2')]
        [string[]]$To,
        [Parameter(Mandatory,Position='3')]
        [string]$SmtpServer,
        [Parameter(Mandatory,ParameterSetName='ProfileName-Password')]
        [Parameter(Mandatory,ParameterSetName='ProfileFilePath-Password')]
        [string]$UserName,
        [Parameter(ParameterSetName='ProfileName-Password')]
        [Parameter(ParameterSetName='ProfileFilePath-Password')]
        $Password,
        [Parameter(Mandatory,ParameterSetName='ProfileName-Credential')]
        [Parameter(Mandatory,ParameterSetName='ProfileFilePath-Credential')]
        [ValidateNotNullOrEmpty()]
        $Credential,
        [string]$Subject,
        [int]$Port,
        [switch]$UseSSL,
        [string]$Encoding,
        [switch]$BodyAsHtml,
        [string[]]$CC,
        [string[]]$BCC,
        [ValidateSet('None','OnSuccess','OnFailure','Delay','Never')]
        [string[]]$DeliveryNotificationOption,
        [ValidateSet('Normal','High','Low')]
        [string]$Priority,
        [Parameter(ParameterSetName='ProfileName-Password')]
        [Parameter(ParameterSetName='ProfileFilePath-Password')]
        [Parameter(ParameterSetName='ProfileName-Credential')]
        [Parameter(ParameterSetName='ProfileFilePath-Credential')]
        [switch]$StorePasswordInPlainText,
        [switch]$DoNotSendIfMessageIsEmpty
    )

    if ($PSCmdlet.ParameterSetName -eq 'ProfileName' -or $PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
    {
        $MailParameters = [sthMailProfile]::new($From, $To, $SmtpServer)
    }

    elseif ($PSCmdlet.ParameterSetName -eq 'ProfileName-Password' -or $PSCmdlet.ParameterSetName -eq 'ProfileFilePath-Password')
    {
        if ($PSBoundParameters.ContainsKey('Password'))
        {
            if ($Password.GetType().FullName -eq 'System.String')
            {
                if ($Password -eq '')
                {
                    $Password = [System.Security.SecureString]::new()
                }
                else
                {
                    $Password = ConvertTo-SecureString -String $Password -AsPlainText -Force
                }
            }
        }

        else
        {
            $Password = Read-Host -Prompt "Type the password" -AsSecureString
        }
        
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, $Password

        $MailParameters = [sthMailProfile]::new($From, $To, $Credential, $SmtpServer)
    }

    elseif ($PSCmdlet.ParameterSetName -eq 'ProfileName-Credential' -or $PSCmdlet.ParameterSetName -eq 'ProfileFilePath-Credential')
    {
        if ($Credential.GetType().BaseType.FullName -eq 'System.Array' -and $Credential.Count -eq 2)
        {
            $Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Credential[0], $(ConvertTo-SecureString -String $Credential[1] -AsPlainText -Force)
        }
        elseif ($Credential.GetType().FullName -ne 'System.Management.Automation.PSCredential')
        {
            inPSCredentialError -Value $Credential
        }

        $MailParameters = [sthMailProfile]::new($From, $To, $Credential, $SmtpServer)
    }

    if ($StorePasswordInPlainText)
    {
        $MailParameters | Add-Member -NotePropertyName PlainTextPassword -NotePropertyValue $Credential.GetNetworkCredential().Password
        $MailParameters.PasswordIs = [PasswordIs]'PlainText'
    }

    foreach ($PSBoundParameter in $PSBoundParameters.GetEnumerator())
    {
        if ($PSBoundParameter.Key -notin 'From','To','SmtpServer','UserName','Password','Credential','ProfileName','ProfileFilePath','StorePasswordInPlainText')
        {
            if ($PSBoundParameter.Key -eq 'Encoding')
            {
                [int]$CodePage = 0
                if ([System.Int32]::TryParse($PSBoundParameter.Value, [ref]$CodePage))
                {
                    $MailParameters.$($PSBoundParameter.Key) = [System.Text.Encoding]::GetEncoding($CodePage)
                }
                else
                {
                    $MailParameters.$($PSBoundParameter.Key) = [System.Text.Encoding]::GetEncoding($PSBoundParameter.Value)
                }
            }
            else
            {
                $MailParameters.$($PSBoundParameter.Key) = $PSBoundParameter.Value
            }
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'ProfileName-Password' -or $PSCmdlet.ParameterSetName -eq 'ProfileName-Credential' -or $PSCmdlet.ParameterSetName -eq 'ProfileName')
    {
        inWriteProfile -ProfileName $ProfileName -Profile $MailParameters
    }

    elseif ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath-Password' -or $PSCmdlet.ParameterSetName -eq 'ProfileFilePath-Credential' -or $PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
    {
        inWriteProfile -ProfileFilePath $ProfileFilePath -Profile $MailParameters
    }
}

# .ExternalHelp sthMailProfile.help.ps1xml
function Get-sthMailProfile
{
    [CmdletBinding(DefaultParameterSetName='ProfileName')]
    Param(
        [Parameter(Position='0',ParameterSetName='ProfileName')]
        [string[]]$ProfileName = "*",
        [Parameter(ParameterSetName='ProfileFilePath')]
        [string[]]$ProfileFilePath,
        [switch]$ShowPassword
        )

    if ($PSCmdlet.ParameterSetName -eq 'ProfileName')
    {
        $FolderPath = Join-Path -Path $PSScriptRoot -ChildPath $ProfileDirectory

        foreach ($PName in $ProfileName)
        {
            foreach ($ProfileFile in (Get-Item -Path $("$FolderPath\$PName.xml") -ErrorAction SilentlyContinue | Where-Object -FilterScript {$_.PSIsContainer -eq $false}))
            {
                inComposeMailProfile -ProfileFile $ProfileFile
            }
        }
    }

    elseif ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
    {
        foreach ($PFile in $ProfileFilePath)
        {
            foreach ($ProfileFile in (Get-Item -Path $PFile -ErrorAction SilentlyContinue | Where-Object -FilterScript {$_.PSIsContainer -eq $false}))
            {
                inComposeMailProfile -ProfileFile $ProfileFile
            }
        }
    }
}

# .ExternalHelp sthMailProfile.help.ps1xml
function Remove-sthMailProfile
{
    Param(
        [Parameter(Mandatory,Position='0',ParameterSetName='ProfileName')]
        [string]$ProfileName,
        [Parameter(Mandatory,ParameterSetName='ProfileFilePath')]
        [string]$ProfileFilePath
    )

    if ($PSCmdlet.ParameterSetName -eq 'ProfileName')
    {
        $Path = Join-Path -Path $PSScriptRoot -ChildPath $ProfileDirectory
        $Path = Join-Path -Path $Path -ChildPath $($ProfileName + '.xml')
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
    {
        $Path = $ProfileFilePath
    }

    Remove-Item -Path $Path
}

function inComposeMailProfile
{
    Param (
        $ProfileFile
    )

    $xml = Import-Clixml -Path $ProfileFile.FullName

    if ($Xml.Encoding)
    {
        $xml.Encoding = [System.Text.Encoding]::GetEncoding($xml.Encoding.CodePage)
    }

    $MailProfile = [sthMailProfile]::new($xml.From,$xml.To,$xml.Credential,$xml.PasswordIs,$xml.SmtpServer,$xml.Subject,$xml.Port,$xml.UseSSL,$xml.Encoding,$xml.BodyAsHtml,$xml.CC,$xml.BCC,$xml.DeliveryNotificationOption,$xml.Priority,$xml.DoNotSendIfMessageIsEmpty)
    $MailProfile | Add-Member -NotePropertyName ProfileName -NotePropertyValue $ProfileFile.Name.Substring(0,$ProfileFile.Name.Length - 4)

    $MailProfile | Add-Member -NotePropertyName UserName -NotePropertyValue $MailProfile.Credential.UserName
    
    if ($ShowPassword)
    {
        if ($MailProfile.PasswordIs -eq 'Secured')
        {
            $MailProfile | Add-Member -NotePropertyName Password -NotePropertyValue $MailProfile.Credential.GetNetworkCredential().Password
        }
        elseif ($MailProfile.PasswordIs -eq 'PlainText')
        {
            $MailProfile | Add-Member -NotePropertyName Password -NotePropertyValue $xml.PlainTextPassword
        }
        $MailProfile | Add-Member -TypeName 'sthMailProfile#Password'
    }
    $MailProfile
}

function inWriteProfile
{
    Param (
        [Parameter(ParameterSetName='ProfileName')]
        [string]$ProfileName,
        [Parameter(ParameterSetName='ProfileFilePath')]
        [string]$ProfileFilePath,
        $Profile
    )

    if ($PSCmdlet.ParameterSetName -eq 'ProfileName')
    {
        $Path = Join-Path -Path $PSScriptRoot -ChildPath $ProfileDirectory
        
        if (-not (Test-Path -Path $Path))
        {
            New-Item -Path $Path -ItemType Directory | Out-Null
        }

        $FilePath = Join-Path -Path $Path -ChildPath $($ProfileName + '.xml')
    }

    elseif ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
    {
        $FilePath = $ProfileFilePath
    }

    Export-Clixml -Path $FilePath -InputObject $Profile
}

function inProfileNameError
{
    Param(
        [string]$Value,
        [ValidateSet('ProfileNotFound','MultipleProfiles')]
        [string]$ErrorType
    )

    if ($ErrorType -eq 'ProfileNotFound')
    {
        $Exception = [System.ArgumentException]::new("`nProfile '$Value' is not found.`n")
    }
    elseif ($ErrorType -eq 'MultipleProfiles')
    {
        $Exception = [System.ArgumentException]::new("`n'$Value' value matches multiple profiles.`n")
    }

    $ErrorId = 'ArgumentError'
    $ErrorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument

    $ErrorRecord = [System.Management.Automation.ErrorRecord]::new($Exception, $ErrorId, $ErrorCategory, $null) 

    $PSCmdlet.WriteError($ErrorRecord)
}
function inPSCredentialError
{
    Param(
        [string]$Value
    )

    $Exception = [System.ArgumentException]::new("Value of the -Credential parameter (`"$Value`") is wrong. The value should be a PSCredential object or an array of two elements.")
    $ErrorId = 'ArgumentTypeError'
    $ErrorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument

    $ErrorRecord = [System.Management.Automation.ErrorRecord]::new($Exception, $ErrorId, $ErrorCategory, $null)

    throw $ErrorRecord
}

function inNoSubjectError
{
    $Exception = [System.ArgumentException]::new("The Subject can not be empty. You can define it in the profile or by using -Subject parameter of the function.")
    $ErrorId = 'ArgumentIsNullOrEmpty'
    $ErrorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument

    $ErrorRecord = [System.Management.Automation.ErrorRecord]::new($Exception, $ErrorId, $ErrorCategory, $null)

    throw $ErrorRecord
}
