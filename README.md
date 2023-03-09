# winrm-rdp-rebinding-tasks
Scheduled tasks that rebinds winrm and rdp processes to newly refreshed certificates.

To implement, search&replace "Intern-ServerCert" into whatever you Certificate Template Name is. Setting up certificate template and autoenrolling is out of scope for this git.

Scripts do the work, and are triggered by a scheduled task. The task is created through a powershell-scriptlet that adds all nessecary Trigger Variables:

```
New-CertificateNotificationTask -PSScript C:\Scripts\SetWinRMCert.ps1 -Channel System -Type Replace -Name "Reconfigure WinRM certificate when certificate is renewed"
New-CertificateNotificationTask -PSScript C:\Scripts\SetRDPCert.ps1 -Channel System -Type Replace -Name "Reconfigure RDP certificate when certificate is renewed"
```

If you store the files under C:\Scripts, the above two lines of PowerShell will make the Scheduled Task for you, and two jobs should appear under Microsoft -> CertificateServicesClient -> Notification.

