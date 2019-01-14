<# 
This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Permissions Report
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '460,260'
$Form.text                       = "Permissions Report"
$Form.TopMost                    = $true
$Form.FormBorderStyle            = 'Fixed3D'
$Form.MaximizeBox                = $false

$DirectoryLocation               = New-Object system.Windows.Forms.TextBox
$DirectoryLocation.multiline     = $false
$DirectoryLocation.width         = 300
$DirectoryLocation.height        = 20
$DirectoryLocation.location      = New-Object System.Drawing.Point(25,25)
$DirectoryLocation.Font          = 'Segoe UI,15'

$DirecoryBrowse                  = New-Object system.Windows.Forms.Button
$DirecoryBrowse.text             = "Browse"
$DirecoryBrowse.width            = 100
$DirecoryBrowse.height           = 35
$DirecoryBrowse.location         = New-Object System.Drawing.Point(345,25)
$DirecoryBrowse.Font             = 'Segoe UI,15'

$ReportBrowse                    = New-Object system.Windows.Forms.Button
$ReportBrowse.text               = "Browse"
$ReportBrowse.width              = 100
$ReportBrowse.height             = 35
$ReportBrowse.location           = New-Object System.Drawing.Point(345,95)
$ReportBrowse.Font               = 'Segoe UI,15'

$ReportLocation                  = New-Object system.Windows.Forms.TextBox
$ReportLocation.multiline        = $false
$ReportLocation.width            = 300
$ReportLocation.height           = 20
$ReportLocation.location         = New-Object System.Drawing.Point(25,95)
$ReportLocation.Font             = 'Segoe UI,15'

$MakeReport                      = New-Object system.Windows.Forms.Button
$MakeReport.BackColor            = "#33d534"
$MakeReport.text                 = "Make Report"
$MakeReport.width                = 180
$MakeReport.height               = 50
$MakeReport.location             = New-Object System.Drawing.Point(140,175)
$MakeReport.Font                 = 'Segoe UI,20'

$Browser                         = New-Object System.Windows.Forms.FolderBrowserDialog
$Browser.Description             = "Select a folder"
$Browser.rootfolder              = "MyComputer"

$Form.controls.AddRange(@($DirectoryLocation,$DirecoryBrowse,$ReportBrowse,$ReportLocation,$MakeReport))

$ReportLocation.Text = "C:\users\$($env:username)\Desktop\Permissions.csv"

$DirecoryBrowse.Add_Click({
    if($Browser.ShowDialog() -eq "OK")
    {
        $DirectoryLocation.Text = $Browser.SelectedPath
    }
})

$ReportBrowse.Add_Click({
    if($Browser.ShowDialog() -eq "OK")
    {
        $ReportLocation.Text = $Browser.SelectedPath
        $lastChar = $ReportLocation.Text.Length - 1

        if($ReportLocation.Text[$lastChar] -ne "\") {
            $ReportLocation.Text += "\permissions.csv"
        }else{
            $ReportLocation.Text += "permissions.csv"
        }
    }
})

$MakeReport.Add_Click({
    if($DirectoryLocation.Text -eq ""){
        [System.Windows.MessageBox]::Show("Enter directory location")
    } elseif ($ReportLocation.Text -eq "") {
        [System.Windows.MessageBox]::Show("Enter report location")
    } else {
        #Get all folders in the directory
        $Folders = Get-ChildItem -force $DirectoryLocation.Text -Directory | get-acl
        #Filter properties
        $Folders = $Folders | %{$_| Add-Member -NotePropertyName Folder -NotePropertyValue (Convert-Path $_.path) -PassThru } | select -ExpandProperty access -property Folder, owner
        
        #Generate Report
        $Folders | export-csv $ReportLocation.Text -Encoding UTF8 -NoTypeInformation

        [System.Windows.MessageBox]::Show("Report is ready !")
    }
})


$Form.ShowDialog()


