# Get the current certificate thumbprint for the RDP-tcp terminal.
$class = "Win32_TSGeneralSetting"
$namespace = "root\cimv2\terminalservices"
$filter = "TerminalName='RDP-tcp'"
$currentThumbprint = (Get-WmiObject -class $class -Namespace $namespace -Filter $filter).SSLCertificateSHA1Hash

# Get the certificate thumbprint for the Intern-ServerCert certificate template.
$TemplateName = "Intern-ServerCert"
$TemplatecertThumbprint = Get-ChildItem 'Cert:\LocalMachine\My' | Where-Object {
    $_.Extensions | Where-Object {
        ($_.Oid.FriendlyName -eq 'Certificate Template Information') -and ($_.Format(0) -match $TemplateName)
    }
} | Select-Object -ExpandProperty Thumbprint

# Only run the rest of the script if the template thumbprint is different from the current thumbprint.
if ($TemplatecertThumbprint -ne $currentThumbprint) {
    # Get the path to the RDP-tcp terminal setting.
    $path = (Get-WmiObject -class $class -Namespace $namespace -Filter $filter).__path

    # Set the SSLCertificateSHA1Hash property to the new thumbprint.
    Set-WmiInstance -Path $path -argument @{SSLCertificateSHA1Hash=$TemplatecertThumbprint}
}
