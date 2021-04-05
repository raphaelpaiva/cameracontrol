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

function Record {
  foreach ($device in $devices)
  {
    RunADBCommand -Device $device.id -Command $ADBShell_HomeCommand
    RunADBCommand -Device $device.id -Command $ADBShell_VideoCommand
    RunADBCommand -Device $device.id -Command $ADBShell_RecordCommand
  }
}
function Stop {
  foreach ($device in $devices)
  {
    RunADBCommand -Device $device.id -Command $ADBShell_RecordCommand
    RunADBCommand -Device $device.id -Command $device.record_accept_command
  }
}

$COMMAND = $args[0]

$COMMANDS = @{
  Record = (Get-Item function:Record)
  Monitor = (Get-Item function:Monitor)
  Stop = (Get-Item function:Stop)
}

Write-Output "Running $COMMAND"
& $COMMANDS[$COMMAND]
