Add-Type -AssemblyName System.Windows.Forms
#Add-Type -AssemblyName System.Text.Encoding
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()


$temp = $env:TEMP

$script:sevenZa = Join-Path $PSScriptRoot "7za.exe"
$script:rcedit  = Join-Path $PSScriptRoot "rcedit.exe"
$7zsd_LZMA2_x64sfx = Join-Path $PSScriptRoot "7zsd_LZMA2_x64.sfx"

$config = @"
;!@Install@!UTF-8!
Title="TTTTTT"
GUIMode="MMMMMM"
RunProgram="hidcon:PPPPPP"
;!@InstallEnd@!
"@

$7zSDsfxBin = [System.IO.File]::ReadAllBytes($7zsd_LZMA2_x64sfx)

function createSFX($repertoireSource,$icone,$commande, $destinationEXE,$visible,$titre = "monProgramme")
{
    $base = Join-Path $($env:TEMP) $(Get-Random).ToString("X2")
    $7z = $base.ToString()+".7z"
    $fx = $base.ToString()+".sfx"
    
    $destinationArchive = $7z
    $destinationSFXbase = $fx
    $destinationConfig  = "$base.conf"

    # Étape 1
    [IO.File]::WriteAllBytes($destinationSFXbase, $7zSDsfxBin)

    #& $script:rcedit $destinationSFXbase --set-icon  (Resolve-Path $icone)
    & $script:rcedit $destinationSFXbase --set-icon  (Resolve-Path $icone) `
        --set-version-string CompanyName $titre `
        --set-version-string ProductName $titre `
        --set-version-string FileDescription "Par CreateurSFX : Le createur de packages Self Extractibles." `
        --set-version-string InternalName $titre `
        --set-version-string OriginalFilename $titre `
        --set-version-string LegalCopyright "SFX: 7-Zip / 7z SFX Modified, GNU LGPL (Igor Pavlov, Oleg N. Scherbakov). Packager CreateurSFX © $((Get-Date).Year) Charles-Antoine Buguet." `
        --set-file-version 1.0.0.0 `
        --set-product-version 1.0.0.0
        #--set-version-string LegalTrademarks $titre `
    if ($LASTEXITCODE -ne 0) { throw "rcedit a échoué (code $LASTEXITCODE)" }

    # Étape 2
    & $script:sevenZa a $destinationArchive $repertoireSource -t7z -mx=9 -r
    if ($LASTEXITCODE -ne 0) { throw "7za a échoué (code $LASTEXITCODE)" }

    # Étape 3 — UTF-8 sans BOM
    $conf = $config.Replace("TTTTTT", $titre).Replace("PPPPPP", $commande)
    if($visible)
    {  
         $conf = $conf.Replace("MMMMMM","1").Replace("hidcon:","")
    }
    else
    {
         $conf = $conf.Replace("MMMMMM","2")
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [IO.File]::WriteAllText($destinationConfig, $conf, $utf8NoBom)

    # Étape 4
    $stub = [IO.File]::ReadAllBytes($destinationSFXbase)
    $configuration = [IO.File]::ReadAllBytes($destinationConfig)
    $dossierCompresse = [IO.File]::ReadAllBytes($destinationArchive)

    $ms = New-Object IO.MemoryStream
    $ms.Write($stub, 0, $stub.Length)
    $ms.Write($configuration, 0, $configuration.Length)
    $ms.Write($dossierCompresse, 0, $dossierCompresse.Length)
    [IO.File]::WriteAllBytes($destinationEXE, $ms.ToArray())
    $ms.Dispose()

    Remove-Item $destinationArchive, $destinationSFXbase, $destinationConfig -Force -ErrorAction SilentlyContinue
}

function faire($cheminSource, $cheminIcone, $commande, $destinationSFX, $visible, $titre)
{
    if ($destinationSFX -notlike "*.exe") {
        $destinationSFX = "$destinationSFX.exe"
    }

    $dossier = Split-Path $destinationSFX -Parent
    if ($dossier -and -not (Test-Path $dossier)) {
        New-Item -ItemType Directory -Path $dossier | Out-Null
    }

    if ((Test-Path $cheminSource) -and (Get-Item $cheminSource).PSIsContainer) {
        $cheminSource = Join-Path $cheminSource "*"
    }

    $titre = [IO.Path]::GetFileNameWithoutExtension($destinationSFX)
    createSFX -repertoireSource $cheminSource -icone $cheminIcone -commande $commande -destinationEXE $destinationSFX -titre $titre -visible $visible
    return $destinationSFX
}

function affichage
{
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "CreateurSFX - Le Createur de Packages Auto-Extractibles au format Executable."
    $form.Size = New-Object System.Drawing.Size(720, 480)
    $form.StartPosition = "CenterScreen"
    $form.Icon = New-Object System.Drawing.Icon("$PSScriptRoot\14773.ico")
    $form.TopMost = $true
    $form.BackColor = [System.Drawing.Color]::DarkBlue
    $form.Font = New-Object System.Drawing.Font("Times New Roman", 10, [System.Drawing.FontStyle]::Regular)
    try
    {
        $form.BackgroundImage = [System.Drawing.Image]::FromFile("$PSScriptRoot\fond.jpg")
        $form.BackgroundImageLayout = "Stretch"
    }
    catch{}
    $form.Opacity = 0.95
    #form.FormBorderStyle = "FixedDialog"


    $transparent = [System.Drawing.Color]::Transparent
    $labelTextBox = New-Object System.Windows.Forms.Label
    $labelTextBox.Text = "Chemin du répertoire source :"
    $labelTextBox.Location = New-Object System.Drawing.Point(20,15)
    $labelTextBox.Size = New-Object System.Drawing.Size(250,20)
    $labelTextBox.Font = New-Object System.Drawing.Font("Times New Roman", 12, [System.Drawing.FontStyle]::Bold)
    $labelTextBox.ForeColor = $transparent
    $labelTextBox.BackColor = [System.Drawing.Color]::FromArgb(70,11,101,227)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(20,47)
    $textBox.Size = New-Object System.Drawing.Size(520,20)
    $textBox.AutoSize = $true
    $textBox.Font = New-Object System.Drawing.Font("Times New Roman", 14, [System.Drawing.FontStyle]::Bold)
    $textBox.AllowDrop = $true

    $labelIcon = New-Object System.Windows.Forms.Label
    $labelIcon.Text = "Fichier icone de l'application (.ico) :"
    $labelIcon.Location = New-Object System.Drawing.Point(20,100)
    $labelIcon.Size = New-Object System.Drawing.Size(260,20)
    $labelIcon.Font = New-Object System.Drawing.Font("Times New Roman", 12, [System.Drawing.FontStyle]::Bold)
    $labelIcon.ForeColor = $transparent
    $labelIcon.BackColor = $transparent # [System.Drawing.Color]::FromArgb(190,74,166,212) #::CadetBlue # ::CornflowerBlue # ::MediumSeaGreen

    $textBoxIcon = New-Object System.Windows.Forms.TextBox
    $textBoxIcon.Location = New-Object System.Drawing.Point(20,135)
    $textBoxIcon.Size = New-Object System.Drawing.Size(520,20)
    $textBoxIcon.AutoSize = $true
    $textBoxIcon.Font = New-Object System.Drawing.Font("Times New Roman", 14, [System.Drawing.FontStyle]::Bold)
    $textBoxIcon.AllowDrop = $true

    $textBox.add_DragEnter({
        $textBox.Text =""
        if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
            $_.Effect = [Windows.Forms.DragDropEffects]::Copy
        }
        elseif ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::Text)) {
            $_.Effect = [Windows.Forms.DragDropEffects]::Copy
        }
    })

    $textBox.add_DragDrop({  
        if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
            $files = $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
            $textBox.Text = $files
        }
        elseif ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::Text)) {
            $text = $_.Data.GetData([Windows.Forms.DataFormats]::Text)
            $textBox.Text = $text
        }
    })

    $textBoxIcon.add_DragEnter({
        $textBoxIcon.Text = ""
        if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
            $_.Effect = [Windows.Forms.DragDropEffects]::Copy
        }
        elseif ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::Text)) {
            $_.Effect = [Windows.Forms.DragDropEffects]::Copy
        }
    })

    $textBoxIcon.add_DragDrop({
        if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {

            $files = $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
            $textBoxIcon.Text = $files
        }
        elseif ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::Text)) {

            $text = $_.Data.GetData([Windows.Forms.DataFormats]::Text)
            $textBoxIcon.Text = $text
        }
    })


    $labelCommande = New-Object System.Windows.Forms.Label
    $labelCommande.Text = "Commande à exécuter après décompression :"
    $labelCommande.Location = New-Object System.Drawing.Point(20,190)
    $labelCommande.Size = New-Object System.Drawing.Size(324,20)
    $labelCommande.Font = New-Object System.Drawing.Font("Times New Roman", 12, [System.Drawing.FontStyle]::Bold)
    $labelCommande.ForeColor = $transparent
    $labelCommande.BackColor = [System.Drawing.Color]::FromArgb(215, 60, 155, 207) # [System.Drawing.Color]::FromArgb(190,0, 145, 255)

    $textBoxCommande = New-Object System.Windows.Forms.TextBox
    $textBoxCommande.Location = New-Object System.Drawing.Point(20,230)
    $textBoxCommande.Size = New-Object System.Drawing.Size(520,20)
    $textBoxCommande.AutoSize = $true
    $textBoxCommande.Font = New-Object System.Drawing.Font("Times New Roman", 14, [System.Drawing.FontStyle]::Bold)
    $textBoxCommande.AllowDrop = $true

    $textBoxCommande.add_DragEnter({
        $textBoxCommande.Text = ""
        if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
            $_.Effect = [Windows.Forms.DragDropEffects]::Copy
        }
        elseif ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::Text)) {
            $_.Effect = [Windows.Forms.DragDropEffects]::Copy
        }
    })

    $textBoxCommande.add_DragDrop({
        if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {

            $files = $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
            $textBoxCommande.Text = $files
        }
        elseif ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::Text)) {

            $text = $_.Data.GetData([Windows.Forms.DataFormats]::Text)
            $textBoxCommande.Text = $text
        }
    })

    $labelCombo = New-Object System.Windows.Forms.Label
    $labelCombo.Text = "Lancement"
    $labelCombo.Location = New-Object System.Drawing.Point(565,100)
    $labelCombo.Size = New-Object System.Drawing.Size(135,20)
    $labelCombo.Font = New-Object System.Drawing.Font("Times New Roman", 12, [System.Drawing.FontStyle]::Bold)
    $labelCombo.ForeColor = $transparent
    $labelCombo.BackColor = $transparent

    $combo = New-Object System.Windows.Forms.ComboBox
    $combo.Items.AddRange(@("Visible","Caché"))
    $combo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $combo.Location = New-Object System.Drawing.Point(565,135)
    $combo.Size = New-Object System.Drawing.Size(120,20)
    $combo.AutoSize = $true
    $combo.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
    $combo.SelectedIndex = 0

    $labelDestination = New-Object System.Windows.Forms.Label
    $labelDestination.Text = "Destination de l'executable :"
    $labelDestination.Location = New-Object System.Drawing.Point(20,280)
    $labelDestination.Size = New-Object System.Drawing.Size(210,20)
    $labelDestination.Font = New-Object System.Drawing.Font("Times New Roman", 12, [System.Drawing.FontStyle]::Bold)
    $labelDestination.ForeColor = $transparent
    $labelDestination.BackColor = [System.Drawing.Color]::FromArgb(200,13,130,212) #::CadetBlue # ::CornflowerBlue # ::MediumSeaGreen

    $textBoxDestination = New-Object System.Windows.Forms.TextBox
    $textBoxDestination.Location = New-Object System.Drawing.Point(20,320)
    $textBoxDestination.Size = New-Object System.Drawing.Size(520,20)
    $textBoxDestination.AutoSize = $true
    $textBoxDestination.Font = New-Object System.Drawing.Font("Times New Roman", 14, [System.Drawing.FontStyle]::Bold)
    $textBoxDestination.AllowDrop = $true

    $textBoxDestination.add_DragEnter({
        $textBoxDestination.Text = ""
        if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
            $_.Effect = [Windows.Forms.DragDropEffects]::Copy
        }
        elseif ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::Text)) {
            $_.Effect = [Windows.Forms.DragDropEffects]::Copy
        }
    })

    $textBoxDestination.add_DragDrop({
        if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {

            $files = $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
            $textBoxDestination.Text = $files
        }
        elseif ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::Text)) {

            $text = $_.Data.GetData([Windows.Forms.DataFormats]::Text)
            $textBoxDestination.Text = $text
        }
    })


    $OK = New-Object System.Windows.Forms.Button
    $OK.Text = "OK"
    $ok.Location = New-Object System.Drawing.Point(565,44)
    $ok.Size = New-Object System.Drawing.Size(120,3)
    $ok.AutoSize = $true
    $ok.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
    $ok.BackColor = [System.Drawing.Color]::LightCyan
    $ok.add_click({
        $cheminSource   = [Environment]::ExpandEnvironmentVariables($textBox.Text.Trim())
        $cheminIcone    = [Environment]::ExpandEnvironmentVariables($textBoxIcon.Text.Trim())
        $commande       = [Environment]::ExpandEnvironmentVariables($textBoxCommande.Text.Trim())
        $destinationSFX = [Environment]::ExpandEnvironmentVariables($textBoxDestination.Text.Trim())

        $titre = [System.IO.Path]::GetFileNameWithoutExtension($destinationSFX)

        $visible = $false
        if($combo.SelectedIndex -eq 0){ $visible  = $true }

        if ($cheminSource.Length -gt 0 -and $destinationSFX.Length -gt 0) {
            $resultat = faire -cheminSource $cheminSource -cheminIcone $cheminIcone -commande $commande -destinationSFX $destinationSFX -visible $visible -titre $titre
            [Windows.Forms.MessageBox]::Show("Fichier créé :`n$resultat", "Terminé", "OK", "Information")
        }
    })


    $form.AcceptButton = $ok

    $labelNote = New-Object System.Windows.Forms.Label
    $labelNote.Text = "Création d'un fichier exécutable avec un icone personnalisé (fichier .ICO)."
    $labelNote.Location = New-Object System.Drawing.Point(20,380)
    $labelNote.Size = New-Object System.Drawing.Size(490,20)
    $labelNote.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $labelNote.ForeColor = $transparent
    $labelNote.BackColor = [System.Drawing.Color]::FromArgb(150,120,130,140)

    $labelSignature = New-Object System.Windows.Forms.Label
    $labelSignature.Text = "Charles-Antoine BUGUET"
    $labelSignature.Location = New-Object System.Drawing.Point(545,410)
    $labelSignature.Size = New-Object System.Drawing.Size(148,15)
    $labelSignature.Font = New-Object System.Drawing.Font("gabriola", 12, [System.Drawing.FontStyle]::Bold)
    $labelSignature.ForeColor = $transparent
    $labelSignature.BackColor = [System.Drawing.Color]::FromArgb(85,171, 118, 32)

    $form.Controls.AddRange(@($labelTextBox, $textBox, $labelIcon, $textBoxIcon, $labelCommande, $textBoxCommande, $labelCombo, $combo, $ok,$labelNote, $labelDestination, $textBoxDestination, $labelSignature))

    $form.ShowDialog()
}

affichage