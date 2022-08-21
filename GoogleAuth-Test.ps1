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