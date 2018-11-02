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
        Param (
            [ValidateSet('Secured','PlainText','NotExist')]
            $PasswordIs
        )
        Context "Get-sthMailProfile" {
                
            BeforeAll {
                $MailProfile = Get-sthMailProfile -ProfileName $ProfileName
                # $TestCases = ComposeTestCases $TestCasesTemplate 'Password','Credential' 'Secured'
                $TestCases = ComposeTestCases $TestCasesTemplate 'Password','Credential' $PasswordIs
            }
            
            It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {
                
                Param ($Name, $Value)
                TestMailProfileContent -Name $Name -Value $Value
            }
        }
        
        Context "Get-sthMailProfile -ShowPassword" {
            
            BeforeAll {
                $MailProfile = Get-sthMailProfile -ProfileName $ProfileName -ShowPassword
                # $TestCases = ComposeTestCases $TestCasesTemplate 'Credential' 'Secured'
                $TestCases = ComposeTestCases $TestCasesTemplate 'Credential' $PasswordIs
            }

            It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {
    
                Param ($Name, $Value)
                TestMailProfileContent -Name $Name -Value $Value
            }
        }
    }

    function RemoveProfile
    {
        Param (
            $ProfileName
        )

        Remove-sthMailProfile -ProfileName $ProfileName

        It "Should remove the profile" {
            Get-sthMailProfile | Should -BeNullOrEmpty
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
                $MailProfile = Get-sthMailProfile -ProfileName $ProfileName

                $TestCases = ComposeTestCases $TestCasesTemplate 'UserName','Password','Credential' 'NotExist'

                It "Should create the profile" {
                    $MailProfile | Should -Not -BeNullOrEmpty
                }
            }

            AfterAll { RemoveProfile -ProfileName $ProfileName }

            It "Should contain property '<Name>' with value '<Value>'" -TestCases $TestCases {

                Param ($Name, $Value)
                TestMailProfileContent -Name $Name -Value $Value
            }
        }

        Context "Profile with -UserName and -Password parameters" {

            Context "New-sthMailProfile" {
                BeforeAll {
                    $ContextSettings = DuplicateOrderedDictionary $Settings
                    $ContextSettings.Remove('Credential')
                    New-sthMailProfile -ProfileName $ProfileName @ContextSettings
    
                    It "Should create the profile" {
                        Get-sthMailProfile -ProfileName $ProfileName | Should -Not -BeNullOrEmpty
                    }
                }
                
                AfterAll { RemoveProfile -ProfileName $ProfileName }
                
                TestMailProfile 'Secured'
            }

            Context "New-sthMailProfile -StorePasswordInPlainText" {
                BeforeAll {
                    $ContextSettings = DuplicateOrderedDictionary $Settings
                    $ContextSettings.Remove('Credential')
                    New-sthMailProfile -ProfileName $ProfileName @ContextSettings -StorePasswordInPlainText
    
                    It "Should create the profile" {
                        Get-sthMailProfile -ProfileName $ProfileName | Should -Not -BeNullOrEmpty
                    }
                }
                
                AfterAll { RemoveProfile -ProfileName $ProfileName }

                TestMailProfile 'PlainText'
            }

        }

        Context "Profile with -UserName and -Password parameters with empty string password" {

            Context "New-sthMailProfile" {

                # BeforeAll executes in upper scope and not in context one, but we need this to execute in the context scope.
                $Settings = DuplicateOrderedDictionary $Settings
                $Settings.Password = ''
                $ContextSettings = DuplicateOrderedDictionary $Settings

                $TestCasesTemplate = @($Settings.GetEnumerator() | ForEach-Object {@{Name = $_.Name; Value = $_.Value}})

                $ContextSettings.Remove('Credential')
                New-sthMailProfile -ProfileName $ProfileName @ContextSettings

                It "Should create the profile" {
                    Get-sthMailProfile -ProfileName $ProfileName | Should -Not -BeNullOrEmpty
                }
                
                AfterAll { RemoveProfile -ProfileName $ProfileName }

                TestMailProfile 'Secured'
            }

            Context "New-sthMailProfile -StorePasswordInPlainText" {

                # BeforeAll executes in upper scope and not in context one, but we need this to execute in the context scope.
                $Settings = DuplicateOrderedDictionary $Settings
                $Settings.Password = ''
                $ContextSettings = DuplicateOrderedDictionary $Settings

                $TestCasesTemplate = @($Settings.GetEnumerator() | ForEach-Object {@{Name = $_.Name; Value = $_.Value}})

                $ContextSettings.Remove('Credential')
                New-sthMailProfile -ProfileName $ProfileName @ContextSettings -StorePasswordInPlainText

                It "Should create the profile" {
                    Get-sthMailProfile -ProfileName $ProfileName | Should -Not -BeNullOrEmpty
                }
                
                AfterAll { RemoveProfile -ProfileName $ProfileName }

                TestMailProfile 'PlainText'
            }
        }

        Context "Profile with -UserName parameter and -Password parameter value from Read-Host" {

            Context "New-sthMailProfile" {

                BeforeAll {
                    Mock "Read-Host" $([scriptblock]::Create("ConvertTo-SecureString -String $($Settings.Password) -AsPlainText -Force")) -ModuleName sthMailProfile

                    $ContextSettings = DuplicateOrderedDictionary $Settings
                    $ContextSettings.Remove('Credential')
                    $ContextSettings.Remove('Password')
                    New-sthMailProfile -ProfileName $ProfileName @ContextSettings

                    It "Should create the profile" {
                        Get-sthMailProfile -ProfileName $ProfileName | Should -Not -BeNullOrEmpty
                    }
                }
                
                AfterAll { RemoveProfile -ProfileName $ProfileName }

                TestMailProfile 'Secured'
            }

            Context "New-sthMailProfile -StorePasswordInPlainText" {

                BeforeAll {
                    Mock "Read-Host" $([scriptblock]::Create("ConvertTo-SecureString -String $($Settings.Password) -AsPlainText -Force")) -ModuleName sthMailProfile

                    $ContextSettings = DuplicateOrderedDictionary $Settings
                    $ContextSettings.Remove('Credential')
                    $ContextSettings.Remove('Password')
                    New-sthMailProfile -ProfileName $ProfileName @ContextSettings -StorePasswordInPlainText

                    It "Should create the profile" {
                        Get-sthMailProfile -ProfileName $ProfileName | Should -Not -BeNullOrEmpty
                    }
                }
                
                AfterAll { RemoveProfile -ProfileName $ProfileName }

                TestMailProfile 'PlainText'
            }
        }


        Context "Profile with -Credentialparameter" {

            Context "New-sthMailProfile" {
                BeforeAll {
                    $ContextSettings = DuplicateOrderedDictionary $Settings
                    $ContextSettings.Remove('UserName')
                    $ContextSettings.Remove('Password')
                    New-sthMailProfile -ProfileName $ProfileName @ContextSettings

                    It "Should create the profile" {
                        Get-sthMailProfile -ProfileName $ProfileName | Should -Not -BeNullOrEmpty
                    }
                }

                AfterAll { RemoveProfile -ProfileName $ProfileName }

                TestMailProfile 'Secured'
            }

            Context "New-sthMailProfile -StorePasswordInPlainText" {
                BeforeAll {
                    $ContextSettings = DuplicateOrderedDictionary $Settings
                    $ContextSettings.Remove('UserName')
                    $ContextSettings.Remove('Password')
                    New-sthMailProfile -ProfileName $ProfileName @ContextSettings -StorePasswordInPlainText

                    It "Should create the profile" {
                        Get-sthMailProfile -ProfileName $ProfileName | Should -Not -BeNullOrEmpty
                    }
                }

                AfterAll { RemoveProfile -ProfileName $ProfileName }

                TestMailProfile 'PlainText'
            }
        }
    }
}