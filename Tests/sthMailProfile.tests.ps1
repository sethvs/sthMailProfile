Remove-Module -Name sthMailProfile -Force -ErrorAction 'SilentlyContinue'
Import-Module "$PSScriptRoot\..\sthMailProfile.psd1"

Describe "sthMailProfile" {
     BeforeAll {
         $Settings = [ordered]@{
            From = 'from@domain.com'
            To = 'to@domain.com','to2@domain.com'
            UserName = 'TheUser'
            Password = 'ThePassword'
            Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'TheUser2', $(ConvertTo-SecureString -String 'ThePassword2' -AsPlainText -Force)
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

        foreach ($Setting in $ContextSettings.Keys)
        {
            switch ($ContextSettings.$Setting.GetType().FullName)
            {
                'System.String'
                {
                    $MailProfile.$Setting | Should -BeExactly $ContextSettings.$Setting
                }
                'System.Object[]'
                {
                    $MailProfile.$Setting.Count | Should -BeExactly $ContextSettings.$Setting.Count
                    for ($i = 0; $i -lt $ContextSettings.$Setting.Count; $i++)
                    {
                        $MailProfile.$Setting[$i] | Should -BeExactly $ContextSettings.$Setting[$i]
                    }
                }
                'System.Boolean'
                {
                    $MailProfile.$Setting.IsPresent | Should -BeExactly $ContextSettings.$Setting
                }
            }
        }
    }

    Context "New-sthMailProfile" {

        Context "Profile without credential" {
            BeforeAll {
                $ContextSettings = $Settings
                $ContextSettings.Remove('UserName')
                $ContextSettings.Remove('Password')
                $ContextSettings.Remove('Credential')
                New-sthMailProfile -ProfileName $ProfileName @ContextSettings
                $MailProfile = Get-sthMailProfile -ProfileName $ProfileName
                $TestCases = @($ContextSettings.GetEnumerator() | ForEach-Object {@{Name = $_.Name; Value = $_.Value}})
                
                It "Should create the profile" {
                    $MailProfile | Should -Not -BeNullOrEmpty
                    # Get-sthMailProfile -ProfileName $ProfileName | Should -Not -BeNullOrEmpty
                }
            }

            AfterAll {
                Remove-sthMailProfile -ProfileName $ProfileName

                It "Should remove the profile" {
                    Get-sthMailProfile | Should -BeNullOrEmpty
                }
            }

            It "Should contain property '<Name>' with value '<Value>'" -TestCases $($TestCases + @{Name = 'PasswordIs'; Value = 'NotExist'}) {
                
                TestMailProfileContent
            }
        }
    }
}