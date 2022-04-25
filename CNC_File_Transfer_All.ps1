$logPath = "C:\NIMS_App\NML_CNC_File_Transfer\FileTransfer_Part1\Log.txt"
$trancriptPath = "C:\NIMS_App\NML_CNC_File_Transfer\FileTransfer_Part1\LogTranscript.txt"
$getDate = Get-Date -Format "dddd MM/dd/yyyy HH:mm "
$counter = 0
Start-Transcript -Path $trancriptPath -Append
Add-Content -Path $logPath -Value ("LOG CREATED $getDate") -PassThru


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
        $fileName = $_.Name
        # Check for duplicate files
        $file = Test-Path -Path $dest\$fileName
        Write-Output $file
        if($file)
        {
        "$srcNameChange\$fileName" | Rename-Item -NewName ("Copy_"+$fileName);
        Add-Content -Path $logPath -Value ("$fileName exists in destination folder. Name change was successful") -PassThru
        }   
    }
    Move-Item -Path $src  -Destination $dest -Force
    Add-Content -Path $logPath -Value ("$counter file(s) moved to $dest") -PassThru
} 

MoveFiles -src $srcMt01 -dest $destMt01 -srcNameChange $srcMt01NameChg
MoveFiles -src $srcMC2o -dest $destMC2o -srcNameChange $srcMC2oNameChg
MoveFiles -src $srcHm03 -dest $destHm03 -srcNameChange $srcHm03NameChg
MoveFiles -src $srcMt02 -dest $destMt02 -srcNameChange $srcMt02NameChg


Stop-Transcript