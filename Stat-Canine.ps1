# requires -version 5
<#
SYNOPSIS
    Develops a set of functions useful in evaluating a canine
DESCRIPTION
    Import a CSV table of known canines, paste in comparisons, output a result (even if partially solved)
PARAMETER <Parameter_Name>
    VerbosePreference can be set to Continue for verbose outputs
INPUTS
    Select a CSV file at startup
OUTPUTS
    Outputs a result in format-table
    Maybe add a log output
NOTES
  Version:        0.9
  Author:         David Winn
  Creation Date:  8/13/2022
  Purpose/Change: Initial script development
  
EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
  #>

# [Initialisations]

[CmdletBinding()]
PARAM ($VerbosePreference)

# [Declarations]
[Void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[Void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

# Setting up hashtables for results, don't need all keys, will add as calculated
$lowPet = [ordered]@{Name="dummy"}
$highPet = [ordered]@{Name="dummy"}
$petDB = @()

# Syntax: passing a hash value with a number in quotes casts as string, without is int

$baseArray = @(
    [PSCustomObject]@{evalText="totally inferior";     low=-1700; high=-71}
    [PSCustomObject]@{evalText="very inferior";        low=-70;   high=-20}
    [PSCustomObject]@{evalText="inferior";             low=-19;   high=-10}
    [PSCustomObject]@{evalText="slightly inferior";    low=-9;    high=-5}
    [PSCustomObject]@{evalText="marginally inferior";  low=-4;    high=-2}
    [PSCustomObject]@{evalText="barely inferior";      low=-1;    high=-1}
    [PSCustomObject]@{evalText="similar";              low=0;     high=0}
    [PSCustomObject]@{evalText="barely better";        low=1;     high=1}
    [PSCustomObject]@{evalText="marginally better";    low=2;     high=4}
    [PSCustomObject]@{evalText="slightly better";      low=5;     high=9}
    [PSCustomObject]@{evalText="better";               low=10;    high=19}
    [PSCustomObject]@{evalText="much better";          low=20;    high=70}
    [PSCustomObject]@{evalText="outstandingly better"; low=71;    high=1700}
    )

$traits = @(
    'Alertness','Appetite','Brutality','Development','Eluding','Energy',
    'Evasion','Ferocity','Fortitude','Insight','Might','Nimbleness',
    'Patience','Procreation','Sufficiency','Targeting','Toughness'
    )

$initialDirectory = $PSScriptRoot

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Get-Selection{
    param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $sourceDBFile    
    )
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    $petDB = Read-Database -sourceDBFile $sourceDBFile

    $Form = New-Object System.Windows.Forms.Form
    # $label = New-Object System.Windows.Forms.Label
    $Form.width = 550
    $Form.height = 250
    $Form.StartPosition = 'CenterScreen'
    $Form.Text = "Character / Canine Selection Window"
    $DropDown = new-object System.Windows.Forms.ComboBox
    $DropDown.Location = new-object System.Drawing.Size(100,10)
    $DropDown.Size = new-object System.Drawing.Size(254,30)
    ###
    ForEach ($Item in $petDB) {
        $DropDown.Items.Add($Item.Name)
        }
    ###
    $DropDown.SelectedIndex = 0
    $Form.Controls.Add($DropDown)

    $DropDownLabel = new-object System.Windows.Forms.Label
    $DropDownLabel.Location = new-object System.Drawing.Size(10,10)
    $DropDownLabel.size = new-object System.Drawing.Size(100,40)
    $DropDownLabel.Text = $args
    $Form.Controls.Add($DropDownLabel)
    $Button = new-object System.Windows.Forms.Button
    $Button.Location = new-object System.Drawing.Size(100,100)
    $Button.Size = new-object System.Drawing.Size(300,100)
    $Button.Text = "Select Character and Pet"

    $Button.Add_Click({$Script:Choice=$DropDown.SelectedIndex;$Script:knownPet=$petDB[$Choice];$Form.Close()})
    
    $form.Controls.Add($Button)
    $Form.Add_Shown({$Form.Activate()})
    $Form.ShowDialog()
    $Script:Answer=[System.Windows.Forms.MessageBox]::Show('Proceed ? ','You selected: ' + $knownPet.Name,'YesNoCancel','Information')
    return $Script:knownPet
}

Function Output-ResultBox{
    Param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $reportPet
        )
    $outputForm = New-Object System.Windows.Forms.Form
    $outputForm.TopMost = $true
    $outputForm.Size = New-Object System.Drawing.Size(700,700)
    $outputForm.StartPosition = "CenterScreen"
    $outputForm.Text = "Result of comparisons"
    $outputForm.Add_Shown({$outputForm.Activate()})

    $outputBox = New-Object System.Windows.Forms.TextBox
    $outputBox.Location = New-Object System.Drawing.Size(10,10)
    $outputBox.Size = New-Object System.Drawing.Size(665,640)
    $outputBox.Multiline = $true
    $outputBox.ScrollBars = "Vertical"
    $font = New-Object System.Drawing.Font("Consolas",9,[System.Drawing.FontStyle]::Regular)
    $outputBox.Font = $font
    $outputForm.Controls.Add($outputBox)
    $myText = $reportPet | Format-Table -HideTableHeaders | Out-String
    $test = $myText | Where-Object { $_ -ne "" }
    $outputBox.Text = $test
    [void] $outputForm.ShowDialog()
}


Function Read-Database {
    Param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $sourceDBFile      
    )
# NOT WORKING Write-Verbose "Read-Database: Opening $sourceDBFile.Fullname"
    $petDB = Import-Csv -Path $sourceDBFile
Write-Verbose "Read-Database: import-CSV is $petDB"
    $petDB = $petDB | Where-Object Status -EQ "Active"
    # If a non-digit is detected, mark the field UNSOLVED, then go fix Get-Traits and Get-Overall to look for that
    $petDB = $petDB | ForEach-Object {
# DEBUG: Write-Host "Read-Database: Object is $_ "
# NOT WORKING Write-Verbose: "Read-Database: Object is $_ "
        if($_.Alertness -match "\D")   {$_.Alertness = [string]"UNSOLVED"}   else {$_.Alertness = [int]$_.Alertness}
        if($_.Appetite -match "\D")    {$_.Appetite = [string]"UNSOLVED"}    else {$_.Appetite = [int]$_.Appetite}
        if($_.Brutality -match "\D")   {$_.Brutality = [string]"UNSOLVED"}   else {$_.Brutality = [int]$_.Brutality}
        if($_.Development -match "\D") {$_.Development = [string]"UNSOLVED"} else {$_.Development = [int]$_.Development}
        if($_.Eluding -match "\D")     {$_.Eluding = [string]"UNSOLVED"}     else {$_.Eluding = [int]$_.Eluding}
        if($_.Energy -match "\D")      {$_.Energy = [string]"UNSOLVED"}      else {$_.Energy = [int]$_.Energy}
        if($_.Evasion -match "\D")     {$_.$trait = [string]"UNSOLVED"}      else {$_.Evasion = [int]$_.Evasion}
        if($_.Ferocity -match "\D")    {$_.Ferocity = [string]"UNSOLVED"}    else {$_.Ferocity = [int]$_.Ferocity}
        if($_.Fortitude -match "\D")   {$_.Fortitude = [string]"UNSOLVED"}   else {$_.Fortitude = [int]$_.Fortitude}
        if($_.Insight -match "\D")     {$_.Insight = [string]"UNSOLVED"}     else {$_.Insight = [int]$_.Insight}
        if($_.Might -match "\D")       {$_.Might = [string]"UNSOLVED"}       else {$_.Might = [int]$_.Might}
        if($_.Nimbleness -match "\D")  {$_.Nimbleness = [string]"UNSOLVED"}  else {$_.Nimbleness = [int]$_.Nimbleness}
        if($_.Patience -match "\D")    {$_.Patience = [string]"UNSOLVED"}    else {$_.Patience = [int]$_.Patience}
        if($_.Procreation -match "\D") {$_.Procreation = [string]"UNSOLVED"} else {$_.Procreation = [int]$_.Procreation}
        if($_.Sufficiency -match "\D") {$_.Sufficiency = [string]"UNSOLVED"} else {$_.Sufficiency = [int]$_.Sufficiency}
        if($_.Targeting -match "\D")   {$_.Targeting = [string]"UNSOLVED"}   else {$_.Targeting = [int]$_.Targeting}
        if($_.Toughness -match "\D")   {$_.Toughness = [string]"UNSOLVED"}   else {$_.Toughness = [int]$_.Toughness}
        if($_.TOTAL -match "\D")       {$_.TOTAL = [string]"UNSOLVED"}       else {$_.TOTAL = [int]$_.TOTAL}
# Output the object
        $_
        }
    $petDB = $petDB | Sort-Object -Property Name
    return $petDB

    }

function Get-EvalText {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $direction        
    )
    $message = "Please enter the text from a CERTAIN comparison"
    $windowTitle = $direction
    $defaultText = "Paste in entire compare block here"
    $evalText = Read-MultiLineInputBoxDialog -Message $message -WindowTitle $windowTitle -DefaultText $defaultText
    if ($null -eq $evalText) { Write-Host "You clicked Cancel - ending selector function";break }
    else {}
    $evalText = $evalText.Split([Environment]::NewLine, [System.StringSplitOptions]::RemoveEmptyEntries)
    return $evalText
}

function Get-Knowledge {
    param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $evalText
    )
    $knowledgePattern = "think","feel","certain"
    foreach($pattern in $knowledgePattern){
        #DEBUG:         Write-Host "Get-Knowledge is Checking $pattern"
        if($evalText -match $pattern){
            $knowledge = $pattern
            } else {
            $knowledge = "KNOWLEDGE level is missing"
            }
        }
    return $knowledge
}

function Get-Relationship {
    Param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $evalText
    )
    $relationshipPattern = "They seem to be"
    if($evalText -match $relationshipPattern){
        $relationship = $evalText -match $relationshipPattern
        $relationship = $relationship.Replace($relationshipPattern,"").Replace(".","").Replace(" ","")
        }
    else{
        $relationship = "UNKNOWN"
        }
    return $relationship
}

Function Get-Traits {
    Param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $evalText,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $direction
    )
    # Cycle through $traits and fill $lowPet $highPet as appropriate
    foreach($trait in $traits){
        # DO STUFF
        $pattern = $trait
# DEBUG: Write-Host "Get-Traits: STARTING $trait"
Write-Verbose "Get-Traits: Looping through traits for $trait "
        # First, establish if the known pet has this trait at all - check for string UNSOLVED
Write-Verbose "Get-Traits: knownPet is $knownPet.Name"
        $knownValue = $knownPet.$trait
Write-Verbose "Get-Traits: KnownPet trait $trait is $knownValue "
Write-Verbose "Get-Traits: Comparing in direction $direction"
        if($knownValue -eq "UNSOLVED"){
            Write-Host "Get-Traits: Known pet does not have value for $trait - skipping" -ForegroundColor Yellow
            return
        } else {

        #Strip down to get the comparison text
        $diffDesc = foreach ($str in $evalText){
            Select-String -InputObject $str -Pattern $pattern
            }
        # If text is from the listener's perspective, strip CharacterName says:
        $diffDesc = $diffDesc -replace '\w+ says: ',''

        $diffDesc = $diffDesc.ToString().TrimStart()           # Remove padding
# DEBUG: Write-Host "Get-Traits working on this string: $diffDesc"
Write-Verbose "Get-Traits: working on string: $diffDesc"
        $diffDesc = $diffDesc -replace '(^(?:\S+\s+\n?){1,2})',''  # Remove 1st 2 words
        $diffDesc = $diffDesc.Replace('.','')
# DEBUG: Write-Host "Get-Traits string: $diffDesc is ready"

        # Translate difference description into two numbers
        foreach($row in $baseArray){
        if($row.evalText -eq $diffDesc){
            $traitLowModifier  = $row.low
            $traitHighModifier = $row.high
            }
        }
Write-Verbose "Get-Traits: $trait lowModifier: $traitLowModifier"
Write-Verbose "Get-Traits: $trait highModifier: $traitHighModifier"
        # Do math, known value + modifier
        if($direction -eq "UnknownToKnown"){
            $potentialLow  = $knownValue + $traitLowModifier
            $potentialHigh = $knownValue + $traitHighModifier
Write-Verbose "Get-Traits: UnknownToKnown: $potentialLow is $knownValue + $traitLowModifier"
Write-Verbose "Get-Traits: UnknownToKnown: $potentialHigh is $knownValue + $traitHighModifier"
        }
        elseif ($direction -eq "KnownToUnknown") {
            $potentialLow  = $knownValue - $traitHighModifier
            $potentialHigh = $knownValue - $traitLowModifier
# DEBUG: Write-Host "Get-Traits direction is $direction for $trait low $potentialLow high $potentialHigh"
Write-Verbose "Get-Traits: KnownToUnknown: $potentialLow is $knownValue - $traitHighModifier"
Write-Verbose "Get-Traits: KnownToUnknown: $potentialHigh is $knownValue - $traitLowModifier"
        }
        elseif ($direction -notin "UnknownToKnown","KnownToUnknown"){
# DEBUG: 
Write-Host "Get-Traits: Something wrong in direction $direction - breaking" -ForegroundColor Yellow
            break
        }
        # Get the current low and high estimates
        $currentLow = $lowPet.$trait
        $currentHigh = $highPet.$trait
# DEBUG: Write-Host "Get-Traits current estimate of LOW is $currentLow"
# DEBUG: Write-Host "Get-Traits current estimate of HIGH is $currentHigh"
Write-Verbose "Get-Traits: checking lowPet: current estimate LOW for $trait is $currentLow"
Write-Verbose "Get-Traits: Checking highPet: current estimate HIGH for $trait is $currentHigh"

        # LOW PET
        # Does the key exist?
        if($lowPet.Keys -notcontains $trait){
# DEBUG: Write-Host "Get-Traits creating key/value $trait $potentialLow in lowPet"
Write-Verbose "Get-Traits: lowPet: Creating Key/Value $trait $potentialLow in lowPet"
            $lowPet.Add($trait,$potentialLow)
            }
        # Simplify the logic, spreadsheet does this: for an array of low ranges (20, 21, 22, 23) select the highest
        # so if $potentialLow > $currentLow, replace value
        elseif($potentialLow -gt $currentLow){
# DEBUG: Write-Host "Get-Traits potential LOW value $potentialLow higher than current : UPDATING"
Write-Verbose "Get-Traits: lowPet: UPDATING $trait : $potentialLow > $currentLow"
            $lowPet.$trait = $potentialLow
            }
        elseif($potentialLow -le $currentLow){
Write-Verbose "Get-Traits: lowPet: NO ACTION : $potentialLow <= $currentLow"
            }

        # HIGH PET
        if($highPet.Keys -notcontains $trait){
# DEBUG: Write-Host "Get-Traits creating key/value $trait $potentialHigh in highPet"
Write-Verbose "Get-Traits: highPet: Creating Key/Value $trait $potentialHigh in highPet"
            $highPet.Add($trait,$potentialHigh)
            }
        # Again, lets keep it simple. spreadsheet does this: for an array of high ranges (23, 24, 25, 26) pick the lowest
        elseif($potentialHigh -lt $currentHigh){
# DEBUG: Write-Host "Get-Traits potential HIGH value $potentialHigh lower than current $currentHigh : UPDATING"
Write-Verbose "Get-Traits: highPet: UPDATING $trait : $potentialHigh < $currentHigh"
            $highPet.$trait = $potentialHigh
            }
        elseif($potentialHigh -ge $currentHigh){
Write-Verbose "Get-Traits: highPet: NO ACTION : $potentialHigh >= $currentHigh"
            }
Write-Verbose "Get-Traits: FINISHED $trait"
        }
    }
}

function Get-Subtotal {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $lowPet,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $highPet
    )
    # Aha, bad logic, you can't subtotal yet because you haven't cycled, move subtotal to a new func
    # Having completed updating lowPet and highPet, we need subtotals, calculate fresh each compare
# DEBUG: Write-Host "Get-Subtotal: Starting Subtotal"
    $subtotalLow = 0
    $subtotalHigh = 0
    foreach($trait in $traits){
# DEBUG: Write-Host "Get-Subtotal: Subtotal subtotalLow adding lowPet trait $trait value $lowPet.$trait "
# This is going to bug on trait missing add an if statement
        $subtotalLow = $subtotalLow + $lowPet.$trait
        $subtotalHigh = $subtotalHigh + $highPet.$trait
    }
    # if $lowpet.keys -notcontains Subtotal add key/value
     if($lowPet.Keys -notcontains "Subtotal"){
# DEBUG: Write-Host "Get-Traits SUBTOTAL LOW creating key/value Subtotal of $subtotalLow in lowPet"
        $lowPet.Add("Subtotal",$subtotalLow)
        }
    # else $lowPet.Subtotal = $subtotalLow
    else{
# DEBUG: Write-Host "Get-Traits SUBTOTAL LOW updating key/value Subtotal to $subtotalLow in lowPet"
        $lowPet.Subtotal = $subtotalLow
        }

    # if $highpet.keys -notcontains Subtotal add key/value
    if($highPet.Keys -notcontains "Subtotal"){
# DEBUG: Write-Host "Get-Traits SUBTOTAL HIGH creating key/value Subtotal of $subtotalHigh in highPet"
        $highPet.Add("Subtotal",$subtotalHigh)
    }
    # else $highPet.Subtotal = $subtotalHigh
    else{
# DEBUG: Write-Host "Get-Traits SUBTOTAL HIGH updating key/value Subtotal to $subtotalHigh in highPet"
        $highPet.Subtotal = $subtotalHigh
    }
    return
    }

Function Get-Overall {
    Param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $evalText,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $direction
    )
    # First, establish if the known pet has this trait at all - check for string UNSOLVED
    $knownValue = $knownPet.TOTAL
    if ($knownValue -eq "UNSOLVED"){
        Write-Host "Get-Overall: Known pet is not completely solved, skipping OVERALL comparison" -ForegroundColor Yellow
        return
    } else {
    $pattern = "Overall"         # Made it a var since I'll use it for key later
    $overallText = foreach ($str in $evalText){
        Select-String -InputObject $str -Pattern $pattern
        }
    $overallText = $overallText.ToString()
    # If text is from the listener's perspective, strip CharacterName says:
    $overallText = $overallText -replace '\w+ says: ',''

    $overallText = $overallText -replace '(^(?:\S+\s+\n?){1,5})','' # Remove 1st 5 words
    $overallText = $overallText.Replace(".","")
# DEBUG: Write-Host "Get-Overall found the Overall to be: $overallText"

    # Turn comparison text into a number
    foreach($row in $baseArray){
        if($row.evalText -eq $overallText){
            $overallLowRange  = $row.low
            $overallHighRange = $row.high
            }
        }
# DEBUG: Write-Host "Get-Overall found modifiers low: $overallLowRange - high: $overallHighRange"
    # Do the math, known.total + modifiers

# DEBUG: Write-Host "Get-Overall found knownpet TOTAL: $knownValue"
    if($direction -eq "UnknownToKnown"){
        $potentialOverallLowValue = $knownValue + $overallLowRange
        $potentialOverallHighValue = $knownValue + $overallHighRange
    }
    elseif($direction -eq "KnownToUnknown"){
        # Comparisons are reversed, so flip the positions
# DEBUG: Write-Host "Get-Overall in KnownToUnknown, flipping position of lookup table values"
        $potentialOverallLowValue = $knownValue - $overallHighRange
        $potentialOverallHighValue = $knownValue - $overallLowRange
    }
    elseif($direction -notin "UnknownToKnown","KnownToUnknown"){
# DEBUG: Write-Host "Get-Overall: Something wrong in direction $direction - breaking"
        break
        }

    # Handling the Overall Low first
# DEBUG: Write-Host "Get-Overall calculated Overall Low: $overallLowValue High: $overallHighValue"

    # Get our current values for low and high
    $currentLowOverall  = $lowPet.$pattern
    $currentHighOverall = $highPet.$pattern
# DEBUG: Write-Host "Get-Overall current Low Overall is $currentLowOverall"
# DEBUG: Write-Host "Get-Overall current High Overall is $currentHighOverall"

    # Do we need to add or change the value in key Overall?
    if($lowpet.keys -notcontains $pattern){
# DEBUG: Write-Host "Get-Overall creating key for lowPet $pattern value $potentialOverallLowValue" 
            $lowPet.Add($pattern,$potentialOverallLowValue)
        }
        # Reworking logic so it looks like Get-Traits.  For low range, select highest value
        elseif($potentialOverallLowValue -gt $currentLowOverall){
# DEBUG: Write-Host "Get-Overall - Updating lowpet $pattern value from $currentLowOverall to $potentialOverallLowValue"
            $lowpet.$pattern = $potentialOverallLowValue
        }
    elseif($potentialOverallLowValue -le $currentLowOverall){
# DEBUG: Write-Host "Get-Overall - no action: potentialOverallLowValue $potentialOverallLowValue <= $currentLowOverall"
        }

    # Handling the Overall High
    if($highpet.keys -notcontains $pattern){
# DEBUG: Write-Host "Get-Overall creating key for highPet $pattern value $potentialOverallHighValue" 
            $highPet.Add($pattern,$potentialOverallHighValue)
        }
        # For high range, select the lowest value you find
        elseif($potentialOverallHighValue -lt $currentHighOverall){  
# DEBUG: Write-Host "Get-Overall - updating highpet $pattern value from $currentHighOverall to $potentialOverallHighValue"
        $highpet.$pattern = $potentialOverallHighValue
    }
    elseif($potentialOverallHighValue -gt $currentHighOverall){
# DEBUG: Write-Host "Get-Overall - no action: Potential Overall High $potentialOverallHighValue >= $currentHighOverall"
    }
    }
}

Function Read-MultiLineInputBoxDialog {
    Param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Message, 
    
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$WindowTitle,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$DefaultText
    )
    
        Add-Type -AssemblyName System.Drawing
        Add-Type -AssemblyName System.Windows.Forms
     
        # Create the Label.
        $label = New-Object System.Windows.Forms.Label
        $label.Location = New-Object System.Drawing.Size(10,10) 
        $label.Size = New-Object System.Drawing.Size(280,20)
        $label.AutoSize = $true
        $label.Text = $Message
     
        # Create the TextBox used to capture the user's text.
        $textBox = New-Object System.Windows.Forms.TextBox 
        $textBox.Location = New-Object System.Drawing.Size(10,40) 
        $textBox.Size = New-Object System.Drawing.Size(575,400)
        $textBox.AcceptsReturn = $true
        $textBox.AcceptsTab = $false
        $textBox.Multiline = $true
        $textBox.ScrollBars = 'Both'
        $textBox.Text = $DefaultText
     
        # Create the OK button.
        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Location = New-Object System.Drawing.Size(415,450)
        $okButton.Size = New-Object System.Drawing.Size(75,25)
        $okButton.Text = "OK"
        $okButton.Add_Click({ $form.Tag = $textBox.Text; $form.Close() })
     
        # Create the Cancel button.
        $cancelButton = New-Object System.Windows.Forms.Button
        $cancelButton.Location = New-Object System.Drawing.Size(510,450)
        $cancelButton.Size = New-Object System.Drawing.Size(75,25)
        $cancelButton.Text = "Cancel"
        $cancelButton.Add_Click({ $form.Tag = $null; $form.Close() })
     
        # Create the form.
        $form = New-Object System.Windows.Forms.Form 
        $form.Text = $WindowTitle
        $form.Size = New-Object System.Drawing.Size(610,520)
        $form.FormBorderStyle = 'FixedSingle'
        $form.StartPosition = "CenterScreen"
        $form.AutoSizeMode = 'GrowAndShrink'
        $form.Topmost = $True
        $form.AcceptButton = $okButton
        $form.CancelButton = $cancelButton
        $form.ShowInTaskbar = $true

        # Check for ENTER and ESC presses
        $Form.KeyPreview = $True
        $Form.Add_KeyDown({if ($PSItem.KeyCode -eq "Enter") 
            {
                # if enter, perform click
                $OKButton.PerformClick()
                }
            })
        $Form.Add_KeyDown({if ($PSItem.KeyCode -eq "Escape") 
        {
            # if escape, exit
            $Form1.Close()
            }
        })
     
        # Add all of the controls to the form.
        $form.Controls.Add($label)
        $form.Controls.Add($textBox)
        $form.Controls.Add($okButton)
        $form.Controls.Add($cancelButton)
     
        # Initialize and show the form.
        $form.Add_Shown({$form.Activate()})
        $form.ShowDialog() > $null   # Trash the text of the button that was clicked.
     
        # Return the text that the user entered.
        return $form.Tag
    }

Function Get-Status {
    Param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $lowPet,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $highPet
    )
    if($lowPet.Keys.count -eq 1){
        Write-Host "--- --- STATUS: No comparisons completed, return to menu --- ---" -ForegroundColor Yellow
        pause
        break
        }
    $i = 0
    foreach($trait in $traits){
    if($lowPet.$trait -eq $highPet.$trait){
        $i=$i+1
        }
    }
    $total = $traits.Count
    Write-Host "--- --- STATUS: Solved $i of $total --- ---" -ForegroundColor Yellow
}

Function Show-Menu {
    Param()
    
    do {
    [int]$userMenuChoice = 0
    while ( $userMenuChoice -lt 1 -or $userMenuChoice -gt 5) {
    Write-Host "+=================================================+"
    Write-Host "|    Ancient Anguish Canine Trait Calculations    |"
    Write-Host "+=================================================+"
    Write-Host "| 1) Compare an UNKNOWN canine to a KNOWN canine  |"
    Write-Host "| 2) Compare a KNOWN canine to an UNKNOWN canine  |"
    Write-Host "| 3) Report current result in vertical columns    |"
    Write-Host "| 4) Report current status                        |"
    Write-Host "| 5) Quit and Exit                                |"
    Write-Host "|                                                 |"
    Write-Host "+-------------------------------------------------+"

    [int]$userMenuChoice = Read-Host "Please choose an option"

    switch ($userMenuChoice) {
            1 { Update-Unknown -direction "UnknownToKnown" -sourceDBFile $sourceDBFile}
            2 { Update-Unknown -direction "KnownToUnknown" -sourceDBFile $sourceDBFile}
            3 { Format-Vertical -lowPet $lowPet -highPet $highPet}
            4 { Get-Status -lowPet $lowPet -highPet $highPet}
            5 { Exit-Script }
    default {
        Write-Host "Nothing selected"
            }
        }
      }
    } 
    while ( $userMenuChoice -ne 5 )
}

Function Update-Unknown {
    Param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $direction,
    
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $sourceDBFile
    )

#    $knownPet = Get-KnownPet -sourceDBFile $sourceDBFile
    $knownPet = Get-Selection -sourceDBFile $sourceDBFile
    $evalText = Get-EvalText -direction $direction
    $knowledge = Get-Knowledge $evalText
    if($knowledge -ne "certain"){
        Write-Host "Update-Unknown - WARNING - Comparison may not be certain!" -ForegroundColor Yellow
        }
    $textName = ($knownPet | Select-Object -Property Name).Name
    Write-Host "Update-Unknown: Using $textName as Known Pet" -ForegroundColor Yellow
    Get-Traits -evalText $evalText -direction $direction
    Get-Subtotal -lowPet $lowPet -highPet $highPet
    Get-Overall -evalText $evalText -direction $direction
    Get-Status -lowPet $lowPet -highPet $highPet
}

Function Exit-Script {
    Param()
    Write-Host "Here it is, your moment of Zen..."
    Format-Vertical -lowPet $lowPet -highPet $highPet
    Pause
    Break
}

<# Transform HashTable to Horizontal Array - HowTo
[PSCustomObject]$highPet | Export-Csv -NoTypeInformation -Path .\highPet.csv
[PSCustomObject]$lowpet  | Export-Csv -NoTypeInformation -Path .\lowPet.csv
#>

Function Format-Vertical {
    Param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $lowPet,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $highPet
    )
    
    if($lowPet.Keys.count -eq 1){
        Write-Host "--- --- REPORT: No comparisons completed --- ---" -ForegroundColor Yellow
        return
    }    
    # build an output hashtable, if trait !=, [string]trait + [string]trait is newval
    $reportPet = [ordered]@{Name="dummy"}
    foreach($trait in $traits){
        if($lowPet.$trait -eq $highPet.$trait){
            $reportPet.$trait += $lowPet.$trait
            }
        elseif($lowPet.$trait -ne $highPet.$trait){
            $lowStr   = ($lowPet.$trait).ToString()
            $highStr  = ($highPet.$trait).ToString()
            $rangeStr = $lowStr + " - " + $highStr
            $reportPet.Add($trait,$rangeStr)
        }      
    }

    $subtotalLow  = ($lowPet.Subtotal).ToString()
    $subtotalHigh = ($highPet.Subtotal).ToString()
    $rangeSubtotal = $subtotalLow + " to " + $subtotalHigh
    $reportPet.Add("Subtotal",$rangeSubtotal)

    $lowOverall   = ($lowPet.Overall).ToString()
    $highOverall  = ($highPet.Overall).ToString()
    $rangeOverall = $lowOverall + " to " + $highOverall
    $reportPet.Add("Overall",$rangeOverall)
#    $reportPet | Format-Table -HideTableHeaders
    Output-ResultBox -reportPet $reportPet
    return $reportPet
}

Function Get-File($initialDirectory) {   
    Write-Verbose "Get-File: This doesn't work in VSCode, find a new method?"
    [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    if ($initialDirectory) { $OpenFileDialog.initialDirectory = $initialDirectory }
    $OpenFileDialog.filter = 'All files (*.*)|*.*'
    [void] $OpenFileDialog.ShowDialog()
    return $OpenFileDialog.FileName
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------


Write-Host "Select a CSV file, default example format is KNOWNS.csv" -ForegroundColor Yellow
$sourceDBFile = Get-File -initialDirectory $initialDirectory
Show-Menu