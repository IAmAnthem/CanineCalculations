# Develop Auth
# Prerequisite:  # https://github.com/PoshCode/Configuration
# Install-Module -Name Configuration -Scope CurrentUser

# Relies on PSGSuite project to access Google Sheets / Drive
# Install-Module -Name PSGSuite -Scope CurrentUser
Import-Module -Name Configuration
Import-Module -Name PSGSuite



<# Free level

DID THIS:
Set-PSGSuiteConfig -ConfigName MyConfig 
    -SetAsDefaultConfig 
    -ClientSecretsPath "C:\Users\winnd\OneDrive\Documents\GitHub\CanineCalculations\CanineComparatorCreds.json" 
    -AdminEmail winndm@gmail.com

Import the module: Import-Module PSGSuite
Run Get-GSGmailProfile -Verbose (or any other Gmail, Drive, Calendar, Contacts or Tasks command) to trigger the authentication/authorization process:

If you are using Windows PowerShell, you should see your browser open with a Google login prompt:

Authenticate using the AdminEmail account configured with Set-PSGSuiteConfig.
Allow PSGSuite to access the below scopes on your account that you desire.
You should see a message in your browser tab stating the following once complete: Received verification code. You may now close this window.

#>

$myToken = Get-GSToken -Scopes all
$myKnownsFileId = Get-GFileID -accessToken $myToken -fileName "TestKNOWNS"

<#
Example of importing as if a CSV
Import-GSSheet -SpreadsheetId '1rhsAYTOB_vrpvfwImPmWy0TcVa2sgmQa_9u976' -SheetName Sheet1 -RowStart 2 -Range 'B:C'
#>

$myArr = Import-GSSheet -SpreadsheetId $myKnownsFileId -SheetName KNOWNS -RowStart 1 -Range 'A:W'
# Well that is amazing.  It works.

# Lets try creating a new sheet inside a spreadsheet - maybe not this
# Export-GSSheet -SpreadsheetId $myKnownsFileId -SheetName Another -Array $myArr

# Manually created a new tab called Sheet2 - can I add data to it? YUP
Add-GSSheetValues -SpreadsheetId $myKnownsFileId -Array $myArr -SheetName Sheet2 -Range 'A:Z'

