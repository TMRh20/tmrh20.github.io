#!/bin/bash

INSTALL_PATH="."
INSTALL_DIR="/rf24libs"

ROOT_PATH=${INSTALL_PATH}
ROOT_PATH+=${INSTALL_DIR}

DORF24=0
DORF24Network=0
DORF24Mesh=0
DORF24Gateway=0
DORF24GatewayMake=0

GITHUB_ROOT="tmrh20"

while getopts :r: opt; do
	case $opt in
		r)
			GITHUB_ROOT=$OPTARG
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			;;
	esac
done

shift $((OPTIND - 1))

echo""
echo "RF24 libraries updater by TMRh20/Sytone"
echo "report issues at https://github.com/TMRh20/RF24/issues"
echo ""
echo "******************** NOTICE **********************"
echo "Updater will update all the libraries under 'rf24libs' it assumes you"
echo "have already used the installer. "
echo ""
echo "Github Root: https://github.com/${GITHUB_ROOT}/"
echo "Install Path: ${ROOT_PATH}"
echo ""



PKG_OK=$(dpkg-query -W --showformat='${Status}\n' git|grep "install ok installed")
echo "Checking for Git..."
if [ "" == "$PKG_OK" ]; then
	echo "No Git. Setting up somelib."
	echo "Prerequisite: GIT "
	echo "If you select yes it will install git, select no if you have it installed already"
	read -p "Do you want to install GIT using APT [Y/n]?" ANSWER
	ANSWER=${ANSWER:-Y}
	case ${ANSWER^^} in
		Y ) sudo apt-get install git
	esac
else
	echo "Git is already installed continuing."
fi

echo "Prerequisite: Cleanup "
echo "Warning, this will scrub the directories below ${ROOT_PATH} "
echo "Select b if you want to take a backup of the existing files"
read -p "Do you want to continue [Y/n/b]?" ANSWER
ANSWER=${ANSWER:-Y}
case ${ANSWER^^} in
	Y) sudo rm -r rf24libs;;
	B)
		TIME=`date +%Y-%m-%d-%H-%M`
		FILENAME=rf24-backup-$TIME.tar.gz
		echo "Backing up files to ./${FILENAME}"
		tar -cpzf ./$FILENAME $ROOT_PATH
		sudo rm -r rf24libs
		;;
	*) exit 1;;
esac


read -p "Do you want to install the RF24 core library [y/N]?" ANSWER
ANSWER=${ANSWER:-Y}
case ${ANSWER^^} in
    Y ) DORF24=1;;
esac

read -p "Do you want to install the RF24Network library [y/N]?" ANSWER
ANSWER=${ANSWER:-Y}
case ${ANSWER^^} in
    Y ) DORF24Network=1;;
esac

read -p "Do you want to install the RF24Mesh library [y/N]?" ANSWER
ANSWER=${ANSWER:-Y}
case ${ANSWER^^} in
    Y ) DORF24Mesh=1;;
esac

read -p "Do you want to install the RF24Gateway library [y/N]?" ANSWER
ANSWER=${ANSWER:-Y}
case ${ANSWER^^} in
    Y ) DORF24Gateway=1;;
esac

read -p "Do you want to build an RF24Gateway example [y/N]?" ANSWER
ANSWER=${ANSWER:-Y}
case ${ANSWER^^} in
	Y ) DORF24GatewayMake=1;;
esac	


if [[ $DORF24Gateway > 0 ]]
then
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' libncurses5-dev|grep "install ok installed")
	echo "Checking for ncurses library..."
	if [ "" == "$PKG_OK" ]; then
		echo "No ncurses library."
		echo "Recommended for RF24Gateway"
		echo "If you select yes it will install ncurses library"
		read -p "Install ncurses library -Recommended for RF24Gateway [y/N]?" ANSWER
		ANSWER=${ANSWER:-Y}
		case ${ANSWER^^} in
			Y ) sudo apt-get install libncurses5-dev
		esac
		echo ""
	else
		echo "ncurses library is already installed continuing."
	fi
fi

if [[ $DORF24 > 0 ]]
then
	echo "Installing RF24 Repo..."
	echo ""
	git clone https://github.com/${GITHUB_ROOT}/RF24.git ${ROOT_PATH}/RF24
	echo ""
    echo "*** Install RF24 core using? ***"
    echo "1.BCM2835 Driver(Performance) 2.SPIDEV(Compatibility, Default)"
    echo "3.WiringPi(Its WiringPi!) 4.MRAA(Intel Devices) 5.LittleWire"
    read answer
    cd ${ROOT_PATH}/RF24
    case ${answer^^} in
        1) ./configure --driver=RPi;;
        2) ./configure --driver=SPIDEV;;
        3) ./configure --driver=wiringPi;;
        4) ./configure --driver=MRAA;;
        5) ./configure --driver=LittleWire;;
        *) ./configure --driver=SPIDEV;;
    esac
    cd ../..
    make -C ${ROOT_PATH}/RF24
	sudo make install -C ${ROOT_PATH}/RF24
	echo ""
fi

if [[ $DORF24Network > 0 ]]
then
	echo "Installing RF24Network_DEV Repo..."
	echo ""
	git clone https://github.com/${GITHUB_ROOT}/RF24Network.git ${ROOT_PATH}/RF24Network
	echo ""
    make -B -C ${ROOT_PATH}/RF24Network
	sudo make install -C ${ROOT_PATH}/RF24Network
	echo ""
fi

if [[ $DORF24Mesh > 0 ]]
then
	echo "Installing RF24Mesh Repo..."
	echo ""
	git clone https://github.com/${GITHUB_ROOT}/RF24Mesh.git ${ROOT_PATH}/RF24Mesh
	echo ""
    make -B -C ${ROOT_PATH}/RF24Mesh
	sudo make install -C ${ROOT_PATH}/RF24Mesh
	echo ""
fi

if [[ $DORF24Gateway > 0 ]]
then
	echo "Installing RF24Gateway Repo..."
	echo ""
	git clone https://github.com/${GITHUB_ROOT}/RF24Gateway.git ${ROOT_PATH}/RF24Gateway
	echo ""
    make -B -C ${ROOT_PATH}/RF24Gateway
	sudo make install -C ${ROOT_PATH}/RF24Gateway
	
    echo ""
	if [[ $DORF24GatewayMake > 0 ]]
	then
		make -B -C${ROOT_PATH}/RF24Gateway/examples/ncurses
		echo ""
		echo "Complete, to run the example:"
		echo "  cd ./rf24libs/RF24Gateway/examples/ncurses"
		echo "  sudo ./RF24Gateway_ncurses"
	fi
fi


echo ""
echo ""
echo "*** Installer Complete ***"
echo "See http://tmrh20.github.io for documentation"
echo "See http://tmrh20.blogspot.com for info "
echo ""
echo "Listing files in install directory:"
ls ${ROOT_PATH}




