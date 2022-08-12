<# 
    Develop at least a single-step, but preferrably multi-step plan to 
    advance a canine through breeding 

    limit this to 3 gens.
    Given a large enough db this should work fine to go n generations but
    you're getting diminishing returns after 3 - example:

    Notional Math (this isn't the real randomized math)
        $advancingChar has a 0 point canine
        $unrelPotentialMates has a bunch of canines averaging 690

        Gen1 = (0+690)/2   = 345
        Gen2 = (345+690)/2 = 517
        Gen3 = (517+690)/2 = 603
        Gen4 = (603+690)/2 = 646


        Sketch out the steps
    $petDB = Import database
    $person = selector - found n humans in db, pick one
    $personCharacters = $petdb | Where-Object $_.PErson -ne $person
    
    $advancingCharacter = selector from $personCharacters
    
    $potentialMates looks like this
    $potentialMates = $petDB | Where-Object { $personCharacters.Person -notcontains $_ }
    $potentialMates gender slice (only allow opposite genders in array)

    foreach($canine in $potentialMates){
    test-relationship - use PetRelations as a starter
    if unrelated add $canine to $unrelPotentialMates
    }

    Select-MateOne - prompt/selector picklist from $unrelPotentialMates
    $genOne = output of breeding from $advancingCharacter and $mateOne

    Prompt - want to continue moving $genOne forward?

    loop back through potentialMates / unrelPotentialMates and prompt again
    output is $genTwo, etc



    #>

