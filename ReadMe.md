# Glam Shot
![alt text](https://github.com/IAmAnthem/CanineCalculations/blob/79897d0c9ec1c1ae7b841d6059e237df79e797e7/GUI-v0.90.PNG)


# Release History
- v0.80 - Softlaunch, solicitation of feedback
- v0.81 - Allow for unsolved pets in source CSV
  - Any non-numeric will mark the trait as UNSOLVED during comparisons
  - Other known values for that pet should still help you refine your unknown
- v0.82 - Fix incorrect casting of Nimbleness, still need test for partial-knowns
- v0.83 - Add GUI selector to pick character / pet before pasting in comparison
- v0.90 - Refactor everything using Windows Presentation Framework (WPF)
- v0.91 - Cleanup broken stuff from Google Sheets integration tests
  

# How To Get and Run the Script (Canine-Comparator-GUI.ps1)
If you're already familiar with github, you don't need directions!
If you are not, try this.  

Pet-Relations.ps1 is just a starter and isn't really deeply tested.

Canine-Comparator-GUI.ps1 should be working if you have good data to start from
- From the repository main page: https://github.com/IAmAnthem/CanineCalculations
- Look for the Code button and click the down-carat
- Select the Download ZIP option
- Extract the zipfile contents to wherever
- Navigate to that folder in Windows Explorer
- Open KNOWNS.csv and copy the formatting out to a new file like MyPets.csv or something is a good idea
  - Partially known pets should now be working (i.e. if a trait is "10-20" or "10 to 20" I mark it unsolved and skip during comparison)
- Right click on `Canine-Comparator-GUI.ps1` and select Run with PowerShell
  - If you get a warning that the script is unsigned and you can't run it, you need to change the ExecutionPolicy
  - Right Click the Windows Start button
  - Click Windows PowerShell
  - Type `'Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser`
  - Try running the script again

# Operations within Canine-Comparator-GUI.ps1
- Click Load Database
  - Select a CSV file to use as your data source (KNOWNS.csv included to show you format, suggest you use your own file like MyPets.csv)
  - PROTIP: You can actually programmatically retrieve a CSV from Google Docs
    - I might add this with some sort of saved-configuration file so you can set up your source and pull it fresh each time
    - Note for me: `curl 'https://docs.google.com/spreadsheets/d/<yourkey>/export?exportFormat=csv',`
- Select the radio button indicating the direction you will be operating in
  - Example:  Dasher is an NPC and changes every time it spawns
    - if you did "compare my pet to dasher", the direction would be "Known to Unknown"
    - if you did "compare dasher to my pet", the diection would be "Unknown to Known"
- Select the KNOWN pet in your comparison by picking from the dropdown list
- To the right is a big text-entry window
  - Paste in the entire comparison block
  - Click Process Comparison for math and display operations
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
- A debugging / status window exists below the Process Comparison button
  - Various messages will report progress, status, and if you did something wrong
- `--- --- STATUS: Solved n of 17 --- ---` will report if any traits were solved
- Continue refining by selecting additional comparators from the dropdown and pasting in the comparison
- Change the placeholder "Name" value from "dummy" to whatever you want
  - Above the Set Name (Unique) button is text input box.  Type whatever you want here.
    - Use truely unique Name fields, or the dropdown won't work properly if you add this data to your CSV
- Share your results with someone by copying the hashtable at the far right
  - copy / paste should work fine with Ancient Anguish (converse mode)
  - Appearance is also reasonable in Facebook Messenger
- Export buttons are currently unavailable
  - What do you want this to do, if anything?

# Try it out!
Included in this repository are three text files, you can use to obtain a verified result.
- Validation files
  - Validation-KnownToUnknown.txt
  - Validation-UnknownToKnown.txt
  - Validation-RESULTS.txt

- Open the `Validation-UnknownToKnown.txt` file
- Launch the script
- Pick `KNOWNS.csv` as your source
- Select `UNKNOWN canine to a KNOWN canine`
- Select the known pet as `Ballad Fireball 730/55`
- Select the first comparison block in the Validation file (Ballad)
- Paste the entire block into the input window
- Click `Process Comparison` button, calculations are performed
  - Note the `--- --- STATUS: Solved 5 of 17 --- ---`
- Review the Column-based output to the right
  - Any `solved` traits will be a single number
  - Any `ranges` will appear as `lowNumber to highNumber`
  - TOTAL is a ranged subtotal of what we've calculated
  - Overall is only reporting the comparison we found in the string `Overall she seems to be ?????`
    - This can be useful, look at the results so far
      ```
      TOTAL = 700 - 728
      Overall  = 721 - 725
      ```
    - Even though we don't have it solved, we know for sure it must be in the range of $Overall

```
Name                           dummy
Alertness                      28 - 30
Appetite                       43 - 45
Brutality                      32
Development                    43 - 45
Eluding                        53 - 55
Energy                         27 - 29
Evasion                        55 - 57
Ferocity                       49 - 51
Fortitude                      45 - 47
Insight                        30 - 34
Might                          38 - 42
Nimbleness                     48
Patience                       33 - 35
Procreation                    51 - 53
Sufficiency                    36
Targeting                      40
Toughness                      49
TOTAL                          700 - 728
Overall                        721 - 725
```
- Continue to refine calculations, select 1 to add another comparison
- Select known pet # 2 - Cover Rocker
- Paste in the comparison block for COVER in the Validation-UnknownToKnown.txt file
- Click *Process Comparison*  for calculations to be performed
  - Notice we've solved more numbers! `--- --- STATUS: Solved 13 of 17 --- ---`
- Review the output again
```
Name                           dummy
Alertness                      29
Appetite                       45
Brutality                      32
Development                    43 - 44
Eluding                        53
Energy                         29
Evasion                        55 - 56
Ferocity                       51
Fortitude                      46
Insight                        34
Might                          40
Nimbleness                     48 - 44
Patience                       35
Procreation                    51 - 53
Sufficiency                    36
Targeting                      40
Toughness                      49
TOTAL                          716 - 716
Overall                        721 - 723
```
- Continue adding comparisons until you see you've solved 17 of 17!
- Your output result should match the result found in `Validation-RESULTS.txt`

# Blathering on about Ancient Anguish and Rangers

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
- Canine-Comparator-GUI.ps1
  - Everything that Stat-Canine did, but in a single pane of glass, windows UI

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
Currently that's PowerShell, not something sexy like a [Serverless Web Application](https://aws.amazon.com/serverless/build-a-web-app/).  Or some PHP/MySQL web app?  But maybe someday?

# Progress Notes - what am I working on?

## Data collection - an analysis of uncertain canine comparisons
- Need new characters (maybe 10? 12?) with traited canines of known stat (or at least very close to known).
  - Figure out more alt names, because OCD
- Cycle alts against a known that's reasonably solvable for them (don't try solving a 700+ with a collection of 300s)
- Drop output into think/feel buckets, include a datestamp and note time to reboot
  - randomizer has a good chance of changing per-boot, so be prepared for it to change
- Run data through statting script in think/feel groups and compare outputs in kvp format
  - Does the group of 'think' statters reach a consensus stat?
  - Does the group of 'feel' statters reach a consensus stat?
  - If so how do they compare to true values?

## Check the knowledge level
  - `if $knowledge -ne certain, abort` Well we can't do that because "listeners" can't see relationships, pinged Paldin
  - Future development: Determine the variations in think/feel
    - Is this predictable?
    - redshift/blueshift the results based on (whatever)

## Verbosity
- Currently spitting out a lot of noise (Write-Verbose) messages in the console
  - Disable this when I reach v1.0

# LICENSE
This project is licensed under the terms of the MIT license.

Repository image credit: Image by <a href="https://pixabay.com/users/sarahrichterart-1546275/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=3833915">Sarah Richter</a> from <a href="https://pixabay.com//?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=3833915">Pixabay</a>

[^1]: Players are the human beings.  Characters are the in-game persona running around.  A player may have many characters.  If you get into breeding, plan on at least 4 characters.