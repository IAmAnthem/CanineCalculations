workflow

Pick a known pet:		Get-KnownPet
* returns $knownPet

Ask for an evaluation	Get-EvalText
* returns $evalText

Check the knowledge level
*		if $knowledge -ne certain, abort
*		Future development: Determine the variations in think/feel
*			Is this predictable?
*			redshift/blueshift the results based on (whatever)


Check the relationship level?
* not really relevant at this point
* Futureproofing for some other need

Update-LowPet and Update-HighPet seem to be working correctly now.
* Add an evaluation of TOTAL
* What do we care about here?
  * known vs unknown OVERALL can really help
  * Complicated logic to use an overall SIMILAR to resolve unknowns
  * Take a stab and see how useful OVERALL is as you cycle

Report-Status checks count of solutions and returns a boolean $solved
* Loops through traits and compare low/high hashtables
* Present the option to [C]ontinue [R]eport [E]xit

Run-Comparisons function?
```
while $solved = $false
 do the things
```

