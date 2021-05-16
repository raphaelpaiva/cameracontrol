from collections import UserString
import subprocess
import argparse
from typing import Callable
from ppadb.client import Client as AdbClient
from ppadb.device import Device

DEFAULT_VIDEO_DIR = "/sdcard/DCIM/Camera"
DEFAULT_VIDEO_FILE_PREFFIX = "VID"
DEFAULT_SAVE_DIR  = f"{DEFAULT_VIDEO_DIR}"

ADBShell_RecordCommand = "input keyevent KEYCODE_VOLUME_UP"

ADBShell_CreateSaveDirCommand = "mkdir -p"
ADBShell_GetLastFileCommand = f"ls -rt {DEFAULT_VIDEO_DIR} | tail -n 1"

RC_ADB_NOT_RUNNING = 1

COMMAND_CHOICES = ['record', 'monitor', 'save_last_file', 'delete_last_file']

def main():
  parser = argparse.ArgumentParser(description="I can help you recording and selecting takes using your android phone.")
  parser.add_argument('command', nargs='?', choices=COMMAND_CHOICES, help='What should i do?')
  parser.add_argument('-q', '--quiet', action='store_true', help='Should i tell you what am I doing?')
  parser.add_argument('--dry-run', action='store_true', help='Should i actually do stuff or just print what I would do?')
  parser.add_argument('--project-name', default='take', help="I'll use this to name a folder so you can quickly find your good takes :)")

  args = parser.parse_args()

  app = App(args)

  commands = dict(zip(COMMAND_CHOICES, app.public_commands))

  if not args.quiet:
    print(f"ADB Version: {app.client.version()}")
    print(f"Available Devices:")
    app.print_devices()
  
  if args.command in commands:
    app.call_command(func=commands[args.command], target=None)
  else:
    app.call_command(app.monitor)
    app.call_command(app.simple_record)

class App(object):
  def __init__(self, args):
    self.args = args
    self.client = self._connect()

    if self.client is None:
      self._fail("Could not run ADB. Is it on $PATH?", RC_ADB_NOT_RUNNING)

    self.public_commands = [self.simple_record, self.monitor, self.save_last_file, self.delete_last_file]

  def _connect(self, try_adb: bool = True) -> AdbClient:
    try:
      client = AdbClient()
      client.create_connection()
      return client
    except (RuntimeError, ConnectionRefusedError):
      if try_adb:
        self._run_adb()
        return self._connect(try_adb=False)
      else:
        print("Failed. ADB is not running.")
        return None

  def _run_adb(self):
    # For now, expect adb in $PATH
    # TODO: https://docs.python.org/3/library/shutil.html#shutil.which
    subprocess.run(['adb', 'start-server'])

  def _fail(message, return_code):
    print(message)
    exit(return_code)

  # Internal Methods

  def call_command(self, func : Callable, target : Device = None):
    if target is not None:
      func(target)
    else:
      for device in self.client.devices():
        func(device)
  
  def print_devices(self):
    num = 1
    for device in self.client.devices():
      print(f"{num}: {device.get_serial_no()}\t{device.get_properties()['ro.product.model']}")
      num += 1

  def get_save_dir(self):
    return f"{DEFAULT_SAVE_DIR}/{self.args.project_name}"


  # Intended to be used by final commands with side effects
  def _run_shell(self, device : Device, shellcmd : str):
    if self.args.dry_run:
      print(shellcmd)
    else:
      return device.shell(shellcmd)

  # Commands

  def delete_last_file(self, device: Device):
    last_file_result = device.shell(ADBShell_GetLastFileCommand)
    last_file_result.strip()

    last_file_full_path = f"{DEFAULT_VIDEO_DIR}/{last_file_result}".strip()
    self._run_shell(device, f"mv {last_file_full_path} {last_file_full_path}_DISCARDED")

    print(last_file_full_path)

  def save_last_file(self, device: Device):
    last_file_result = device.shell(ADBShell_GetLastFileCommand)
    last_file_result.strip()
    last_file_full_path = f"{DEFAULT_VIDEO_DIR}/{last_file_result}".strip()
    
    self._run_shell(device, f"{ADBShell_CreateSaveDirCommand} {self.get_save_dir()}")
    self._run_shell(device, f"cp {last_file_full_path} {self.get_save_dir()}")

    print(last_file_full_path)

  def simple_record(self, device: Device):
    self._run_shell(device, ADBShell_RecordCommand)

  def monitor(self, device: Device):
    serial = device.get_serial_no()
    output_filename = f"scrcpy-{serial}.out"
    subprocess.Popen(f"scrcpy --serial {serial} -b 2M -m800 --stay-awake > {output_filename} 2>&1", shell = True)

if __name__ == '__main__':
  main()



