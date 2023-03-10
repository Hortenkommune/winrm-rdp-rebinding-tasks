function Configure-WinRMHttpsListener
{
    param
    (
        [string] $TemplateName = "Intern-ServerCert"
    )

    # Get certificate thumbprint based on templatename.
    $TemplatecertThumbprint = Get-ChildItem 'Cert:\LocalMachine\My' | Where-Object {
        $_.Extensions | Where-Object {
            ($_.Oid.FriendlyName -eq 'Certificate Template Information') -and ($_.Format(0) -match $TemplateName)
        }
    } | Select-Object -ExpandProperty Thumbprint

    # Get existing winrm thumbprint
    $ExistingWinRMCertThumbprint = Get-WSManInstance winrm/config/Listener -SelectorSet @{Address='*';Transport="HTTPS"} | Select-Object -ExpandProperty CertificateThumbprint

    if ($TemplatecertThumbprint -eq $ExistingWinRMCertThumbprint) {
        return
    }

    # Delete existing HTTPS listener if it exists
    Remove-WSManInstance -ResourceURI winrm/config/Listener -SelectorSet @{Address='*';Transport="HTTPS"} -ErrorAction SilentlyContinue


    # Get fully qualified hostname
    $hostname = [System.Net.Dns]::GetHostByName($env:computerName).HostName

    # Configure WinRM
    New-WSManInstance -ResourceURI winrm/config/Listener -SelectorSet @{Address='*';Transport="HTTPS"} -ValueSet @{Hostname=$hostname;CertificateThumbprint=$TemplatecertThumbprint} -ErrorAction SilentlyContinue
    Set-WSManInstance -ResourceURI winrm/config -ValueSet @{MaxEnvelopeSizekb="8192"}
    Set-WSManInstance -ResourceURI winrm/config/service/auth -ValueSet @{Basic="false";CbtHardeningLevel="Strict"} -ErrorAction SilentlyContinue
}

Configure-WinRMHttpsListener
