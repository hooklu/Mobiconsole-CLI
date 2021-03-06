#!/data/data/com.termux/files/usr/bin/bash
folder=debian-fs
termux-setup-storage
pkg install dialog
dialog --title "Storage Info" --msgbox "\n\nCustom Debian Installation would occupy around 2GB of space on your device as per your Desktop choice.\n\nIf you wish to Quit right now press Ctrl+C\n\n Press OK to Continue." 20 40
dlink="https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/Debian"
if [ -d "$folder" ]; then
	first=1
	echo "skipping downloading"
fi
tarball="debian-rootfs.tar.xz"
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
		i*86)
			archurl="i386" ;;
		x86)
			archurl="i386" ;;
		*)
			echo "unknown architecture"; exit 1 ;;
		esac
		wget "https://github.com/MobilinuxApp/Mobiconsole-CLI/blob/master/Distribution/Debian/Rootfs/stretch/${archurl}/debian-rootfs-${archurl}.tar.xz?raw=true" -O $tarball	
	fi
	cur=`pwd`
	mkdir -p "$folder"
	cd "$folder"
	echo "Decompressing Rootfs, please be patient."
	proot --link2symlink tar -xJf ${cur}/${tarball} --warning=no-unknown-keyword --exclude=dev||:
	cd "$cur"
fi
mkdir -p debian-binds
bin=start-debian.sh
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
if [ -n "\$(ls -A debian-binds)" ]; then
    for f in debian-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b debian-fs/root:/dev/shm"
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

echo "fixing shebang of $bin"
termux-fix-shebang $bin
echo "making $bin executable"
chmod +x $bin
echo "removing image for some space"
rm $tarball

#DE installation addition

wget --tries=20 $dlink/Installer/DEs/LXDE/CompatabilityScripts/debian-compact-lxde.sh -O $folder/root/debian-compact-lxde.sh
clear
echo "Setting up the installation of LXDE VNC"

echo "APT::Acquire::Retries \"3\";" > $folder/etc/apt/apt.conf.d/80-retries #Setting APT retry count
echo "#!/bin/bash
rm -rf /etc/resolv.conf
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
apt update -y && apt install wget sudo ca-certificates dialog -y
clear
if [ ! -f /root/debian-compact-lxde.sh ]; then
    wget --tries=20 $dlink/Installer/DEs/LXDE/CompatabilityScripts/debian-compact-lxde.sh -O /root/debian-compact-lxde.sh
    bash ~/debian-compact-lxde.sh
else
    bash ~/debian-compact-lxde.sh
fi
clear
if [ ! -f /usr/local/bin/vncserver-start ]; then
    wget --tries=20  $dlink/Installer/DEs/LXDE/CompatabilityScripts/vncserver-start -O /usr/local/bin/vncserver-start
    wget --tries=20 $dlink/Installer/DEs/LXDE/vncserver-stop -O /usr/local/bin/vncserver-stop
    chmod +x /usr/local/bin/vncserver-stop
    chmod +x /usr/local/bin/vncserver-start
fi
if [ ! -f /usr/bin/vncserver ]; then
    apt install tightvncserver -y
fi
clear
echo 'Installing Browser'
apt install firefox-esr -y 
clear
#Setup the sources.list
echo " "
echo "Setting up the chosen suite and preparing sources.list, Please Wait!"
echo "Updating repository lists, Please Wait!"
apt-get update && apt-get upgrade
echo " "
echo "Done!"
echo " "
echo 'Creating new user'
wget --tries=20 https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/Debian/Installer/adduser.sh -O /root/adduser.sh && chmod +x adduser.sh
sed -i 's/demousername/defaultusername/g; s/demopasswd/defaultpasswd/g' adduser.sh
bash ~/adduser.sh
chmod u+s /usr/bin/sudo
echo 'User creation....Done'
echo 'Writing Help Script'
wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/distro-help -P /usr/local/bin/
chmod +x /usr/local/bin/distro-help
clear
echo 'You can login to new user using su - USERNAME'
echo ' Welcome to Mobilinux | Debian Stretch (9)'
rm -rf /root/adduser.sh
rm -rf /root/debian-compact-lxde.sh
rm -rf ~/.bash_profile" > $folder/root/.bash_profile 

bash $bin
