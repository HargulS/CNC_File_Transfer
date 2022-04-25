$logPath = "R:\Public\IT\Vantage_Utilities\CNC_Scripts\File Transfer\Fastems\Log.txt"
$trancriptPath = "R:\Public\IT\Vantage_Utilities\CNC_Scripts\File Transfer\Fastems\LogTranscript.txt"
$getDate = Get-Date -Format "dddd MM/dd/yyyy HH:mm "
$counter = 0
$mazakCounter = 0
Start-Transcript -Path $trancriptPath -Append
Add-Content -Path $logPath -Value ("LOG CREATED $getDate") -PassThru

#Sources 
$srcMca = "\\MMS25163S1\Public\NcLib\FromNC\*"
$srcMcaNameChg ="\\MMS25163S1\Public\NcLib\FromNC"
$srcMazak= "\\MMS25163S1\Public\NcLib\FromNC\Mazak\*"
$srcMcaNameChgMazak = "\\MMS25163S1\Public\NcLib\FromNC\Mazak"
#Destination 
$destMca = "\\Sidney2\MfgLib\RevisedPrograms\MC-A"
#Time with milliseconds
$time = (Get-Date -Format hh-mm-fff-tt).ToString()


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
        Write-host $fileName -ForegroundColor Green
        Rename-Item -Path "$srcMcaNameChg\$fileNameExt"  -NewName ($fileName+"_"+"(Time-$time)"+$_.Extension);
        Add-Content -Path $logPath -Value ("Name changed: Time stamp added to $fileName ") -PassThru
    }
    Move-Item -Path $src -Exclude *Mazak*  -Destination $dest -Force
   Add-Content -Path $logPath -Value ("$counter file(s) moved to $dest") -PassThru
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
    Add-Content -Path $logPath -Value ("$mazakCounter file(s) from Mazak folder moved to $dest") -PassThru
}
MoveMazakFiles -srcMazak $srcMazak -dest $destMca -srcNameChange $srcMcaNameChg

Stop-Transcript