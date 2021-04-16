$ADBShell_VideoCommand = "shell am start -a android.media.action.VIDEO_CAPTURE"
$ADBShell_HomeCommand  = "shell input keyevent KEYCODE_HOME"
$ADBShell_BackCommand  = "shell input keyevent KEYCODE_BACK"
$ADBShell_RecordCommand  = "shell input keyevent KEYCODE_VOLUME_UP"

$devices = @(
  @{ name = "Mi9T"
     id = 'fcff35d8'
     record_accept_command = $ADBShell_BackCommand 
  },
  @{ name = "Z3"
     id = '0051736433'
     record_accept_command = $ADBShell_HomeCommand 
  }
)

function Monitor {
  foreach ($device in $devices)
  {
    $id = $device.id
    Start-Process -FilePath "scrcpy.exe" -ArgumentList "--serial $id -b 2M -m800 --stay-awake" -RedirectStandardOutput "scrcpy-$id-out.txt" -RedirectStandardError "scrcpy-$id-err.txt"
  }
}

function RunADBCommand {
  param (
    [String]$Device,
    [String]$Command
  )
  Start-Process -FilePath "adb.exe" -ArgumentList "-s $Device $command" -RedirectStandardOutput "adb-$Device-out.txt" -RedirectStandardError "adb-$Device-err.txt" -Wait
}

function FullRecord {
  foreach ($device in $devices)
  {
    RunADBCommand -Device $device.id -Command $ADBShell_HomeCommand
    RunADBCommand -Device $device.id -Command $ADBShell_VideoCommand
    RunADBCommand -Device $device.id -Command $ADBShell_RecordCommand
  }
}
function FullStop {
  foreach ($device in $devices)
  {
    RunADBCommand -Device $device.id -Command $ADBShell_RecordCommand
    RunADBCommand -Device $device.id -Command $device.record_accept_command
  }
}

Function SimpleRecord {
  foreach ($device in $devices)
  {
    RunADBCommand -Device $device.id -Command $ADBShell_RecordCommand
  }
}

Function SimpleStop {
  foreach ($device in $devices)
  {
    RunADBCommand -Device $device.id -Command $ADBShell_RecordCommand
  }
}


$COMMAND = $args[0]

$COMMANDS = @{
  Record = (Get-Item function:SimpleRecord)
  Stop = (Get-Item function:SimpleStop)
  FullRecord = (Get-Item function:FullRecord)
  FullStop = (Get-Item function:FullStop)
  Monitor = (Get-Item function:Monitor)
}

Write-Output "Running $COMMAND"
& $COMMANDS[$COMMAND]
