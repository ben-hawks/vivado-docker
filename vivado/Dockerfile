FROM almalinux:8.9 as build

# Vivado/vitis Version
ENV VERSION=2020.1
ARG INSTALLER_NAME=Xilinx_Unified_2020.1_0602_1208
ENV INSTALLER_PATH=/opt/${INSTALLER_NAME}/
ARG BUILD_INSTALLER_PATH=files/installers
ENV APPLY_Y2K22_FIX=true
ARG TARBALL_NAME=${INSTALLER_NAME}.tar.gz
ARG INSTALL_DIR=/opt/install_files
ARG TARBALL_PATH=${INSTALL_DIR}/${TARBALL_NAME}

# Installer download locations
ARG REFERENCE_MD5SUM=b018f7b331ab0446137756156ff944d9
ARG CERNBOX_URL_LIST="https://xilinx-ax-dl.entitlenow.com/dl/ul/2020/06/03/R210329635/Xilinx_Unified_2020.1_0602_1208.tar.gz;"
ARG REFERENCE_SPLIT_MD5SUM_LIST="b018f7b331ab0446137756156ff944d9;"

# Copy Installer if it exists, wget will not clobber file if it exists, but download if it doesn't (the build doesn't cache/export/save the tarball to this location!) 
RUN echo "Attempting to copy installer ${BUILD_INSTALLER_PATH}/${INSTALLER_NAME}/${INSTALLER_NAME}.tar.gz to ${TARBALL_PATH}"
COPY files/${INSTALLER_NAME}* ${INSTALL_DIR}/
RUN ls -alh /opt/install_files 

# Board Files - set SPECIFIC_BOARD if only one board needs installing, or leave as SPECIFIC_BOARD=${EMPTY:+STRING} for all boards to be installed
ENV INSTALL_BOARD_FILES=true
ENV SPECIFIC_BOARD=${EMPTY:+STRING}

# Install wget (rest installed after installer download for docker build caching purposes)
RUN dnf -y install wget
 
# Download Tarball for Vivado/Vitis Install	- wget no-clobber is enabled, will skip if file exists
RUN echo "Downloading the tarball ..." \
    && IFS='; ' read -r -a CERNBOX_URL_ARRAY <<< "${CERNBOX_URL_LIST}" \
    && IFS='; ' read -r -a REFERENCE_SPLIT_MD5SUM_ARRAY <<< "${REFERENCE_SPLIT_MD5SUM_LIST}" \
	&& echo "${#CERNBOX_URL_ARRAY[@]} Files found in download list..." \
    && for i in "${!CERNBOX_URL_ARRAY[@]}"; do \
           INDEX=$(printf "%02d" ${i}); \
           CERNBOX_URL_DOWNLOAD="${CERNBOX_URL_ARRAY[$i]}"; \
           echo -e "\tDownloading file ${INDEX} ..."; \
           echo -e "\t\tThe download url is: ${CERNBOX_URL_DOWNLOAD}"; \
           echo -e "\t\tThe output filename is: ${TARBALL_PATH}"; \
           wget --progress=dot:giga -c -nc -O ${TARBALL_PATH} ${CERNBOX_URL_DOWNLOAD}; \
           echo -e "\tChecking the md5sum ..."; \
           checksum=$(echo $(md5sum ${TARBALL_PATH}) | awk '{print $1;}'); \
           reference_checksum="${REFERENCE_SPLIT_MD5SUM_ARRAY[$i]}"; \
           [[ "${checksum}" == "${reference_checksum}" ]] && { echo -e "\t\tChecksums match!"; } || { echo -e "\t\tWARNING::The checksum ${checksum}) doesn't match its reference checksum (${reference_checksum})!"; break; }; \
           df -h; \
       done \
    && ls -alh /opt \
    && echo "Unpacking the tarball ..." 
	
# Unpack and remove tarball

RUN echo "Unpacking the tarball ..." \
    && tar -xzf ${TARBALL_PATH} --directory /opt/ \
    && echo "Removing the tarball ..." \
    && rm ${TARBALL_PATH} 
	
# Install the rest of the packages

RUN dnf -y install 'dnf-command(config-manager)' \
	&& dnf config-manager --set-enabled powertools \
	&& dnf -y install bzip2-devel gcc gcc-c++ git java-1.8.0-openjdk kernel-devel kernel-headers libffi-devel libXrender-devel libXtst-devel make ncurses-compat-libs openssl-devel python39 unzip xorg-x11-apps xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-utils zip zlib-devel\
    && dnf clean all \
    && df -ih \
    && mkdir -p /opt \
    && ls -alh 
	
# Copy install scripts/config 
COPY files/install_config.txt /opt/install_config.txt
COPY files/get_boards.tcl /opt/get_boards.tcl
COPY files/get_y2k22_fix.sh /opt/get_y2k22_fix.sh
COPY files/install.sh /opt/install.sh
	
# Run Installer for Vivado/Vitis & creating vivado user/group (UID/GID defaults to 1000) 	
RUN echo "Installing Vivado ${VERSION} ..." \
    && chmod +x ${INSTALLER_PATH}/xsetup \
    && chmod +x /opt/install.sh \
	&& chmod +x /opt/get_boards.tcl \
	&& chmod +x /opt/get_y2k22_fix.sh \
    && /opt/install.sh \
    && df -ih \
    && ls -alh /opt \
    && echo -e "Installation complete!!!\nRemoving the installer ..." \
    && rm -rf ${INSTALLER_PATH} \
    && df -ih \
    && ls -alh /opt \
    && echo "Cleaning /tmp ..." \
    && rm -rf /tmp/.X* \
    && echo "Setting up the 'vivado' user ..." \
    && useradd -ms /bin/bash vivado \
    && chown -R vivado /home/vivado \
    && echo "source /opt/Xilinx/Vivado/${VERSION}/settings64.sh" >> /home/vivado/.bashrc

# install Tini 
RUN TINI_VERSION=`curl --silent "https://api.github.com/repos/krallin/tini/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/'` \
	&& curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.rpm" > tini.rpm \
    && rpm -i tini.rpm \
    && rm tini.rpm

# hack to be able to use $VERSION in our entrypoint... (exec form doesn't support args :< ) 

# Setup Final details	
USER vivado
WORKDIR /home/vivado

ENV DISPLAY :0
ENV GEOMETRY 1920x1200
ENV VERSION=${VERSION}

SHELL ["/bin/bash", "-c"]
ENTRYPOINT [ "/usr/bin/tini", "--", "/opt/Xilinx/Vivado/2020.1/bin/vivado" ]
# CMD ["-mode", "batch"]

#Flatten the image so that it's not >100GB...
FROM scratch
COPY --from=build / /
