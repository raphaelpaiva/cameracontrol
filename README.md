Camera Control
==============

Original use case
-----------------
I do [cover song videos](https://www.youtube.com/playlist?list=PLYIe4iH7ysFKtJKiiv183Y4RTnnFSf3f4), mostly by myself and needed something to start / stop audio and video recording with a button. I can rig my audio software to call this script when I hit record, so that was it :)

Usage
-----

This script uses adb and [scrcpy](https://github.com/Genymobile/scrcpy) to monitor android device screens and to record video.

The idea for now is fairly simple:

1. Use `cameracontrol monitor` to start scrcpy monitoring all connected device screens
2. Open your favorite camera app
3. Use `cameracontrol record` to start / stop recording.

For now, it assumes that ADB and SCRCPY is on yout path. More options in the future.
