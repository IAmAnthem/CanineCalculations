<# Stat-Canine.ps1

Develops a set of functions useful in evaluating a canine

#>
Function Read-Database {
    Param()
    # The default behaviour of Import-CSV to import everything as strings
    # Cast the integers!
    # Your pet database should be something like KNOWNS.csv
    # A sample file is included in this repository
    # I develop/test against PRIVATE-KNOWNS.csv which has data from other players
    $petDB = Import-CSV -Path .\PRIVATE-KNOWNS.csv
    $petDB = $petDB | Where-Object Status -EQ "Active"
    $petDB = $petDB | ForEach-Object {
        #Cast things to integer explicitly
        $_.Alertness   = [int]$_.Alertness
        $_.Appetite	   = [int]$_.Appetite
        $_.Brutality   = [int]$_.Brutality
        $_.Development = [int]$_.Development
        $_.Eluding     = [int]$_.Eluding
        $_.Energy      = [int]$_.Energy
        $_.Evasion     = [int]$_.Evasion
        $_.Ferocity    = [int]$_.Ferocity
        $_.Fortitude   = [int]$_.Fortitude
        $_.Insight     = [int]$_.Insight
        $_.Might       = [int]$_.Might
        $_.Nimbleness  = [int]$_.Nimbleness
        $_.Patience    = [int]$_.Patience
        $_.Procreation = [int]$_.Procreation
        $_.Sufficiency = [int]$_.Sufficiency
        $_.Targeting   = [int]$_.Targeting
        $_.Toughness   = [int]$_.Toughness
        $_.TOTAL       = [int]$_.TOTAL

        # Output object
        $_
        }
    $petDB = $petDB | Sort-Object -Property Name
    return $petDB
    }

function Get-EvalText {
    param ()
    $message = "Please enter a CERTAIN eval, KNOWN to UNKNOWN"
    $windowTitle = "Compare Known to Unknown"
    $defaultText = "Enter some text here..."
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
        Write-Host "Get-Traits is looking for $trait"

        #Strip down to get the comparison text
        $diffDesc = foreach ($str in $evalText){
            Select-String -InputObject $str -Pattern $pattern
            }
        # If text is from the listener's perspective, strip CharacterName says:
        $diffDesc = $diffDesc -replace '\w+ says: ',''

        $diffDesc = $diffDesc.ToString().TrimStart()           # Remove padding
        Write-Host "Get-Traits working on this string: $diffDesc"
        $diffDesc = $diffDesc -replace '(^(?:\S+\s+\n?){1,2})',''  # Remove 1st 2 words
        $diffDesc = $diffDesc.Replace('.','')
        Write-Host "Get-Traits string: $diffDesc is ready"

        # Translate difference description into two numbers
        foreach($row in $baseArray){
        if($row.evalText -eq $diffDesc){
            $traitLowModifier  = $row.low
            $traitHighModifier = $row.high
            }
        }
Write-Host "Get-Traits found lowModifier: $traitLowModifier"
Write-Host "Get-Traits found highModifier: $traitHighModifier"

        # Do math, known value + modifier
        $knownValue = $knownPet.$trait

        if($direction -eq "UnknownToKnown"){
            $potentialLow  = $knownValue + $traitLowModifier
            $potentialHigh = $knownValue + $traitHighModifier
Write-Host "Get-Traits direction is $direction for $trait low $potentialLow high $potentialHigh"
        }
        elseif ($direction -eq "KnownToUnknown") {
            $potentialLow  = $knownValue - $traitHighModifier
            $potentialHigh = $knownValue - $traitLowModifier
Write-Host "Get-Traits direction is $direction for $trait low $potentialLow high $potentialHigh"
        }
        elseif ($direction -notin "UnknownToKnown","KnownToUnknown"){
            Write-Host "Get-Traits: Something wrong in direction $direction - breaking"
            break
        }
        # Get the current low and high estimates
        $currentLow = $lowPet.$trait
        $currentHigh = $highPet.$trait

        # LOW PET
        # Does the key exist?
        if($lowPet.Keys -notcontains $trait){
Write-Host "Get-Traits creating key/value $trait $potentialLow in lowPet"
            $lowPet.Add($trait,$potentialLow)
            }
        # Simplify the logic, spreadsheet does this: for an array of low ranges (20, 21, 22, 23) select the highest
        # so if $potentialLow > $currentLow, replace value
        elseif($potentialLow -gt $currentLow){
Write-Host "Get-Traits potential LOW value $potentialLow higher than current : UPDATING"
            $lowPet.$trait = $potentialLow
            }
        elseif($currentLow -le $potentialLow){
Write-Host "Get-Traits potential value $potentialLow <= $currentLow : NO ACTION"
            }

        # HIGH PET
        if($highPet.Keys -notcontains $trait){
Write-Host "Get-Traits creating key/value $trait $potentialHigh in highPet"
            $highPet.Add($trait,$potentialHigh)
            }
        # Again, lets keep it simple. spreadsheet does this: for an array of high ranges (23, 24, 25, 26) pick the lowest
        elseif($potentialHigh -lt $currentHigh){
Write-Host "Get-Traits potential value $potentialHigh lower than current : UPDATING"
            $highPet.$trait = $potentialHigh
            }
        elseif($potentialHigh -ge $currentHigh){
Write-Host "Get-Traits potential value $potentialHigh >= current : NO ACTION"
            }
            pause
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
    # Get the comparison text
    $pattern = "Overall"         # Made it a var since I'll use it for key later
    $overallText = foreach ($str in $evalText){
        Select-String -InputObject $str -Pattern $pattern
        }
    $overallText = $overallText.ToString()
    # If text is from the listener's perspective, strip CharacterName says:
    $overallText = $overallText -replace '\w+ says: ',''

    $overallText = $overallText -replace '(^(?:\S+\s+\n?){1,5})','' # Remove 1st 5 words
    $overallText = $overallText.Replace(".","")
    Write-Host "Get-Overall found the Overall to be: $overallText"

    # Turn comparison text into a number
    foreach($row in $baseArray){
        if($row.evalText -eq $overallText){
            $overallLowRange  = $row.low
            $overallHighRange = $row.high
            }
        }
    Write-Host "Get-Overall found modifiers low: $overallLowRange - high: $overallHighRange"
    Write-Host "Get-Overall - pay attention, this is probably broken"
    # Do the math, known.total + modifiers
    $knownValue = $knownPet.TOTAL
    Write-Host "Get-Overall found knownpet TOTAL: $knownValue"
    if($direction -eq "UnknownToKnown"){
        $potentialOverallLowValue = $knownValue + $overallLowRange
        $potentialOverallHighValue = $knownValue + $overallHighRange
    }
    elseif($direction -eq "KnownToUnknown"){
        # Comparisons are reversed, so flip the positions
Write-Host "Get-Overall in KnownToUnknown, flipping position of lookup table values"
        $potentialOverallLowValue = $knownValue - $overallHighRange
        $potentialOverallHighValue = $knownValue - $overallLowRange
    }
    elseif($direction -notin "UnknownToKnown","KnownToUnknown"){
        Write-Host "Get-Overall: Something wring in direction $direction - breaking"
        break
        }

    # Handling the Overall Low first
    Write-Host "Get-Overall calculated Overall Low: $overallLowValue High: $overallHighValue"

    # Get our current values for low and high
    $currentLowOverall  = $lowPet.$pattern
    $currentHighOverall = $highPet.$pattern
    Write-Host "Get-Overall current Low Overall is $currentLowOverall"
    Write-Host "Get-Overall current High Overall is $currentHighOverall"

    # Do we need to add or change the value in key Overall?
    if($lowpet.keys -notcontains $pattern){
Write-Host "Get-Overall creating key for lowPet $pattern value $potentialOverallLowValue" 
            $lowPet.Add($pattern,$potentialOverallLowValue)
        }
    elseif($currentLowOverall -lt $potentialOverallLowValue){  
            # The low range should continue to 'rise' as we refine
            # Since our current overall low < than calculated low, update!
Write-Host "Get-Overall updating lowpet $pattern value from $currentLowOverall to $potentialOverallLowValue"
            $lowpet.$pattern = $potentialOverallLowValue
        }
    elseif($currentLowOverall -ge $potentialLowOverall){
            # current overall low  >= potential overall low, discard this (Don't do anything)
Write-Host "Get-Overall - no action: $currentLowOverall is greater or equal to $potentialOverallLowValue"
        }

    if($highpet.keys -notcontains $pattern){
Write-Host "Get-Overall creating key for highPet $pattern value $potentialOverallHighValue" 
            $highPet.Add($pattern,$potentialOverallHighValue)
        }
    elseif($currentHighOverall -gt $potentialOverallHighValue){  
        # The high range should continue to 'sink' as we refine
        # Since our current overall high > calculated low, update!
Write-Host "Get-Overall updating highpet $pattern value from $currentHighOverall to $potentialOverallHighValue"
        $highpet.$pattern = $potentialOverallHighValue
    }
    elseif($currentHighOverall -le $potentialHighOverall){
        # current overall low  <= potential overall low, discard this (Don't do anything)
Write-Host "Get-Overall - no action: $currentHighOverall is less than or equal to $potentialOverallHighValue"
    }
}

Function Get-KnownPet{
    param()     # No params, we're going to start by asking who you compared against
    # Develop picker-code
    $petDB = Read-Database
    $validChoices = 0..($petDB.Count -1)
    $choice = ''
    while ([string]::IsNullOrEmpty($choice)){
    Write-Host "+=================================================+"
    Write-Host "|      Select a known pet from the database       |"
    Write-Host "+=================================================+"
        foreach ($line in $petDB){
            #another thing
            Write-Host ('{0} - {1} - {2}' -f $petDB.IndexOf($line),$line.Name,$line.Person)
            }
        $choice = Read-Host -Prompt 'Please chose one of the known pets by number'
        if($choice -in $validChoices){
            Write-Host (' --- Your choice of: [{0}] is valid.' -f $choice)
            $knownPet = $petDB[$choice]
            }
            else{
            Write-Warning (' [{0}] is not a valid selection.' -f $choice)
            Write-Warning '--- TRY AGAIN'
            pause
            $choice = ''
            }
        }
    return $knownPet
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
    Write-Host "| 1) Compare an unknown canine to a known canine  |"
    Write-Host "| 2) Compare a known canine to an unknown canine  |"
    Write-Host "| 3) Report current result in vertical columns    |"
    Write-Host "| 4) Report current status                        |"
    Write-Host "| 5) Quit and Exit                                |"
    Write-Host "|                                                 |"
    Write-Host "+-------------------------------------------------+"

    [int]$userMenuChoice = Read-Host "Please choose an option"

    switch ($userMenuChoice) {
            1 { Update-Unknown -direction "KnownToUnknown" }
            2 { Update-Unknown -direction "KnownToUnknown"}
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
    $direction    
    )
    $knownPet = Get-KnownPet
    $evalText = Get-EvalText
    $knowledge = Get-Knowledge $evalText
    if($knowledge -ne "certain"){
        Write-Host "Update-Unknown - WARNING - Comparison may not be certain!" -ForegroundColor Yellow
        }
    $textName = ($knownPet | Select-Object -Property Name).Name
    Write-Host "Update-Unknown: Using $textName as Known Pet" -ForegroundColor Yellow
    Get-Traits -evalText $evalText -direction $direction
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

Function Format-Vertical
{
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
    $lowOverall   = ($lowPet.Overall).ToString()
    $highOverall  = ($highPet.Overall).ToString()
    $rangeOverall = $lowOverall + " - " + $highOverall
    $reportPet.Add("Overall",$rangeOverall)
    $reportPet | Format-Table -HideTableHeaders
}

<# ######### END OF FUNCTIONS ########## Setting up vars  ########## #>

# Setting up hashtables for results, don't need all keys, will add as calculated
$lowPet = [ordered]@{Name="dummy"}
$highPet = [ordered]@{Name="dummy"}


# Syntax: passing a hash value with a number in quotes casts as string, without is int
$baseArray = @(
    [PSCustomObject]@{evalText="totally inferior";     low=-1700; high=-71}
    [PSCustomObject]@{evalText="very inferior";        low=-70;   high=-21}
    [PSCustomObject]@{evalText="inferior";             low=-20;   high=-10}
    [PSCustomObject]@{evalText="slightly inferior";    low=-9;    high=-5}
    [PSCustomObject]@{evalText="marginally inferior";  low=-4;    high=-2}
    [PSCustomObject]@{evalText="barely inferior";      low=-1;    high=-1}
    [PSCustomObject]@{evalText="similar";              low=0;     high=0}
    [PSCustomObject]@{evalText="barely better";        low=1;     high=1}
    [PSCustomObject]@{evalText="marginally better";    low=2;     high=4}
    [PSCustomObject]@{evalText="slightly better";      low=5;     high=9}
    [PSCustomObject]@{evalText="better";               low=10;    high=20}
    [PSCustomObject]@{evalText="much better";          low=21;    high=70}
    [PSCustomObject]@{evalText="outstandingly better"; low=71;    high=1700}
    )

$traits = @(
    'Alertness','Appetite','Brutality','Development','Eluding','Energy',
    'Evasion','Ferocity','Fortitude','Insight','Might','Nimbleness',
    'Patience','Procreation','Sufficiency','Targeting','Toughness'
    )

<#  Run through sequence and validate 
        Spreadsheet (uses Uknown to Known method)
    Unknown To Known sequence: Ballad - Cover - Mulapin - Crescendo - Exie = Angrynerd Solution
    Known to Unknown sequence: 
#>

Show-Menu