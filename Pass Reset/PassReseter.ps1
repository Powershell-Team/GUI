<#  Powershell tool to reset password for the simple user  #>

# Run as Admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Assemblies required
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Import ActiveDirectory
if(Get-Module -ListAvailable ActiveDirectory){
    Write-Host "Module Exist"
} else {
    Import-Module ActiveDirectory
}

$Font = [System.Drawing.Font]::new('Segoe UI', 14)
$FontBold = [System.Drawing.Font]::new('Segoe UI', 14, [System.Drawing.FontStyle]::Bold)

<#  Main Window  #>

$PwdReset                             = New-Object system.Windows.Forms.Form
$PwdReset.ClientSize                  = '300,260'
$PwdReset.Text                        = "User Password Reset"
$PwdReset.FormBorderStyle             = 'Fixed3D'
$PwdReset.MaximizeBox                 = $false
                                      
$UserName                             = New-Object system.Windows.Forms.TextBox
$UserName.multiline                   = $false
$UserName.text                        = "שם משתמש"
$UserName.width                       = 170
$UserName.height                      = 35
$UserName.location                    = New-Object System.Drawing.Point(20,23)
$UserName.Font                        = $Font
$UserName.Enabled                     = $false
                                      
$Browse                               = New-Object system.Windows.Forms.Button
$Browse.text                          = "בחר"
$Browse.width                         = 60
$Browse.height                        = 35
$Browse.location                      = New-Object System.Drawing.Point(215,20)
$Browse.Font                          = $Font
                                      
$ResetAfter                           = New-Object system.Windows.Forms.CheckBox
$ResetAfter.text                      = "אפס לאחר התחברות"
$ResetAfter.AutoSize                  = $false
$ResetAfter.width                     = 220
$ResetAfter.height                    = 25
$ResetAfter.location                  = New-Object System.Drawing.Point(20,120)
$ResetAfter.Font                      = $Font
                                      
$Reset                                = New-Object system.Windows.Forms.Button
$Reset.BackColor                      = "#7ed321"
$Reset.ForeColor                      = "#ffffff"
$Reset.text                           = "אפס"
$Reset.width                          = 80
$Reset.height                         = 50
$Reset.location                       = New-Object System.Drawing.Point(115,170)
$Reset.Font                           = $FontBold
                                      
$NewPass                              = New-Object system.Windows.Forms.TextBox
$NewPass.multiline                    = $false
$NewPass.text                         = "הכנס סיסמה חדשה"
$NewPass.ForeColor                    = '#5B5B5B'
$NewPass.width                        = 170
$NewPass.height                       = 35
$NewPass.location                     = New-Object System.Drawing.Point(20,75)
$NewPass.Font                         = $Font

$PwdReset.controls.AddRange(@($UserName,$Browse,$ResetAfter,$Reset,$NewPass))

<#  Users Window  #>

$Users                                = New-Object system.Windows.Forms.Form
$Users.ClientSize                     = '200,300'
$Users.FormBorderStyle                = 'Fixed3D'
$Users.MaximizeBox                    = $false
                                      
$DomainUsers                          = New-Object system.Windows.Forms.ListView
$DomainUsers.width                    = 180
$DomainUsers.height                   = 245
$DomainUsers.location                 = New-Object System.Drawing.Point(10,10)
$DomainUsers.View                     = 'List'
$DomainUsers.Font                     = $Font

$Select                               = New-Object system.Windows.Forms.Button
$Select.text                          = "Select"
$Select.width                         = 65
$Select.height                        = 25
$Select.location                      = New-Object System.Drawing.Point(70,265)
$Select.Font                          = $Font

$Users.controls.AddRange(@($DomainUsers,$Select))

# Local Users
#$dmnUsers = Get-LocalUser | ? Enabled -eq $true | sort Name
# Domain Users
$dmnUsers = Get-ADUser -Filter * | ? Enabled -eq $true | sort Name
foreach($user in $dmnUsers){
    $listItem = New-Object System.Windows.Forms.ListViewItem("$($user.Name)")
    $DomainUsers.Items.Add($listItem)
}

$Browse.Add_Click({
    $Users.ShowDialog()
})

$NewPass.Add_GotFocus({
    if($NewPass.Text -eq "הכנס סיסמה חדשה"){
        $NewPass.Text = ""
        $NewPass.ForeColor = '#000000'
    }
})

$NewPass.Add_LostFocus({
    if($NewPass.Text -eq ""){
        $NewPass.Text = "הכנס סיסמה חדשה"
        $NewPass.ForeColor = '#5B5B5B'
    }
})

$Select.Add_Click({
    $UserName.Text = $DomainUsers.SelectedItems[0].Text
    $Users.Close()
})

$Reset.Add_Click({
    $userToReset = $UserName.Text
    $pass = ConvertTo-SecureString -AsPlainText –String $NewPass.Text -force

    Try{
        # Set password for Local User
        # Set-LocalUser -Name $userToReset -Password $pass
        
        # Set password for Domain User
        Set-ADAccountPassword -Identity $userToReset -Reset -NewPassword $pass
        Set-ADUser -Identity $userToReset -ChangePasswordAtLogon $ResetAfter.Checked -PasswordNeverExpires $false
        [System.Windows.MessageBox]::Show('סיסמה אופסה!')
    } Catch {
        $ErrorMessage = $_.Exception.Message
        if($ErrorMessage -Like "*The password does not meet*"){
            [System.Windows.MessageBox]::Show("הסיסמה לא עומדת בדרישות המינימום")
        } if($ErrorMessage -Like "*Cannot find an object*") {
            [System.Windows.MessageBox]::Show("לא נבחר משתמש")
        } else {
            [System.Windows.MessageBox]::Show("$($ErrorMessage)")
        }
    } Finally {
        if($ErrorMessage -eq ""){
            [System.Windows.MessageBox]::Show("סיסמה אופסה !")
        }
    }
})

$PwdReset.ShowDialog()