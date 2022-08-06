# Canine Calculations for Ancient Anguish

Ancient Anguish is a MUD that's been around a long time.

A feature was introduced that allows players in the Ranger class to breed pets, and for those pets to raise their traits through breeding.

Everyone started at 0, and the traits were all unknown.  What are they?  How many of them are there? What do they do?
Well, we discovered there are 17 traits.
Days were spent just figuring out the basics of getting two pets to procreate reliably.
Months were spent trying to get all traits to have a non-zero value.
More months trying to get all traits to a positive value.

Once the basics were discovered, some progress was being made, then another wrench was thrown in the works. 
RELATIONSHIPS?!  Yes, breeding between related canines produces resulting puppies between suboptimal and completely awful.

## Why do we need a script?
The players can only see a description of the difference between canines, not the actual values.
This script will turn those descriptions into values, if you have enough known pets to compare against.

## What does the script do?
Pick from a list of pets with known values
Paste in the comparison text (shortcut, hitting ENTER is equivalent to clicking OK - mudders ARE keyboard warriors)
## Why isn't this an open webapp?

### Progress Notes

- Check the knowledge level

  - `if $knowledge -ne certain, abort`
  - Future development: Determine the variations in think/feel
    - Is this predictable?
    - redshift/blueshift the results based on (whatever)

- Check the relationship level?
  - not really relevant at this point
  - Futureproofing for some other need

Workup Show-Menu

- Seems good!
  - Whoops, assumed that everyone does compares in the same direction
- FIXES
  - Relabel existing funcs to explicitly state direction
    - Update Menu
  - Add new funcs to reverse direction
- ENHANCEMENT
  - Insert this pet into database (prompt for fields to fill in for real name/owner/whatnet) and updatecsv

Selecting Known Pet

- FIXES
  - Can I switch the selection menu to start counting at 1 instead of 0?
    - Pretty sure there's an example somewhere that does this
