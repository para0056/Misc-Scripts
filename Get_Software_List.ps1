#Basic script to export a list of installed software
#Author: Nick Paradis
#Date Created: 2018-12-28


#Define date variable and format
$currentDate = Get-Date -UFormat "%Y.%m.%d"

#Define the location where the list will be saved as %PROFILE%\Desktop
$savePath = [Environment]::GetFolderPath('Desktop')

echo "**********************************************************************" > $savePath\$currentDate+InstalledPrograms-PS.txt
echo " List of 32-bit applications installed" >> $savePath\$currentDate+InstalledPrograms-PS.txt
echo "**********************************************************************" >> $savePath\$currentDate+InstalledPrograms-PS.txt
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize >> $savePath\$currentDate+InstalledPrograms-PS.txt
echo "" >> $savePath\$currentDate+InstalledPrograms-PS.txt

echo "**********************************************************************" >> $savePath\$currentDate+InstalledPrograms-PS.txt
echo " List of 64-bit applications installed" >> $savePath\$currentDate+InstalledPrograms-PS.txt
echo "**********************************************************************" >> $savePath\$currentDate+InstalledPrograms-PS.txt
Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table -AutoSize >> $savePath\$currentDate+InstalledPrograms-PS.txt
