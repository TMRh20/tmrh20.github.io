#!/bin/bash

INSTALL_PATH="."
INSTALL_DIR="/rf24libs"

ROOT_PATH=${INSTALL_PATH}
ROOT_PATH+=${INSTALL_DIR}

DORF24=0
DORF24Network=0
DORF24Mesh=0
DORF24toTUN=0
DORF24toTUNMESH=0

echo""
echo "RF24 libraries installer by TMRh20"
echo "report issues at https://github.com/TMRh20/RF24/issues"
echo ""
echo "******************** NOTICE **********************"
echo "Installer will create an 'rf24libs' folder for installation of selected libraries"
echo "To prevent mistaken deletion, users must manually delete existing library folders within 'rf24libs' if upgrading"
echo "Run 'sudo rm -r rf24libs' to clear the entire directory"
echo ""
echo ""

echo "Prerequisite: GIT "
echo "Do you want to install GIT using APT?" 
echo -n "(Used to download source code) "
read answer
case ${answer^^} in
	Y ) sudo apt-get install git
esac

echo $'\n'
echo -n "Do you want to install the RF24 core library, Y/N?"
read answer
case ${answer^^} in
    Y ) DORF24=1;;
esac

echo $'\n'
echo -n "Do you want to install the RF24Network library?"
read answer
case ${answer^^} in
    Y ) DORF24Network=1;;
esac

echo $'\n'
echo -n "Do you want to install the RF24Mesh library?"
read answer
case ${answer^^} in
    Y ) DORF24Mesh=1;;
esac

echo $'\n'
echo -n "Do you want to install the RF24toTUN library?"
read answer
case ${answer^^} in
    Y ) DORF24toTUN=1;;
esac

if [[ $DORF24toTUN > 0 ]]
then
	echo "RF24toTUN requires installation of boost libraries"
	echo -n "Install boost libs via APT?"
	read answer
	case ${answer^^} in
		Y ) sudo apt-get install libboost-thread1.50-dev libboost-system1.50-dev
	esac
	echo $'\n'
	echo -n "Do you want to compile RF24toTUN with RF24Mesh support?"
	read answer
	case ${answer^^} in
    		Y ) DORF24toTUNMESH=1;;
	esac
fi



if [[ $DORF24 > 0 ]]
then
	echo "Installing RF24 Repo..."
	echo ""
	git clone https://github.com/tmrh20/RF24.git ${ROOT_PATH}/RF24
	echo ""
	sudo make install -B -C ${ROOT_PATH}/RF24
	echo ""
fi

if [[ $DORF24Network > 0 ]]
then
	echo "Installing RF24Network_DEV Repo..."
	echo ""
	git clone -b Development https://github.com/tmrh20/RF24Network.git ${ROOT_PATH}/RF24Network
	echo ""
	sudo make install -B -C ${ROOT_PATH}/RF24Network
	echo ""
fi

if [[ $DORF24Mesh > 0 ]]
then
	echo "Installing RF24Mesh Repo..."
	echo ""
	git clone https://github.com/tmrh20/RF24Mesh.git ${ROOT_PATH}/RF24Mesh
	echo ""
	sudo make install -B -C ${ROOT_PATH}/RF24Mesh
	echo ""
fi

if [[ $DORF24toTUN > 0 ]]
then
	echo "Installing RF24toTUN Repo..."
	echo ""
	git clone https://github.com/tmrh20/RF24toTUN.git ${ROOT_PATH}/RF24toTUN
	echo ""
	
	if [[ $DORF24toTUNMESH > 0 ]]
	then
		sudo make install MESH=1 -B -C ${ROOT_PATH}/RF24toTUN
	else
		sudo make install -B -C ${ROOT_PATH}/RF24toTUN
	fi
	echo ""
fi


echo ""
echo ""
echo "*** Installer Complete ***"
echo "See http://tmrh20.github.io for documentation"
echo "See http://tmrh20.blogspot.com for info "
echo ""
echo "Listing files in install directory:"
ls ${ROOT_PATH}



