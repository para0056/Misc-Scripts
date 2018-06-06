<#
.Synopsis
   Clean-Movies moves all .avi and .mp4 files from one folder to another and sorts/renames them
.DESCRIPTION
   Clean-Movies searches the source path for all .avi and .mp4 files (add other types in the $IncludeFileTypes variable) and will then move/sort them.
   Movies and TV shows are moved to seperate subfolders within the destination path.  These subfolders can be modified by changing the $MovieFolderName
   and $TVFolderName variables.

   All scene info (ie - .HDTV.x264-EXCELLENCE ) info is stripped off and all extra periods and any other non-word characters are replaced with spaces.

   If the script detects that there is season and episode info in the file name (S##E##) then it will determine the show name and season and create
   folders (if not already there) for each season inside a folder for each show.

   Movies include the year if detected.

   If no year or season/episode is found then it is assumed that the video is a movie and sorted as such. Since there is no way to know 
   what is part of the video name and what is scene info so nothing is removed from the file name except non-word characters.

   If a duplicate file name is detected in the destination folder then the new file has _DUP_## appended to the end of the filename, where ## is a 
   random number.

   A logfile is created (where the script is run in a logs folder) in case some renaming issues occur to allow you to figure out what happened and 
   to find out the original names of the files. The location can be changed with the $LogFile variable.

   In addition to writing the results to the logfile, they are also output to the console.  Any results in yellow are duplicates or it wasn't able
   to determine if it was a movie or TV.


.EXAMPLE
   ./Clean-movies.ps1
      Run the script with default options
.EXAMPLE
   ./Clean-movies.ps1 -SourcePath "\\Server\Torrents" -DestinationPath "\\Server\Videos"
      Run the script but specify different source and destination paths
.NOTES
   VERSION 1.0
    - Initial release

   A shortcut to the script can be created that you can double click to run by entering the following as the shortcuts target
   Make sure to change the location that you have saved the script.

   C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -file "C:\LOCATION OF SCRIPT\Clean-Movies.ps1"

#>

<#Notes for things to change.
- for files without S##E## or year, do a regex search for HDRIP or DVDRIP or similar and use that instead
- Doesn't account for any subtitle files
- add switch to not include year for movies
- progress bar

#>

[CmdletBinding()]
    Param
    (
        # SourcePath is where the script will look for the video files to be moved
        [Parameter()]
        [alias("Source")]
        $SourcePath = "\\server\Torrents",

        # DestinationPath is the base folder wheret the script will move the video files to
        [Parameter()]
        [alias("Dest","Destination")]
        $DestinationPath = "\\server\Videos"

    )


#Other variables needed for correct functioning of the script
$IncludeFileTypes = @("*.mp4","*.avi")
$TVSplit = "S[0-9][0-9]E[0-9][0-9]" 
$MovieSplit = "19[0-9][0-9]|20[0-9][0-9]"
$fileSplitSearch =  "19[0-9][0-9]|20[0-9][0-9]|S[0-9][0-9]E[0-9][0-9]"
$fileSplit=""
$IsTV=$false
$MovieFolderName = "\001 - Movies\New\"
$TVFolderName = "\002 - TV Shows\"
$LogFile = $PSScriptRoot +"\logs\ChangeLog_movies.csv"


#Function used to remove all text after the year/episode info 
#Source: http://stackoverflow.com/questions/5831479/powershell-remove-text-from-end-of-string
function Remove-TextAfter
{   
    param (
        [Parameter(Mandatory=$true)]
        $string, 
        [Parameter(Mandatory=$true)]
        $value,
        [Switch]$Insensitive
    )

    $comparison = [System.StringComparison]"Ordinal"
    if($Insensitive) 
    {

        $comparison = [System.StringComparison]"OrdinalIgnoreCase"
    }

    $position = $string.IndexOf($value, $comparison)

    #manipulate the cutoff if necessary
    $newposition = $position

    if($position -ge 0) 
    {
        $string.Substring(0, $newposition + $value.Length)
    }
}

#Start of script
$files = Get-ChildItem $SourcePath -Recurse -include $IncludeFileTypes -force -file

#Re-iterate each file in the $files array and perform the rename function
ForEach($file in $files)
{
    $IsTV=$false
    $fileextension = $file.extension
    $filebasename = $file.BaseName
    $OutColour = 'green'
 
    #remove all non-word characters (.,# etc) and double spaces and replace them with a single space
    $filebasenamewithcharactersreplaced = $filebasename -replace "\W"," " -replace "  "," "


    #Define $fileSplit by extracting only the part of the string that matches $MovieSplit or $TVSplit
    $fileSplit = $filebasename | select-string -pattern $fileSplitSearch -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }

    IF($fileSplit -match $TVSplit) {
        $IsTV = $true
    } elseif ($fileSplit -match $MovieSplit) {
        $filebasenamewithcharactersreplaced = $filebasenamewithcharactersreplaced -replace "$fileSplit","($fileSplit)"
        $fileSplit = "("+$fileSplit+")"
    }
    
    if($fileSplit -ne $null) {    
        #Define $newFileName to be the filename with everything after the $fileSplit removed
        $newFileName = Remove-TextAfter $filebasenamewithcharactersreplaced $fileSplit

    } ELSE {
        #When no $fileSplit has been detected, $filebasenamewithcharactersreplaced cannot be split so assume its a movie
        #Unfortunately that means we can't remove the scene info from the end
        #Define $newFileName to match the new desired moviename to be used for the file name
        $newFileName = $filebasenamewithcharactersreplaced
        $OutColour = 'yellow'

    }

    #Define $newfilennamecomplete to match the desired $newFileName + the $fileextension
    $newfilenamecomplete = "$newFileName$fileextension"

    if ($file -notlike "thumbs*"){
        #Detect if its a tv show and if so then find the season # and show name.
        if($IsTV -eq $true) {
            [int]$season=$fileSplit.substring(1,2) #Extact season number
            $showname=($newFileName -replace "\S*\s*$").trim() #This finds the last space and removes everything after it
            $newPath="$DestinationPath$TVFolderName$showname"+"\Season "+$Season+"\"
        } elseif($IsTV -ne $true) {
            $newPath ="$DestinationPath$MovieFolderName"
        }
        if(!(Test-Path $newPath)) {
            New-Item -Path $newPath -ItemType Directory -Force | Out-Null
        }

        #Check if there is already a file in the new location by the new name and if so then append _DUP_ + Random # from 1-50
        while((Test-Path $newPath$newfilenamecomplete)) {
            $newfilenamecomplete=$newfilename+"_DUP_"+(Get-Random -min 1 -max 50)+$fileextension
            $OutColour = 'yellow'
        }

        #Write to screen what changes are being made
        Write-Host "$file " -ForegroundColor Magenta -nonewline; Write-Host "--> " -nonewline;Write-Host "$newPath$newfilenamecomplete " -ForegroundColor $OutColour;

        #Write log of processed files with process date/time,old file name, new file name and size
        #Should something have gone wrong, you can check what the old name was

        $LogObj = New-Object -TypeName psobject -Property ([ordered]@{
            'Date/Time'=get-date -format s;
            'Old File Name'=$file;
            'New File Name'= "$newPath$newfilenamecomplete";
            'File Length (MB)'= ($file.length)/1mb;
        })

        $Logobj | export-csv $LogFile -Append -NoTypeInformation

        #Perform the actual rename
        Move-Item -literalpath $file.FullName -Destination $newpath$newfilenamecomplete #-Force

    }
}

#Check for any empty folders in the source location and delete if found
#Get-ChildItem -Path "$SourcePath" -Directory | Where-Object {(Get-ChildItem -Path $_.FullName -Recurse) -eq $null} | Remove-Item


#Read-Host "Press enter to continue ..."