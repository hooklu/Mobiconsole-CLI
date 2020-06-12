#!/bin/bash

#Get the necessary components
yum install icewm tigervnc-server --forcearch=armv7hl -y

#Setup the necessary files
mkdir ~/.vnc
wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/Fedora/Installer/WindowManager/arm/IceWM/xstartup -P ~/.vnc/
wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/Fedora/Installer/WindowManager/arm/IceWM/vncserver-start -P /usr/local/bin/
wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/Fedora/Installer/WindowManager/arm/IceWM/vncserver-stop -P /usr/local/bin/

chmod +x ~/.vnc/xstartup
chmod +x /usr/local/bin/vncserver-start
chmod +x /usr/local/bin/vncserver-stop

echo " "
echo "You can now start vncserver by running vncserver-start"
echo " "
echo "It will ask you to enter a password when first time starting it."
echo " "
echo "The VNC Server will be started at 127.0.0.1:5901"
echo " "
echo "You can connect to this address with a VNC Viewer you prefer"
echo " "
echo "Connect to this address will open a window with IceWM Window Manager"
echo " "
echo " "
echo " "
echo "Running vncserver-start"
echo " "
echo " "
echo " "
echo "To Kill VNC Server just run vncserver-stop"
echo " "
echo " "
echo " "

echo "export DISPLAY=":1"" >> /etc/profile
source /etc/profile

vncserver-start
