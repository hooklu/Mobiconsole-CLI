#!/data/data/com.termux/files/usr/bin/bash
folder=ubuntu-fs
termux-setup-storage
pkg install dialog
dialog --title "Storage Info" --msgbox "\n\nCustom Ubuntu Installation would occupy around 2GB of space on your device as per your Desktop choice.\n\nIf you wish to Quit right now press Ctrl+C\n\n Press OK to Continue." 20 40
dlink="https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/Ubuntu"
if [ -d "$folder" ]; then
	first=1
	echo "skipping downloading"
fi
tarball="ubuntu20-rootfs.tar.gz"

if [ "$first" != 1 ];then
	if [ ! -f $tarball ]; then
		echo "Download Rootfs, this may take a while base on your internet speed."
		case `dpkg --print-architecture` in
		aarch64)
			archurl="arm64" ;;
		arm)
			archurl="armhf" ;;
		amd64)
			archurl="amd64" ;;
		x86_64)
			archurl="amd64" ;;	
		*)
			echo "unknown architecture"; exit 1 ;;
		esac
		wget "https://github.com/MobilinuxApp/Mobiconsole-CLI/blob/master/Distribution/Ubuntu/Rootfs/Focal/${archurl}/ubuntu-focal-${archurl}-root.tar.gz?raw=true" -O $tarball

fi
	cur=`pwd`
	mkdir -p "$folder"
	cd "$folder"
	echo "Decompressing Rootfs, please be patient."
	proot --link2symlink tar -xf ${cur}/${tarball} --exclude=dev||:
	cd "$cur"
fi
mkdir -p ubuntu-binds
bin=start-ubuntu.sh
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" --kill-on-exit"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A ubuntu-binds)" ]; then
    for f in ubuntu-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b ubuntu-fs/root:/dev/shm"
command+=" -b /data"
command+=" -b /mnt"
command+=" -b /proc/mounts:/etc/mtab"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## uncomment the following line to mount /sdcard directly to / 
command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

mkdir -p ubuntu-fs/var/tmp
rm -rf ubuntu-fs/usr/local/bin/*
echo "127.0.0.1 localhost localhost" > $folder/etc/hosts
wget -q https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu19/.profile -O ubuntu-fs/root/.profile.1 > /dev/null
cat $folder/root/.profile.1 >> $folder/root/.profile && rm -rf $folder/root/.profile.1
wget -q https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu19/.bash_profile-ub19 -O ubuntu-fs/root/.bash_profile > /dev/null
wget -q https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu19/vnc -P ubuntu-fs/usr/local/bin > /dev/null
wget -q https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu19/vncpasswd -P ubuntu-fs/usr/local/bin > /dev/null
wget -q https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu19/vncserver-stop -P ubuntu-fs/usr/local/bin > /dev/null
wget -q https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu19/vncserver-start -P ubuntu-fs/usr/local/bin > /dev/null

chmod +x ubuntu-fs/root/.bash_profile
chmod +x ubuntu-fs/root/.profile
chmod +x ubuntu-fs/usr/local/bin/vnc
chmod +x ubuntu-fs/usr/local/bin/vncpasswd
chmod +x ubuntu-fs/usr/local/bin/vncserver-start
chmod +x ubuntu-fs/usr/local/bin/vncserver-stop

echo "fixing shebang of $bin"
termux-fix-shebang $bin
echo "making $bin executable"
chmod +x $bin
echo "removing image for some space"
rm $tarball

#DE installation addition

wget --tries=20 $dlink/Installer/WindowManager/IceWM/ubuntu_icewm_wm_patch.sh -O $folder/root/ubuntu_icewm_wm_patch.sh

echo "Setting up the installation of ICEWM VNC"

echo "APT::Acquire::Retries \"3\";" > $folder/etc/apt/apt.conf.d/80-retries #Setting APT retry count
touch $folder/root/.hushlogin
echo "#!/bin/bash
rm -rf /etc/resolv.conf
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
mkdir -p ~/.vnc
apt update -y && apt install sudo dialog wget -y > /dev/null
clear
if [ ! -f /root/ubuntu_icewm_wm_patch.sh ]; then
    wget --tries=20 $dlink/Installer/WindowManager/IceWM/ubuntu_icewm_wm_patch.sh -O /root/ubuntu_icewm_wm_patch.sh
    bash ~/ubuntu_icewm_wm_patch.sh
else
    bash ~/ubuntu_icewm_wm_patch.sh
fi
clear
if [ ! -f /usr/local/bin/vncserver-start ]; then
    wget --tries=20  $dlink/Installer/WindowManager/IceWM/vncserver-start -O /usr/local/bin/vncserver-start 
    wget --tries=20 $dlink/Installer/WindowManager/IceWM/vncserver-stop -O /usr/local/bin/vncserver-stop
    chmod +x /usr/local/bin/vncserver-stop
    chmod +x /usr/local/bin/vncserver-start
fi
if [ ! -f /usr/bin/vncserver ]; then
    apt install tigervnc-standalone-server -y
fi
echo 'Creating new user'
wget --tries=20 https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/Debian/Installer/adduser.sh -O /root/adduser.sh && chmod +x adduser.sh
sed -i 's/demousername/defaultusername/g; s/demopasswd/defaultpasswd/g' adduser.sh
bash ~/adduser.sh
echo 'User creation....Done'
echo 'Writing Help Script'
wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/distro-help -P /usr/local/bin/
chmod +x /usr/local/bin/distro-help
clear
echo 'You can login to new user using "su - USERNAME" '
echo ' Welcome to Mobilinux | Ubuntu 20.04LTS'
rm -rf /root/adduser.sh
rm -rf /root/ubuntu_icewm_wm_patch.sh
rm -rf ~/.bash_profile" > $folder/root/.bash_profile 

bash $bin
