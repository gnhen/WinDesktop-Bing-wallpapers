Bing image of the day
=====================
This Windows PowerShell script automatically fetches the Bing image of
the day and sets it as your desktop wallpaper.

The script uses the XML page of [Microsoft Bing](https://www.bing.com/)
to download the images and directly applies them as your wallpaper.

Automatic Wallpaper Setting
--------------------------
The `Set-BingWallpaper.ps1` script handles everything automatically:
1. Downloads the current Bing image of the day
2. Sets it as your desktop wallpaper immediately
3. Skips downloading if today's image is already set as wallpaper
4. Uses a fallback image if the download fails

Script options
--------------
The script supports several options which allows you to customize the
behavior.

* `-locale` Get the Bing image of the day for this
  [region](https://msdn.microsoft.com/en-us/library/dd251064.aspx).

  **Possible values** `'auto'`, `'en-US'`, `'en-GB'`, `'fr-FR'`, `'de-DE'`, `'zh-CN'`

  **Default value** `'auto'`

  **Remarks** By using the value `'auto'`, Bing will attempt to
  determine an applicable locale based on your IP address.

* `-resolution` Determines which image resolution will be downloaded.
  If set to `'auto'` the script will try to determine which resolution
  is more appropriate based on your primary screen resolution.

  **Possible values** `'auto'`, `'1024x768'`, `'1280x720'`, `'1366x768'`, 
  `'1920x1080'`, `'1920x1200'`

  **Default value** `'auto'`

* `-downloadFolder` Destination folder to download the wallpapers to.

  **Default value**
  `"$([Environment]::GetFolderPath("MyPictures"))\Wallpapers"`
  (the subfolder `Wallpapers` inside your default Pictures folder)

  **Remarks** The folder will automatically be created if it doesn't
  exist already.

Setting up a fallback image
--------------------------
If the script fails to download today's Bing image (for example, due to network issues), it can use a fallback image instead. To configure this:

1. Create a file named `fallback.json` in the same directory as the script
2. Add the following content, specifying the path to your desired fallback image:

```json
{
  "imagePath": "C:\\Path\\To\\Your\\Fallback\\Image.jpg"
}
```

Replace the path with the full path to your preferred fallback image. Make sure to use double backslashes in the path.

Using the script
=====================

Running the script manually
-------------------------
Simply run the PowerShell script to immediately update your wallpaper:
```powershell
.\Set-BingWallpaper.ps1
```

Or customize it with parameters:
```powershell
.\Set-BingWallpaper.ps1 -locale "en-US" -resolution "1920x1080" -downloadFolder "D:\Wallpapers"
```

Setting up automatic execution
----------------------------
First, make sure that you can actually run PowerShell scripts.
You might have to set the execution policy to unrestricted by running
`Set-ExecutionPolicy Unrestricted` in a PowerShell window executed with
administrator rights.
Additionally, you might need to unblock the file since you downloaded
the file from an untrusted source on the Internet.
You can do this by running `Unblock-File <path to the script>` as
administrator.
Note that the script itself doesn't need to be run as administrator!

You can configure to run the script periodically using "Task Scheduler."
Open Task Scheduler and click `Action` ⇨ `Create Task…`.
Enter a name and description that you like.
Next, add a trigger to run the task once a day.
Finally, add the script as an action.
Run the program `powershell` with the arguments `-WindowStyle Hidden
-file "<path to the script>" <optional script arguments>`.

Unlike the older approach, you don't need to manually configure a slideshow - 
the script directly sets your wallpaper to the latest Bing image of the day.
