
$trancriptCurrent = "C:\NIMS_App\NML_CNC_File_Transfer\FileTransfer_Part1\LogTranscript_Current.txt"
$trancriptOld = "C:\NIMS_App\NML_CNC_File_Transfer\FileTransfer_Part1\LogTranscript_Old.txt"
$trancriptSize = 1MB
$counter = 0
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
$srcMt01 = "\\Mt01t\programs\RECEIVE\*"
$srcMt01NameChg ="\\Mt01t\programs\RECEIVE"
$srcMC2o = "\\vmnmlfileserver\Predator\Revised Programs\MC2o\*"
$srcMC2oNameChg ="\\vmnmlfileserver\Predator\Revised Programs\MC2o"
$srcHm03 = "\\vmnmlfileserver\Predator\Revised Programs\H3\*"
$srcHm03NameChg ="\\vmnmlfileserver\Predator\Revised Programs\H3"
$srcMt02 = "\\Mt02t\programs\RECEIVE\*"
$srcMt02NameChg ="\\Mt02t\programs\RECEIVE"


#Destination 
$destMt01 = "\\Sidney2\MfgLib\RevisedPrograms\MT01"
$destMC2o = "\\Sidney2\MfgLib\RevisedPrograms\MC2old"
$destHm03 = "\\Sidney2\MfgLib\RevisedPrograms\H3"
$destMt02 = "\\Sidney2\MfgLib\RevisedPrograms\MT02"

Function MoveFiles{
    Param(
        [string]$src,
        [string]$dest,
        [string]$srcNameChange
    )
   Get-ChildItem -Force -Recurse $src -ErrorAction SilentlyContinue -ErrorVariable SearchError | ForEach-Object{
        $counter++
        $fileName = $_.BaseName
        $fileNameExt = $_.Name
        Rename-Item -Path "$srcMcaNameChg\$fileNameExt"  -NewName ($fileName+"_"+"(Time-$timeMilliSec)"+$_.Extension);
        Write-Host "Time Stamp added to $fileName "  
    }
    Move-Item -Path $src  -Destination $dest -Force
    Write-Host"$counter file(s) moved to $dest"
} 

MoveFiles -src $srcMt01 -dest $destMt01 -srcNameChange $srcMt01NameChg
MoveFiles -src $srcMC2o -dest $destMC2o -srcNameChange $srcMC2oNameChg
MoveFiles -src $srcHm03 -dest $destHm03 -srcNameChange $srcHm03NameChg
MoveFiles -src $srcMt02 -dest $destMt02 -srcNameChange $srcMt02NameChg


Stop-Transcript