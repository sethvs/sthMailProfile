$ProfileDirectory = 'Profiles'

# .ExternalHelp sthMailProfile.help.ps1xml
function Send-sthMailMessage
{
    Param(
        [Parameter(ValueFromPipeline)]
        $Message,
        [Parameter(Mandatory)]
        [string]$Subject,
        [Parameter(Mandatory,ParameterSetName='ProfileName')]
        [string]$ProfileName,
        [Parameter(Mandatory,ParameterSetName='ProfileFilePath')]
        [string]$ProfileFilePath,
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
        if ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
        {
            $MailProfile = Get-sthMailProfile -ProfileFilePath $ProfileFilePath
        }
        # if ($MailProfile = Get-sthMailProfile -ProfileName $ProfileName)
        if ($MailProfile)
        {
            if ($MailProfile.PasswordIs -eq 'PlainText')
            {
                try
                {
                    if ($PSCmdlet.ParameterSetName -eq 'ProfileName')
                    {
                        $Password = ConvertTo-SecureString -String (Get-sthMailProfile -ProfileName $ProfileName -ShowPassword | Select-Object -ExpandProperty Password) -AsPlainText -Force
                    }
                    if ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
                    {
                        $Password = ConvertTo-SecureString -String (Get-sthMailProfile -ProfileFilePath $ProfileFilePath -ShowPassword | Select-Object -ExpandProperty Password) -AsPlainText -Force
                    }
                }
                catch [System.Management.Automation.ParameterBindingException]
                {
                    $Password = [System.Security.SecureString]::new()
                }
<# 
                if ($PSCmdlet.ParameterSetName -eq 'ProfileName')
                {
                    try
                    {
                        $Password = ConvertTo-SecureString -String (Get-sthMailProfile -ProfileName $ProfileName -ShowPassword | Select-Object -ExpandProperty Password) -AsPlainText -Force
                    }
                    catch [System.Management.Automation.ParameterBindingException]
                    {
                        $Password = [System.Security.SecureString]::new()
                    }
                }
                if ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
                {
                    try
                    {
                        $Password = ConvertTo-SecureString -String (Get-sthMailProfile -ProfileFilePath $ProfileFilePath -ShowPassword | Select-Object -ExpandProperty Password) -AsPlainText -Force
                    }
                    catch [System.Management.Automation.ParameterBindingException]
                    {
                        $Password = [System.Security.SecureString]::new()
                    }
                }
 #>
                $MailProfile.Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $MailProfile.Credential.UserName, $Password
            }

            $Parameters = @{}

            foreach ($Property in $MailProfile.PSObject.Properties.Name | Where-Object -FilterScript {$_ -notin 'ProfileName', 'PasswordIs', 'UserName', 'Password'})
            {
                if ($MailProfile.$Property)
                {
                    $Parameters.Add($Property, $MailProfile.$Property)
                }
            }

            $Parameters.Add("Subject", $Subject)

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

        else
        {
            if ($PSCmdlet.ParameterSetName -eq 'ProfileName')
            {
                inProfileNameError -Value $ProfileName
            }
            if ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
            {
                inProfileNameError -Value $ProfileFilePath
            }
        }
    }

}

# .ExternalHelp sthMailProfile.help.ps1xml
function New-sthMailProfile
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword","")]
    [CmdletBinding(DefaultParameterSetName='ProfileName')]
    Param(
        [Parameter(Mandatory,ParameterSetName='ProfileName')]
        [Parameter(Mandatory,ParameterSetName='ProfileName-Password')]
        [Parameter(Mandatory,ParameterSetName='ProfileName-Credential')]
        [string]$ProfileName,
        [Parameter(Mandatory,ParameterSetName='ProfileFilePath')]
        [Parameter(Mandatory,ParameterSetName='ProfileFilePath-Password')]
        [Parameter(Mandatory,ParameterSetName='ProfileFilePath-Credential')]
        [string]$ProfileFilePath,
        [Parameter(Mandatory)]
        [string]$From,
        [Parameter(Mandatory)]
        [string[]]$To,
        [Parameter(Mandatory,ParameterSetName='ProfileName-Password')]
        [Parameter(Mandatory,ParameterSetName='ProfileFilePath-Password')]
        [string]$UserName,
        [Parameter(ParameterSetName='ProfileName-Password')]
        [Parameter(ParameterSetName='ProfileFilePath-Password')]
        $Password,
        [Parameter(Mandatory,ParameterSetName='ProfileName-Credential')]
        [Parameter(Mandatory,ParameterSetName='ProfileFilePath-Credential')]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential,
        [Parameter(Mandatory)]
        [string]$SmtpServer,
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
        [switch]$StorePasswordInPlainText
    )

    # Wait-Debugger
    if ($PSCmdlet.ParameterSetName -eq 'ProfileName-Password' -or $PSCmdlet.ParameterSetName -eq 'ProfileFilePath-Password')
    {
        if ($PSBoundParameters.ContainsKey('UserName'))
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

        # else
        # {
        #     $MailParameters = [sthMailProfile]::new($From, $To, $SmtpServer)
        # }
    }

    if ($PSCmdlet.ParameterSetName -eq 'ProfileName' -or $PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
    {
        $MailParameters = [sthMailProfile]::new($From, $To, $SmtpServer)
    }

    if ($PSCmdlet.ParameterSetName -eq 'ProfileName-Credential' -or $PSCmdlet.ParameterSetName -eq 'ProfileFilePath-Credential')
    {
        $MailParameters = [sthMailProfile]::new($From, $To, $Credential, $SmtpServer)
    }

    if ($StorePasswordInPlainText)
    {
        $MailParameters | Add-Member -NotePropertyName PlainTextPassword -NotePropertyValue $Credential.GetNetworkCredential().Password
        $MailParameters.PasswordIs = [PasswordIs]'PlainText'
    }

    foreach ($PSBoundParameter in $PSBoundParameters.GetEnumerator())
    {
        if ($PSBoundParameter.Key -notin 'From','To','SmtpServer','UserName','Password','ProfileName','ProfileFilePath','StorePasswordInPlainText')
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
<# 
        $Path = Join-Path -Path $PSScriptRoot -ChildPath $ProfileDirectory
        
        if (-not (Test-Path -Path $Path))
        {
            New-Item -Path $Path -ItemType Directory | Out-Null
        }
    
        $FilePath = Join-Path -Path $Path -ChildPath $($ProfileName + '.xml')
 #>
    }

    if ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath-Password' -or $PSCmdlet.ParameterSetName -eq 'ProfileFilePath-Credential' -or $PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
    {
        inWriteProfile -ProfileFilePath $ProfileFilePath -Profile $MailParameters
        # $FilePath = $ProfileFilePath
    }

    # Export-Clixml -Path $FilePath -InputObject $MailParameters
}

# .ExternalHelp sthMailProfile.help.ps1xml
function Get-sthMailProfile
{
    [CmdletBinding(DefaultParameterSetName='ProfileName')]
    Param(
        [Parameter(ParameterSetName='ProfileName')]
        [string[]]$ProfileName = "*",
        [Parameter(ParameterSetName='ProfileFilePath')]
        [string]$ProfileFilePath,
        [switch]$ShowPassword
        )

    if ($PSCmdlet.ParameterSetName -eq 'ProfileName')
    {
        $FolderPath = Join-Path -Path $PSScriptRoot -ChildPath $ProfileDirectory
        
        foreach ($PName in $ProfileName)
        {
            foreach ($ProfilePath in (Get-Item -Path $("$FolderPath\$PName.xml") -ErrorAction SilentlyContinue | Where-Object -FilterScript {$_.PSIsContainer -eq $false}))
            {
                $xml = Import-Clixml -Path $ProfilePath.FullName
                inComposeMailProfile -Xml $xml -ProfileFileName $ProfilePath.Name
<# 
                $xml.Encoding = [System.Text.Encoding]::GetEncoding($xml.Encoding.CodePage)
                
                $MailProfile = [sthMailProfile]::new($xml.From,$xml.To,$xml.Credential,$xml.PasswordIs,$xml.SmtpServer,$xml.Port,$xml.UseSSL,$xml.Encoding,$xml.BodyAsHtml,$xml.CC,$xml.BCC,$xml.DeliveryNotificationOption,$xml.Priority)
                $MailProfile | Add-Member -NotePropertyName ProfileName -NotePropertyValue $ProfilePath.Name.Substring(0,$ProfilePath.Name.Length - 4)
                $MailProfile | Add-Member -NotePropertyName UserName -NotePropertyValue $MailProfile.Credential.UserName
                if ($ShowPassword)
                {
                    if ($MailProfile.PasswordIs -eq 'Secured')
                    {
                        $MailProfile | Add-Member -NotePropertyName Password -NotePropertyValue $MailProfile.Credential.GetNetworkCredential().Password
                    }
                    if ($MailProfile.PasswordIs -eq 'PlainText')
                    {
                        $MailProfile | Add-Member -NotePropertyName Password -NotePropertyValue $xml.PlainTextPassword
                    }
                    $MailProfile | Add-Member -TypeName 'sthMailProfile#Password'
                }
                $MailProfile
 #>
            }
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
    {
        # $ProfilePath = Get-Item $ProfileFilePath
        # if ($ProfilePath = Get-Item -Path $ProfileFilePath -ErrorAction SilentlyContinue)
        if (Test-Path -Path $ProfileFilePath)
        {
            $xml = Import-Clixml -Path $ProfileFilePath
            inComposeMailProfile -Xml $xml -ProfileFileName $(Split-Path -Path $ProfileFilePath -Leaf)
        }
    }
}

# .ExternalHelp sthMailProfile.help.ps1xml
function Remove-sthMailProfile
{
    Param(
        [Parameter(Mandatory,ParameterSetName='ProfileName')]
        [string]$ProfileName,
        [Parameter(Mandatory,ParameterSetName='ProfileFilePath')]
        [string]$ProfileFilePath
    )

    if ($PSCmdlet.ParameterSetName -eq 'ProfileName')
    {
        $Path = Join-Path -Path $PSScriptRoot -ChildPath $ProfileDirectory
        $Path = Join-Path -Path $Path -ChildPath $($ProfileName + '.xml')
    }
    if ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
    {
        $Path = $ProfileFilePath
    }

    Remove-Item -Path $Path
}

function inProfileNameError
{
    Param(
        [string]$Value
    )

    $Exception = [System.ArgumentException]::new("`nProfile '$Value' is not found.`n")
    $ErrorId = 'ArgumentError'
    $ErrorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument

    $ErrorRecord = [System.Management.Automation.ErrorRecord]::new($Exception, $ErrorId, $ErrorCategory, $null)

    $PSCmdlet.WriteError($ErrorRecord)
}

function inComposeMailProfile
{
    Param (
        $Xml,
        [string]$ProfileFileName
    )

    $xml.Encoding = [System.Text.Encoding]::GetEncoding($xml.Encoding.CodePage)
                
    $MailProfile = [sthMailProfile]::new($xml.From,$xml.To,$xml.Credential,$xml.PasswordIs,$xml.SmtpServer,$xml.Port,$xml.UseSSL,$xml.Encoding,$xml.BodyAsHtml,$xml.CC,$xml.BCC,$xml.DeliveryNotificationOption,$xml.Priority)
    # $MailProfile | Add-Member -NotePropertyName ProfileName -NotePropertyValue $ProfilePath.Name.Substring(0,$ProfilePath.Name.Length - 4)
    $MailProfile | Add-Member -NotePropertyName ProfileName -NotePropertyValue $ProfileFileName.Substring(0,$ProfileFileName.Length - 4)
    $MailProfile | Add-Member -NotePropertyName UserName -NotePropertyValue $MailProfile.Credential.UserName
    if ($ShowPassword)
    {
        if ($MailProfile.PasswordIs -eq 'Secured')
        {
            $MailProfile | Add-Member -NotePropertyName Password -NotePropertyValue $MailProfile.Credential.GetNetworkCredential().Password
        }
        if ($MailProfile.PasswordIs -eq 'PlainText')
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

    if ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
    {
        $FilePath = $ProfileFilePath
    }

    Export-Clixml -Path $FilePath -InputObject $Profile
}
