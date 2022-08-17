$direction=""
#-------------------------------------------------------------#
#----Initial Declarations-------------------------------------#
#-------------------------------------------------------------#

Add-Type -AssemblyName PresentationCore, PresentationFramework

$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Width="1000" Height="800">
<Grid Name="MasterGrid" Margin="0,0,0,0">

<Label VerticalAlignment="Top" VerticalContentAlignment="Center" HorizontalContentAlignment="Center" Content="Canine Comparator" Margin="0,0,0,0" Name="RightTopLabel" Height="39" Background="#473e72" Foreground="#e2eeed" FontFamily="Consolas" FontSize="26"/>
<StackPanel HorizontalAlignment="Left" Height="700" VerticalAlignment="Top" Width="181" Margin="0,40,0,0">
<TextBlock HorizontalAlignment="Left" VerticalAlignment="Top" TextWrapping="Wrap" Text="Select Mode Below" Height="24" Width="179" Margin="20,5,0,0"/>
<RadioButton HorizontalAlignment="Left" VerticalAlignment="Top" Content="Unknown To Known" Height="35" Width="179" Margin="10,2,0,0" Name="UtoKButton"/>
<RadioButton HorizontalAlignment="Left" VerticalAlignment="Top" Content="Known To Unknown" Height="32" Width="179" Margin="10,2,0,0" Name="KtoUButton"/>
<ComboBox HorizontalAlignment="Left" VerticalAlignment="Top" Width="175" Name="CharSelect" Height="32" ItemsSource="{Binding knowns}" Margin="5,12,0,0" VerticalContentAlignment="Bottom"/>
<Button Content="Select Known" HorizontalAlignment="Left" VerticalAlignment="Top" Width="155" Margin="10,12,0,0" Height="27"/>
<Button Content="Process Comparison" HorizontalAlignment="Left" VerticalAlignment="Top" Width="155" Margin="10,12,0,0" Height="27" Name="ProcessCompButton"/>
<Button Content="Export Result" HorizontalAlignment="Left" VerticalAlignment="Top" Width="155" Margin="10,12,0,0" Height="27" Name="ExportResultCompButton"/>
<Button Content="Reset Comparison" HorizontalAlignment="Left" VerticalAlignment="Top" Width="155" Margin="10,12,0,0" Height="27" Name="ResetButton"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="165" Margin="5,15,0,0"/>
<TextBox HorizontalAlignment="Left" VerticalAlignment="Top" Height="27" Width="155" TextWrapping="Wrap" Margin="10,12,0,0" Name="NameBox"/>
<Button Content="Set Name (Unique)" HorizontalAlignment="Left" VerticalAlignment="Top" Width="155" Margin="10,12,0,0" Height="27" Name="SetNameButton"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="165" Margin="5,15,0,0"/>
<Rectangle HorizontalAlignment="Left" VerticalAlignment="Top" Fill="#FFF4F4F5" Stroke="Black" Height="5" Width="165" Margin="5,15,0,0"/>
</StackPanel>

<StackPanel HorizontalAlignment="Left" Height="435" VerticalAlignment="Top" Width="390" Margin="240,50,0,0">
<TextBox HorizontalAlignment="Left" VerticalAlignment="Top" Height="435" Width="390" TextWrapping="Wrap" Name="InputBox" Margin="0,0,0,0" AcceptsReturn="True"/>
</StackPanel>
<DataGrid HorizontalAlignment="Left" VerticalAlignment="Top" Width="300" Height="435" Margin="645,50,0,0" AlternationCount="2" AlternatingRowBackground="Bisque" Name="ReportPetGrid" ItemsSource="{Binding reportPet}"/>
</Grid>
</Window>
"@

#-------------------------------------------------------------#
#----Control Event Handlers-----------------------------------#
#-------------------------------------------------------------#


#region Logic
#Write your code here
#endregion 
#region Set-UtoK
Function Set-UtoK{
    $Script:direction = "UnknownToKnown"
}
#endregion 
#region Set-KtoU
Function Set-KtoU{
    $Script:direction = "KnownToUnknown"
}
#endregion 
#region Generate-Columns

#endregion 


#-------------------------------------------------------------#
#----Script Execution-----------------------------------------#
#-------------------------------------------------------------#

$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }


$UtoKButton.Add_Checked({Set-UtoK $this $_})
$KtoUButton.Add_Checked({Set-KtoU $this $_})

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
"knowns": [
    "An Untraited Canine",
    "Mulapin Ringo 733/54",
    "Lullaby Sandman 722/57",
    "Grazioso Hoover 718/54",
    "Exie Shaker 694/53",
    "Dirge Fluid 692/57",
    "Crescendo Eddie 698/51",
    "Cover Rocker 714/60",
    "Ballad Fireball 730/55",
    "Mulapin Gringo 709/53",
    "Guest Puppeh"
    ],
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
]
}

"@

$DataContext = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
FillDataContext @("knowns","reportPet") 

$Window.DataContext = $DataContext
Set-Binding -Target $CharSelect -Property $([System.Windows.Controls.ComboBox]::ItemsSourceProperty) -Index 0 -Name "knowns"  
Set-Binding -Target $ReportPetGrid -Property $([System.Windows.Controls.DataGrid]::ItemsSourceProperty) -Index 1 -Name "reportPet"  
$Window.ShowDialog()


