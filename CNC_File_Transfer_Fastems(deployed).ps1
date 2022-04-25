$trancriptCurrent = "R:\Public\IT\Vantage_Utilities\CNC_Scripts\File Transfer\Fastems\LogTranscript_Current.txt"
$trancriptOld = "R:\Public\IT\Vantage_Utilities\CNC_Scripts\File Transfer\Fastems\LogTranscript_Old.txt"
$trancriptSize = 1MB
$counter = 0
$mazakCounter = 0
$date = (Get-Date -Format dd-mm-yyyy).ToString()
$time = (Get-Date -Format hh-mm-tt).ToString()
$timeMilliSec = (Get-Date -Format hh-mm-fff-tt).ToString()
#If the size of LogTranscript_Current exceeds 1MB move the contents from it to "LogTranscript_Old"
If(Test-Path -Path $trancriptCurrent -PathType Leaf){
    #check if Transcript is at its maximum size
    if((Get-Item -Path $trancriptCurrent).Length -ge $trancriptSize){
        # append the contents of the log file to another file 'LogTranscript_Old.Txt'
        Add-Content -Path $trancriptOld -Value (Get-Content -Path $trancriptCurrent)
        #clear the contents of 'LogTranscript_Current'
        Clear-Content -Path $trancriptCurrent
    }
}
Start-Transcript -Path $trancriptCurrent -Append
Write-Host " TRANSCRIPT DATE - $date"
Write-Host " TRANSCRIPT TIME - $time"


#Sources 
$srcMca = "\\MMS25163S1\Public\NcLib\FromNC\*"
$srcMcaNameChg ="\\MMS25163S1\Public\NcLib\FromNC"
$srcMazak= "\\MMS25163S1\Public\NcLib\FromNC\Mazak\*"
$srcMcaNameChgMazak = "\\MMS25163S1\Public\NcLib\FromNC\Mazak"
#Destination 
$destMca = "\\Sidney2\MfgLib\RevisedPrograms\MC-A"



Function MoveFiles{
    Param(
        [string]$src,
        [string]$dest,
        [string]$srcNameChange
    )
   Get-Item -Path $src -Exclude *Mazak* -ErrorAction SilentlyContinue | ForEach-Object{
        $counter++
        $fileName = $_.BaseName
        $fileNameExt = $_.Name
        Rename-Item -Path "$srcMcaNameChg\$fileNameExt"  -NewName ($fileName+"_"+"(Time-$timeMilliSec)"+$_.Extension);
        Write-Host "Time Stamp added to $fileName "
    }
    Move-Item -Path $src -Exclude *Mazak*  -Destination $dest -Force
    Write-Host "$counter file(s) moved to $dest"
 
} 
MoveFiles -src $srcMca -dest $destMca -srcNameChange $srcMcaNameChg




Function MoveMazakFiles{
    Param(
        [string]$srcMazak,
        [string]$dest,
        [string]$srcNameChange
    )
    Get-ChildItem $srcMazak -Recurse -ErrorAction SilentlyContinue | ForEach-Object{
        $mazakCounter++
        $fileName = $_.BaseName
        $fileNameExt = $_.Name
        Write-host $fileName -ForegroundColor Green
        Rename-Item -Path "$srcMcaNameChgMazak\$fileNameExt"  -NewName ($fileName+"_"+"(Time-$time)"+$_.Extension);  
    }
    Move-Item -Path $srcMazak  -Destination $dest -Force
    Write-Host ""$mazakCounter file(s) from Mazak folder moved to $dest""
}
MoveMazakFiles -srcMazak $srcMazak -dest $destMca -srcNameChange $srcMcaNameChg

Stop-Transcript