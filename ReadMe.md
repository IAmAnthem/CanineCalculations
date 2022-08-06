# Canine Calculations for Ancient Anguish 
Ancient Anguish is a MUD that's been around a long time.


## Why do we need a script?


## What does the script do?


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