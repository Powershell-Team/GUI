add-Type -AssemblyName System.Windows.Forms

	$buttonGetUptime_Click={    
        $label2.Text = "Querying..."
        $button4.Enabled = $false
		$Getdata = (Get-WmiObject -Class win32_operatingsystem).ConverttoDateTime((Get-WmiObject -Class win32_Operatingsystem -ComputerName $computername.text).LastBootUpTime)
        if ($Error) {$label2.Text = "Unable to query host."; $Error.Clear()} else {
		$label2.Text = $Getdata        
        }
        $button4.Enabled = $true
	}

$Form = New-Object system.Windows.Forms.Form
$Form.Text = 'Get-Uptime'
$Form.Width = 300
$Form.Height = 200

$Computername = new-object System.Windows.Forms.TextBox
$Computername.Location = new-object System.Drawing.Size(40,30)
$Computername.Size = new-object System.Drawing.Size(100,20)
$Computername.Text = "localhost"
$Form.Controls.Add($Computername)

$button4 = New-Object system.windows.Forms.Button
$button4.add_Click($buttonGetUptime_Click)
$button4.Text = 'Get-Uptime'
$button4.Width = 100
$button4.Height = 30
$button4.location = new-object system.drawing.size(40,60)
$button4.Font = "Microsoft Sans Serif,10"
$button4.AutoEllipsis
$Form.controls.Add($button4)

$label2 = New-Object system.windows.Forms.Label
$label2.AutoSize = $true
$label2.Width = 25
$label2.Height = 10
$label2.location = new-object system.drawing.size(40,100)
$label2.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($label2)

$Form.ShowDialog()
