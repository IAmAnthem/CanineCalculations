# Release History
- v0.80 - Softlaunch, solicitation of feedback
- v0.81 - Allow for unsolved pets in source CSV
  - Any non-numeric will mark the trait as UNSOLVED during comparisons
  - Other known values for that pet should still help you refine your unknown
  

# How To Get and Run the Script (Stat-Canine.ps1)
If you're already familiar with github, you don't need directions!
If you are not, try this.  

Pet-Relations.ps1 is just a starter and isn't really deeply tested.

Stat-Canine.ps1 should be working if you have good data to start from
- From the repository main page: https://github.com/IAmAnthem/CanineCalculations
- Look for the Code button and click the down-carat
- Select the Download ZIP option
- Extract the zipfile contents to wherever
- Navigate to that folder in Windows Explorer
- Open KNOWNS.csv and copy the formatting out to a new file like MyPets.csv or something is a good idea
  - Partially known pets should now be working (i.e. if a trait is "10-20" I mark it unsolved and skip during comparison)
- Right click on Stat-Canine.ps1 and select Run with PowerShell
  - If you get a warning that the script is unsigned and you can't run it, you need to change the ExecutionPolicy
  - Right Click the Windows Start button
  - Click Windows PowerShell
  - Type 'Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
  - Try running the script again

# Operations within Stat-Canine.ps1
- Select a CSV file to use as your data source (KNOWNS.csv included to show you format, suggest you use your own file like MyPets.csv)
- Select the direction you will be operating in
  - Example:  Dasher is an NPC and changes every time it spawns
    - if you did "compare my pet to dasher", the direction would be "Known to Unknown"
    - if you did "compare dasher to my pet", the diection would be "Unknown to Known"
- Select the KNOWN pet in your comparison by number
- The text-entry window appears, the title bar reminds you the direction it expects to see
  - Paste in the entire comparison block and click OK (or hit ENTER) for the comparison to be processed
  - All comparison text **must be certain**
    - From the player's perspective, you should see **You are certain that...**
    - If you are listening to someone compare out loud, make sure THEY saw the **certain** message
      - Bug Paldin about getting 'out loud' to include **"Playername says: I am certain that *target* is:"**
```
  compare fox 2 to petname
You look hard at a very large merle grey trained fox comparing to a very
large light grey trained fox ...
You are certain that fox 2 is:
 Alertness seems slightly inferior.
 Appetite seems slightly inferior.
 Brutality seems barely better.
 Development seems slightly inferior.
 Eluding seems marginally better.
 Energy seems barely better.
 Evasion seems slightly better.
 Ferocity seems marginally inferior.
 Fortitude seems marginally inferior.
 Insight seems barely inferior.
 Might seems slightly better.
 Nimbleness seems marginally better.
 Patience seems marginally inferior.
 Procreation seems slightly inferior.
 Sufficiency seems barely inferior.
 Targeting seems marginally better.
 Toughness seems marginally better.
Overall he seems to be inferior.
They seem to be unrelated.
```
- A warning message will appear if the comparison text does not include CERTAIN
- `--- --- STATUS: Solved n of 17 --- ---` will report if any traits were solved
- Select option 3 to see the range of values currently
- Select 1 or 2 to continue processing comparisons

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

My estimate is something over 12,000 canines have been tamed.  The highest traited pets are a bit under halfway to the maximum value.  It took YEARS.


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
- WISHLIST
  - Insert this pet into database (prompt for fields to fill in for real name/owner/whatnot?) and updatecsv
  - This is a long way off and I don't relish the idea
    - Would mean users also need the ability to mark existing records inactive


#### Working on Update-Unknown (Get-Traits and Get-Overall)
- Validation: larger data set, Unknown to Known looks good
- Validation: larger data set, Known to Unknown looks good
- Validation: mixed mode comparisons (KtoU, then UtoK, etc etc - seems OK from limited test)


#### Source Data (Import-CSV)
- User request - add logic to allow inclusion of partially-solved canines in KNOWNS.csv
  - Logic something like (if $arr.field matches any non-numeric (\D), set field value to UNSOLVED)
- Added a column for active/inactive
- Starting to get a little clunky with > 20 pets in PRIVATE-KNOWNS.csv
- I really hate dealing with GUI elements in powershell, just get the logic all sorted then consider a web-enabled approach
- Would you prefer a GUI pick-list?
  - Click to select a known pet, click OK to proceed with inputting the comparison
- WISHLIST: Some people like to store their data pivoted so it's easy to copy/paste into AA, WebApp would need to provide a filtered / pivoted data view
  - Cheat: Borrow users source-data and write the view code in Google Sheets?  
  Inelegant and not portable.  *Why am I considering this?*

#### Selecting Known Pet
- CHANGES
  - Source data now includes a STATUS field, and I filter on import, selecting only **Active** canines
  - Allows CSV to contain historical data
    - You're going to need a lot of historical data if you want to make educated guesses at the breeding calculation formulas

# LICENSE
This project is licensed under the terms of the MIT license.


Repository image credit: Image by <a href="https://pixabay.com/users/sarahrichterart-1546275/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=3833915">Sarah Richter</a> from <a href="https://pixabay.com//?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=3833915">Pixabay</a>

[^1]: Players are the human beings.  Characters are the in-game persona running around.  A player may have many characters.  If you get into breeding, plan on at least 4 characters.