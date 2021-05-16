Camera Control
==============

Original use case
-----------------
I do [cover song videos](https://www.youtube.com/playlist?list=PLYIe4iH7ysFKtJKiiv183Y4RTnnFSf3f4), mostly by myself using my android phone and needed something to start / stop video recording when I hit record in the audio software. I can rig my audio software to call this script when I hit record, so that was it :)

Features
--------

* Start / Stop recording
* Monitoring via [scrcpy]
* Save or discard last take (the last recorded video)

Usage
-----

This script uses adb and [scrcpy](https://github.com/Genymobile/scrcpy) to monitor android device screens and to record video.

The idea for now is fairly simple:

1. Use `cameracontrol monitor` to start [scrcpy], monitoring all connected device screens
2. Open your favorite camera app
3. Use `cameracontrol record` to start / stop recording.
4. Use `cameracontrol save_last_file` to save the last recorded video in a separated folder in the default camera roll directory.
5. Use `cameracontrol delete_last_file` to discard the last recorded video.

This way you can quickly record and select only the good takes without having to search through many video files.

Discarded videos are not deleted for safety. They are marked with a _DISCARDED suffix so you can easily find and delete them later.

Command line arguments
----------------------
```
usage: cameracontrol.exe [-h] [-q] [--dry-run] [--project-name PROJECT_NAME] [{record,monitor,save_last_file,delete_last_file}]

I can help you recording and selecting takes using your android phone.

positional arguments:
  {record,monitor,save_last_file,delete_last_file}
                        What should i do?

optional arguments:
  -h, --help            show this help message and exit
  -q, --quiet           Should i tell you what am I doing?
  --dry-run             Should i actually do stuff or just print what I would do?
  --project-name PROJECT_NAME
                        I'll use this to name a folder so you can quickly find your good takes :)
```

Requirements
------------

For now, it assumes that [ADB] and [SCRCPY] are installed and on your path. More flexibility in the future.

[scrcpy]: https://github.com/Genymobile/scrcpy
[ADB]: https://developer.android.com/studio/releases/platform-tools