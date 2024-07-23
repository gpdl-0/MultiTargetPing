$host.ui.RawUI.WindowTitle = “MultiTargetPing v0.1 # By gpdl-0”

Write-Host "`n========== MultiTargetPing v0.1 # By gpdl-0 ==========`n" -BackgroundColor Black -ForegroundColor White

Write-Host "After each ping the results will be appended to output file (.csv)."

$ping_interval = (Read-Host "`nEnter delay in seconds between each ping loop") -as [int]

$contine = Read-Host "`nPress Q to exit or`nPress ENTER to start pinging"

if ($contine -eq 'q')
    {
        Write-Host "`nExiting..." 
        Start-Sleep -Seconds 3 
        Exit 
     }

$Output= @()
$pcname = $env:COMPUTERNAME
$timestamp = (Get-Date).ToString('ddMMyyHHmmss')
$names = Get-content "targets_file.txt"

  while ($true) {
    Write-Host "------------------------------------"
    foreach ($name in $names){
      $Time = (Get-Date).ToString(“HH:mm:ss”)
      $Date = Get-Date -Format dd/MM/yy
      $response = (Test-Connection -ComputerName $name -Count 2 -BufferSize 52 -ErrorAction SilentlyContinue | measure-Object -Property ResponseTime -Average).average
      if ($response -ne $null){
        $response = ($response -as [int]) 
        $Output+= "$Date,$Time,$name,up,$response ms,$pcname"
        Write-Host "$Date,$Time,$Name,up,$response ms" -ForegroundColor Green
      }else{
        $Output+= "$Date,$Time,$name,down,no response"
        Write-Host "$Date,$Time,$Name,down,no response" -ForegroundColor Red
        #Sending alert to Telegram telling that ping between "$pcname" and "$Name" failed
        #Invoke-RestMethod -Uri "https://api.telegram.org/$GROUP OR BOT CODE$:##### API KEY ######/sendMessage?chat_id=-4178484810&text=$pcname->$Name-is-down" -Method Post
      }
    }
    
    $Output | Out-file ping_output_$timestamp.csv
    #Checking IPs each n seconds:
    Start-Sleep -Seconds $ping_interval
}
