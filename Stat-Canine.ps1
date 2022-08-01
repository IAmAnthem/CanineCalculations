<# Stat-Canine.ps1

Develops a set of functions useful in evaluating a canine

#>
function Get-EvalText {
    param ()
    $evalText = Get-Content -Path C:\Users\winnd\OneDrive\Documents\Scripts\CertainStat.txt
    return $evalText
}

function Get-Knowledge {
    param()
    $evalText = Get-EvalText

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
    } else {
        $relationship = "UNKNOWN"
    }
    return $relationship
}

function Get-TraitText {
    param(
    $traitName
    )
    # DEBUG:         Write-Host "Get-TraitText is looking for $traitName"
    $evalText = Get-EvalText
    if($evalText -match $traitName){
        # DEBUG:         Write-Host "Get-TraitText found $traitName in evaltext"
        $evalString = $evalText -match $traitName
        # DEBUG: Write-Host "Get-TraitText created evalString: $evalString"
        $stripText = $traitName + " seems"
        $traitText = $evalString.Replace($stripText,"").Replace(".","").Substring(2)
        # DEBUG:        Write-Host "Get-TraitText calculated $traitName as $traitText"
        return $traitText
        } else {
        if ($traitName -eq "Total"){
            $evalString = $evalText -match "Overall"
            $traitText = $evalString -replace '(^(?:\S+\s+\n?){1,5})',''
            $traitText = $traitText.Replace(".","")
            return $traitText
        } else {
        Write-Host "FUBAR! I can't match $traitName - exiting script"
        break
        }
    return $traitText
    }
}

function Get-EvalLowRange {
    param(
    $traitName
    )
    $traitText = Get-TraitText $traitName
    # DEBUG    Write-Host "Get-EvalLowRange is looking for $traitText"
    foreach ($row in $baseArray){
        if($row.evalText -eq $traitText){$evalLowRange = $row.low}	
        }
    return $evalLowRange
}

function Get-EvalHighRange {
    param(
    $traitName
    )
    $traitText = Get-TraitText $traitName
    foreach ($row in $baseArray){
        if($row.evalText -eq $traitText){$evalHighRange = $row.high}	
        }
    return $evalHighRange

    }

Function Get-KnownPet{
    param(
    $name # Would need to add UniqueName param for real usage
    )
    foreach ($row in $knownPet){
        if ($row.Name -eq "Heap ZeroDog"){
            $knownPet = $row
            } else {
            Write-Host "Can't find this pet in database, breaking"
            break;
            }
        }
    return $knownPet
    }

Function Get-EvalLowValue {
    param(
    $traitName
    )
    $knownPet = Get-KnownPet
    $evalLowRange = Get-EvalLowRange $traitName
    $knownValue = $knownPet.$traitName
    $evalLowValue = $knownValue + $evalLowRange
    return $evalLowValue

}

Function Get-EvalHighValue {
    param(
    $traitName
    )
    $knownPet = Get-KnownPet
    $evalHighRange = Get-EvalHighRange $traitName
    $knownValue = $knownPet.$traitName
    $evalHighValue = $knownValue + $evalHighRange
    return $evalHighValue

}

Function Get-TraitValueRange {
    Param(
    $traitName
    )
    $traitValueHashTable = @{
        traitName = $traitName
        Low       = Get-EvalLowValue $traitName
        High      = Get-EvalHighValue $traitName
        }
    return $traitValueHashTable
}

Function Update-LowPet {
    Param(
        $name # add $name here to lookup against something other than the zeropet
    )
    foreach ($traitName in $traits){
        $traitValueHashTable = Get-TraitValueRange $traitName
        if($null -eq $lowPet.$traitName){
            $lowPet.$traitName += $traitValueHashTable.Low
            }
        elseif($lowpet.$traitName -lt $traitValueHashTable.Low){
            # The low range should continue to 'rise' as we refine
            # Since our lowPet low is less than calculated low, Update
            $lowPet.$traitName = $traitValueHashTable.Low
            }
        elseif($lowPet.traitName -ge $traitValueHashTable.Low){
            # his value is fine, don't change it
            }
        else{
            Write-Host "null, lt, ge cases accounted for, but still no match"
            Write-Host "Welcome to New Math"
            break
            }
            
    }

}

# FIX THIS NEXT
Function Update-HighPet {
    Param(
        $name # add $name here to lookup against something other than the zeropet
    )
    foreach ($traitName in $traits){
        $traitValueHashTable = Get-TraitValueRange $traitName
        if($null -eq $highPet.$traitName){
            $highPet.$traitName += $traitValueHashTable.High
            }
        elseif($highPet.$traitName -lt $traitValueHashTable.High){
            # The high range should continue to 'sink' as we refine
            $highPet.TraitName = $traitValueHashTable.High
            }
        elseif($lowPet.traitName -ge $traitValueHashTable.Low){
            # This value is fine, don't change it
            }
        else{
            Write-Host "null, lt, ge cases accounted for, but still no match"
            Write-Host "Welcome to New Math"
            break
            }
            
    }

}

<# Placeholder - something like this?, need multiple pets to compare against
    Make a better CSV-replica
    Need to loop through compare-pet until low=high or user says stop
    Spit out the result
    John likes hashtable but we need array for database-like operations

Function Compare-Pet(
    Param($name)
    Update-LowPet
    Update-HighPet
#>


########## END OF FUNCTIONS ##########
########## Setting up vars  #########
# Playing with hashtables to see how this works
# Eventually I guess I need to switch to horizontal, since my sourcedata is csv
# Problem for later!

# Setting up low pet hashtable, don't even need all traits here
$lowPet = [ordered]@{    
        Name        ="lowPet"
        }


$highPet = [ordered]@{
        Name        ="highPet"
        }

$baseArray = @(
    [PSCustomObject]@{evalText="totally inferior";low="-1700";high="-71"}
	[PSCustomObject]@{evalText="very inferior";low="-70";high="-21"}
    [PSCustomObject]@{evalText="inferior";low="-20";high="-10"}
    [PSCustomObject]@{evalText="slightly inferior";low="-9";high="-5"}
    [PSCustomObject]@{evalText="marginally inferior";low="-4";high="-2"}
    [PSCustomObject]@{evalText="barely inferior";low="-1";high="-1"}
    [PSCustomObject]@{evalText="similar";low="0";high="0"}
    [PSCustomObject]@{evalText="barely better";low="1";high="1"}
    [PSCustomObject]@{evalText="marginally better";low="2";high="4"}
    [PSCustomObject]@{evalText="slightly better";low="5";high="9"}
    [PSCustomObject]@{evalText="better";low="10";high="20"}
   	[PSCustomObject]@{evalText="much better";low="21";high="70"}
    [PSCustomObject]@{evalText="outstandingly better";low="71";high="1700"}
	)

# knownPet replicates the effect of Import-CSV against a normal csv
$knownPet = @(
    [PSCustomObject]@{
        Name="Heap ZeroDog";
        Alertness=0;
        Appetite=0;
        Brutality=0;
        Development=0;
        Eluding=0;
        Energy=0;
        Evasion=0;
        Ferocity=0;
        Fortitude=0;
        Insight=0;
        Might=0;
        Nimbleness=0;
        Patience=0;
        Procreation=0;
        Sufficiency=0;
        Targeting=0;
        Toughness=0;
        Total=0
    }
    )

$traits = @(
    'Alertness','Appetite','Brutality','Development','Eluding','Energy',
    'Evasion','Ferocity','Fortitude','Insight','Might','Nimbleness',
    'Patience','Procreation','Sufficiency','Targeting','Toughness'
    )

# Maybe I'll do a transform with lowpet hashtable to ghostArray csv format?
$ghostArray = @()

