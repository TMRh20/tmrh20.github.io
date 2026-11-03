#!/bin/bash

INSTALL_PATH="."
INSTALL_DIR="/rf24libs"

ROOT_PATH=${INSTALL_PATH}
ROOT_PATH+=${INSTALL_DIR}

DORF24=0
DORF24Network=0
DORF24Mesh=0
DORF24Gateway=0
USE_CCM="N"
CCM_HEADER="/usr/local/include/RF24Network/RF24CCM.h"
NETWORK_LIB="/usr/local/lib/librf24network.so"

MAKE_EXTRA_DIR="$(pwd)${INSTALL_DIR}/.make"
MAKE_EXTRA="${MAKE_EXTRA_DIR}/extra.mk"

# Build and install RF24Network, RF24Mesh or RF24Gateway with its Makefile.
# An extra makefile is read after the library's own Makefile to append to CCFLAGS:
#  - The legacy Makefiles link with -lrf24-bcm, but RF24 now installs librf24.so, so a
#    librf24-bcm.so link to librf24.so is provided through -L (nothing is changed in /usr/local)
#  - When CCM is selected, -DRF24NETWORK_CCM builds in the RF24CCM (AES-CCM) classes
# Arg 1: path to the library repo
make_build_lib() {
	mkdir -p "$MAKE_EXTRA_DIR"
	ln -sf /usr/local/lib/librf24.so "${MAKE_EXTRA_DIR}/librf24-bcm.so"
	echo "CCFLAGS += -L${MAKE_EXTRA_DIR}" > "$MAKE_EXTRA"
	if [[ ${USE_CCM^^} = "Y" ]]
	then
		echo "CCFLAGS += -DRF24NETWORK_CCM" >> "$MAKE_EXTRA"
	fi
	if ! make -B -C "$1" -f Makefile -f "$MAKE_EXTRA"
	then
		echo "Building $1 failed. Quitting now."
		exit 1
	fi
	if ! sudo make install -C "$1" -f Makefile -f "$MAKE_EXTRA"
	then
		echo "Installing $1 failed. Quitting now."
		exit 1
	fi
	sudo ldconfig
}

echo""
echo "******************** WARNING *********************"
echo "This installer is DEPRECATED and supports 32-bit systems only."
echo "It builds the libraries with their legacy Makefiles."
echo "For the latest installer and 64-bit support, see https://nrf24.github.io/RF24"
echo "**************************************************"
echo ""
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
echo -n "Do you want to install GIT using APT (Used to download source code) [y/N]? " 
read answer
case ${answer^^} in
	Y ) sudo apt-get install git
esac

echo $'\n'
echo -n "Do you want to install the RF24 core library, [y/N]? "
read answer
case ${answer^^} in
    Y ) DORF24=1;;
esac

echo $'\n'
echo -n "Do you want to install the RF24Network library [y/N]? "
read answer
case ${answer^^} in
    Y ) DORF24Network=1;;
esac

echo $'\n'
echo -n "Do you want to install the RF24Mesh library [y/N]? "
read answer
case ${answer^^} in
    Y ) DORF24Mesh=1;;
esac

echo $'\n'
echo -n "Do you want to install the RF24Gateway library [y/N]? "
read answer
case ${answer^^} in
    Y ) DORF24Gateway=1;;
esac

if [[ $DORF24Network > 0 || $DORF24Mesh > 0 || $DORF24Gateway > 0 ]]
then
	echo $'\n'
	echo "AES-CCM encryption lets Linux nodes communicate with nRF52840 nodes using nrf_to_nrf encryption."
	echo "RF24Network, RF24Mesh and RF24Gateway must all be built with it for RF24Gateway to use it."
	echo -n "Build with CCM encryption support (RF24NETWORK_CCM) [y/N]? "
	read USE_CCM
	case ${USE_CCM^^} in
		Y )
			# RF24Mesh and RF24Gateway need an RF24Network lib built with CCM support.
			# Reinstall RF24Network unless the installed lib already provides ESBNetwork<RF24CCM>
			# and its installed RF24CCM.h matches the local source.
			if [[ $DORF24Network = 0 ]]
			then
				if [[ ! -f "$CCM_HEADER" ]] || ! nm -DC "$NETWORK_LIB" 2>/dev/null | grep -q "ESBNetwork<RF24CCM>"
				then
					echo "The installed RF24Network has no CCM support. Adding RF24Network to the installation."
					DORF24Network=1
				elif [[ -f "${ROOT_PATH}/RF24Network/RF24CCM.h" ]] && ! cmp -s "${ROOT_PATH}/RF24Network/RF24CCM.h" "$CCM_HEADER"
				then
					echo "The installed RF24CCM.h differs from ${ROOT_PATH}/RF24Network/RF24CCM.h. Adding RF24Network to the installation."
					DORF24Network=1
				fi
			fi
			;;
		* ) USE_CCM="N";;
	esac
fi

if [[ $DORF24Gateway > 0 ]]
then
	echo ""
	echo "Install ncurses library, recommended for RF24Gateway [y/N]? "
	read answer
    case ${answer^^} in
		Y ) sudo apt-get install libncurses5-dev
	esac
	echo ""
fi

if [[ $DORF24 > 0 ]]
then
    echo ""
	echo "Installing RF24 Repo..."
	echo ""
	git clone https://github.com/tmrh20/RF24.git ${ROOT_PATH}/RF24
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
	echo "Installing RF24Network Repo..."
	echo ""
	git clone https://github.com/tmrh20/RF24Network.git ${ROOT_PATH}/RF24Network
	echo ""
	make_build_lib ${ROOT_PATH}/RF24Network
	if [[ ${USE_CCM^^} = "Y" ]]
	then
		# RF24Mesh, RF24Gateway and gateway programs compile against the installed RF24CCM.h,
		# so it must be the same file the RF24Network lib was just built from
		SRC_CCM="${ROOT_PATH}/RF24Network/RF24CCM.h"
		if ! cmp -s "$SRC_CCM" "$CCM_HEADER"
		then
			echo "Installed $CCM_HEADER does not match $SRC_CCM. Replacing it."
			sudo rm -f "$CCM_HEADER"
			if ! sudo install -D -m 644 "$SRC_CCM" "$CCM_HEADER" || ! cmp -s "$SRC_CCM" "$CCM_HEADER"
			then
				echo "Replacing $CCM_HEADER failed. Quitting now."
				exit 1
			fi
		fi
		echo "Verified the installed RF24CCM.h matches $SRC_CCM"
	fi
	echo ""
fi

if [[ $DORF24Mesh > 0 ]]
then
	echo "Installing RF24Mesh Repo..."
	echo ""
	git clone https://github.com/tmrh20/RF24Mesh.git ${ROOT_PATH}/RF24Mesh
	echo ""
	make_build_lib ${ROOT_PATH}/RF24Mesh
	echo ""
fi

if [[ $DORF24Gateway > 0 ]]
then
	echo "Installing RF24Gateway Repo..."
	echo ""
	git clone https://github.com/tmrh20/RF24Gateway.git ${ROOT_PATH}/RF24Gateway
	echo ""
	make_build_lib ${ROOT_PATH}/RF24Gateway

    echo ""; echo -n "Do you want to build an RF24Gateway example [y/N]? "
    read answer
    case ${answer^^} in
       Y ) make -B -C${ROOT_PATH}/RF24Gateway/examples/ncurses; echo ""; echo "Complete, to run the example, cd to rf24libs/RF24Gateway/examples/ncurses and enter  sudo ./RF24Gateway_ncurses";;
    esac	
fi


echo ""
echo ""
echo "*** Installer Complete ***"
if [[ ${USE_CCM^^} = "Y" ]]
then
	echo "Built with CCM encryption support (RF24NETWORK_CCM)."
	echo "See the RF24CCM comments in the RF24Gateway examples to enable encryption in your programs."
fi
echo "NOTE: This installer is deprecated (32-bit only). For the latest installer see https://nrf24.github.io/RF24"
echo "See http://tmrh20.github.io for documentation"
echo "See http://tmrh20.blogspot.com for info "
echo ""
echo "Listing files in install directory rf24libs/"
ls ${ROOT_PATH}



