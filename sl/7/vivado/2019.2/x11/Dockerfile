FROM sl:7

COPY files/install_config.txt /opt/install_config.txt
COPY files/install.sh /opt/install.sh
COPY files/get_boards.tcl /opt/get_boards.tcl
COPY files/get_y2k22_fix.sh /opt/get_y2k22_fix.sh

# Vivado Version
ENV VERSION=2019.2
ARG INSTALLER_NAME=Xilinx_Vivado_2019.2_1106_2127
ENV INSTALLER_PATH=/opt/${INSTALLER_NAME}/
ENV APPLY_Y2K22_FIX=true

# Board Files
ENV INSTALL_BOARD_FILES=true
ENV SPECIFIC_BOARD=${EMPTY:+STRING}

# Cernbox download locations 
ARG TARBALL_NAME=${INSTALLER_NAME}.tar.gz
ARG TARBALL_PATH=/opt/${TARBALL_NAME}
ARG REFERENCE_MD5SUM=e2b2762964ef5f014591b13d77d823ab
ARG CERNBOX_URL_LIST="https://xilinx-ax-dl.entitlenow.com/dl/ul/2019/11/08/R210260632/Xilinx_Vivado_2019.2_1106_2127.tar.gz;"
ARG REFERENCE_SPLIT_MD5SUM_LIST="e2b2762964ef5f014591b13d77d823ab;"

# Install packages
RUN yum -y install gcc gcc-c++ make java-1.8.0-openjdk libXrender-devel libXtst-devel xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-apps wget \
    && yum clean all \
    && df -ih \
    && mkdir -p /opt \
    && ls -alh /
	
# Download Tarball for Vivado/Vitis Install	
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
           wget --progress=dot:giga -c -O ${TARBALL_PATH} ${CERNBOX_URL_DOWNLOAD}; \
           echo -e "\tChecking the md5sum ..."; \
           checksum=$(echo $(md5sum ${TARBALL_PATH}) | awk '{print $1;}'); \
           reference_checksum="${REFERENCE_SPLIT_MD5SUM_ARRAY[$i]}"; \
           [[ "${checksum}" == "${reference_checksum}" ]] && { echo -e "\t\tChecksums match!"; } || { echo -e "\t\tWARNING::The checksum ${checksum}) doesn't match its reference checksum (${reference_checksum})!"; break; }; \
           df -h; \
       done \
    && ls -alh /opt \
    && echo "Unpacking the tarball ..." \
    && tar -xzf ${TARBALL_PATH} --directory /opt/ \
    && ls -alh /opt \
    && df -ih \
    && echo "Removing the tarball ..." \
    && rm ${TARBALL_PATH} \
    && ls -alh /opt \
    && df -ih 
	
# Run Installer for Vivado/Vitis	
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

# Setup Final details	
USER vivado
WORKDIR /home/vivado

ENV DISPLAY :0
ENV GEOMETRY 1920x1200
ENV VERSION=${VERSION}

ENTRYPOINT /opt/Xilinx/Vivado/${VERSION}/bin/vivado -mode batch
