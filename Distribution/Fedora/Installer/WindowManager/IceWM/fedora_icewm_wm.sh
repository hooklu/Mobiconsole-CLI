#!/bin/bash

#Get the necessary components

dnf install dialog -y
clear
trap '' 2
dialog --clear --backtitle "System Installation Type" --title "Choose Installation type:" --menu "Please select:" 10 45 3 1 "Minimal Installation 1.5GB" 2 "Full Installation 4GB" 2>temp
# OK is pressed
if [ "$?" = "0" ]
then
        _return=$(cat temp)
 
        # Minimal is selected
        if [ "$_return" = "1" ]
        then
                echo 'Installing Minimal System '
		            sleep 4
    		       yum install icewm tigervnc-server -y
        fi
 
         # Full is selected
        if [ "$_return" = "2" ]
        then
            	echo 'Installing Full System '
		          sleep 4
		          yum install icewm tigervnc-server -y
              dnf install neofetch gimp libreoffice -y
              
        fi
 # Cancel is pressed
else
        echo "Cancel is pressed, Restarting The Menu......"
	sleep 3
	dialog --menu "Choose Installation type:" 10 40 3 1 "Minimal Installation 1.5GB" 2 "Full Installation 4GB" 2>temp
fi
 
# remove the temp file
rm -f temp
trap 2

#Setup the necessary files
mkdir ~/.vnc
wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/Fedora/Installer/WindowManager/IceWM/xstartup -P ~/.vnc/
wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/Fedora/Installer/WindowManager/IceWM/vncserver-start -P /usr/local/bin/
wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/Fedora/Installer/WindowManager/IceWM/vncserver-stop -P /usr/local/bin/

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
echo "**Note : Please note that you will need to enter view only password too while configuring VNC password to avoid connection errors."
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
