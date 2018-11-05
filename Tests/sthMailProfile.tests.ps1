Remove-Module -Name sthMailProfile -Force -ErrorAction 'SilentlyContinue'
Import-Module "$PSScriptRoot\..\sthMailProfile.psd1"

# Write-Host $PSVersionTable.PSVersion

Describe "sthMailProfile" {
     BeforeAll {
        $Settings = [ordered]@{
            From = 'from@domain.com'
            To = 'to@domain.com','to2@domain.com'
            UserName = 'TheUser'
            Password = 'ThePassword'
            Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'TheUser', $(ConvertTo-SecureString -String 'ThePassword' -AsPlainText -Force)
            SmtpServer = 'smtp@domain.com'
            Port = '25'
            UseSSL = $true
            Encoding = 'Unicode'
            BodyAsHtml = $true
            CC = 'cc@domain.com','cc2@domain.com'
            BCC = 'bcc@domain.com','bcc2@domain.com'
            DeliveryNotificationOption = 'OnSuccess','OnFailure','Delay'
            Priority = 'Normal'
        }

        $TestCasesTemplate = @($Settings.GetEnumerator() | ForEach-Object {@{Name = $_.Name; Value = $_.Value}})

        $ProfileName = '_Profile'
        $ProfileFilePath = 'TestDrive:\_Profile.xml'

        $theMessage = 'TheMessage' 
        $theSubject = 'TheSubject' 
        $theAttachment = 'TestDrive:\TheAttachment.xml'

        $ProfileDirectory = InModuleScope -ModuleName sthMailProfile -ScriptBlock {$ProfileDirectory}
        
        if (Test-Path -Path "$PSScriptRoot\..\$ProfileDirectory" -PathType Container)
        {
            Rename-Item -Path "$PSScriptRoot\..\$ProfileDirectory" -NewName _OriginalProfileFolder
        }
    }

    AfterAll {
        Remove-Item -Path "$PSScriptRoot\..\$ProfileDirectory"
        if (Test-Path -Path "$PSScriptRoot\..\_OriginalProfileFolder")
        {
            Rename-Item -Path "$PSScriptRoot\..\_OriginalProfileFolder" -NewName $ProfileDirectory
        }
    }

    $ParameterFilterConditionsWithoutMessageAndCredential = @(
        '$Subject -eq $theSubject'
        '$Attachments -eq $theAttachment'
        '$From -eq $($Settings.From)'
        '$($To.Count) -eq $($Settings.To.Count)'
        '$($Result = $true;
        for ($i = 0; $i -lt $($To.Count); $i++)
        {
            if ($To[$i] -ne $($Settings.To[$i])) {$Result = $False; break}
        }
        $Result)'
        '$SmtpServer -eq $Settings.SmtpServer'
        '$Port -eq $Settings.Port'
        '$UseSSL -eq $Settings.UseSSL'
        '$Encoding.EncodingName -eq $Settings.Encoding'
        '$BodyAsHtml -eq $Settings.BodyAsHtml'
        '$($CC.Count) -eq $($Settings.CC.Count)'
        '$($Result = $true;
        for ($i = 0; $i -lt $($CC.Count); $i++)
        {
            if ($CC[$i] -ne $($Settings.CC[$i])) {$Result = $False; break}
        }
        $Result)'
        '$($BCC.Count) -eq $($Settings.BCC.Count)'
        '$($Result = $true;
        for ($i = 0; $i -lt $($BCC.Count); $i++)
        {
            if ($BCC[$i] -ne $($Settings.BCC[$i])) {$Result = $False; break}
        }
        $Result)'
        '$DeliveryNotificationOption -eq [System.Net.Mail.DeliveryNotificationOptions]$Settings.DeliveryNotificationOption'
        '$Priority -eq $Settings.Priority'
    )

    $CredentialConditions = @(
    '$Credential.UserName -eq $Settings.UserName'
    '[System.Net.NetworkCredential]::new("something",$Credential.Password).Password -eq $Settings.Password'
    )

    $MessageCondition = @(
        '$Body -eq "$theMessage`r`n"'
    )

    $ParameterFilterWithoutMessageAndCredential = [scriptblock]::Create($ParameterFilterConditionsWithoutMessageAndCredential -join " -and `n")
    $ParameterFilterWithoutCredential = [scriptblock]::Create($MessageCondition + $ParameterFilterConditionsWithoutMessageAndCredential -join " -and `n")
    $ParameterFilterWithoutMessage = [scriptblock]::Create($ParameterFilterConditionsWithoutMessageAndCredential + $CredentialConditions -join " -and `n")
    $ParameterFilter = [scriptblock]::Create($MessageCondition + $ParameterFilterConditionsWithoutMessageAndCredential + $CredentialConditions -join " -and `n")
    
    function TestMailProfileContent
    {
        Param ($Name, $Value)

        switch ($Value.GetType().FullName)
        {
            'System.String'
            {
                if ($Name -eq 'Encoding')
                {
                    $MailProfile.$Name.EncodingName | Should -BeExactly $Value
                }
                else
                {
                    $MailProfile.$Name | Should -BeExactly $Value
                }
            }
            'System.Object[]'
            {
                $MailProfile.$Name.Count | Should -BeExactly $Value.Count
                for ($i = 0; $i -lt $Value.Count; $i++)
                {
                    $MailProfile.$Name[$i] | Should -BeExactly $Value[$i]
                }
            }
            'System.Boolean'
            {
                $MailProfile.$Name.IsPresent | Should -BeExactly $Value
            }
        }
    }

    function DuplicateOrderedDictionary
    {
        Param (
            [Parameter(Mandatory)]
            [System.Collections.Specialized.OrderedDictionary]$Settings
        )

        $ContextSettings = [ordered]@{}

        foreach ($s in $Settings.GetEnumerator())
        {
            $ContextSettings.Add($s.Key, $s.Value)
        }

        return $ContextSettings
    }

    function ComposeTestCases
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword","")]
        Param (
            [array]$TestCasesTemplate,
            [string[]]$Remove,
            [ValidateSet('Secured','PlainText','NotExist')]
            [string]$PasswordIs
        )

        $TestCases = $TestCasesTemplate | Where-Object {$_.Name -notin $Remove}
        
        $TestCases += @{Name = 'PasswordIs'; Value = $PasswordIs}

        return $TestCases
    }

    function TestMailProfile
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword","")]
        [CmdletBinding(DefaultParameterSetName='ProfileName')]
        Param (
            [Parameter(ParameterSetName='ProfileName')]
            $ProfileName,
            [ValidateSet('Secured','PlainText','NotExist')]
            $PasswordIs
        )

        if ($PSCmdlet.ParameterSetName -eq 'ProfileName')
        {
            mock "Send-MailMessage" -ModuleName sthMailProfile

            Context "Get-sthMailProfile" {
                    
                $MailProfile = Get-sthMailProfile -ProfileName $ProfileName
                $TestCases = ComposeTestCases $TestCasesTemplate 'Password','Credential' $PasswordIs

                It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {
                    
                    Param ($Name, $Value)
                    TestMailProfileContent -Name $Name -Value $Value
                }

                It "Send-sthMailMessage" {
                    Send-sthMailMessage -ProfileName $ProfileName -Message $theMessage -Subject $theSubject -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilter
                }

                It "Send-sthMailMessage using pipeline" {
                    $theMessagee | Send-sthMailMessage -ProfileName $ProfileName -Subject $theSubject -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutMessage
                }
            }
            
            Context "Get-sthMailProfile -ShowPassword" {
                
                $MailProfile = Get-sthMailProfile -ProfileName $ProfileName -ShowPassword
                $TestCases = ComposeTestCases $TestCasesTemplate 'Credential' $PasswordIs
    
                It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {

                    Param ($Name, $Value)
                    TestMailProfileContent -Name $Name -Value $Value
                }
            }
        }
    }

    function RemoveProfile
    {
        [CmdletBinding(DefaultParameterSetName='ProfileName')]
        Param (
            [Parameter(ParameterSetName='ProfileName')]
            $ProfileName
        )

        if ($PSCmdlet.ParameterSetName -eq 'ProfileName')
        {
            Remove-sthMailProfile -ProfileName $ProfileName
    
            It "Should remove the profile" {
                Get-sthMailProfile | Should -BeNullOrEmpty
            }
        }
    }

    function TestProfileExistence
    {
        [CmdletBinding(DefaultParameterSetName='ProfileName')]
        Param (
            [Parameter(ParameterSetName='ProfileName')]
            $ProfileName
        )

        if ($PSCmdlet.ParameterSetName -eq 'ProfileName')
        {
            It "Should create the profile" {
                Get-sthMailProfile -ProfileName $ProfileName | Should -Not -BeNullOrEmpty
            }
        }
    }

    function CreateAndTestProfile
    {
        Context "New-sthMailProfile" {

            New-sthMailProfile -ProfileName $ProfileName @ContextSettings
            TestProfileExistence -ProfileName $ProfileName

            TestMailProfile -ProfileName $ProfileName -PasswordIs 'Secured'
            RemoveProfile -ProfileName $ProfileName
        }

        Context "New-sthMailProfile -StorePasswordInPlainText" {

            New-sthMailProfile -ProfileName $ProfileName @ContextSettings -StorePasswordInPlainText
            TestProfileExistence -ProfileName $ProfileName

            TestMailProfile -ProfileName $ProfileName -PasswordIs 'PlainText'
            RemoveProfile -ProfileName $ProfileName
        }
    }
    
    Context "New-sthMailProfile" {

        Context "Profile without credential" {

            BeforeAll {
                $ContextSettings = DuplicateOrderedDictionary $Settings
                $ContextSettings.Remove('UserName')
                $ContextSettings.Remove('Password')
                $ContextSettings.Remove('Credential')
                
                New-sthMailProfile -ProfileName $ProfileName @ContextSettings
                TestProfileExistence -ProfileName $ProfileName

                $MailProfile = Get-sthMailProfile -ProfileName $ProfileName
                $TestCases = ComposeTestCases $TestCasesTemplate 'UserName','Password','Credential' 'NotExist'
            }

            mock "Send-MailMessage" -ModuleName sthMailProfile

            It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {

                Param ($Name, $Value)
                TestMailProfileContent -Name $Name -Value $Value
            }

            It "Send-sthMailMessage" {
                Send-sthMailMessage -ProfileName $ProfileName -Message $theMessage -Subject $theSubject -Attachments $theAttachment
                Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
            }

            It "Send-sthMailMessage using pipeline" {
                $theMessagee | Send-sthMailMessage -ProfileName $ProfileName -Subject $theSubject -Attachments $theAttachment
                Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutMessageAndCredential
            }

            RemoveProfile -ProfileName $ProfileName
        }

        Context "Profile with -UserName and -Password parameters" {

            $ContextSettings = DuplicateOrderedDictionary $Settings
            $ContextSettings.Remove('Credential')

            CreateAndTestProfile
        }

        Context "Profile with -UserName and -Password parameters with empty string password" {

            $Settings = DuplicateOrderedDictionary $Settings
            $Settings.Password = ''
            $ContextSettings = DuplicateOrderedDictionary $Settings

            $TestCasesTemplate = @($Settings.GetEnumerator() | ForEach-Object {@{Name = $_.Name; Value = $_.Value}})

            $ContextSettings.Remove('Credential')

            CreateAndTestProfile
        }

        Context "Profile with -UserName parameter and -Password parameter value from Read-Host" {

            Mock "Read-Host" $([scriptblock]::Create("ConvertTo-SecureString -String $($Settings.Password) -AsPlainText -Force")) -ModuleName sthMailProfile

            $ContextSettings = DuplicateOrderedDictionary $Settings
            $ContextSettings.Remove('Credential')
            $ContextSettings.Remove('Password')

            CreateAndTestProfile
            Assert-MockCalled "Read-Host" -ModuleName sthMailProfile -Times 2 -Exactly -Scope Context
        }

        Context "Profile with -Credentialparameter" {

            $ContextSettings = DuplicateOrderedDictionary $Settings
            $ContextSettings.Remove('UserName')
            $ContextSettings.Remove('Password')

            CreateAndTestProfile
        }

        Context "Profile with -Credentialparameter with encoding as CodePage" {

            $ContextSettings = DuplicateOrderedDictionary $Settings
            $ContextSettings.Remove('UserName')
            $ContextSettings.Remove('Password')
            $ContextSettings.Encoding = '1200'

            CreateAndTestProfile
        }

        Context "Send-sthMailMessage - non-existing profile" {
            
            It "Should return 'Profile is not found'." {
                Send-sthMailMessage -ProfileName 'Non-Existent Profile' -Message $theMessage -Subject $theSubject -Attachments $theAttachment | Should -BeExactly "`nProfile 'Non-Existent Profile' is not found.`n"
            }
        }
    }
}