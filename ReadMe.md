workflow

Pick a known pet:		Get-KnownPet
*	returns $knownPet

Ask for an evaluation	Get-EvalText
*	returns $evalText

Check the knowledge level
*		if $knowledge -ne certain, abort
*		Future development: Determine the variations in think/feel
*			Is this predictable?
*			redshift/blueshift the results based on (whatever)


Check the relationship level?
*	not really relevant at this point
*	Futureproofing for some other need

Update-LowPet and Update-HighPet seem to be working correctly now.

Compare the two hashtables somehow
*	Ingest them into an array like our PetDB?
`
``
	foreach($trait in $traitnames){
	if array.lowpet.traitname -eq array.highpet.traitname
		Solved $traitname
		spit to solution.$traitName
```
