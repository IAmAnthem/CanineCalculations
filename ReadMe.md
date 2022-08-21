# Glam Shot
![alt text](https://github.com/IAmAnthem/CanineCalculations/blob/15c73ac96f3e9b0a71748816fea11ca41bc6c353/GUI-v0.90.PNG)


# Release History
- v0.80 - Softlaunch, solicitation of feedback
- v0.81 - Allow for unsolved pets in source CSV
  - Any non-numeric will mark the trait as UNSOLVED during comparisons
  - Other known values for that pet should still help you refine your unknown
- v0.82 - Fix incorrect casting of Nimbleness, still need test for partial-knowns
- v0.83 - Add GUI selector to pick character / pet before pasting in comparison
- v0.90 - Refactor everything using Windows Presentation Framework (WPF)
  

# How To Get and Run the Script
If you're already familiar with github, you don't need directions!  
If you are not, try this.  

`Pet-Relations.ps1` is just a starter and isn't really deeply tested.

`Canine-Comparator-GUI.ps1` should be working if you have good data to start from
- From the repository main page: https://github.com/IAmAnthem/CanineCalculations
- Look for the Code button and click the down-carat
- Select the Download ZIP option
- Extract the zipfile contents to wherever
- Navigate to that folder in Windows Explorer
- Open `KNOWNS.csv` and copy the formatting out to a new file like MyPets.csv or something is a good idea
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
- Stat-Canine.ps1 (mostly-console with some Windows Forms - deprecated)
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
Currently that's PowerShell, not something sexy like a [Serverless Web Application](https://aws.amazon.com/serverless/build-a-web-app/).  Or some PHP/MySQL web app?  But maybe someday?

# Progress Notes

## New-BreedingPlan.ps1
- Take a set of knowns and devise a three-stage breeding plan
  - Challenges: gender decisions
  - Query: last-step gender?
  - Decision: Do I want to expose this algorithm?  Lot of hours went into figuring it out

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

## Check the relationship level
  - not really relevant at this point
  - Futureproofing for some other need
  - Trying to decide between One Big Table and different tables for Traits / Relationships

## Work on Menu functionality
- WISHLIST
  - Insert this pet into database (prompt for fields to fill in for real name/owner/whatnot?) and updatecsv
  - This is a long way off and I don't relish the idea
    - Would mean users also need the ability to mark existing records inactive

## Working on Update-Unknown (Get-Traits and Get-Overall)
- Validation: larger data set, Unknown to Known looks good
- Validation: larger data set, Known to Unknown looks good
- Validation: mixed mode comparisons (KtoU, then UtoK, etc etc - seems OK from limited test)

## Verbosity
- Currently spitting out a lot of noise (Write-Verbose) messages in the console
  - Disable this when I reach v1.0

---

## Source Data (Import-CSV)
- Look at Google APIs and pulling / pushing to a source spreadsheet
  - Estimate 40 hours, I know nothing about Google APIs!
  - PowerShell
- Set up Google API Access
  - References:
    - [UMN Google Module](https://github.com/umn-microsoft-automation/UMN-Google)
      - From what I can tell, didn't refactor to remove Internet Explorer requirement
    - https://docs.microsoft.com/en-us/advertising/scripts/examples/authenticating-with-google-services#option3
      - Microsoft provides some help here I think

### Walkthrough of setup (Careful what goes into the repo!)
1. Go to Google developer console [API dashboard](https://console.cloud.google.com/projectselector2/apis/dashboard?supportedpurview=project)
2. Create `Create Project`
  1. Set Name to `CanineComparatorTest`
  2. Select `Create`
3. On Dashboard, click ENABLE APIS AND SERVICES
4. In the search box, enter sheets and click Google Sheets API
  1. click ENABLE
5. On Dashboard, click Credentials in the left navigation pane 
  1. click CONFIGURE CONSENT SCREEN. 
  2. If asked to select a User Type, select External, then click Create
  3. Enter data in the App Name name field (for example, `Canine Comparator Test`)
  4. Enter your email in the fields that ask for it, then click SAVE AND CONTINUE
  5. Click ADD OR REMOVE SCOPES
    1. Select Google Sheets API
    2. click Update
  6. Click SAVE AND CONTINUE
  7. Click ADD USERS
    1. enter your Google email and click ADD
  8. Click Save and Continue
  9. Review Oath consent screen summary and click Back to Dashboard
6. On Dashboard, click Credentials in the left navigation pane
7. Click Create credentials (dropdown) and select Oauth client ID
  1. From Application type dropdown
    1. Select Desktop app application type
    2. Enter a name for the client(for example, Canine Comparator creds)
    3. Click Create
  2. Copy your client ID and client secret to a file on your computer
    1. PROTECT THIS - it will have fill access to your data!
    2. BACK THIS UP - keep it in more than one secure location
  3. Download the JSON file too, because maybe we'll use that too
    1. PROTECT / BACK UP as above
8. Create a PowerShell script to get user consent and a refresh token.
  1. Create this script

```
# Develop Auth
function Get-GSheetsToken {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $jsonPath
    )
    $testJSON = Get-Content -Path $jsonPath | ConvertFrom-Json

    Write-Host $testJSON.installed.client_id
    Write-Host $testJSON.installed.project_id
    Write-Host $testJSON.installed.auth_uri
    Write-Host $testJSON.installed.token_uri
    Write-Host $testJSON.installed.auth_provider_x509_cert_url
    Write-Host $testJSON.installed.client_secret
    Write-Host $testJSON.installed.redirect_uris
    
    $clientId = $testJSON.installed.client_id
    $clientSecret = $testJSON.installed.client_secret
    $scope = "https://www.googleapis.com/auth/spreadsheets"
    # $scopes = "https://www.googleapis.com/auth/drive", "https://www.googleapis.com/auth/gmail.send"
    
    # Start-Process "https://accounts.google.com/o/oauth2/v2/auth?client_id=$clientId&scope=$([string]::Join("%20", $scopes))&access_type=offline&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob"
    Start-Process "https://accounts.google.com/o/oauth2/v2/auth?client_id=$clientId&scope=$([string]::Join("%20", $scope))&access_type=offline&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob"
     
    $code = Read-Host "Please enter the code"
       
    $response = Invoke-WebRequest https://www.googleapis.com/oauth2/v4/token -ContentType application/x-www-form-urlencoded -Method POST -Body "client_id=$clientid&client_secret=$clientSecret&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code&grant_type=authorization_code"
      
    # Write-Output "Refresh token obtained: " ($response.Content | ConvertFrom-Json).refresh_token
    $myRefreshToken = ($response.Content | ConvertFrom-Json).refresh_token
    return $myRefreshToken
}

$jsonPath = "C:\Users\winnd\OneDrive\Documents\Anguish\CanineComparatorCreds.json"
$myRefreshToken = Get-GSheetsToken -jsonPath $jsonPath
```




# LICENSE
This project is licensed under the terms of the MIT license.


Repository image credit: Image by <a href="https://pixabay.com/users/sarahrichterart-1546275/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=3833915">Sarah Richter</a> from <a href="https://pixabay.com//?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=3833915">Pixabay</a>

[^1]: Players are the human beings.  Characters are the in-game persona running around.  A player may have many characters.  If you get into breeding, plan on at least 4 characters.