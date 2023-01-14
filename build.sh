PLATFORM="`uname -s`_`uname -m`"
ARCHIVE_NAME="cameracontrol-$PLATFORM.zip"

echo '### Installing prerequisites'
pip3 install virtualenv
virtualenv venv
. ./venv/bin/activate
pip install -r requirements.txt

echo;echo;echo
echo '### Compiling application'
pyinstaller --clean -Dy cameraControl.py

echo;echo;echo
echo "### Building $ARCHIVE_NAME"
(cd dist && zip -qr9 ../$ARCHIVE_NAME cameraControl/)

echo 'Done!'