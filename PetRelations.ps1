<#

Get-DB pulls in a CSV in format 
  NAME,OWNER,TRAITS,GENDER,CLOSE1,CLOSE2,PARTIAL1,PARTIAL2,PARTIAL3,PARTIAL4
    CLOSE1 = Male Parent                CLOSE2 = Female Parent
    PARTIAL1 = Paternal Grandfather     PARTIAL2 = Paternal Grandmother
    PARTIAL3 = Maternal Grandfather     PARTIAL4 = Maternal Grandmother
        This organization is to make it easier for humans to read.
        I started my DB this way to make the excel functions simpler

  Note that NAME must be completely unique for each pet, and use the same pattern

  IF you don't have unique info yet
    Build up your database over a couple of breedings and you'll have all the data

    NAME     : Ardent Minsi 686/52
    OWNER    : Sarah
    TRAITS   : 686
    GENDER   : F
    CLOSE1   : Exie Shaker 694/53
    CLOSE2   : Ardent Caddie 673/44
    PARTIAL1 : Exie Hook 695/53
    PARTIAL2 : Morsel Narah 683/53
    PARTIAL3 : Ballad Finale 670/43
    PARTIAL4 : Ardent Tiz [NOTE THIS PET HAD UNKNOWN STATS SO UNRELIABLE]

Get-Gender validates the gender as male or female
Get-Set returns a set of males or females
Get-Pet returns a pet
Show-Puppy returns a puppy's lineage from a mating
    TRAITS calculation is simple average
    ### This is not the real formula ####
    If you gather ~500 puppy stats, you can make a good guess at the math
Compare-Pet compare two pets

#>

function Get-DB{
    $tempDB = Import-CSV -Path .\Breeders.csv
    $tempDB = $tempDB | Sort-Object -Property NAME # Make it alpha sorted
    # If source CSV has blanks rows (useful for humans), remove them
    $tempDB = $tempDB | Where-Object -Property NAME -ne "" 
    return $tempDB
}
function Get-Gender{
    Param()
        if($null -eq $script:gender){
            $Script:gender = Read-Host -Prompt "Enter a gender (M or F):"
            $gender = $script:gender.ToUpper()
            # DEBUG Write-Host " There was no value for Gender"
            return $gender
        } elseif ($script:gender -eq "M"){
            # DEBUG Write-Host "Already selected Male, picking F"
            $gender = "F"
            return $gender
        } elseif ($script:gender -eq "F"){
            # DEBUG Write-Host "Alread selected Female - picking M"
            $gender = "M"
            return $gender
        }
}
function Get-Set
{
    [CmdletBinding()]
    Param(
        $gender
    )
    $tempDB = Get-DB
    $maleDB = @()
    $femaleDB = @()
    $gender = Get-Gender
    $tempDB = $tempDB  | Where-Object GENDER -eq $gender
    if ($gender -eq "M"){
        $maleDB = $tempDB
        return $maleDB
    } else {
        $femaleDB = $tempDB
        return $femaleDB
    }
}
function Get-Pet
{
    $pet = Get-Set | Out-GridView -Title "Select a pet" -PassThru
    return $pet
}
function Show-Puppy
{
    $properties = [ordered]@{
        'NAME' = 'PUPPY';
        'OWNER' = 'HUMAN';
        'TRAITS' = ([Int]$a.TRAITS + [Int]$b.TRAITS)/2;
        'GENDER' = 'M or F';
        'CLOSE1' = $a.NAME;
        'CLOSE2' = $b.NAME;
        'PARTIAL1' = $a.CLOSE1;
        'PARTIAL2' = $a.CLOSE2;
        'PARTIAL3' = $b.CLOSE1;
        'PARTIAL4' = $b.CLOSE2
    }
    $outputPuppy = New-Object -TypeName PSObject -Property $properties
    return $outputPuppy
}
function Compare-Pet
{
    $a = Get-Pet
    $b = Get-Pet
    $aRelations = @($a.NAME,$a.CLOSE1,$a.CLOSE2,$a.PARTIAL1,$a.PARTIAL2,$a.PARTIAL3,$a.PARTIAL4)
    $bRelations = @($b.NAME,$b.CLOSE1,$b.CLOSE2,$b.PARTIAL1,$b.PARTIAL2,$b.PARTIAL3,$b.PARTIAL4)
    $linkage = $aRelations | Where-Object {$bRelations -contains $_}
    $linkage = $linkage | Select-Object -Unique #Clean up duplications
    if ($null -eq $linkage){
        Write-Host "These canines are unrelated!  Make puppies!" -ForegroundColor Black -BackgroundColor Green
        # FUTURE call another function that produces the puppy row for database and return it
        $outputPuppy = Show-Puppy $a $b
        return $outputPuppy | Format-Table
    } else {
        Write-Host "These pets are related by:" -ForegroundColor Black -BackgroundColor Yellow
        return $linkage
    }
}

# null out the gender var at start so user is prompted
$script:gender = $null
Compare-Pet

# Null it out again for safety, comment out this and $script:gender is your initially selected value
$script:gender = $null