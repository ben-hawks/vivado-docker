# This downloads (if not already present in the image) a given Vivado/Vitis installer tarball, then installs it into an external mounted directory/volume (mounted to /opt/Xilinx in the container)
if [ ! -f /opt/Xilinx/.mountcheck ] || $IN_BUILDER; then
  echo "Checking Tarball Path: ${TARBALL_PATH} ..."
  if [ ! -f "${TARBALL_PATH}" ]; then
  ls -alh /opt
  echo "Contents of Install Dir: ${INSTALL_DIR} - "
  ls -alh "${INSTALL_DIR}"
  # Download Tarball for Vivado/Vitis Install if not already present	- wget no-clobber is enabled, will skip if file exists
  echo "Downloading ${TARBALL_NAME} ..."
  IFS='; ' read -r -a CERNBOX_URL_ARRAY <<< "${CERNBOX_URL_LIST}"
  IFS='; ' read -r -a REFERENCE_SPLIT_MD5SUM_ARRAY <<< "${REFERENCE_SPLIT_MD5SUM_LIST}"
  echo "${#CERNBOX_URL_ARRAY[@]} Files found in download list..."
    for i in "${!CERNBOX_URL_ARRAY[@]}"; do
      INDEX=$(printf "%02d" ${i});
      CERNBOX_URL_DOWNLOAD="${CERNBOX_URL_ARRAY[$i]}";
      echo -e "\tDownloading file ${INDEX} ...";
      echo -e "\t\tThe download url is: ${CERNBOX_URL_DOWNLOAD}";
      echo -e "\t\tThe output filename is: ${TARBALL_PATH}";
      wget --progress=dot:giga -c -nc -O ${TARBALL_PATH} ${CERNBOX_URL_DOWNLOAD};
      echo -e "\tChecking the md5sum ...";
      checksum=$(echo $(md5sum ${TARBALL_PATH}) | awk '{print $1;}');
      reference_checksum="${REFERENCE_SPLIT_MD5SUM_ARRAY[$i]}";
      [[ "${checksum}" == "${reference_checksum}" ]] && { echo -e "\t\tChecksums match!"; } || { echo -e "\t\tWARNING::The checksum ${checksum}) doesn't match its reference checksum (${reference_checksum})!"; break; };
      df -h;
    done
  else
    echo "Tarball already found at ${TARBALL_PATH}! Continuing to install..."
  fi
  echo "Unpacking the tarball ..."
  mkdir -p "${INSTALLER_BASE_DIR}"
  tar -xzf "${TARBALL_PATH}" --directory "${INSTALLER_BASE_DIR}"
  echo "Removing the tarball ..."
  rm "${TARBALL_PATH}"
	echo "Installing Vivado ${VERSION} ..." 
	chmod +x "${INSTALLER_PATH}"/xsetup
	source /opt/install.sh 
	ls -alh /opt 
	echo -e "Installation complete!!!\nRemoving the installer ..." 
	rm -rf "${INSTALLER_PATH}"
	echo "Cleaning /tmp ..." 
	rm -rf /tmp/.X*
	if [[ $BUILDING_SPLIT && (-f /opt/Xilinx/.mountcheck || $IN_BUILDER ) ]] ; then
	  echo "Cleaning /opt/Xilinx/ ... (Should only occur when building the minimal image _without_ a mounted volume!!!) "
	  rm -rf "/opt/Xilinx/"
	  echo "Current /opt/Xilinx Contents:"
	  ls -alh /opt/Xilinx
	fi
	echo "Install Complete!!"
	exit 0
else
	echo "Mount Check Failed! External volume/directory should be mounted as /opt/Xilinx - Check that it's mounted correctly."
	echo "Contents of /opt -"
	ls -alh /opt
	echo "Contents of /opt/Xilinx -"
	ls -alh /opt/Xilinx 
	exit 1
fi

	
	