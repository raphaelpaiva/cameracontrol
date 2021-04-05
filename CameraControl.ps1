$devices = @(
 'fcff35d8',   # Mi9T
  '0051736433' # Z3
)

$ADBShell_VideoCommand = "shell am start -a android.media.action.VIDEO_CAPTURE"
$ADBShell_HomeCommand  = "shell input keyevent KEYCODE_HOME"
$ADBShell_RecordCommand  = "shell input keyevent KEYCODE_VOLUME_UP"

function RunADBCommand {
  param (
    [String]$device,
    [String]$command
  )
  Start-Process -FilePath "adb.exe" -ArgumentList "-s $device $command" -RedirectStandardOutput "adb-$device-out.txt" -RedirectStandardError "adb-$device-err.txt" -Wait
}

foreach($device in $devices)
{
  Start-Process -FilePath "scrcpy.exe" -ArgumentList "--serial $device -b 2M -m800 --stay-awake" -RedirectStandardOutput "scrcpy-$device-out.txt" -RedirectStandardError "scrcpy-$device-err.txt"
  RunADBCommand($device, $ADBShell_HomeCommand)
  RunADBCommand($device, $ADBShell_VideoCommand)
  RunADBCommand($device, $ADBShell_RecordCommand)
}


