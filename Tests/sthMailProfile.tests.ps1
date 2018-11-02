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
            Encoding = 'unicode'
            BodyAsHtml = $true
            CC = 'cc@domain.com','cc2@domain.com'
            BCC = 'bcc@domain.com','bcc2@domain.com'
            DeliveryNotificationOption = 'OnSuccess','OnFailure','Delay'
            Priority = 'Normal'
        }

        $TestCasesTemplate = @($Settings.GetEnumerator() | ForEach-Object {@{Name = $_.Name; Value = $_.Value}})

        $ProfileName = '_Profile'
        $ProfileFilePath = 'TestDrive:\_Profile.xml'

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

    function TestMailProfileContent
    {
        Param ($Name, $Value)

        switch ($Value.GetType().FullName)
        {
            'System.String'
            {
                $MailProfile.$Name | Should -BeExactly $Value
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

    # remove
    # function TestMailProfileContent_v1
    # {
    #     Param ($Name, $Value)

    #     foreach ($Setting in $ContextSettings.Keys)
    #     {
    #         switch ($ContextSettings.$Setting.GetType().FullName)
    #         {
    #             'System.String'
    #             {
    #                 $MailProfile.$Setting | Should -BeExactly $ContextSettings.$Setting
    #             }
    #             'System.Object[]'
    #             {
    #                 $MailProfile.$Setting.Count | Should -BeExactly $ContextSettings.$Setting.Count
    #                 for ($i = 0; $i -lt $ContextSettings.$Setting.Count; $i++)
    #                 {
    #                     $MailProfile.$Setting[$i] | Should -BeExactly $ContextSettings.$Setting[$i]
    #                 }
    #             }
    #             'System.Boolean'
    #             {
    #                 $MailProfile.$Setting.IsPresent | Should -BeExactly $ContextSettings.$Setting
    #             }
    #         }
    #     }
    # }

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
        Param (
            [array]$TestCasesTemplate,
            [string[]]$Remove,
            [hashtable[]]$Add
        )

        $TestCases = $TestCasesTemplate | Where-Object {$_.Name -notin $Remove}
        
        foreach ($a in $Add)
        {
            $TestCases += $a
        }

        return $TestCases
    }

    Context "New-sthMailProfile" {

        Context "Profile without credential" {
            BeforeAll {
                $ContextSettings = DuplicateOrderedDictionary $Settings
                $ContextSettings.Remove('UserName')
                $ContextSettings.Remove('Password')
                $ContextSettings.Remove('Credential')
                New-sthMailProfile -ProfileName $ProfileName @ContextSettings
                $MailProfile = Get-sthMailProfile -ProfileName $ProfileName
                # $TestCases = @($ContextSettings.GetEnumerator() | ForEach-Object {@{Name = $_.Name; Value = $_.Value}}) + @{Name = 'PasswordIs'; Value = 'NotExist'}
                # $TestCases = DuplicateOrderedDictionary $TestCasesTemplate
                # $TestCases.Remove('UserName')
                # $TestCases.Remove('Password')

                $TestCases = ComposeTestCases $TestCasesTemplate 'UserName','Password','Credential' @{Name = 'PasswordIs'; Value = 'NotExist'}
                
                It "Should create the profile" {
                    $MailProfile | Should -Not -BeNullOrEmpty
                }
            }

            AfterAll {
                Remove-sthMailProfile -ProfileName $ProfileName

                It "Should remove the profile" {
                    Get-sthMailProfile | Should -BeNullOrEmpty
                }
            }

            It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {

                Param ($Name, $Value)
                TestMailProfileContent -Name $Name -Value $Value
            }
        }

        Context "Profile with -UserName and -Password parameters" {

            BeforeAll {
                $ContextSettings = DuplicateOrderedDictionary $Settings
                $ContextSettings.Remove('Credential')
                New-sthMailProfile -ProfileName $ProfileName @ContextSettings
                $MailProfile = Get-sthMailProfile -ProfileName $ProfileName
                
                # $TestCases = @($ContextSettings.GetEnumerator() | Where-Object {$_.Name -ne 'Password'} | ForEach-Object {@{Name = $_.Name; Value = $_.Value}}) + @{Name = 'PasswordIs'; Value = 'Secured'}

                $TestCases = ComposeTestCases $TestCasesTemplate 'Password','Credential' @{Name = 'PasswordIs'; Value = 'Secured'}

                It "Should create the profile" {
                    $MailProfile | Should -Not -BeNullOrEmpty
                }
            }

            AfterAll {
                Remove-sthMailProfile -ProfileName $ProfileName

                It "Should remove the profile" {
                    Get-sthMailProfile | Should -BeNullOrEmpty
                }
            }

            It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {

                Param ($Name, $Value)
                TestMailProfileContent -Name $Name -Value $Value
            }
        }

        Context "Profile with -UserName, -Password, and -ShowPassword parameters" {

            BeforeAll {
                $ContextSettings = DuplicateOrderedDictionary $Settings
                $ContextSettings.Remove('Credential')
                New-sthMailProfile -ProfileName $ProfileName @ContextSettings
                $MailProfile = Get-sthMailProfile -ProfileName $ProfileName -ShowPassword
                
                # $TestCases = @($ContextSettings.GetEnumerator() | ForEach-Object {@{Name = $_.Name; Value = $_.Value}}) + @{Name = 'PasswordIs'; Value = 'Secured'}
                $TestCases = ComposeTestCases $TestCasesTemplate 'Credential' @{Name = 'PasswordIs'; Value = 'Secured'}

                It "Should create the profile" {
                    $MailProfile | Should -Not -BeNullOrEmpty
                }
            }

            AfterAll {
                Remove-sthMailProfile -ProfileName $ProfileName

                It "Should remove the profile" {
                    Get-sthMailProfile | Should -BeNullOrEmpty
                }
            }

            It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {

                Param ($Name, $Value)
                TestMailProfileContent -Name $Name -Value $Value
            }
        }

        Context "Profile with -Credentialparameter" {

            BeforeAll {
                $ContextSettings = DuplicateOrderedDictionary $Settings
                $ContextSettings.Remove('UserName')
                $ContextSettings.Remove('Password')
                New-sthMailProfile -ProfileName $ProfileName @ContextSettings
                $MailProfile = Get-sthMailProfile -ProfileName $ProfileName

                # $TestCases = @($ContextSettings.GetEnumerator() | Where-Object {$_.Name -ne 'Credential'} | ForEach-Object {@{Name = $_.Name; Value = $_.Value}}) + @{Name = 'UserName'; Value = 'TheUser'} + @{Name = 'PasswordIs'; Value = 'Secured'}
                $TestCases = ComposeTestCases $TestCasesTemplate 'Password','Credential' @{Name = 'PasswordIs'; Value = 'Secured'}

                It "Should create the profile" {
                    $MailProfile | Should -Not -BeNullOrEmpty
                }
            }

            AfterAll {
                Remove-sthMailProfile -ProfileName $ProfileName

                It "Should remove the profile" {
                    Get-sthMailProfile | Should -BeNullOrEmpty
                }
            }

            It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {

                Param ($Name, $Value)
                TestMailProfileContent -Name $Name -Value $Value
            }
        }
    }
}