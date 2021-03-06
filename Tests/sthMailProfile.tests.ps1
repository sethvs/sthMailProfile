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
            Subject = 'TheSubject'
            Port = '25'
            UseSSL = $true
            Encoding = 'Unicode'
            BodyAsHtml = $true
            CC = 'cc@domain.com','cc2@domain.com'
            BCC = 'bcc@domain.com','bcc2@domain.com'
            DeliveryNotificationOption = 'OnSuccess','OnFailure','Delay'
            Priority = 'Normal'
            DoNotSendIfMessageIsEmpty = $false
        }

        $ProfileName = '_Profile'
        $ProfileFilePath = 'TestDrive:\_Profile.xml'

        $theMessage = 'TheMessage'
        $theMessageArray = 'TheMessage','TheMessage2','TheMessage3'
        $theSubject = 'AnotherSubject'
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

    $MessageCondition = @('$Body -eq "$theMessage`r`n"')
    $MessageArrayCondition = @('$Body -eq "$theMessage`r`n${theMessage}2`r`n${theMessage}3`r`n"')
    $EmptyMessageCondition = @('$Body -eq $null')
    $ParameterFilterConditionsWithoutCredential = @(
        '$Subject -eq $ContextSettings.Subject'
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

    $ParameterFilterWithoutCredential = [scriptblock]::Create($MessageCondition + $ParameterFilterConditionsWithoutCredential -join " -and `n")
    $ParameterFilter = [scriptblock]::Create($MessageCondition + $ParameterFilterConditionsWithoutCredential + $CredentialConditions -join " -and `n")

    $ParameterFilterWithoutCredentialMessageAsArray = [scriptblock]::Create($MessageArrayCondition + $ParameterFilterConditionsWithoutCredential -join " -and `n")
    $ParameterFilterMessageAsArray = [scriptblock]::Create($MessageArrayCondition + $ParameterFilterConditionsWithoutCredential + $CredentialConditions -join " -and `n")

    $ParameterFilterWithoutCredentialEmptyMessage = [scriptblock]::Create($EmptyMessageCondition + $ParameterFilterConditionsWithoutCredential -join " -and `n")
    $ParameterFilterEmptyMessage = [scriptblock]::Create($EmptyMessageCondition + $ParameterFilterConditionsWithoutCredential + $CredentialConditions -join " -and `n")

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
            [string[]]$Remove,
            [ValidateSet('Secured','PlainText','NotExist')]
            [string]$PasswordIs
        )

        if ($ContextSettings.Encoding -eq '1200')
        {
            $ContextSettings.Encoding = 'Unicode'
        }

        $TestCasesTemplate = @($ContextSettings.GetEnumerator() | ForEach-Object {@{Name = $_.Name; Value = $_.Value}})
        $TestCasesTemplate += @{Name = 'ProfileName'; Value = $Script:ProfileName}

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
                $TestCases = ComposeTestCases 'Password','Credential' $PasswordIs

                It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {

                    Param ($Name, $Value)
                    TestMailProfileContent -Name $Name -Value $Value
                }

                It "Send-sthMailMessage" {
                    Send-sthMailMessage -ProfileName $ProfileName -Message $theMessage -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilter
                }

                It "Send-sthMailMessage using pipeline" {
                    $theMessage | Send-sthMailMessage -ProfileName $ProfileName -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilter
                }

                It "Send-sthMailMessage using pipeline - array" {
                    $theMessageArray | Send-sthMailMessage -ProfileName $ProfileName -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterMessageAsArray
                }
            }

            Context "Get-sthMailProfile -ShowPassword" {

                $MailProfile = Get-sthMailProfile -ProfileName $ProfileName -ShowPassword
                $TestCases = ComposeTestCases 'Credential' $PasswordIs

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
                $TestCases = ComposeTestCases 'Password','Credential' $PasswordIs

                It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {

                    Param ($Name, $Value)
                    TestMailProfileContent -Name $Name -Value $Value
                }

                It "Send-sthMailMessage" {
                    Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Message $theMessage -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilter
                }

                It "Send-sthMailMessage using pipeline" {
                    $theMessage | Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilter
                }

                It "Send-sthMailMessage using pipeline - array" {
                    $theMessageArray | Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterMessageAsArray
                }
            }

            Context "Get-sthMailProfile -ShowPassword" {

                $MailProfile = Get-sthMailProfile -ProfileFilePath $ProfileFilePath -ShowPassword
                $TestCases = ComposeTestCases 'Credential' $PasswordIs

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
                Get-sthMailProfile -ProfileName $ProfileName | Should -BeNullOrEmpty
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'ProfileFilePath')
        {
            Remove-sthMailProfile -ProfileFilePath $ProfileFilePath

            It "Should remove the profile" {
                Get-sthMailProfile -ProfileFilePath $ProfileFilePath | Should -BeNullOrEmpty
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

                $TestCases = ComposeTestCases 'UserName','Password','Credential' 'NotExist'
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
                    Send-sthMailMessage -ProfileName $ProfileName -Message $theMessage -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }

                It "Send-sthMailMessage using pipeline" {
                    $theMessage | Send-sthMailMessage -ProfileName $ProfileName -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }

                It "Send-sthMailMessage using pipeline - array" {
                    $theMessageArray | Send-sthMailMessage -ProfileName $ProfileName -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredentialMessageAsArray
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
                    Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Message $theMessage -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }

                It "Send-sthMailMessage using pipeline" {
                    $theMessage | Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }

                It "Send-sthMailMessage using pipeline - array" {
                    $theMessageArray | Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredentialMessageAsArray
                }

                RemoveProfile -ProfileFilePath $ProfileFilePath
            }
        }

        Context "Profile without credential using positional parameters, and redefining Subject from profile with new value" {

            BeforeAll {
                $ContextSettings = DuplicateOrderedDictionary $Settings
                $ContextSettings.Remove('UserName')
                $ContextSettings.Remove('Password')
                $ContextSettings.Remove('Credential')
                $ContextSettings.Remove('From')
                $ContextSettings.Remove('To')
                $ContextSettings.Remove('SmtpServer')
                $ContextSettings.Subject = $theSubject

                $TestCases = ComposeTestCases 'UserName','Password','Credential' 'NotExist'
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
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }

                It "Send-sthMailMessage using pipeline - array" {
                    $theMessageArray | Send-sthMailMessage $ProfileName $theSubject -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredentialMessageAsArray
                }

                Remove-sthMailProfile $ProfileName

                It "Should remove the profile" {
                    Get-sthMailProfile $ProfileName | Should -BeNullOrEmpty
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
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }

                It "Send-sthMailMessage using pipeline - array" {
                    $theMessageArray | Send-sthMailMessage -ProfileFilePath $ProfileFilePath $theSubject -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredentialMessageAsArray
                }

                Remove-sthMailProfile -ProfileFilePath $ProfileFilePath

                It "Should remove the profile" {
                    Get-sthMailProfile $ProfileFilePath | Should -BeNullOrEmpty
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

        Context "Profile with -Credential parameter" {

            $ContextSettings = DuplicateOrderedDictionary $Settings
            $ContextSettings.Remove('UserName')
            $ContextSettings.Remove('Password')

            CreateAndTestProfile
        }

        Context "Profile with -Credential parameter as an array " {

            $ContextSettings = DuplicateOrderedDictionary $Settings
            $ContextSettings.Remove('UserName')
            $ContextSettings.Remove('Password')
            $ContextSettings.Credential = @('TheUser','ThePassword')

            CreateAndTestProfile
        }

        Context "Profile with -Credential parameter with encoding as CodePage" {

            $ContextSettings = DuplicateOrderedDictionary $Settings
            $ContextSettings.Remove('UserName')
            $ContextSettings.Remove('Password')
            $ContextSettings.Encoding = '1200'

            CreateAndTestProfile
        }

        Context "Send-sthMailMessage - non-existing profile" {

            It "Should return 'Profile is not found'." {
                { Send-sthMailMessage -ProfileName 'Non-Existent Profile' -Message $theMessage -Attachments $theAttachment -ErrorAction Stop } | Should -Throw -ExceptionType 'System.ArgumentException'
            }
            It "Should return 'Profile is not found'." {
                { Send-sthMailMessage -ProfileFilePath '.\NonExistentFilePath' -Message $theMessage -Attachments $theAttachment -ErrorAction Stop } | Should -Throw -ExceptionType 'System.ArgumentException'
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

        Context "New-sthMailProfile - wrong -Credential parameter value" {

            It "Should return terminating error - string object" {
                { New-sthMailProfile -ProfileName $ProfileName -From $Settings.From -To $Settings.To -SmtpServer $Settings.SmtpServer -Credential 'oneObject' } | Should -Throw -ExceptionType 'System.ArgumentException'
            }

            It "Should return terminating error - three element array" {
                { New-sthMailProfile -ProfileName $ProfileName -From $Settings.From -To $Settings.To -SmtpServer $Settings.SmtpServer -Credential @(1,2,3) } | Should -Throw -ExceptionType 'System.ArgumentException'
            }
        }

        Context "New-sthMailProfile and Send-sthMailMessage - Subject is empty" {

            Context "New-sthMailProfile -ProfileName" {

                New-sthMailProfile -ProfileName $ProfileName -From $Settings.From -To $Settings.To -SmtpServer $Settings.SmtpServer
                TestProfileExistence -ProfileName $ProfileName

                It "Should return terminating error - subject is empty" {
                    { Send-sthMailMessage -ProfileName $ProfileName } | Should -Throw -ExceptionType 'System.ArgumentException'
                }

                RemoveProfile -ProfileName $ProfileName
            }

            Context "New-sthMailProfile -ProfileName" {

                New-sthMailProfile -ProfileFilePath $ProfileFilePath -From $Settings.From -To $Settings.To -SmtpServer $Settings.SmtpServer
                TestProfileExistence -ProfileFilePath $ProfileFilePath

                It "Should return terminating error - subject is empty" {
                    { Send-sthMailMessage -ProfileFilePath $ProfileFilePath } | Should -Throw -ExceptionType 'System.ArgumentException'
                }

                RemoveProfile -ProfileFilePath $ProfileFilePath
            }
        }

        Context "DoNotSendIfMessageIsEmpty = `$True - Should not send empty message" {

            BeforeAll {
                $ContextSettings = DuplicateOrderedDictionary $Settings
                $ContextSettings.Remove('UserName')
                $ContextSettings.Remove('Password')
                $ContextSettings.DoNotSendIfMessageIsEmpty = $true

                $TestCases = ComposeTestCases 'Password','Credential' 'Secured'
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
                    Send-sthMailMessage -ProfileName $ProfileName -Message $theMessage -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }

                It "Send-sthMailMessage using pipeline" {
                    $theMessage | Send-sthMailMessage -ProfileName $ProfileName -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }

                It "Send-sthMailMessage using pipeline - array" {
                    $theMessageArray | Send-sthMailMessage -ProfileName $ProfileName -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredentialMessageAsArray
                }

                It "Send-sthMailMessage -Message `$null" {
                    Send-sthMailMessage -ProfileName $ProfileName -Message $null -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 0 -Exactly
                }

                It "Send-sthMailMessage using pipeline - `$null" {
                    $null | Send-sthMailMessage -ProfileName $ProfileName -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 0 -Exactly
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
                    Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Message $theMessage -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }

                It "Send-sthMailMessage using pipeline" {
                    $theMessage | Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredential
                }

                It "Send-sthMailMessage using pipeline - array" {
                    $theMessageArray | Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterWithoutCredentialMessageAsArray
                }

                It "Send-sthMailMessage -Message `$null" {
                    Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Message $null -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 0 -Exactly
                }

                It "Send-sthMailMessage using pipeline - `$null" {
                    $null | Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 0 -Exactly
                }

                RemoveProfile -ProfileFilePath $ProfileFilePath
            }
        }

        Context "DoNotSendIfMessageIsEmpty = `$False - Should send empty message" {

            BeforeAll {
                $ContextSettings = DuplicateOrderedDictionary $Settings
                $ContextSettings.Remove('UserName')
                $ContextSettings.Remove('Password')

                $TestCases = ComposeTestCases 'Password','Credential' 'Secured'
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

                It "Send-sthMailMessage -Message `$null" {
                    Send-sthMailMessage -ProfileName $ProfileName -Message "" -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterEmptyMessage
                }

                It "Send-sthMailMessage using pipeline - `$null" {
                    "" | Send-sthMailMessage -ProfileName $ProfileName -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterEmptyMessage
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

                It "Send-sthMailMessage -Message `$null" {
                    Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Message $null -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterEmptyMessage
                }

                It "Send-sthMailMessage using pipeline - `$null" {
                    $null | Send-sthMailMessage -ProfileFilePath $ProfileFilePath -Attachments $theAttachment
                    Assert-MockCalled -CommandName "Send-MailMessage" -ModuleName sthMailProfile -Scope It -Times 1 -Exactly -ParameterFilter $ParameterFilterEmptyMessage
                }

                RemoveProfile -ProfileFilePath $ProfileFilePath
            }
        }

        Context "Multiple profiles" {

            $ContextSettings = DuplicateOrderedDictionary $Settings
            $ContextSettings.Remove('UserName')
            $ContextSettings.Remove('Password')
            $TestCases = ComposeTestCases 'Password','Credential' 'Secured'
            $TestCases2 = ComposeTestCases 'Password','Credential' 'Secured' | Where-Object {$_.Name -ne 'ProfileName'}
            $TestCases2 += @{Name = 'ProfileName'; Value = "${ProfileName}2"}

            Context "ProfileName" {

                New-sthMailProfile -ProfileName $ProfileName @ContextSettings
                New-sthMailProfile -ProfileName "${ProfileName}2" @ContextSettings

                Context "Wildcards" {

                    $Profiles = Get-sthMailProfile -ProfileName "${ProfileName}*"

                    It "Should create two profiles" {
                        $Profiles | Should -HaveCount 2
                    }

                    $MailProfile = $Profiles[0]
                    It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {

                        Param ($Name, $Value)
                        TestMailProfileContent -Name $Name -Value $Value
                    }

                    $MailProfile = $Profiles[1]
                    It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases2 {

                        Param ($Name, $Value)
                        TestMailProfileContent -Name $Name -Value $Value
                    }
                }

                Context "Array" {

                    $Profiles = Get-sthMailProfile -ProfileName $ProfileName, "${ProfileName}2"

                    It "Should create two profiles" {
                        $Profiles | Should -HaveCount 2
                    }

                    $MailProfile = $Profiles[0]
                    It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {

                        Param ($Name, $Value)
                        TestMailProfileContent -Name $Name -Value $Value
                    }

                    $MailProfile = $Profiles[1]
                    It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases2 {

                        Param ($Name, $Value)
                        TestMailProfileContent -Name $Name -Value $Value
                    }
                }

                It "Should return value matches multiple profiles." {
                    { Send-sthMailMessage -ProfileName "${ProfileName}*" -ErrorAction Stop } | Should -Throw -ExceptionType 'System.ArgumentException'
                }

                Remove-sthMailProfile -ProfileName "${ProfileName}*"

                It "Should remove the profiles" {
                    Get-sthMailProfile | Should -BeNullOrEmpty
                }
            }

            Context "ProfileFilePath" {

                $ProfileFilePath2 = 'TestDrive:\_Profile2.xml'
                $ProfileFilePathWildcard = 'TestDrive:\_Profile*.xml'
                New-sthMailProfile -ProfileFilePath $ProfileFilePath @ContextSettings
                New-sthMailProfile -ProfileFilePath $ProfileFilePath2 @ContextSettings

                Context "Wildcards" {

                    $Profiles = Get-sthMailProfile -ProfileFilePath $ProfileFilePathWildcard

                    It "Should create two profiles" {
                        $Profiles | Should -HaveCount 2
                    }

                    $MailProfile = $Profiles[0]
                    It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {

                        Param ($Name, $Value)
                        TestMailProfileContent -Name $Name -Value $Value
                    }

                    $MailProfile = $Profiles[1]
                    It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases2 {

                        Param ($Name, $Value)
                        TestMailProfileContent -Name $Name -Value $Value
                    }
                }

                Context "Array" {

                    $Profiles = Get-sthMailProfile -ProfileFilePath $ProfileFilePath, $ProfileFilePath2

                    It "Should create two profiles" {
                        $Profiles | Should -HaveCount 2
                    }

                    $MailProfile = $Profiles[0]
                    It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {

                        Param ($Name, $Value)
                        TestMailProfileContent -Name $Name -Value $Value
                    }

                    $MailProfile = $Profiles[1]
                    It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases2 {

                        Param ($Name, $Value)
                        TestMailProfileContent -Name $Name -Value $Value
                    }
                }

                It "Should return value matches multiple profiles." {
                    { Send-sthMailMessage -ProfileFilePath $ProfileFilePathWildcard -ErrorAction Stop } | Should -Throw -ExceptionType 'System.ArgumentException'
                }

                Remove-sthMailProfile -ProfileFilePath $ProfileFilePathWildcard

                It "Should remove the profiles" {
                    Get-sthMailProfile | Should -BeNullOrEmpty
                }
            }
        }
    }
}
