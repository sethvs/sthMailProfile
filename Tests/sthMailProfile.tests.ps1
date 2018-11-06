Remove-Module -Name sthMailProfile -Force -ErrorAction 'SilentlyContinue'
Import-Module "$PSScriptRoot\..\sthMailProfile.psd1"

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

    # $ParameterFilterConditionsWithoutMessageAndCredential = @(
    $ParameterFilterConditionsWithoutCredential = @(
        '$Body -eq "$theMessage`r`n"'
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

    # $MessageCondition = @(
    #     '$Body -eq "$theMessage`r`n"'
    # )

    # $ParameterFilterWithoutMessageAndCredential = [scriptblock]::Create($ParameterFilterConditionsWithoutMessageAndCredential -join " -and `n")
    # $ParameterFilterWithoutCredential = [scriptblock]::Create($MessageCondition + $ParameterFilterConditionsWithoutMessageAndCredential -join " -and `n")
    # $ParameterFilterWithoutCredential = [scriptblock]::Create($ParameterFilterConditionsWithoutMessageAndCredential -join " -and `n")
    $ParameterFilterWithoutCredential = [scriptblock]::Create($ParameterFilterConditionsWithoutCredential -join " -and `n")
    # $ParameterFilterWithoutMessage = [scriptblock]::Create($ParameterFilterConditionsWithoutMessageAndCredential + $CredentialConditions -join " -and `n")
    # $ParameterFilter = [scriptblock]::Create($MessageCondition + $ParameterFilterConditionsWithoutMessageAndCredential + $CredentialConditions -join " -and `n")
    # $ParameterFilter = [scriptblock]::Create($ParameterFilterConditionsWithoutMessageAndCredential + $CredentialConditions -join " -and `n")
    $ParameterFilter = [scriptblock]::Create($ParameterFilterConditionsWithoutCredential + $CredentialConditions -join " -and `n")

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
            [Parameter(ParameterSetName='ProfileFilePath')]
            $ProfileFilePath,
            [ValidateSet('Secured','PlainText','NotExist')]
            $PasswordIs
        )

        mock "Send-MailMessage" -ModuleName sthMailProfile

        if ($PSCmdlet.ParameterSetName -eq 'ProfileName')
        {
            Context "Get-sthMailProfile" {
                    
                $MailProfile = Get-sthMailProfile -ProfileName $ProfileName
                $TestCases = ComposeTestCases $TestCasesTemplate 'Password','Credential' $PasswordIs

                It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {
                    
                    Param ($Name, $Value)
                    TestMailProfileContent -Name $Name -Value $Value
                }

                It "Send-sthMailMessage" {
                    Send-sthMailMessage -ProfileName $ProfileName -Subject $theSubject -Message $theMessage -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilter
                }

                It "Send-sthMailMessage using pipeline" {
                    $theMessage | Send-sthMailMessage -ProfileName $ProfileName -Subject $theSubject -Attachments $theAttachment
                    # Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutMessage
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilter
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

        if ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
        {
            Context "Get-sthMailProfile" {

                $MailProfile = Get-sthMailProfile -ProfileFilePath $ProfileFilePath
                $TestCases = ComposeTestCases $TestCasesTemplate 'Password','Credential' $PasswordIs

                It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {

                    Param ($Name, $Value)
                    TestMailProfileContent -Name $Name -Value $Value
                }

                It "Send-sthMailMessage" {
                    Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Subject $theSubject -Message $theMessage -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilter
                }

                It "Send-sthMailMessage using pipeline" {
                    $theMessage | Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Subject $theSubject -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilter
                    # Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutMessage
                }
            }
            
            Context "Get-sthMailProfile -ShowPassword" {

                $MailProfile = Get-sthMailProfile -ProfileFilePath $ProfileFilePath -ShowPassword
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
            $ProfileName,
            [Parameter(ParameterSetName='ProfileFilePath')]
            $ProfileFilePath
        )

        if ($PSCmdlet.ParameterSetName -eq 'ProfileName')
        {
            Remove-sthMailProfile -ProfileName $ProfileName
    
            It "Should remove the profile" {
                Get-sthMailProfile | Should -BeNullOrEmpty
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
        {
            Remove-sthMailProfile -ProfileFilePath $ProfileFilePath
    
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
            $ProfileName,
            [Parameter(ParameterSetName='ProfileFilePath')]
            $ProfileFilePath
        )

        if ($PSCmdlet.ParameterSetName -eq 'ProfileName')
        {
            It "Should create the profile" {
                Get-sthMailProfile -ProfileName $ProfileName | Should -Not -BeNullOrEmpty
            }
        }
        
        if ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
        {
            It "Should create the profile" {
                Get-sthMailProfile -ProfileFilePath $ProfileFilePath | Should -Not -BeNullOrEmpty
            }
        }
    }

    function CreateAndTestProfile
    {
        Context "New-sthMailProfile -ProfileName" {

            New-sthMailProfile -ProfileName $ProfileName @ContextSettings
            TestProfileExistence -ProfileName $ProfileName

            TestMailProfile -ProfileName $ProfileName -PasswordIs 'Secured'
            RemoveProfile -ProfileName $ProfileName
        }

        Context "New-sthMailProfile -ProfileName -StorePasswordInPlainText" {

            New-sthMailProfile -ProfileName $ProfileName @ContextSettings -StorePasswordInPlainText
            TestProfileExistence -ProfileName $ProfileName

            TestMailProfile -ProfileName $ProfileName -PasswordIs 'PlainText'
            RemoveProfile -ProfileName $ProfileName
        }

        Context "New-sthMailProfile -ProfileFilePath" {

            New-sthMailProfile -ProfileFilePath $ProfileFilePath @ContextSettings
            TestProfileExistence -ProfileFilePath $ProfileFilePath

            TestMailProfile -ProfileFilePath $ProfileFilePath -PasswordIs 'Secured'
            RemoveProfile -ProfileFilePath $ProfileFilePath
        }

        Context "New-sthMailProfile -ProfileFilePath -StorePasswordInPlainText" {

            New-sthMailProfile -ProfileFilePath $ProfileFilePath @ContextSettings -StorePasswordInPlainText
            TestProfileExistence -ProfileFilePath $ProfileFilePath

            TestMailProfile -ProfileFilePath $ProfileFilePath -PasswordIs 'PlainText'
            RemoveProfile -ProfileFilePath $ProfileFilePath
        }
    }

    Context "New-sthMailProfile" {

        Context "Profile without credential" {

            BeforeAll {
                $ContextSettings = DuplicateOrderedDictionary $Settings
                $ContextSettings.Remove('UserName')
                $ContextSettings.Remove('Password')
                $ContextSettings.Remove('Credential')

                $TestCases = ComposeTestCases $TestCasesTemplate 'UserName','Password','Credential' 'NotExist'
            }

            mock "Send-MailMessage" -ModuleName sthMailProfile

            Context "New-sthMailProfile -ProfileName" {
                New-sthMailProfile -ProfileName $ProfileName @ContextSettings
                TestProfileExistence -ProfileName $ProfileName

                $MailProfile = Get-sthMailProfile -ProfileName $ProfileName

                It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {
    
                    Param ($Name, $Value)
                    TestMailProfileContent -Name $Name -Value $Value
                }
    
                It "Send-sthMailMessage" {
                    Send-sthMailMessage -ProfileName $ProfileName -Subject $theSubject -Message $theMessage -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }
    
                It "Send-sthMailMessage using pipeline" {
                    $theMessage | Send-sthMailMessage -ProfileName $ProfileName -Subject $theSubject -Attachments $theAttachment
                    # Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutMessageAndCredential
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }
    
                RemoveProfile -ProfileName $ProfileName
            }

            Context "New-sthMailProfile -ProfileFilePath" {
                New-sthMailProfile -ProfileFilePath $ProfileFilePath @ContextSettings
                TestProfileExistence -ProfileFilePath $ProfileFilePath

                $MailProfile = Get-sthMailProfile -ProfileFilePath $ProfileFilePath

                It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {
    
                    Param ($Name, $Value)
                    TestMailProfileContent -Name $Name -Value $Value
                }
    
                It "Send-sthMailMessage" {
                    Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Subject $theSubject -Message $theMessage -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }
    
                It "Send-sthMailMessage using pipeline" {
                    $theMessage | Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Subject $theSubject -Attachments $theAttachment
                    # Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutMessageAndCredential
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }

                RemoveProfile -ProfileFilePath $ProfileFilePath
            }
            
        }

        Context "Profile without credential using positional parameters" {

            BeforeAll {
                $ContextSettings = DuplicateOrderedDictionary $Settings
                $ContextSettings.Remove('UserName')
                $ContextSettings.Remove('Password')
                $ContextSettings.Remove('Credential')
                $ContextSettings.Remove('From')
                $ContextSettings.Remove('To')
                $ContextSettings.Remove('SmtpServer')

                $TestCases = ComposeTestCases $TestCasesTemplate 'UserName','Password','Credential' 'NotExist'
            }

            mock "Send-MailMessage" -ModuleName sthMailProfile

            Context "New-sthProfile -ProfileName" {

                New-sthMailProfile $ProfileName $Settings.From $Settings.To $Settings.SmtpServer @ContextSettings
                
                TestProfileExistence -ProfileName $ProfileName

                $MailProfile = Get-sthMailProfile $ProfileName
                
                It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {
                    
                    Param ($Name, $Value)
                    TestMailProfileContent -Name $Name -Value $Value
                }

                It "Send-sthMailMessage" {
                    Send-sthMailMessage $ProfileName $theSubject $theMessage -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }
                
                It "Send-sthMailMessage using pipeline" {
                    $theMessage | Send-sthMailMessage $ProfileName $theSubject -Attachments $theAttachment
                    # Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutMessageAndCredential
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }

                Remove-sthMailProfile $ProfileName
                
                It "Should remove the profile" {
                    Get-sthMailProfile | Should -BeNullOrEmpty
                }
            }

            Context "New-sthProfile -ProfileFilePath" {

                New-sthMailProfile -ProfileFilePath $ProfileFilePath $Settings.From $Settings.To $Settings.SmtpServer @ContextSettings
                
                TestProfileExistence -ProfileFilePath $ProfileFilePath

                $MailProfile = Get-sthMailProfile -ProfileFilePath $ProfileFilePath
                
                It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {
                    
                    Param ($Name, $Value)
                    TestMailProfileContent -Name $Name -Value $Value
                }

                It "Send-sthMailMessage" {
                    Send-sthMailMessage -ProfileFilePath $ProfileFilePath $theSubject $theMessage -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }

                It "Send-sthMailMessage using pipeline" {
                    $theMessage | Send-sthMailMessage -ProfileFilePath $ProfileFilePath $theSubject -Attachments $theAttachment
                    # Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutMessageAndCredential
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }

                Remove-sthMailProfile -ProfileFilePath $ProfileFilePath
                
                It "Should remove the profile" {
                    Get-sthMailProfile | Should -BeNullOrEmpty
                }
            }
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
            Assert-MockCalled "Read-Host" -ModuleName sthMailProfile -Times 4 -Exactly -Scope Context
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
                { Send-sthMailMessage -ProfileName 'Non-Existent Profile' -Subject $theSubject -Message $theMessage -Attachments $theAttachment -ErrorAction Stop } | Should -Throw -ExceptionType 'System.ArgumentException'
            }
            It "Should return 'Profile is not found'." {
                { Send-sthMailMessage -ProfileFilePath '.\NonExistentFilePath' -Subject $theSubject -Message $theMessage -Attachments $theAttachment -ErrorAction Stop } | Should -Throw -ExceptionType 'System.ArgumentException'
            }
        }

        Context "Get-sthMailProfile - non-existing profile" {

            It "Should return nothing." {
                Get-sthMailProfile -ProfileName 'Non-Existent Profile' | Should -BeNullOrEmpty
            }
            It "Should return nothing." {
                Get-sthMailProfile -ProfileFilePath '.\NonExistentFilePath' | Should -BeNullOrEmpty
            }
        }
    }
}