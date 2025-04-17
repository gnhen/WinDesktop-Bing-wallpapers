# Define path to OneDrive Pictures folder
$onedrivePictures = Join-Path $env:OneDrive 'Pictures\BingWallpapers'

# Create folder if it doesn't exist
if (!(Test-Path $onedrivePictures)) {
    New-Item -ItemType Directory -Path $onedrivePictures | Out-Null
}

# Fetch Bing image metadata
$response = Invoke-RestMethod "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US"
$imagePath = $response.images[0].url

# Replace resolution and construct full image URL
$uhdImagePath = $imagePath -replace "1920x1080", "UHD"
$fullImageUrl = "https://www.bing.com$uhdImagePath"

# Delete all previous Bing wallpapers in the folder
Get-ChildItem -Path $onedrivePictures -Filter "*.jpg" | Remove-Item -Force

# Create filename using current date
$dateString = Get-Date -Format "yyyy-MM-dd"
$downloadPath = Join-Path $onedrivePictures "$dateString.jpg"

# Download the new UHD image
Invoke-WebRequest -Uri $fullImageUrl -OutFile $downloadPath

# Set as wallpaper using user32.dll
Add-Type @"
using System.Runtime.InteropServices;
public class Wallpaper {
  [DllImport("user32.dll", SetLastError = true)]
  public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

[Wallpaper]::SystemParametersInfo(20, 0, $downloadPath, 3)
