<# Stat-Canine.ps1

Develops a set of functions useful in evaluating a canine

#>
Function Read-Database {
    Param()
    # The default behaviour of Import-CSV to import everything as strings
    # Cast the integers!
    $petDB = Import-CSV -Path .\KNOWNS.csv
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
    # Ok prompt for some text, we need an input box
    $message = "Please enter a CERTAIN eval, KNOWN to UNKNOWN"
    $windowTitle = "Compare Known to Unknown"
    $defaultText = "Enter some text here..."
    $evalText = Read-MultiLineInputBoxDialog -Message $message -WindowTitle $windowTitle -DefaultText $defaultText
    if ($null -eq $evalText) { Write-Host "You clicked Cancel - ending script";break }
    else { 
        # Don't do anything
        # Write-Host "You entered the following text: $multiLineText" 
        }
    $evalText = $evalText.Split([Environment]::NewLine, [System.StringSplitOptions]::RemoveEmptyEntries)
    return $evalText
}

function Get-Knowledge {
    param(
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
    $evalText = Get-EvalText
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
        $evalText
    )
    # Cycle through $traits and fill $lowPet $highPet as appropriate
    foreach($trait in $traits){
        # DO STUFF
        $pattern = $trait
        Write-Host "Get-Traits is looking for $trait"

        #Strip down to get the comparison text
        $diffDesc = foreach ($str in $evalText){               # Difference Description
            Select-String -InputObject $str -Pattern $pattern
            }
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
        $potentialLow  = $knownValue + $traitLowModifier
        $potentialHigh = $knownValue + $traitHighModifier

        $currentLow  = $lowPet.$trait
        $currentHigh = $highPet.$trait

        # LOW PET
        # Create / Modify value for this key
        # Does the key exist?
        if($lowPet.Keys -notcontains $trait){
            Write-Host "Get-Traits creating key/value $trait $potentialLow in lowPet"
            $lowPet.Add($trait,$potentialLow)
            }
        elseif($currentLow -lt $potentialLow){
            Write-Host "Get-Traits $currentLow < $potentialLow : UPDATING"
            $lowPet.$trait = $potentialLow
            }
        elseif($currentLow -ge $potentialLow){
            Write-Host "Get-Traits $currentLow >= $potentialLow : NO ACTION"
            }

        # HIGH PET
        if($highPet.Keys -notcontains $trait){
            Write-Host "Get-Traits creating key/value $trait $potentialHigh in highPet"
            $highPet.Add($trait,$potentialHigh)
            }
        elseif($currentHigh -gt $potentialHigh){
            Write-Host "Get-Traits $currentHigh > $potentialHigh : UPDATING"
            $highPet.$trait = $potentialHigh
            }
        elseif($currentHigh -le $potentialHigh){
            Write-Host "Get-Traits $currentHigh <= $potentialHigh : NO ACTION"
            }

    }
    return
}


Function Get-Overall {
    Param(
    $evalText
    )
    # In testing through this might make everything a lot cleaner to do traits this way
    # Get the comparison text
    $pattern = "Overall"         # Made it a var since I'll use it for key later
    $overallText = foreach ($str in $evalText){
        Select-String -InputObject $str -Pattern $pattern
        }
    $overallText = $overallText.ToString()
    $overallText = $overallText -replace '(^(?:\S+\s+\n?){1,5})','' # Remove 1st 5 words
    $overallText = $overallText.Replace(".","")
    # DEBUG:    Write-Host "Get-Overall found the Overall to be: $overallText"

    # Turn comparison text into a number
    foreach($row in $baseArray){
        if($row.evalText -eq $overallText){
            $overallLowRange  = $row.low
            $overallHighRange = $row.high
            }
        }
    # DEBUG:    Write-Host "Get-Overall found modifiers low: $overallLowRange - high: $overallHighRange"

    # Do the math, known.total + modifiers
    $knownValue = $knownPet.TOTAL
    # DEBUG:    Write-Host "Get-Overall found knownpet TOTAL: $knownValue"
    $potentialOverallLowValue = $knownValue + $overallLowRange
    $potentialOverallHighValue = $knownValue + $overallHighRange

    # Handling the Overall Low first
    # DEBUG:    Write-Host "Get-Overall calculated Overall Low: $overallLowValue High: $overallHighValue"

    # Get our current values for low and high
    $currentLowOverall  = $lowPet.$pattern
    $currentHighOverall = $highPet.$pattern
    # DEBUG:    Write-Host "Get-Overall current Low Overall is $currentLowOverall"
    # DEBUG:    Write-Host "Get-Overall current High Overall is $currentHighOverall"

    # Do we need to add or change the value in key Overall?
    if($lowpet.keys -notcontains $pattern){
        # DEBUG:    Write-Host "Get-Overall creating key for lowPet $pattern value $potentialOverallLowValue" 
        $lowPet.Add($pattern,$potentialOverallLowValue)
    }
    elseif($currentLowOverall -lt $potentialOverallLowValue){  
        # The low range should continue to 'rise' as we refine
        # Since our current overall low < than calculated low, update!
        # DEBUG:    Write-Host "Get-Overall updating lowpet $pattern value from $currentLowOverall to $potentialOverallLowValue"
        $lowpet.$pattern = $potentialOverallLowValue
    }
    elseif($currentLowOverall -ge $potentialLowOverall){
        # current overall low  >= potential overall low, discard this (Don't do anything)
        # DEBUG:    Write-Host "Get-Overall - no action: $currentLowOverall is greater or equal to $potentialOverallLowValue"
    }

    # Handle the Overall High
    # DEBUG: 
    # Get our current values for low and high
    # DEBUG:    Write-Host "Get-Overall current High Overall is $currentHighOverall"

    # Do we need to add or change the value in key Overall?
    if($highpet.keys -notcontains $pattern){
        # DEBUG:   Write-Host "Get-Overall creating key for highPet $pattern value $potentialOverallHighValue" 
        $highPet.Add($pattern,$potentialOverallHighValue)
    }
    elseif($currentHighOverall -gt $potentialOverallHighValue){  
        # The high range should continue to 'sink' as we refine
        # Since our current overall high > calculated low, update!
        # DEBUG:    Write-Host "Get-Overall updating highpet $pattern value from $currentHighOverall to $potentialOverallHighValue"
        $highpet.$pattern = $potentialOverallHighValue
    }
    elseif($currentHighOverall -le $potentialHighOverall){
        # current overall low  <= potential overall low, discard this (Don't do anything)
    # DEBUG:    Write-Host "Get-Overall - no action: $currentHighOverall is less than or equal to $potentialOverallHighValue"
    }

}


Function Get-KnownPet{
    param()     # No params, we're going to start by asking who you compared to
    # Develop picker-code
    $petDB = Read-Database
    $validChoices = 0..($petDB.Count -1)
    $choice = ''
    while ([string]::IsNullOrEmpty($choice)){
        #thing
        foreach ($line in $petDB){
            #another thing
            Write-Host ('{0} - {1} - {2}' -f $petDB.IndexOf($line),$line.Person,$line.Name)
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


function Read-MultiLineInputBoxDialog([string]$Message, [string]$WindowTitle, [string]$DefaultText)
    {
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
        $lowPet,
        $highPet
        )
    $i = 0
    foreach($trait in $traits){
    if($lowPet.$trait -eq $highPet.$trait){
        $i=$i+1
        }
    }
    $total = $traits.Count
    $lowOverall  = ($lowPet.Overall  | Out-String).Replace("`n","") # force to string
    $highOverall = ($highPet.Overall | Out-String).Replace("`n","") # remove newline in string
    
    Write-Host "STATUS: Solved $i of $total"
    Write-Output "Unknown Pet OVERALL is between $lowOverall and $highOverall"
    if($i -eq $total){$solved = $true}
    else{$solved = $false}
    return $solved
}

Function Get-Response {
    Param(
        $solved,
        $lowPet,
        $highPet
        )
    # Do Stuff
    Write-Host "Build a menuing system here:"
    Write-Host "[C]ontinue process (call Update-Unknown)"
    Write-Host "[R]eport columnar data where x axis is low,high, y axis is properties [ordered]"
    Write-Host "[E]xport prep, csv-style data where x axis is properties [complicated, unsolved must switch to str]"
    Write-Host "[Q]uit this application"
    Write-Host "STRETCH GOAL"
    Write-Host "[I]nsert this pet into database (prompt for fields to fill in for real name/owner/whatnet) and updatecsv"
}

Function Update-Unknown {
    Param()
    $knownPet = Get-KnownPet
    $evalText = Get-EvalText
    $knowledge = Get-Knowledge $evalText
    if($knowledge -ne "certain"){Write-Host "Comparison not certain, breaking run!";break}
    Get-Traits -evalText $evalText
    Get-Overall -evalText $evalText
    Get-Status $lowPet $highPet
    Get-Response $solved $lowPet $highPet
}


<#

Transform HashTable to Horizontal Array
[PSCustomObject]$highPet | Export-Csv -NoTypeInformation -Path .\highPet.csv
[PSCustomObject]$lowpet  | Export-Csv -NoTypeInformation -Path .\lowPet.csv

#>

Function Format-VerticalReport {
    Param(
        $lowPet,
        $highPet
    )
    # build an output hashtable, if trait !=, [string]trait + [string]trait is newval
    $reportPet = [ordered]@{Name="dummy"}
    foreach($trait in $traits){
        if($lowPet.$trait -eq $highPet.$trait){
            # DEBUG: 
            Write-Host "Format-VerticalReport creating key for $trait value $lowpet.$trait"
            $reportPet.$trait += $lowPet.$trait
            }
        else{

        }
    return            
    }
}


########## END OF FUNCTIONS ##########
########## Setting up vars  #########

# Setting up hashtables for results, don't need all keys, will add as calculated
$lowPet = [ordered]@{    
        Name        ="dummy"
        }

$highPet = [ordered]@{
        Name        ="dummy"
        }


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


<#
        Build your program here
  Run through sequence and validate against spreadsheet
  Ballad - Cover - Mulapin - Crescendo - Exie = Angrynerd Solution

#>




$knownPet = Get-KnownPet
$evalText = Get-EvalText
$knowledge = Get-Knowledge $evalText

if($knowledge -ne "certain"){
    Write-Host "Comparison not certain, breaking run!";break
    }

Get-Traits -evalText $evalText
Get-Overall -evalText $evalText
Get-Status $lowPet $highPet
Get-Response $solved $lowPet $highPet

<#

$knownPet = Get-KnownPet
$evalText = Get-EvalText
$knowledge = Get-Knowledge $evalText

if($knowledge -ne "certain"){
    Write-Host "Comparison not certain, breaking run!";break
    }
    else{
    Write-Host "Yup, good eval"
    }


Update-LowPet -evalText $evalText
Update-HighPet -evalText $evalText

#>

## TESTING
