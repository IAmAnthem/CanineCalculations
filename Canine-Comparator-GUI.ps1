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
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Width="1210" Height="950" Title="Canine Comparator" WindowStartupLocation="CenterScreen" Name="MyWindow">
<Grid Name="MasterGrid" Margin="0,0,0,0">

<Label VerticalAlignment="Top" VerticalContentAlignment="Center" HorizontalContentAlignment="Center" Content="Canine Comparator" Margin="0,0,0,0" Name="RightTopLabel" Height="39" Background="#473e72" Foreground="#e2eeed" FontFamily="Consolas" FontSize="26"/>
<StackPanel HorizontalAlignment="Left" Height="730" VerticalAlignment="Top" Width="230" Margin="0,41,0,0">
<Button Content="Load Database" HorizontalAlignment="Left" VerticalAlignment="Top" Width="210" Margin="8,12,0,0" Height="27" Name="LoadDbButton" Background="#7ed321" Foreground="#000000"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="216" Margin="5,15,0,0"/>
<TextBlock HorizontalAlignment="Left" VerticalAlignment="Top" TextWrapping="Wrap" Text="Select Mode" Height="24" Width="179" Margin="60,5,0,0"/>
<RadioButton HorizontalAlignment="Left" VerticalAlignment="Top" Content="Unknown To Known" Height="35" Width="179" Margin="25,0,0,0" Name="UtoKButton" IsChecked="True"/>
<RadioButton HorizontalAlignment="Left" VerticalAlignment="Top" Content="Known To Unknown" Height="32" Width="179" Margin="25,0,0,0" Name="KtoUButton"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="216" Margin="5,15,0,0"/>
<TextBlock HorizontalAlignment="Left" VerticalAlignment="Top" TextWrapping="Wrap" Text="Pick Known Character/Pet" Height="24" Width="179" Margin="35,5,0,0"/>
<ComboBox HorizontalAlignment="Left" VerticalAlignment="Top" Width="210" Name="CharSelect" Height="32" ItemsSource="{Binding internalJSON}" DisplayMemberPath="Name" Margin="8,12,0,0" VerticalContentAlignment="Bottom" Background="LimeGreen"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="216" Margin="5,15,0,0"/>
<TextBox HorizontalAlignment="Left" VerticalAlignment="Top" Height="27" Width="210" TextWrapping="Wrap" Margin="8,12,0,0" Name="NameBox"/>
<Button Content="Set Name (Unique)" HorizontalAlignment="Left" VerticalAlignment="Top" Width="210" Margin="8,12,0,0" Height="27" Name="SetNameButton" Background="Gold"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="216" Margin="5,15,0,0"/>
<Button Content="Export Result Table" HorizontalAlignment="Left" VerticalAlignment="Top" Width="210" Margin="8,12,0,0" Height="27" Name="ExportTableButton" Opacity="0.5"/>
<Button Content="Export Result CSV" HorizontalAlignment="Left" VerticalAlignment="Top" Width="210" Margin="8,12,0,0" Height="27" Name="ExportCSVButton" Opacity="0.5"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="216" Margin="5,15,0,0"/>
<Button Content="Reset Comparison" HorizontalAlignment="Left" VerticalAlignment="Top" Width="210" Margin="8,12,0,0" Height="27" Name="ResetButton" Background="#4a90e2"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="216" Margin="5,15,0,0"/>
</StackPanel>
<StackPanel HorizontalAlignment="Left" Height="730" VerticalAlignment="Top" Width="437" Margin="240,51,0,0">
<Label HorizontalAlignment="Left" VerticalAlignment="Top" VerticalContentAlignment="Center" HorizontalContentAlignment="Center" Content="Paste in comparison text below" Height="24" Width="388" Name="InputBoxLabel"/>
<TextBox HorizontalAlignment="Left" VerticalAlignment="Top" Height="413" Width="430" TextWrapping="Wrap" Name="InputBox" AcceptsReturn="True"/>
<Button Content="Process Comparison" HorizontalAlignment="Left" VerticalAlignment="Top" Width="430" Margin="0,5,0,0" Height="27" Name="ProcessCompButton" Background="LimeGreen" BorderThickness="2,2,2,2"/>
<TextBox HorizontalAlignment="Left" VerticalAlignment="Top" TextWrapping="Wrap" Text="Latest Status Here" Margin="0,10,0,0" Width="430" Height="195" Name="DebugTextBox" HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Auto"/>
</StackPanel>
<StackPanel HorizontalAlignment="Left" Height="730" VerticalAlignment="Top" Width="437" Margin="679,51,0,0">
<DataGrid HorizontalAlignment="Left" VerticalAlignment="Top" Width="300" Height="413" Margin="5,25,0,0" AlternationCount="2" AlternatingRowBackground="Bisque" Name="ReportPetGrid" ItemsSource="{Binding emptyReportPet}" ColumnWidth="Auto"/>
<ProgressBar HorizontalAlignment="Left" Height="27" VerticalAlignment="Top" Width="300" Margin="5,5,0,0" Name="StatusBar" IsIndeterminate="False" ToolTip="Progress Meter" Background="Red" Value="0" BorderThickness="2,2,2,2"/>
<Button HorizontalAlignment="Left" VerticalAlignment="Top" Content="CLEAR DEBUG MESSAGES" VerticalContentAlignment="Center" HorizontalContentAlignment="Center" Margin="5,10,0,0" Name="DebugLabel" Width="150" Height="190" BorderThickness="2,2,2,2" Background="Yellow" Foreground="Black"/>
</StackPanel>
<DataGrid HorizontalAlignment="Left" VerticalAlignment="Bottom" Width="1184" Height="65" Margin="5,0,0,7" Name="CSVGrid"/>
</Grid>
</Window>
"@

#-------------------------------------------------------------#
#----Control Event Handlers-----------------------------------#
#-------------------------------------------------------------#


#region Logic

#endregion 
#region Set-Direction
Function Set-UtoK() {
    $Script:direction = "UnknownToKnown"
    Write-Status -Message "Setting Direction: $direction"
    $UtoKButton.IsChecked=($true)
    $KtoUButton.IsChecked=($false)
    
}

Function Set-KtoU() {
    $Script:direction = "KnownToUnknown"
    Write-Status -Message "Setting Direction: $Script:direction"
    $UtoKButton.IsChecked=($false)
    $KtoUButton.IsChecked=($true)
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
        $InputBox.Text = ""
        Write-Status -Message "Select-Known: Picked String $selectedString"
    }
    $InputBox.Text = ""
    if ($Script:petDB.Count -eq 0){
        Write-Verbose "Select-Known: internalDB not loaded - throwing user a message"
        Write-Status -Message "Select-Known: petDB not loaded - please load database"
    }
    else {
    $Script:knownPet = $Script:petDB | Where-Object -Property Name -eq $selectedString
    Write-Verbose "Select-Known: Picked from petDB $Script:knownPet"
    Write-Status -Message "Select-Known: Picked from petDB $selectedString"
    }
}

Function Read-Database(){
    # Stick a selector here to allow pick an external CSV
    # For now lets carry my known values in the script so I can build all functionality
    Write-Status -Message "Read-Database: Reading Internal JSON loaded as petDB"
    $Script:petDB = $DataObject.internalJSON  # Produces the same array I got from Import-CSV 
    $Script:petDB = $Script:petDB | Where-Object -Property Status -eq "Active"
    $Script:petDB = $Script:petDB | Sort-Object -Property Name
    Write-Verbose "Read-Database: Using JSON from DataObject"
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

function File-Picker(){
    $csvFilePath = New-WPFOpenFileDialog -WindowsTitle 'CSV Selector' -Path '$MyInvocation.MyCommand.Path' -Filter "CSV files (*.csv)|*.csv|All files (*.*)|*.*"
    Write-Status -Message "File-Picker: selected $csvFilePath"
    Read-CSVFile $csvFilePath
    # Change the InputsSource on the file picker
    $CharSelect.ItemsSource = $Script:petDB
    $CharSelect.DisplayMemberPath = "Name"
}

function New-WPFOpenFileDialog {
<#
    .SYNOPSIS
        The New-WFOpenFileDialog function will ask the user to select one of multiple files.
        The function will return the literal path of the file(s) selected
     
    .DESCRIPTION
        The New-WFOpenFileDialog function will ask the user to select one of multiple files.
        The function will return the literal path of the file(s) selected
     
    .PARAMETER WindowsTitle
        Specifies the Title of the window.
     
    .PARAMETER Path
        Specifies the Path where the dialog will open.
     
    .PARAMETER Filter
        Specifies the extension filter.Default is "All files (*.*)|*.*"
            Other example:
                "Text files (*.txt)|*.txt|All files (*.*)|*.*";
                "Photos files (*.jpg)|*.png|All files (*.*)|*.*";
                         
    .PARAMETER AllowMultiSelect
        Allow the user to select multiple files.
     
    .EXAMPLE
        PS C:\> New-WPFOpenFileDialog -WindowsTitle 'Upload' -Path 'c:\"
     
    .NOTES
        Author: Francois-Xavier Cat
        Twitter:@LazyWinAdm
        www.lazywinadmin.com
        github.com/lazywinadmin
#>
    
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias('Title')]
        [String]$WindowsTitle,
        
        [Parameter(Mandatory = $true)]
        [String]$Path,
        
        [String]$Filter = "All files (*.*)|*.*",
        
        [switch]$AllowMultiSelect
    )
    
    BEGIN
    {
        Add-Type -AssemblyName System.Windows.Forms
    }
    PROCESS
    {
        
        # Create Object and add properties
        $OpenFileDialog = New-Object -TypeName System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.InitialDirectory = $Path
        $OpenFileDialog.CheckPathExists = $true
        $OpenFileDialog.CheckFileExists = $true
        $OpenFileDialog.Title = $WindowTitle
        
        IF ($PSBoundParameters["Filter"]) { $OpenFileDialog.Filter = $Filter }
        IF ($PSBoundParameters["AllowMultiSelect"]) { $OpenFileDialog.MultiSelect = $true }
        
        IF ($PSCmdlet.ShouldProcess('OpenFileDialog','Will prompt to select a file'))
        {
            # Show the Dialog
            $OpenFileDialog.ShowHelp = $True
            [void]$OpenFileDialog.ShowDialog()
        }
    }
    END
    {
        # Return the selected file
        IF ($PSBoundParameters["AllowMultiSelect"]) { $OpenFileDialog.Filenames }
        
        # Return the selected files
        IF (-not $PSBoundParameters["AllowMultiSelect"]) { $OpenFileDialog.Filename }
    }
}

function Read-CSVFile($csvFilePath){
    Write-Status -Message "Read-CSVFile: trying Import-CSV"
    $Script:petDB = Import-CSV -Path $csvFilePath
    $Script:petDB = $Script:petDB | Where-Object -Property Status -eq "Active"
    $Script:petDB = $Script:petDB | Sort-Object -Property Name
    # Import-CSV brings in NoteProperty as string.  Cast as needed.
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
    Write-Status -Message "Read-CSVFile: petDB loaded, populating dropdown selector"
}

#endregion 
#region Process Comparison Data
function New-Comparison($reportPet) {
    # Ensure a direction is selected
    if ($Script:direction -notin "UnknownToKnown","KnownToUnknown"){
        Write-Status -Message "New-Comparison: Select a direction of comparison from radio buttons"
        return
    }
      Write-Status -Message "New-Comparison: Direction indicator is $Script:direction"

    # Ensure a knownPet exists
    if ($knownPet.Count -eq 0){
        Write-Status -Message "New-Comparison: No knownPet selected"
        return
    }
    # Read the text from inputbox
    $Script:evalText = Get-EvalText
    if($Script:evalText.count -lt 5){
        Write-Status -Message "Get-EvalText: Not enough lines from inputBox to continue"
        return
    }
    
    # Generate lowPet, highPet
    Get-Traits -evalText $Script:evalText

    # Generate subtotals
    Get-Subtotal -lowPet $lowPet -highPet $highPet

    # Generate overall    
    Get-Overall -evalText $evalText -direction $direction

    # Throw a status message in the debugging window
    # Maybe some cool wacky button things someday
    Get-Status -lowPet $lowPet -highPet $highPet
    
    # Generate reportPet hashtable
    $Script:reportPet = New-ReportPet -lowPet $lowPet -highPet $highPet
    
    # Transform reportPet Hashtable to an Object with Properties because not Enumerable
    [array]$Script:reportPetCSV = Format-CSVrow -hashtable $script:reportPet

    # Populate vertical DataGrid
    $ReportPetGrid.ItemsSource = $Script:reportPet
    
    # Populate horizontal data grid
    $CSVGrid.ItemsSource = $Script:reportPetCSV
}

function Get-EvalText() {
    $tmp = $InputBox.Text
    # Split a giant chunk of string input into lines
    $tmp = $tmp.Split([Environment]::NewLine, [System.StringSplitOptions]::RemoveEmptyEntries)
    Write-Status "Get-EvalText: loaded text from input box"
    return $tmp
}

function Get-Traits {
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
     if($lowPet.Keys -notcontains "TOTAL"){
        Write-Verbose "Get-Subtotal: SUBTOTAL LOW creating key/value Subtotal of $subtotalLow"
        $lowPet.Add("TOTAL",$subtotalLow)
        }
    else{
        Write-Verbose "Get-Subtotal: SUBTOTAL LOW - Updating key/value Subtotal to $subtotalLow"
        $lowPet.TOTAL = $subtotalLow
        }

    # if $highpet.keys -notcontains Subtotal add key/value
    if($highPet.Keys -notcontains "TOTAL"){
        Write-Verbose "Get-Subtotal: SUBTOTAL HIGH creating key/value Subtotal of $subtotalHigh"
        $highPet.Add("TOTAL",$subtotalHigh)
    }
    else{
        Write-Verbose "Get-Subtotal: SUBTOTAL HIGH updating key/value Subtotal to $subtotalHigh"
        $highPet.TOTAL = $subtotalHigh
    }
}

function Get-Overall {
    param(
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

function Get-Status {
    param(
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
    Write-Status -Message "Get-Status: Updating Progress Bar"
    $StatusBar.Value = ($i / $total)*100
}

function New-ReportPet {
    param(
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

    $subtotalLow  = ($lowPet.TOTAL).ToString()
    $subtotalHigh = ($highPet.TOTAL).ToString()
    if($subtotalLow -eq $subtotalHigh){
        $reportPet.Add("TOTAL",$subtotalLow)
    }
    else{
    $rangeSubtotal = $subtotalLow + " to " + $subtotalHigh
    $reportPet.Add("TOTAL",$rangeSubtotal)
    }

    $lowOverall   = ($lowPet.Overall).ToString()
    $highOverall  = ($highPet.Overall).ToString()
    if($lowOverall -eq $highOverall){
        $reportPet.Add("Overall",$lowOverall)
    }
    else{
    $rangeOverall = $lowOverall + " to " + $highOverall
    $reportPet.Add("Overall",$rangeOverall)
    }

    # If TOTAL is an integer, remove the key 'Overall'
    if($reportPet.Total.Contains("to")){
        # Leave HT alone, keep Overall
    }
    else{
        #remove the Overall    
        $reportPet.Remove('Overall')
    }

    Write-Verbose "New-ReportPet: BREAKPOINT - is reportPet populating correctly?"
    return $reportPet
}

function ConvertTo-Object($hashtable){
   $object = New-Object PSObject
   $hashtable.GetEnumerator() | 
      ForEach-Object { Add-Member -inputObject $object `
	  	-memberType NoteProperty -name $_.Name -value $_.Value }
   $object
}

function Format-CSVrow($hashtable){
    [array]$tmpObj = ConvertTo-Object $hashtable
    return $tmpObj
}

#endregion 
#region Update reportPet Display
Function Update-ReportPetName(){
    $Script:reportPet.Name = $NameBox.Text
    $ReportPetGrid.ItemsSource = $null
    $ReportPetGrid.ItemsSource = $Script:reportPet
    $Script:reportPetCSV[0].Name = $NameBox.Text
    $CSVGrid.ItemsSource = $null
    $CSVGrid.ItemsSource = $Script:reportPetCSV    
    Write-Verbose "Update-ReportPetName: BREAKPOINT is script reportPetName changing?"
    Write-Status -Message "Update-ReportPetName: Changed NAME value in reportPet"
}

Function Reset-Result(){
    # Reset things back to on-load condition
    # lowPet and highPet are used to generate reportPet
    Clear-Variable -Name lowPet -Scope Script
    Clear-Variable -Name highPet -Scope Script
    Clear-Variable -Name reportPet -Scope Script
    Set-Variable -Name knownPet -Value @() -Option AllScope
    Set-Variable -Name evalText -Value "" -Option AllScope
    $Script:lowPet = [ordered]@{Name="dummy"}
    $Script:highPet = [ordered]@{Name="dummy"}
    $Script:reportPet = [ordered]@{Name="dummy"}
    $Script:knownPet = @()
    $Script:evalText = ""
    $ReportPetGrid.ItemsSource = $null
    $CSVGrid.ItemsSource = $null
    $InputBox.Text = ""
    Clear-DebugTextBox
    Set-UtoK
    Write-Status -Message "Reset-Result: Select a new comparator from dropdown"
    $CharSelect.SelectedItem = ""
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
#region ExportData
Function Export-MyTable(){
    Write-Status -Message "Export-MyData: Button not yet implemented"
}

Function Export-MyRow(){
    Write-Status -Message "Export-MyRow: Button not yet implemented"
}
#endregion 


#-------------------------------------------------------------#
#----Script Execution-----------------------------------------#
#-------------------------------------------------------------#

$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }


$MyWindow.Add_Initialized({undefined $this $_})
$MyWindow.Add_Loaded({Set-UtoK $this $_})
$LoadDbButton.Add_Click({File-Picker $this $_})
$UtoKButton.Add_Checked({Set-UtoK $this $_})
$UtoKButton.Add_Click({undefined $this $_})
$KtoUButton.Add_Checked({Set-KtoU $this $_})
$KtoUButton.Add_Click({undefined $this $_})
$CharSelect.Add_DropDownClosed({Select-Known $this $_})
$ProcessCompButton.Add_Click({New-Comparison $this $_})
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
	{"Key":"TOTAL","Value":"UNKNOWN"},
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


