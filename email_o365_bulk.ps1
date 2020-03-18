# Function to create email
function SendNotification{

Send-MailMessage `
    -From $FromAddress `
    -To $User.Email `
    -Subject "Microsoft Teams Access" `
    -Body $EmailBody `
    -BodyAsHTML `
    -SmtpServer $SMTPServer `
    -Port $SMTPPort `
    -Encoding UTF8
}

# Define variables for SMTP 
$SMTPServer = ""
$SMTPPort = ""
$FromAddress = "" #! Insert SMTP address to be used to send the mail messages

# Import user list from .CSV file
#! CSV must contain the following columns: Email, DisplayName, Password
$Users = Import-Csv -Path "C:\TEMP\bulk_password_output.csv"

# Send email to each user in the list with customized message body
Foreach ($User in $Users) {
$ToAddress = $User.Email
$Name     = $User.DisplayName
$Password = $User.Password
$EmailBody = @"
<DOCTYPE html>
<head>
<meta charset="utf-8"/>

<p>*** La version fran&ccedil;aise suit ***</p>
<p>Hello,</p>
<p>
  <br>
</p>
<p>An account for <b>$Name</b> has been created in Microsoft Office 365 as requested.</p>
<p>Please find your username and temporary password below:</p>
<p>
  <br>
</p>
<p><b>Username: $ToAddress</b></p>
<p><b>Password: $Password</b></p>
<p>
  <br>
</p>
<p>When you first log in, you will also be prompted to set up your self-service password recovery questions.</p>
<p>
  <br>
</p>
<p>Access to Microsoft Office 365: https://www.office.com/?auth=2</p>
<p>
  <br>
</p>
<p>*** The English version precedes ***</p>
<p>
  <br>
</p>
<p>Bonjour,</p>
<p>
  <br>
</p>
<p>Un compte pour $Name a &eacute;t&eacute; cr&eacute;&eacute; dans Microsoft Office 365 comme demand&eacute;.</p>
<p>Veuillez trouver votre nom d'utilisateur et votre mot de passe temporaire ci-dessous:</p>
<p>
  <br>
</p>
<p>Nom d'utilisateur: $ToAddress</p>
<p>Mot de passe: $Password</p>
</head>
"@
Write-Host "Sending notification to $ToAddress" -ForegroundColor Yellow
Write-Output "Email sent to $ToAddress" >> C:\TEMP\bulk-status.txt
SendNotification
}
