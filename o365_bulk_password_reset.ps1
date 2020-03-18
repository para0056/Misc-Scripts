# Funtion to reset Office365 password
function ResetPassword {
    Set-MsolUserPassword `
    –UserPrincipalName $UserName `
    –NewPassword $Password `
    -ForceChangePassword $True
}

# Import data from CSV file
#! CSV must contain at least the following fields:
#! UserPrincipalName (first.last@cra-arc.gc.ca)
#! Display Name
#! Password

$Users = Import-Csv -Path "C:\TEMP\password_reset.csv"

# Call ResetPassword function for all users
Foreach ($User in $Users) {
    $UserName = $User.UserPrincipalName
    $Password   = $User.Password
    $Name       = $User.DisplayName

    Write-Host "Resetting password for $UserName" -ForegroundColor Yellow
    ResetPassword
    Write-Output "$UserName, $Name, $Password" >> C:\TEMP\bulk_password_output.csv
}
