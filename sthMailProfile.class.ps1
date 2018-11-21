enum PasswordIs
{
    Secured
    PlainText
    NotExist
}

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword","")]
class sthMailProfile
{
    [string]$From
    [string[]]$To
    [System.Management.Automation.PSCredential]$Credential
    [PasswordIs]$PasswordIs
    [string]$SmtpServer
    [string]$Subject
    [int]$Port
    [switch]$UseSSL
    [System.Text.Encoding]$Encoding
    [switch]$BodyAsHtml
    [string[]]$CC
    [string[]]$BCC
    [string[]]$DeliveryNotificationOption
    [string]$Priority

    sthMailProfile([string]$From, [string[]]$To, [string]$SmtpServer)
    {
        $this.From = $From
        $this.To = $To
        $this.SmtpServer = $SmtpServer
        $this.PasswordIs = [PasswordIs]'NotExist'
    }

    sthMailProfile([string]$From, [string[]]$To, [PSCredential]$Credential, [string]$SmtpServer)
    {
        $this.From = $From
        $this.To = $To
        $this.Credential = $Credential
        $this.SmtpServer = $SmtpServer
        $this.PasswordIs = [PasswordIs]'Secured'
    }

    sthMailProfile([string]$From,[string[]]$To,[PSCredential]$Credential,[PasswordIs]$PasswordIs,[string]$SmtpServer,[string]$Subject,[int]$Port,[switch]$UseSSL,[System.Text.Encoding]$Encoding,[switch]$BodyAsHtml,[string[]]$CC,[string[]]$BCC,[string[]]$DeliveryNotificationOption,[string]$Priority)
    {
        $this.From = $From
        $this.To = $To
        $this.Credential = $Credential
        $this.PasswordIs = $PasswordIs
        $this.SmtpServer = $SmtpServer
        $this.Subject = $Subject
        $this.Port = $Port
        $this.UseSSL = $UseSSL
        $this.Encoding = $Encoding
        $this.BodyAsHtml = $BodyAsHtml
        $this.CC = $CC
        $this.BCC = $BCC
        $this.DeliveryNotificationOption = $DeliveryNotificationOption
        $this.Priority = $Priority
    }
}
