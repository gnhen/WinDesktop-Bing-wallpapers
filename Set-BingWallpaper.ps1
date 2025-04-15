Param(
    [ValidateSet('auto', 'en-US', 'en-GB', 'fr-FR', 'de-DE', 'zh-CN')][string]$locale = 'auto',
    [ValidateSet('auto', '1920x1080', '1920x1200', '1366x768', '1280x720', '1024x768')][string]$resolution = 'auto',
    [string]$downloadFolder = "$([Environment]::GetFolderPath("MyPictures"))\Wallpapers"
)

$today = (Get-Date).ToString("yyyy-MM-dd")
$hostname = "https://www.bing.com"
$market = if ($locale -eq 'auto') { "" } else { "&mkt=$locale" }
$uri = "$hostname/HPImageArchive.aspx?format=xml&idx=0&n=1$market"

# Determine resolution
if ($resolution -eq 'auto') {
    Add-Type -AssemblyName System.Windows.Forms
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen
    $w = $screen.Bounds.Width
    $h = $screen.Bounds.Height
    $resolution = if ($w -le 1024) { '1024x768' } elseif ($w -le 1280) { '1280x720' } elseif ($w -le 1366) { '1366x768' } elseif ($h -le 1080) { '1920x1080' } else { '1920x1200' }
}

# Ensure folder exists
if (!(Test-Path $downloadFolder)) {
    New-Item -ItemType Directory -Path $downloadFolder | Out-Null
}

# Check if today's wallpaper already set
$currentWallpaper = Get-ItemPropertyValue -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper
if ($currentWallpaper -like "*$today.jpg") {
    Write-Host "Today's wallpaper already set. No update needed."
    # Still perform cleanup
    Get-ChildItem -Path $downloadFolder -Filter *.jpg | Where-Object { $_.Name -ne "$today.jpg" } | Remove-Item
    exit 0
}

# Download today's image
try {
    $xml = [xml](Invoke-WebRequest -Uri $uri -ErrorAction Stop).Content
    $urlBase = $xml.images.image.urlBase
    $imageUrl = "$hostname${urlBase}_$resolution.jpg"
    $localFile = Join-Path $downloadFolder "$today.jpg"

    if (!(Test-Path $localFile)) {
        (New-Object System.Net.WebClient).DownloadFile($imageUrl, $localFile)
    }
}
catch {
    Write-Warning "Failed to get or download Bing wallpaper. Trying fallback."
    $fallbackJsonPath = Join-Path $PSScriptRoot "fallback.json"
    if (Test-Path $fallbackJsonPath) {
        try {
            $fallbackConfig = Get-Content $fallbackJsonPath -Raw | ConvertFrom-Json
            if ($fallbackConfig.imagePath) {
                $localFile = $fallbackConfig.imagePath
                Write-Host "Using fallback image path from fallback.json"
            }
            else {
                Write-Warning "No imagePath found in fallback.json"
                $localFile = Join-Path $downloadFolder "$today.jpg"
            }
        }
        catch {
            Write-Warning "Error parsing fallback.json: $_"
            $localFile = Join-Path $downloadFolder "$today.jpg"
        }
    }
    else {
        Write-Warning "fallback.json not found in script directory"
        $localFile = Join-Path $downloadFolder "$today.jpg"
    }
    if (!(Test-Path $localFile)) {
        Write-Error "Fallback image also not found. Exiting."
        exit 1
    }
}

# Set the wallpaper
Add-Type -TypeDefinition @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
[Wallpaper]::SystemParametersInfo(20, 0, $localFile, 3)
Write-Host "Wallpaper updated to: $localFile"

# Delete any non-today wallpapers in the folder
Get-ChildItem -Path $downloadFolder -Filter *.jpg | Where-Object { $_.Name -ne "$today.jpg" } | Remove-Item
