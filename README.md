# Linux Container with Xilinx Vivado/Vitis HLS
For many reasons having Xilinx Vivado/Vitis HLS installed in a docker image can be useful. This package is setup to build docker images with various setups using the CERN GitLab docker-builder runners. The configurations for the docker builds can be found in the table below:

| **Linux Flavor** | **Vivado Version** |
| ---------------- | ------------------ | 
| AlmaLinux 8      | 2020.1             | 
| AlmaLinux 9      | 2022.2             | 
| AlmaLinux 9      | 2023.1             | 


The general idea behind these containers was that they would be transient and always run with the ```--rm``` option. Any external files that needed to be used within the container could be mapped using a shared folder (i.e. ```-v <path to host folder>:<path in container>```). I never intended, nor have I tested, ssh'ing into the containers. This tends to open up security holes (i.e. root access, passwords, internal vs external port connections) that I didn't want to deal with.

the default entrypoint of the containers calls `<vivado|vitis> -mode gui`. If you have things configured to use X11 (see "Run Using X11" below), it will launch Vivado in the `/project` directory. 
To actually run something with this container as it stands, You _must_ mount a project directory to the `/project` location in the docker container through a bind mount. you can do this by appending the following to your `docker run` command:
``` bash
--mount type=bind,source="$(pwd)"/your_vivado_project,target=/project
```

To perform more complex actions and/or use <vivado/vitis> HLS, you can override the default CMD. 

In general, it's best to lock down docker so that ssh to the remote machine is only accessible from your local machine. To do this, you can use the option ```-p 127.0.0.1:22:22``` when doing the ```ssh``` command (not ```-P```). Alternatively, you can go to the docker settings and change the default to always listen only on the local interface. Go to ```Preferences... > Daemon > Advanced``` and add the lines:
```
{
    "ip" : "127.0.0.1"
}
```

Due to the large size of the recent tools, it's likely that these images will also support and be primarily used via a "minimal" version, in which the actual tools themselves are mounted to the container from an pre-existing location (such as a Kubernetes Persistant Volume) 

## Build Instructions
When building the containers, they are configured so that they will look for a given "unified installer" tar.gz file in the relevant `<vivado|vitis>/files` location, and if not present will download it for the build process.
**If the images are downloaded during the build process, they will not be saved to `<vivado|vitis>/files` location. 
**If you are going to try and build these images regularly or tweak/develop/test them, it's highly recomended to download the installer from Xilinx's website and place it in `<vivado|vitis>/files` to avoid potentially downloading *100GB+ each build*
**The Xilinx installers and subsiquent docker images are *very* large, with the ranging from ~40GB (Vivado 2020.1) to ~110GB (Vitis 2023.2) - Make sure you have enough free disk space (~250GB for build, ~Xilinx Installer size + 3GB for built image itself)!
**Make sure you clean your docker build cache and dangling images after building to reclaim a large amount of disk space!!!
```bash
docker builder prune 
docker image prune
```
To actually build and push a given image:
```bash
docker login
cd <vivado|vitis>
docker build --pull -t <username>/vivado-docker/<container name>:<container tag> -f <relative path to Dockerfile> .
docker push <username>/vivado-docker/<container name>:<container tag>
```

**Note:** The container image name must contain only lowercase letters.

## Run Using X11
This is my preferred way of accessing the remote windows. For one, it requires fewer additions to the base operating system. Additionally, it's easier to resize the windows, not having to set the geometry when running the container. That being said, some care must be taken to secure the connection between the remote system and the localhost.

### Directly Connect Host and Remote
These directions will assume that the user is running OSX and has XQuartz installed. Settings for other host systems and/or X11 window programs are left to the user to figure out.

This next step only has to be performed once for the host system. We will need to make sure that XQuartz allows connections from network/remote clients. Open the menu at ```XQuartz > Preferences...``` and click on the ```Security``` tab. Make sure that the check box next to "Allow connections from network clients" is selected. You will need to restart XQuartz if this option wasn't already enabled.

Add the local interface to the list of acceptable connections by doing ```xhost + 127.0.0.1```. This needs to be done only when the xhost list is reset. I'm not sure when this is (i.e. upon restart?).

To open the remote program and start an x-window use the command:
```bash
docker run --rm -it --net=host -e DISPLAY=host.docker.internal:0 docker.io/bhawks/vivado-docker/<container name>:<container tag> /opt/Xilinx/<Vivado|Vitis>/<version>/bin/<Vivado|Vitis>
```

**Note:** You may need to do ```docker login gitlab-registry.cern.ch``` in order to pull the image from GitLab. Use your CERN username and password.

### Use the System IP Address
This is a less secure method of connecting the remote program to the X11 system on the host. This is because you are allowing the remote system to access the internet and then connect to your system's external IP address. While the xhost command does limit the connections to just that one address, this is still note the best practice and may get you booted off the network at FNAL.

```bash
IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')  # use en1 for Wifi
xhost + $IP
docker run --rm -it -e DISPLAY=$IP:0 -v /tmp/.X11-unix:/tmp/.X11-unix docker.io/bhawks/vivado-docker/<container name>:<container tag> /opt/Xilinx/<Vivado|Vitis>/<version>/bin/<Vivado|Vitis>
```

**Note:** I found that at one point I needed to reset my xhost list by turning off the xhost filtering and then turning it back on ```xhost <-/+>```. At FNAL, remember to disconnect from the internet before you do this because it will be seen as opening up a hole in your firewall and get you blocked from the network.

### Alternate Entrypoint
To override the entrypoint, you need to use the ```--entrypoint``` option. You may want to do this, for instance, if you want to open a bash terminal rather than Vivado directly.
```bash
docker run --rm -it -e DISPLAY=$IP:0 -v /tmp/.X11-unix:/tmp/.X11-unix --entrypoint /bin/bash docker.io/bhawks/vivado-docker/<container name>:<container tag>
```

### xilinx_docker Bash Function
Inside the file ```.xilinx_docker``` there is a bash function named xilinx_docker. This function is meant to help the user quickly spin up a one of these docker containers. Rather than having to remember the entire docker run command and the variations for each entrypoint, this function provides a much simpler interface. It is based on the "Direct Connection" method mentioned above. I find it useful to source the ```.xilinx_docker``` file from within my login script.

For a complete set of directions on how to use this utility, see the functions help message. Simply use:
```bash
xilinx_docker -h
```

## Specifying a Xilinx License Server
In order to access the some Vivado instances/features, it may be necessary to set the Xilinx License Server location via an environment variable. When running the docker container, add ```-e XILINXD_LICENSE_FILE=<license server>```

## Command Line Access to a Currently Running Container
If you need to access the command line for a container which is currently running you can use the following command to open up a bash prompt:
```bash
docker exec -it <container name> bash
```

You may need to run ```docker ps -a``` to find the name of the container if you didn't set one yourself. Docker will set it's own name if you didn't specify one.