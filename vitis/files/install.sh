#!/bin/bash

${INSTALLER_PATH}/xsetup --agree XilinxEULA,3rdPartyEULA,WebTalkTerms --batch Install --config /opt/install_config.txt

#if [$INSTALL_BOARD_FILES]; then
# Install Board files if desired
# Set $SPECIFIC_BOARD if to install one board only, otherwise installs all availible boards
# See https://github.com/Xilinx/XilinxBoardStore/wiki/Accessing-the-Board-Store-Repository
	source /opt/Xilinx/Vitis/${VERSION}/settings64.sh
	vitis -mode batch -source opt/get_boards.tcl
	echo "Xilinx Board Store Install Complete (Vitis)"
	#Install Pynq-Z1 from github if requested (or all selected) because it's not availible on the board store... 
	#if [$SPECIFIC_BOARD -eq "pynq-z1"] || [[ -z $SPECIFIC_BOARD ]]; then 
		git clone https://github.com/cathalmccabe/pynq-z1_board_files.git /tmp/pynq-z1
		mv /tmp/pynq-z1/pynq-z1 /opt/Xilinx/vitis/${VERSION}/data/boards/board_files/
		echo "Installed Pynq Boards:"
		ls /opt/Xilinx/vitis/${VERSION}/data/boards/board_files/ | grep pynq 
		echo "Pynq-Z1 Board Install complete"
	#fi
	echo "### Board Install Complete! ###"
#fi