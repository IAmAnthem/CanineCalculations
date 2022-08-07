# Canine Calculations for Ancient Anguish

[Ancient Anguish](http://www.anguish.org) is a MUD that has been around a long time.

A feature was introduced that allows characters[^1] in the Ranger class to breed pets, and for those pets to raise their traits through breeding.

Everyone started at 0, and the traits were all unknown.  
- How many of them are there? (17)
- What is the trait value range? (-100 to 100, yes a trait can have a negative value)
- What are they?
  - Alertness, Appetite, Brutality, Development, Eluding, Energy
  - Evasion, Ferocity, Fortitude, Insight, Might, Nimbleness
  - Patience, Procreation, Sufficiency, Targeting, Toughness
- What do they do? Hah, who knows.  We can make some guesses by the descriptive word, but no clear definition exists.
  - Guesses as to function are conjecture, and we really have very little way to know
  - If your *baking* trait was 100, would that mean you bake cakes faster? Cakes are more delicious? Cakes are prettier?

Days were spent just figuring out the basics of getting two pets to procreate reliably.
Months were spent trying to get all traits to have a non-zero value.
More months trying to get all traits to a positive value.

Once the basics were discovered, some progress was being made, then another wrench was thrown in the works. 
RELATIONSHIPS?!  Yes, breeding between related canines produces resulting puppies between suboptimal and completely awful.

My initial efforts are to develop the logic for automating the cacluation of trait values and checking to ensure pets are unrelated for breeding.

My estimate is something over 12,000 canines have been tamed.  The highest traited pets are a bit over halfway to the maximum value.  It took YEARS.
## Why do we need scripts?
### Trait Values
Characters develop more certainty in their 'compare' ability the more puppies they have.
Once the comparison is *certain* (instead of *think* or *feel*) you can definately use the Stat script.
If you are still in *think* or *feel* your results are shifted by some unknown amount, which may vary per-reboot.
More research is required.

The players can only see a description of the difference between canines, not the actual values.
- "totally inferior"
- "very inferior"
- "inferior"
- "slightly inferior"
- "marginally inferior"
- "barely inferior"
- "similar"
- "barely better"
- "marginally better"
- "slightly better"
- "better"
- "much better"
- "outstandingly better"

The script will turn those descriptions into values, if you have enough known pets to compare against.

### Relationships
Once a character has had MANY litters, the compare ability also reports the relationship level between two canines.
Any player can get the lineage tree for their canine at the bottom of the character's [Player Info Page](http://anguish.org/tools/player_info.php_)

## What do the scripts do (right now)?
- Stat-Canine.ps1
  - Pick from a list of pets with known values
  - Paste in the comparison text (shortcut, hit ENTER after paste - mudders ARE keyboard warriors)
  - Report the number of traits 'solved'
  - Continue adding comparisons to refine
  - Report the known values and ranges for unknown values
- PetRelations.ps1
  - Compare the lineage of two pets to see if they are related
  - If unrelated, report the lineage of any output puppies

## Limitations of Scripts
I'm starting with some assumptions and haven't really tested the workflow in the wild with someone not heavily invested in canine breeding. 

There are probably things I don't know.

I don't do any data validation, you can probably break the script by injecting bad data into the CSV.


## Why isn't this an open webapp?
- Poisoning: in an online world where people are anonymous, spiteful, and selfish an open website is invitation to destruction.
You know who you are.
- Privacy: The only data you see by example here has been OK'd by the data owner.  
Some players may choose to not reveal their pet lineage or stats for whatever reason.
- Skills: I'm a systems engineer by trade and at heart, I learn enough code to do what I need to do.  
Currently that's PowerShell, not something sexy like a [Serverless Web Application](https://aws.amazon.com/serverless/build-a-web-app/).  But maybe someday?

### Progress Notes - what am I working on?

#### Check the knowledge level

  - `if $knowledge -ne certain, abort` Well we can't do that because "listeners" can't see relationships, pinged Paldin
  - Future development: Determine the variations in think/feel
    - Is this predictable?
    - redshift/blueshift the results based on (whatever)

#### Check the relationship level
  - not really relevant at this point
  - Futureproofing for some other need
  - Trying to decide between One Big Table and different tables for Traits / Relationships

#### Work on Menu functionality

- USABILITY
  - Should we select a mode (KtoU or UtoK) THEN cycle?
- FIXES
  - Relabel existing funcs to explicitly state direction
    - Update Menu
- WISHLIST
  - Insert this pet into database (prompt for fields to fill in for real name/owner/whatnot?) and updatecsv
  - This is a long way off and I don't relish the idea
    - Would mean users also need the ability to mark existing records inactive

#### Working on Update-Unknown (Get-Traits and Get-Overall)
- Directional indicator implementation (still not confident this is "what I want")
  - Add another array for $newReportPet and see what it looks like
    - Why not look at the approach I used in the spreadsheet? Something like
    - foreach ($row in $newReport){$traitValues += ($value = $row.$trait);Some-Get-Minimum-Function;Some-Get-Maximum-Function}

`$tableLow` maybe looks like this
| Field       | Comparison 1 | Comparison N | Result |
| ----------- | ------------ | ------------ | ------ |
| Alertness   | Integer      | Integer      | `Function Max-Value $tableLow.Alertness`
| Comparison2 | Integer      | Integer      | `Function Max-Value $tableLow.Alertness`


#### Source Data (Import-CSV)
- Added a column for active/inactive
- Starting to get a little clunky with > 20 pets in PRIVATE-KNOWNS.csv
- I really hate dealing with GUI elements in powershell, just get the logic all sorted then consider a web-enabled approach
- WISHLIST: Some people like to store their data pivoted so it's easy to copy/paste into AA, WebApp would need to provide a filtered / pivoted data view
  - Cheat: Borrow users source-data and write the view code in Google Sheets?  Inelegant and not portable.  Why am I considering this?

#### Selecting Known Pet
- CHANGES
  - Source data now includes a STATUS field, and I filter on import, selecting only **Active** canines
  - Allows CSV to contain historical data
    - You're going to need a lot of historical data if you want to make educated guesses at the breeding calculation formulas

[^1]: Players are the human beings.  Characters are the in-game persona running around.  A player may have many characters.