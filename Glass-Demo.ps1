$verbosePreference = "Continue"
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

$knownPet = @()
#-------------------------------------------------------------#
#----Initial Declarations-------------------------------------#
#-------------------------------------------------------------#

Add-Type -AssemblyName PresentationCore, PresentationFramework

$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Width="1000" Height="800">
<Grid Name="MasterGrid" Margin="1,1,-1,-1">

<Label VerticalAlignment="Top" VerticalContentAlignment="Center" HorizontalContentAlignment="Center" Content="Canine Comparator" Margin="0,-1,0,0" Name="RightTopLabel" Height="39" Background="#473e72" Foreground="#e2eeed" FontFamily="Consolas" FontSize="26"/>
<StackPanel HorizontalAlignment="Left" Height="700" VerticalAlignment="Top" Width="181" Margin="-1,40,0,0">
<TextBlock HorizontalAlignment="Left" VerticalAlignment="Top" TextWrapping="Wrap" Text="Select Mode Below" Height="24" Width="179" Margin="20,5,0,0"/>
<RadioButton HorizontalAlignment="Left" VerticalAlignment="Top" Content="Unknown To Known" Height="35" Width="179" Margin="10,2,0,0" Name="UtoKButton"/>
<RadioButton HorizontalAlignment="Left" VerticalAlignment="Top" Content="Known To Unknown" Height="32" Width="179" Margin="10,2,0,0" Name="KtoUButton"/>
<ComboBox HorizontalAlignment="Left" VerticalAlignment="Top" Width="175" Name="CharSelect" Height="32" ItemsSource="{Binding internalJSON}" DisplayMemberPath="Name" Margin="5,111,0,0" VerticalContentAlignment="Bottom"/>
<Button Content="Select Known" HorizontalAlignment="Left" VerticalAlignment="Top" Width="155" Margin="10,12,0,0" Height="27" Name="l6yi1eo1k7aaa"/>
<Button Content="Process Comparison" HorizontalAlignment="Left" VerticalAlignment="Top" Width="155" Margin="10,12,0,0" Height="27" Name="ProcessCompButton"/>
<Button Content="Export Result" HorizontalAlignment="Left" VerticalAlignment="Top" Width="155" Margin="10,12,0,0" Height="27" Name="ExportResultCompButton"/>
<Button Content="Reset Comparison" HorizontalAlignment="Left" VerticalAlignment="Top" Width="155" Margin="10,12,0,0" Height="27" Name="ResetButton"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="165" Margin="5,15,0,0"/>
<TextBox HorizontalAlignment="Left" VerticalAlignment="Top" Height="27" Width="155" TextWrapping="Wrap" Margin="10,12,0,0" Name="NameBox"/>
<Button Content="Set Name (Unique)" HorizontalAlignment="Left" VerticalAlignment="Top" Width="155" Margin="10,12,0,0" Height="27" Name="SetNameButton"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="165" Margin="5,15,0,0"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="165" Margin="5,15,0,0"/>
<Button Content="Load Database" HorizontalAlignment="Left" VerticalAlignment="Top" Width="155" Margin="10,12,0,0" Height="27" Name="LoadDbButton"/>
</StackPanel>
<StackPanel HorizontalAlignment="Left" Height="435" VerticalAlignment="Top" Width="390" Margin="240,50,0,0">
<Label HorizontalAlignment="Left" VerticalAlignment="Top" VerticalContentAlignment="Center" HorizontalContentAlignment="Center" Content="Paste in comparison text below" Height="24" Width="388" Name="InputBoxLabel"/>
<TextBox HorizontalAlignment="Left" VerticalAlignment="Top" Height="405" Width="390" TextWrapping="Wrap" Name="InputBox" AcceptsReturn="True" Margin="0,3,0,0"/>
</StackPanel>
<DataGrid HorizontalAlignment="Left" VerticalAlignment="Top" Width="300" Height="435" Margin="642,50,0,0" AlternationCount="2" AlternatingRowBackground="Bisque" Name="ReportPetGrid" ItemsSource="{Binding reportPet}"/>
<Label HorizontalAlignment="Left" VerticalAlignment="Top" Content="" Margin="272.84375,545.984375,0,0" Name="selectionIndicatorLabel" Width="345" Height="35" Background="#d4e2db" Foreground="#231955"/>
<Label HorizontalAlignment="Left" VerticalAlignment="Top" Content="Current selection shown above" Margin="267.84375,601.984375,0,0" Name="verifySelectionLabel"/>
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
}

Function Set-KtoU() {
    $Script:direction = "KnownToUnknown"
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
    }
    $selectionIndicatorLabel.Content = $selectedString
    if ($null -eq $internalDB){
        $knownPet = $DataObject.internalJSON | Where-Object -Property Name -eq $selectedString
        Write-Verbose "Select-Known: internalDB not loaded - Picked $knownPet"
    }
    else {
    $knownPet = $internalDB | Where-Object -Property Name -eq $selectedString
    Write-Verbose "Select-Known: Picked from internalDB $knownPet"
    }
}

Function Read-Database(){
    # Stick a selector here to allow pick an external CSV
    # For now lets carry my known values in the script so I can build all functionality
    $internalDB = $DataObject.internalJSON  # Produces the same array I got from Import-CSV 
    $internalDB = $internalDB | Where-Object -Property Status -eq "Active"
    $internalDB = $internalDB | Sort-Object -Property Name
}
#endregion 
#region Update reportPet
Function Check-Enter($sender,$event){
    if($event.key -eq "Return"){
        # Do the thing that populates reportPet.Name
    }
}
#endregion 


#-------------------------------------------------------------#
#----Script Execution-----------------------------------------#
#-------------------------------------------------------------#

$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }


$UtoKButton.Add_Checked({Set-UtoK $this $_})
$KtoUButton.Add_Checked({Set-KtoU $this $_})
$l6yi1eo1k7aaa.Add_Click({Select-Known $this $_})
$NameBox.Add_KeyUp({Check-Enter $this $_})
$LoadDbButton.Add_Click({Read-Database $this $_})

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
"reportPet": [
    {"Key":"Name","Value":"dummy"},
    {"Key":"Alertness","Value":"28 to 30"},
    {"Key":"Appetite","Value":"43 to 45"},
    {"Key":"Brutality","Value":"32"},
    {"Key":"Development","Value":"43 to 45"},
    {"Key":"Eluding","Value":"53 to 55"},
    {"Key":"Energy","Value":"27 to 29"},
    {"Key":"Evasion","Value":"55 to 57"},
    {"Key":"Ferocity","Value":"49 to 51"},
    {"Key":"Fortitude","Value":"45 to 47"},
    {"Key":"Insight","Value":"30 to 34"},
    {"Key":"Might","Value":"38 to 42"},
    {"Key":"Nimbleness","Value":"48"},
    {"Key":"Patience","Value":"33 to 35"},
    {"Key":"Procreation","Value":"51 to 53"},
    {"Key":"Sufficiency","Value":"36"},
    {"Key":"Targeting","Value":"40"},
    {"Key":"Toughness","Value":"49"},
    {"Key":"TOTAL","Value":"721 to 725"}
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
FillDataContext @("reportPet","internalJSON") 

$Window.DataContext = $DataContext
Set-Binding -Target $CharSelect -Property $([System.Windows.Controls.ComboBox]::ItemsSourceProperty) -Index 1 -Name "internalJSON"  
Set-Binding -Target $ReportPetGrid -Property $([System.Windows.Controls.DataGrid]::ItemsSourceProperty) -Index 0 -Name "reportPet"  
$Window.ShowDialog()
