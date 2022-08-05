workflow

Pick a known pet:		Get-KnownPet
* returns $knownPet

Ask for an evaluation	Get-EvalText
* returns $evalText

Check the knowledge level
* `if $knowledge -ne certain, abort`
* Future development: Determine the variations in think/feel
  * Is this predictable?
  * redshift/blueshift the results based on (whatever)


Check the relationship level?
* not really relevant at this point
* Futureproofing for some other need


Update-LowPet and Update-HighPet seem to be working correctly now.
* Add an evaluation of OVERALL
  * overAll for the low estimate is the floor, rarely this low
  * overAll for the high estimate is the ceiling, rarely this high
* Add a subTotal all traits and include in hashtable
    * for low estimate, this is the true floor (usually higher than Overall)
	* for the high estimate, this is the true ceiling (usually lower than Overall)
* What do we care about here?
  * knowing overAll and subtotals could resolve the last point or two
    * humans can eyeball that (fairly common to recognize trait MUST be x because of this)
	* I'd have to figure out the logic to calculate that
  * Complicated logic to use an overall SIMILAR to resolve unknowns
  * Take a stab and see how useful OVERALL is as you cycle


Report-Status checks count of solutions and returns a boolean $solved
* Loops through traits and compare low/high hashtables
* Present the option to [C]ontinue [R]eport [E]xit

Workup New-Menu
*  MEH. Didn't like it

Workup Better-Menu
* Seems good!
* ENHANCEMENT
  * [I]nsert this pet into database (prompt for fields to fill in for real name/owner/whatnet) and updatecsv


Run-Comparisons function?
```
while $solved = $false
 do the things
```

