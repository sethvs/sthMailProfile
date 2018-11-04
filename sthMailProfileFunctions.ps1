$ProfileDirectory = 'Profiles'

# .ExternalHelp sthMailProfile.help.ps1xml
function Send-sthMailMessage
{
    Param(
        [Parameter(ValueFromPipeline)]    
        $Message,
        [Parameter(Mandatory)]
        [string]$Subject,
        [Parameter(Mandatory)]
        [string]$ProfileName,
        [string[]]$Attachments
    )

    Begin
    {
        $Body = @()
    }

    Process
    {
        $Body += $Message
    }

    End
    {
        if ($MailProfile = Get-sthMailProfile -ProfileName $ProfileName)
        {
            if ($MailProfile.PasswordIs -eq 'PlainText')
            {
                try
                {
                    $Password = ConvertTo-SecureString -String (Get-sthMailProfile -ProfileName $ProfileName -ShowPassword | Select-Object -ExpandProperty Password) -AsPlainText -Force
                }
                catch [System.Management.Automation.ParameterBindingException]
                {
                    $Password = [System.Security.SecureString]::new()
                }

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

            if ($Body)
            {
                $Body = $Body | Out-String -Width 1000
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
            Write-Output -InputObject "`nProfile $ProfileName not found.`n"
        }
    }

}

# .ExternalHelp sthMailProfile.help.ps1xml
function New-sthMailProfile
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword","")]
    [CmdletBinding(DefaultParameterSetName='Password')]
    Param(
        [Parameter(Mandatory)]
        [string]$ProfileName,
        [Parameter(Mandatory)]
        [string]$From,
        [Parameter(Mandatory)]
        [string[]]$To,
        [Parameter(ParameterSetName='Password')]
        [string]$UserName,
        [Parameter(ParameterSetName='Password')]
        $Password,
        [Parameter(ParameterSetName='Credential')]
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

    if ($PSCmdlet.ParameterSetName -eq 'Password')
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

        else
        {
            $MailParameters = [sthMailProfile]::new($From, $To, $SmtpServer)
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'Credential')
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
        if ($PSBoundParameter.Key -notin 'From','To','SmtpServer','UserName','Password','ProfileName','StorePasswordInPlainText')
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

    $Path = Join-Path -Path $PSScriptRoot -ChildPath $ProfileDirectory
    
    if (-not (Test-Path -Path $Path))
    {
        New-Item -Path $Path -ItemType Directory | Out-Null
    }

    $FilePath = Join-Path -Path $Path -ChildPath $($ProfileName + '.xml')

    Export-Clixml -Path $FilePath -InputObject $MailParameters
}

# .ExternalHelp sthMailProfile.help.ps1xml
function Get-sthMailProfile
{
    Param(
        [string[]]$ProfileName = "*",
        [switch]$ShowPassword
        )

    $FolderPath = Join-Path -Path $PSScriptRoot -ChildPath $ProfileDirectory

    foreach ($PName in $ProfileName)
    {
        foreach ($ProfilePath in (Get-ChildItem -Path $("$FolderPath\$PName.xml") | Where-Object -FilterScript {$_.PSIsContainer -eq $false}))
        {
            $xml = Import-Clixml -Path $ProfilePath.FullName
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
        }
    }
}

# .ExternalHelp sthMailProfile.help.ps1xml
function Remove-sthMailProfile
{
    Param(
        [Parameter(Mandatory)]
        [string]$ProfileName
    )

    $Path = Join-Path -Path $PSScriptRoot -ChildPath $ProfileDirectory
    $Path = Join-Path -Path $Path -ChildPath $($ProfileName + '.xml')

    Remove-Item -Path $Path
}