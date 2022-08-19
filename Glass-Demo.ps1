$verbosePreference = "Continue"
$lowPet = [ordered]@{Name="dummy"}
$highPet = [ordered]@{Name="dummy"}
$reportPet = [ordered]@{Name="dummy"}
$knownPet = @()
$petDB = @()
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


#-------------------------------------------------------------#
#----Initial Declarations-------------------------------------#
#-------------------------------------------------------------#

Add-Type -AssemblyName PresentationCore, PresentationFramework

$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Width="1000" Height="800">
<Grid Name="MasterGrid" Margin="0,0,0,0">

<Label VerticalAlignment="Top" VerticalContentAlignment="Center" HorizontalContentAlignment="Center" Content="Canine Comparator" Margin="0,0,0,0" Name="RightTopLabel" Height="39" Background="#473e72" Foreground="#e2eeed" FontFamily="Consolas" FontSize="26"/>
<StackPanel HorizontalAlignment="Left" Height="648" VerticalAlignment="Top" Width="182" Margin="0,41,0,0">
<Button Content="Load Database" HorizontalAlignment="Left" VerticalAlignment="Top" Width="155" Margin="10,12,0,0" Height="27" Name="LoadDbButton"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="165" Margin="5,15,0,0"/>
<TextBlock HorizontalAlignment="Left" VerticalAlignment="Top" TextWrapping="Wrap" Text="Select Mode" Height="24" Width="179" Margin="50,5,0,0"/>
<RadioButton HorizontalAlignment="Left" VerticalAlignment="Top" Content="Unknown To Known" Height="35" Width="179" Margin="10,2,0,0" Name="UtoKButton" IsChecked="True"/>
<RadioButton HorizontalAlignment="Left" VerticalAlignment="Top" Content="Known To Unknown" Height="32" Width="179" Margin="10,2,0,0" Name="KtoUButton"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="165" Margin="5,15,0,0"/>
<TextBlock HorizontalAlignment="Left" VerticalAlignment="Top" TextWrapping="Wrap" Text="Pick Known Character/Pet" Height="24" Width="179" Margin="20,5,0,0"/>
<ComboBox HorizontalAlignment="Left" VerticalAlignment="Top" Width="175" Name="CharSelect" Height="32" ItemsSource="{Binding internalJSON}" DisplayMemberPath="Name" Margin="5,5,0,0" VerticalContentAlignment="Bottom"/>
<Button Content="Process Comparison" HorizontalAlignment="Left" VerticalAlignment="Top" Width="155" Margin="10,12,0,0" Height="27" Name="ProcessCompButton"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="165" Margin="5,15,0,0"/>
<TextBox HorizontalAlignment="Left" VerticalAlignment="Top" Height="27" Width="155" TextWrapping="Wrap" Margin="10,12,0,0" Name="NameBox"/>
<Button Content="Set Name (Unique)" HorizontalAlignment="Left" VerticalAlignment="Top" Width="155" Margin="10,12,0,0" Height="27" Name="SetNameButton"/>
<Button Content="Export Result" HorizontalAlignment="Left" VerticalAlignment="Top" Width="155" Margin="10,12,0,0" Height="27" Name="ExportResultCompButton"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="165" Margin="5,15,0,0"/>
<Button Content="Reset Comparison" HorizontalAlignment="Left" VerticalAlignment="Top" Width="155" Margin="10,12,0,0" Height="27" Name="ResetButton"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="165" Margin="5,15,0,0"/>

</StackPanel>
<StackPanel HorizontalAlignment="Left" Height="435" VerticalAlignment="Top" Width="390" Margin="240,50,0,0">
<Label HorizontalAlignment="Left" VerticalAlignment="Top" VerticalContentAlignment="Center" HorizontalContentAlignment="Center" Content="Paste in comparison text below" Height="24" Width="388" Name="InputBoxLabel"/>
<TextBox HorizontalAlignment="Left" VerticalAlignment="Top" Height="405" Width="390" TextWrapping="Wrap" Name="InputBox" AcceptsReturn="True"/>
</StackPanel>
<DataGrid HorizontalAlignment="Left" VerticalAlignment="Top" Width="300" Height="435" Margin="642,75,0,0" AlternationCount="2" AlternatingRowBackground="Bisque" Name="ReportPetGrid" ItemsSource="{Binding emptyReportPet}"/>
<Label HorizontalAlignment="Left" VerticalAlignment="Bottom" Content="" Margin="1,0,0,30" Name="selectionIndicatorLabel" Width="190" Height="35" Background="#d4e2db" Foreground="#231955"/>
<Label HorizontalAlignment="Left" VerticalAlignment="Bottom" Content="Current Known shown above" Margin="2,0,0,0" Name="verifySelectionLabel"/>
<Border BorderBrush="Black" BorderThickness="1" HorizontalAlignment="Left" Height="32" VerticalAlignment="Top" Width="390" Margin="240,489,0,0" Name="DebugBorder">
<Button HorizontalAlignment="Left" VerticalAlignment="Top" Content="CLEAR DEBUG MESSAGES" VerticalContentAlignment="Center" HorizontalContentAlignment="Center" Margin="2,0,0,0" Name="DebugLabel" Width="388" Height="30" Background="#dcf03f" Foreground="#000000"/>
</Border>
<TextBox HorizontalAlignment="Left" VerticalAlignment="Top" TextWrapping="Wrap" Text="Latest Status Here" Margin="240,535,0,0" Width="390" Height="220" Name="DebugTextBox" HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Auto"/>
</Grid>
</Window>
"@

#-------------------------------------------------------------#
#----Control Event Handlers-----------------------------------#
#-------------------------------------------------------------#


#region Logic
#Write your code here
#endregion 
#region Set-Direction
Function Set-UtoK() {
    $Script:direction = "UnknownToKnown"
    Write-Status -Message "Setting Direction: $Script:direction"
}

Function Set-KtoU() {
    $Script:direction = "KnownToUnknown"
    Write-Status -Message "Setting Direction: $Script:direction"
}
#endregion 
#region Select from DB
Function Select-Known() {
    # Get the value currently in Combobox
    # Explode if combobox empty (actually, can I pop a warning? FANCY)
    # Look up value in DB
    # Store that Row as a var
    $selectedString = $CharSelect.Text
    if ($selectedString -eq ""){
        $selectedString = "Select from dropdown"
        $selectionIndicatorLabel.Content = $selectedString
        $InputBox.Text = ""
        Write-Status -Message "Select-Known: Picked String $selectedString"
    }
    $selectionIndicatorLabel.Content = $selectedString
    $InputBox.Text = ""
    if ($Script:petDB.Count -eq 0){
        Write-Verbose "Select-Known: internalDB not loaded - throwing user a message"
        Write-Status -Message "Select-Known: petDB not loaded - please load database"
    }
    else {
    $Script:knownPet = $Script:petDB | Where-Object -Property Name -eq $selectedString
    Write-Verbose "Select-Known: Picked from petDB $Script:knownPet"
    $tempStr = $Script:knownPet | Out-String
    Write-Status -Message "Select-Known: Picked object $tempStr"
    }
}

Function Read-Database(){
    # Stick a selector here to allow pick an external CSV
    # For now lets carry my known values in the script so I can build all functionality
    Write-Status -Message "Read-Database: Internal JSON loaded as petDB"
    $Script:petDB = $DataObject.internalJSON  # Produces the same array I got from Import-CSV 
    $Script:petDB = $Script:petDB | Where-Object -Property Status -eq "Active"
    $Script:petDB = $Script:petDB | Sort-Object -Property Name
    Write-Verbose "Read-Database: Using JSON from DataObject"
    Write-Verbose "Read-Database: BREAKPOINT - check data types"
    # Just like Import-CSV, my numerical values have come in as strings.  Cast them properly.
    $Script:petDB = $Script:petDB | ForEach-Object {
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
    $Script:petDB = $Script:petDB | Sort-Object -Property Name
}
#endregion 
#region Process Comparison Data
Function New-Comparison($reportPet) {
    # Ensure a direction is selected
    if ($Script:direction -notin "UnknownToKnown","KnownToUnknown"){
        Write-Verbose "New-Comparison: value in direction variable is not valid"
        Write-Status -Message "New-Comparison: Select a direction of comparison from radio buttons"
        return
    }
      Write-Verbose "New-Comparison: Checking direction as: $Script:direction"
      Write-Status -Message "New-Comparison: Direction indicator is $Script:direction"

    # Ensure a knownPet exists
    if ($knownPet.Count -eq 0){
        Write-Verbose "New-Comparison: No knownPet data - how do I popup?"
    }
    # Read the text from inputbox
    Get-EvalText

    # Check for knowledge level - Omitting
    # Get-Knowledge -evalText $Script:evalText

    # Generate lowPet, highPet
    Get-Traits -evalText $Script:evalText

    # Generate subtotals
    Get-Subtotal -lowPet $lowPet -highPet $highPet

    # Generate overall    
    Get-Overall -evalText $evalText -direction $direction

    # Throw a status message in the debugging window
    # Maybe some cool wacky button things someday
    Get-Status -lowPet $lowPet -highPet $highPet
    
    # Generate reportPet
    $Script:reportPet = New-ReportPet -lowPet $lowPet -highPet $highPet

    Write-Verbose "New-Comparison: BREAKPOINT - is reportPet populating correctly?"
    
    # Populate DataGrid somehow
    $ReportPetGrid.ItemsSource = $Script:reportPet
}

<#
Function Update-Unknown {
    Param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $direction,
    
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $sourceDBFile
    )

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
#>

function Get-EvalText() {
    $Script:evalText = $InputBox.Text
    # Split a giant chunk of string input into lines
    $Script:evalText = $evalText.Split([Environment]::NewLine, [System.StringSplitOptions]::RemoveEmptyEntries)
    if($Script:evalText.count -lt 5){
        Write-Verbose "Get-EvalText: evalText array of lines seems too short: $Script:evalText"
        Write-Status -Message "Get-EvalText: Not enough text in eval to continue, Dave should be smarter and write something that can handle 4-trait evals"
        return
    }
    Write-Verbose "Get-EvalText: reading InputBox content to be: $evalText"
}

function Get-Knowledge {
    param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $evalText
    )
    $knowledgePattern = "think","feel","certain"
    foreach($pattern in $knowledgePattern){
        Write-Verbose "Get-Knowledge: Checking $pattern"
        if($evalText -match $pattern){
            $knowledge = $pattern
            } else {
            $knowledge = "KNOWLEDGE level is missing"
            }
        }
}

Function Get-Traits {
    Param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $evalText
    )
    # Cycle through $traits and fill $lowPet $highPet as appropriate
    foreach($trait in $traits){
        $pattern = $trait
        Write-Verbose "Get-Traits: Looping through traits for $trait "
        # First, establish if the known pet has this trait at all - check for string UNSOLVED
        Write-Verbose "Get-Traits: knownPet is $knownPet.Name"
        $knownValue = $knownPet.$trait
        Write-Verbose "Get-Traits: KnownPet trait $trait is $knownValue "
        Write-Verbose "Get-Traits: Comparing in direction $direction"
        if($knownValue -eq "UNSOLVED"){
            Write-Verbose "Get-Traits: Known pet does not have value for $trait - skipping"
            Write-Message -Message "Get-Traits: Known pet does not have a value for $trait - skipping"
            return
        } else {

        #Strip down to get the comparison text
        $diffDesc = foreach ($str in $evalText){
            Select-String -InputObject $str -Pattern $pattern
            }
        # If text is from the listener's perspective, strip CharacterName says:
        $diffDesc = $diffDesc -replace '\w+ says: ',''

        $diffDesc = $diffDesc.ToString().TrimStart()           # Remove padding
        Write-Verbose "Get-Traits: working on string: $diffDesc"
        $diffDesc = $diffDesc -replace '(^(?:\S+\s+\n?){1,2})',''  # Remove 1st 2 words
        $diffDesc = $diffDesc.Replace('.','')

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
        Write-Verbose "Get-Traits: KnownToUnknown: $potentialLow is $knownValue - $traitHighModifier"
        Write-Verbose "Get-Traits: KnownToUnknown: $potentialHigh is $knownValue - $traitLowModifier"
        }
        elseif ($direction -notin "UnknownToKnown","KnownToUnknown"){
            Write-Verbose "Get-Traits: Something wrong in direction $direction - breaking" -ForegroundColor Yellow
            Write-Message "Get-Traits: KABOOM.  Script exploded because no direction selected.  Should never happen."
            break
        }
        # Get the current low and high estimates
        $currentLow = $lowPet.$trait
        $currentHigh = $highPet.$trait
        Write-Verbose "Get-Traits: checking lowPet: current estimate LOW for $trait is $currentLow"
        Write-Verbose "Get-Traits: Checking highPet: current estimate HIGH for $trait is $currentHigh"

        # LOW PET
        # Does the key exist?
        if($lowPet.Keys -notcontains $trait){
            Write-Verbose "Get-Traits: lowPet: Creating Key/Value $trait $potentialLow in lowPet"
            $lowPet.Add($trait,$potentialLow)
            }
        # Simplify the logic, spreadsheet does this: for an array of low ranges (20, 21, 22, 23) select the highest
        # so if $potentialLow > $currentLow, replace value
        elseif($potentialLow -gt $currentLow){
            Write-Verbose "Get-Traits: lowPet: UPDATING $trait : $potentialLow > $currentLow"
            $lowPet.$trait = $potentialLow
            }
        elseif($potentialLow -le $currentLow){
            Write-Verbose "Get-Traits: lowPet: NO ACTION : $potentialLow <= $currentLow"
            }

        # HIGH PET
        if($highPet.Keys -notcontains $trait){
            Write-Verbose "Get-Traits: highPet: Creating Key/Value $trait $potentialHigh in highPet"
            $highPet.Add($trait,$potentialHigh)
            }
        # Again, lets keep it simple. spreadsheet does this: for an array of high ranges (23, 24, 25, 26) pick the lowest
        elseif($potentialHigh -lt $currentHigh){
            Write-Verbose "Get-Traits: highPet: UPDATING $trait : $potentialHigh < $currentHigh"
            $highPet.$trait = $potentialHigh
            }
        elseif($potentialHigh -ge $currentHigh){
            Write-Verbose "Get-Traits: highPet: NO ACTION : $potentialHigh >= $currentHigh"
            }
        Write-Verbose "Get-Traits: FINISHED $trait"
        }
    }
    Write-Verbose "Get-Traits: BREAKPOINT - Evaulate status of lowPet and highPet"
    Write-Status -Message "Get-Traits: Completed comparison data"
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
    # Having completed updating lowPet and highPet, we need subtotals, calculate fresh each compare
    $subtotalLow = 0
    $subtotalHigh = 0
    foreach($trait in $traits){
# This might bug on trait missing?  Needs more testing
        $subtotalLow = $subtotalLow + $lowPet.$trait
        $subtotalHigh = $subtotalHigh + $highPet.$trait
    }
    # if $lowpet.keys -notcontains Subtotal add key/value
     if($lowPet.Keys -notcontains "Subtotal"){
        Write-Verbose "Get-Subtotal: SUBTOTAL LOW creating key/value Subtotal of $subtotalLow"
        $lowPet.Add("Subtotal",$subtotalLow)
        }
    else{
        Write-Verbose "Get-Subtotal: SUBTOTAL LOW - Updating key/value Subtotal to $subtotalLow"
        $lowPet.Subtotal = $subtotalLow
        }

    # if $highpet.keys -notcontains Subtotal add key/value
    if($highPet.Keys -notcontains "Subtotal"){
        Write-Verbose "Get-Subtotal: SUBTOTAL HIGH creating key/value Subtotal of $subtotalHigh"
        $highPet.Add("Subtotal",$subtotalHigh)
    }
    else{
        Write-Verbose "Get-Subtotal: SUBTOTAL HIGH updating key/value Subtotal to $subtotalHigh"
        $highPet.Subtotal = $subtotalHigh
    }
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
    # If text is from the listener's perspective, strip CharacterName says
    # e.g. Angrynerd says: Overall he seems to be totally inferior.
    $overallText = $overallText -replace '\w+ says: ',''

    $overallText = $overallText -replace '(^(?:\S+\s+\n?){1,5})','' # Remove 1st 5 words
    $overallText = $overallText.Replace(".","")

    # Turn comparison text into a number
    foreach($row in $baseArray){
        if($row.evalText -eq $overallText){
            $overallLowRange  = $row.low
            $overallHighRange = $row.high
            }
        }
    Write-Verbose "Get-Overall: modify low: $overallLowRange - modify high $overallHighRange"

    # Do the math, known.total + modifiers
    Write-Verbose "Get-Overall: knownPet TOTAL: $knownValue"
    if($direction -eq "UnknownToKnown"){
        Write-Verbose "Get-Overall: Direction UtoK, adding modifiers to known"
        $potentialOverallLowValue = $knownValue + $overallLowRange
        $potentialOverallHighValue = $knownValue + $overallHighRange
    }
    elseif($direction -eq "KnownToUnknown"){
        # Comparisons are reversed, so flip the positions
        Write-Verbose "Get-Overall: Direction KtoU, subtracting modifiers from known"
        $potentialOverallLowValue = $knownValue - $overallHighRange
        $potentialOverallHighValue = $knownValue - $overallLowRange
    }
    elseif($direction -notin "UnknownToKnown","KnownToUnknown"){
        Write-Verbose "Get-Overall: KABOOM - this should never happen. What's wrong with direction?"
        break
        }

    # Handling the Overall Low first

    # Get our current values for low and high
    $currentLowOverall  = $lowPet.$pattern
    $currentHighOverall = $highPet.$pattern

    # Do we need to add or change the value in key Overall?
    if($lowpet.keys -notcontains $pattern){
        Write-Verbose "Get-Overall: LOW PET - creating key/value for $pattern value $potentialOverallLowValue"
            $lowPet.Add($pattern,$potentialOverallLowValue)
        }
        # Reworking logic so it looks like Get-Traits.  For low range, select highest value
    elseif($potentialOverallLowValue -gt $currentLowOverall){
        Write-Verbose "Get-Overall: LOW PET - Updating $pattern from $currentLowOVerall to $potentialOverallLowValue"
            $lowpet.$pattern = $potentialOverallLowValue
        }
    elseif($potentialOverallLowValue -le $currentLowOverall){
        Write-Verbose "Get-Overall: LOW PET - no action, potential <= current"
        }

    # Handling the Overall High
    if($highpet.keys -notcontains $pattern){
        Write-Verbose "Get-Overall: HIGH PET - creating key/value for $pattern value $potentialOverallHighValue"
            $highPet.Add($pattern,$potentialOverallHighValue)
        }
        # For high range, select the lowest value you find
    elseif($potentialOverallHighValue -lt $currentHighOverall){  
        Write-Verbose "Get-Overall: HIGH PET - Updating $pattern from $currentHighOverall to $potentialOverallHighValue"
        $highpet.$pattern = $potentialOverallHighValue
    }
    elseif($potentialOverallHighValue -gt $currentHighOverall){
        Write-Verbose "Get-Overall: HIGH PET - no action, potential >= current"
        }
    }
    Write-Status -Message "Get-Overall: Finished processing"
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
        Write-Status -Message "Get-Status: WARNING: --- --- STATUS: No comparisons completed --- --- (this should never happen)"
        }
    $i = 0
    foreach($trait in $traits){
    if($lowPet.$trait -eq $highPet.$trait){
        $i=$i+1
        }
    }
    $total = $traits.Count
    Write-Verbose "Get-Status: Completed low/high comparison"
    Write-Status -Message "Get-Status: --- --- Solved $i of $total --- ---"
}

Function New-ReportPet {
    Param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $lowPet,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $highPet
    )
    
    if($lowPet.Keys.count -eq 1){
        Write-Status -Message "New-ReportPet: --- --- WARNING --- --- No Comparisons Completed (this should never happen)"
        return
    }    
    # build an output hashtable, if trait !=, [string]trait + "to" + [string]trait is newval
    Write-Verbose "New-ReportPet: Creating reportPet hashtable"
    $reportPet = [ordered]@{Name="dummy"}
    foreach($trait in $traits){
        if($lowPet.$trait -eq $highPet.$trait){
            $reportPet.$trait += $lowPet.$trait
            }
        elseif($lowPet.$trait -ne $highPet.$trait){
            $lowStr   = ($lowPet.$trait).ToString()
            $highStr  = ($highPet.$trait).ToString()
            $rangeStr = $lowStr + " to " + $highStr
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
    Write-Verbose "New-ReportPet: BREAKPOINT - is reportPet populating correctly?"
    Write-Status -Message "New-ReportPet: reportPet ready for viewing"
    return $reportPet
}

#endregion 
#region Update reportPet
Function Update-ReportPetName(){
    $Script:reportPet.Name = $NameBox.Text
    $ReportPetGrid.ItemsSource = $null
    $ReportPetGrid.ItemsSource = $Script:reportPet
    Write-Verbose "Update-ReportPetName: BREAKPOINT is script reportPetName changing?"
    Write-Status -Message "Update-ReportPetName: Changed NAME value in reportPet"
}

Function Reset-Result(){
    # Reset things back to on-load condition
    # lowPet and highPet are used to generate reportPet
    $lowPet = [ordered]@{Name="dummy"}
    $highPet = [ordered]@{Name="dummy"}
    $Script:reportPet = [ordered]@{Name="dummy"}
    $knownPet = @()
    $ReportPetGrid.ItemsSource = "{Binding emptyReportPet}"
    $InputBox.Text = ""
    Clear-DebugTextBox
}
#endregion 
#region DebugWindow
Function Write-Status($sender,$event,$message){
    $DebugTextBox.Text = $DebugTextBox.Text + "`n" + $message
}

Function Clear-DebugTextBox(){
    $DebugTextBox.Text = ""
}

Function Update-DebugTextBoxPosition(){
    $DebugTextBox.ScrollToEnd()
}
#endregion 


#-------------------------------------------------------------#
#----Script Execution-----------------------------------------#
#-------------------------------------------------------------#

$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }


$LoadDbButton.Add_Click({Read-Database $this $_})
$UtoKButton.Add_Checked({Set-UtoK $this $_})
$UtoKButton.Add_Initialized({Set-UtoK $this $_})
$KtoUButton.Add_Checked({Set-KtoU $this $_})
$CharSelect.Add_DropDownClosed({Select-Known $this $_})
$ProcessCompButton.Add_Click({New-Comparison $this $_})
$SetNameButton.Add_Click({Update-ReportPetName $this $_})
$ResetButton.Add_Click({Reset-Result $this $_})
$DebugLabel.Add_Click({Clear-DebugTextBox $this $_})
$DebugTextBox.Add_TextChanged({Update-DebugTextBoxPosition $this $_})

$State = [PSCustomObject]@{}


Function Set-Binding {
    Param($Target,$Property,$Index,$Name,$UpdateSourceTrigger)
 
    $Binding = New-Object System.Windows.Data.Binding
    $Binding.Path = "["+$Index+"]"
    $Binding.Mode = [System.Windows.Data.BindingMode]::TwoWay
    if($UpdateSourceTrigger -ne $null){$Binding.UpdateSourceTrigger = $UpdateSourceTrigger}


    [void]$Target.SetBinding($Property,$Binding)
}

function FillDataContext($props){

    For ($i=0; $i -lt $props.Length; $i++) {
   
   $prop = $props[$i]
   $DataContext.Add($DataObject."$prop")
   
    $getter = [scriptblock]::Create("Write-Output `$DataContext['$i'] -noenumerate")
    $setter = [scriptblock]::Create("param(`$val) return `$DataContext['$i']=`$val")
    $State | Add-Member -Name $prop -MemberType ScriptProperty -Value  $getter -SecondValue $setter
               
       }
   }



$DataObject =  ConvertFrom-Json @"

{
"emptyReportPet": [
    {"Key":"Name","Value":"No Comparisons Started"},
    {"Key":"Alertness","Value":"UNKNOWN"},
    {"Key":"Appetite","Value":"UNKNOWN"},
    {"Key":"Brutality","Value":"UNKNOWN"},
    {"Key":"Development","Value":"UNKNOWN"},
    {"Key":"Eluding","Value":"UNKNOWN"},
    {"Key":"Energy","Value":"UNKNOWN"},
    {"Key":"Evasion","Value":"UNKNOWN"},
    {"Key":"Ferocity","Value":"UNKNOWN"},
    {"Key":"Fortitude","Value":"UNKNOWN"},
    {"Key":"Insight","Value":"UNKNOWN"},
    {"Key":"Might","Value":"UNKNOWN"},
    {"Key":"Nimbleness","Value":"UNKNOWN"},
    {"Key":"Patience","Value":"UNKNOWN"},
    {"Key":"Procreation","Value":"UNKNOWN"},
    {"Key":"Sufficiency","Value":"UNKNOWN"},
    {"Key":"Targeting","Value":"UNKNOWN"},
    {"Key":"Toughness","Value":"UNKNOWN"},
	{"Key":"Subtotal","Value":"UNKNOWN"},
	{"Key":"Overall","Value":"UNKNOWN"}
],
"internalJSON":
[
    {
        "Name":  "An Untraited Canine",
        "Character":  "Anyone",
        "Gender":  "U",
        "Alertness":  "0",
        "Appetite":  "0",
        "Brutality":  "0",
        "Development":  "0",
        "Eluding":  "0",
        "Energy":  "0",
        "Evasion":  "0",
        "Ferocity":  "0",
        "Fortitude":  "0",
        "Insight":  "0",
        "Might":  "0",
        "Nimbleness":  "0",
        "Patience":  "0",
        "Procreation":  "0",
        "Sufficiency":  "0",
        "Targeting":  "0",
        "Toughness":  "0",
        "TOTAL":  "0",
        "Person":  "Anyone",
        "Status":  "Active"
    },
    {
        "Name":  "Mulapin Ringo 733/54",
        "Character":  "Mulapin",
        "Gender":  "M",
        "Alertness":  "30",
        "Appetite":  "48",
        "Brutality":  "26",
        "Development":  "36",
        "Eluding":  "52",
        "Energy":  "37",
        "Evasion":  "59",
        "Ferocity":  "55",
        "Fortitude":  "47",
        "Insight":  "36",
        "Might":  "47",
        "Nimbleness":  "54",
        "Patience":  "34",
        "Procreation":  "54",
        "Sufficiency":  "37",
        "Targeting":  "38",
        "Toughness":  "43",
        "TOTAL":  "733",
        "Person":  "Dave",
        "Status":  "Active"
    },
    {
        "Name":  "Lullaby Sandman 722/57",
        "Character":  "Lullaby",
        "Gender":  "M",
        "Alertness":  "30",
        "Appetite":  "46",
        "Brutality":  "27",
        "Development":  "38",
        "Eluding":  "50",
        "Energy":  "29",
        "Evasion":  "56",
        "Ferocity":  "57",
        "Fortitude":  "45",
        "Insight":  "39",
        "Might":  "46",
        "Nimbleness":  "57",
        "Patience":  "32",
        "Procreation":  "57",
        "Sufficiency":  "31",
        "Targeting":  "41",
        "Toughness":  "41",
        "TOTAL":  "722",
        "Person":  "Dave",
        "Status":  "Active"
    },
    {
        "Name":  "Grazioso Hoover 718/54",
        "Character":  "Grazioso",
        "Gender":  "M",
        "Alertness":  "24",
        "Appetite":  "47",
        "Brutality":  "28",
        "Development":  "39",
        "Eluding":  "54",
        "Energy":  "35",
        "Evasion":  "58",
        "Ferocity":  "54",
        "Fortitude":  "45",
        "Insight":  "35",
        "Might":  "46",
        "Nimbleness":  "52",
        "Patience":  "34",
        "Procreation":  "54",
        "Sufficiency":  "29",
        "Targeting":  "40",
        "Toughness":  "44",
        "TOTAL":  "718",
        "Person":  "Dave",
        "Status":  "Active"
    },
    {
        "Name":  "Exie Shaker 694/53",
        "Character":  "Exie",
        "Gender":  "M",
        "Alertness":  "22",
        "Appetite":  "47",
        "Brutality":  "30",
        "Development":  "43",
        "Eluding":  "48",
        "Energy":  "33",
        "Evasion":  "55",
        "Ferocity":  "44",
        "Fortitude":  "46",
        "Insight":  "39",
        "Might":  "40",
        "Nimbleness":  "55",
        "Patience":  "29",
        "Procreation":  "53",
        "Sufficiency":  "30",
        "Targeting":  "38",
        "Toughness":  "42",
        "TOTAL":  "694",
        "Person":  "Dave",
        "Status":  "Active"
    },
    {
        "Name":  "Dirge Fluid 692/57",
        "Character":  "Dirge",
        "Gender":  "F",
        "Alertness":  "26",
        "Appetite":  "50",
        "Brutality":  "25",
        "Development":  "41",
        "Eluding":  "51",
        "Energy":  "29",
        "Evasion":  "53",
        "Ferocity":  "52",
        "Fortitude":  "39",
        "Insight":  "39",
        "Might":  "43",
        "Nimbleness":  "51",
        "Patience":  "31",
        "Procreation":  "57",
        "Sufficiency":  "29",
        "Targeting":  "33",
        "Toughness":  "43",
        "TOTAL":  "692",
        "Person":  "Dave",
        "Status":  "Active"
    },
    {
        "Name":  "Crescendo Eddie 698/51",
        "Character":  "Crescendo",
        "Gender":  "M",
        "Alertness":  "29",
        "Appetite":  "51",
        "Brutality":  "31",
        "Development":  "34",
        "Eluding":  "49",
        "Energy":  "31",
        "Evasion":  "55",
        "Ferocity":  "46",
        "Fortitude":  "45",
        "Insight":  "32",
        "Might":  "44",
        "Nimbleness":  "54",
        "Patience":  "34",
        "Procreation":  "51",
        "Sufficiency":  "32",
        "Targeting":  "39",
        "Toughness":  "41",
        "TOTAL":  "698",
        "Person":  "Dave",
        "Status":  "Active"
    },
    {
        "Name":  "Cover Rocker 714/60",
        "Character":  "Cover",
        "Gender":  "M",
        "Alertness":  "29",
        "Appetite":  "49",
        "Brutality":  "26",
        "Development":  "40",
        "Eluding":  "53",
        "Energy":  "33",
        "Evasion":  "52",
        "Ferocity":  "55",
        "Fortitude":  "46",
        "Insight":  "35",
        "Might":  "40",
        "Nimbleness":  "50",
        "Patience":  "35",
        "Procreation":  "60",
        "Sufficiency":  "30",
        "Targeting":  "37",
        "Toughness":  "44",
        "TOTAL":  "714",
        "Person":  "Dave",
        "Status":  "Active"
    },
    {
        "Name":  "Ballad Fireball 730/55",
        "Character":  "Ballad",
        "Gender":  "M",
        "Alertness":  "26",
        "Appetite":  "47",
        "Brutality":  "32",
        "Development":  "41",
        "Eluding":  "51",
        "Energy":  "31",
        "Evasion":  "53",
        "Ferocity":  "53",
        "Fortitude":  "43",
        "Insight":  "39",
        "Might":  "47",
        "Nimbleness":  "52",
        "Patience":  "37",
        "Procreation":  "55",
        "Sufficiency":  "36",
        "Targeting":  "39",
        "Toughness":  "48",
        "TOTAL":  "730",
        "Person":  "Dave",
        "Status":  "Active"
    },
    {
        "Name":  "Mulapin Gringo 709/53",
        "Character":  "Mulapin",
        "Gender":  "M",
        "Alertness":  "24",
        "Appetite":  "45",
        "Brutality":  "27",
        "Development":  "36",
        "Eluding":  "56",
        "Energy":  "35",
        "Evasion":  "59",
        "Ferocity":  "52",
        "Fortitude":  "47",
        "Insight":  "34",
        "Might":  "45",
        "Nimbleness":  "49",
        "Patience":  "36",
        "Procreation":  "53",
        "Sufficiency":  "30",
        "Targeting":  "35",
        "Toughness":  "46",
        "TOTAL":  "709",
        "Person":  "Dave",
        "Status":  "Inactive"
    },
    {
        "Name":  "Guest Puppeh",
        "Character":  "Guest",
        "Gender":  "U",
        "Alertness":  "1",
        "Appetite":  "2",
        "Brutality":  "3",
        "Development":  "4",
        "Eluding":  "5",
        "Energy":  "6",
        "Evasion":  "7",
        "Ferocity":  "8",
        "Fortitude":  "9",
        "Insight":  "10",
        "Might":  "11",
        "Nimbleness":  "12",
        "Patience":  "13",
        "Procreation":  "14",
        "Sufficiency":  "15",
        "Targeting":  "16",
        "Toughness":  "0-1",
        "TOTAL":  "136-137",
        "Person":  "Anyone",
        "Status":  "Active"
    }
]

}

"@

$DataContext = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
FillDataContext @("emptyReportPet","internalJSON") 

$Window.DataContext = $DataContext
Set-Binding -Target $CharSelect -Property $([System.Windows.Controls.ComboBox]::ItemsSourceProperty) -Index 1 -Name "internalJSON"  
Set-Binding -Target $ReportPetGrid -Property $([System.Windows.Controls.DataGrid]::ItemsSourceProperty) -Index 0 -Name "emptyReportPet"  
$Window.ShowDialog()