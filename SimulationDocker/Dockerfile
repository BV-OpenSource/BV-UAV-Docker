#FROM phusion/baseimage:master-amd64 as base
FROM ubuntu:18.04 as base

SHELL ["/bin/bash", "-c"]

ENV TZ=Europe/Lisbon
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -q update && apt-get install alien -y
RUN apt-get install lsb-core -y -q
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt update -q
RUN apt install ros-melodic-desktop-full -y -q
RUN apt install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential -y -q
RUN /bin/bash -c "source /opt/ros/melodic/setup.bash"
RUN rosdep init

RUN adduser --disabled-password -q user
RUN echo 'user ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN apt-get install -y ros-melodic-catkin python-catkin-tools

USER user
RUN rosdep update
RUN echo "source /opt/ros/melodic/setup.bash" >> /home/user/.bashrc
RUN mkdir -p /home/user/catkin_ws/src
WORKDIR /home/user/catkin_ws/
RUN cat ~/.bashrc
ARG CPU_CORE
RUN source /opt/ros/melodic/setup.bash && catkin_init_workspace && catkin build -j $CPU_CORE
RUN echo "source /home/user/catkin_ws/devel/setup.bash" >> /home/user/.bashrc

RUN git config --global url."https://docker:glpat-UJtf_rx2k4B6rzXWrUv4@gitlab.pdmfc.com/".insteadOf git@gitlab.pdmfc.com:
RUN git config --global http.sslverify false
RUN git config --global url."https://github.com/".insteadOf git://github.com/

ENV HOME_WS /home/user
ENV CATKIN_WS /home/user/catkin_ws
ENV ROS_DISTRO melodic
ENV USER user

WORKDIR /home/user/catkin_ws/src
RUN git clone git@gitlab.pdmfc.com:drones/ros1/heifu-uav/heifu-simulation.git -b melodic-dev
WORKDIR /home/user/catkin_ws/src/heifu-simulation
RUN git submodule update --init --recursive

WORKDIR /home/user/catkin_ws/src/heifu-simulation/ardupilot
RUN git submodule update --init --recursive
RUN Tools/environment_install/install-prereqs-ubuntu.sh -y
RUN source /home/user/.profile && ./modules/waf/waf-light configure --board sitl
RUN source /home/user/.profile && ./modules/waf/waf-light build --target bin/arducopter

WORKDIR /home/user/catkin_ws/src/heifu-simulation
RUN git fetch
RUN git pull origin melodic-dev
RUN git fetch
RUN git submodule update --init --recursive
RUN source /opt/ros/melodic/setup.bash && catkin build -j $CPU_CORE

ARG GITHASH
RUN echo $GITHASH
RUN git fetch
RUN git pull origin melodic-dev
RUN git submodule update --init --recursive
RUN source /opt/ros/melodic/setup.bash && catkin build -j $CPU_CORE

COPY ./rosCatkinEntrypoint.sh /

USER root
RUN chmod +x /rosCatkinEntrypoint.sh
USER user

ENV PATH=/opt/gcc-arm-none-eabi-6-2017-q2-update/bin:$PATH
ENV PATH=/home/user/catkin_ws/src/heifu-simulation/ardupilot/Tools/autotest:$PATH
ENV PATH=/usr/lib/ccache:$PATH

RUN sed -i 's/sim_vehicle.py -v/sim_vehicle.py -N -v/g' $CATKIN_WS/src/heifu-simulation/simulation-bringup/scripts/arducopterSITL.py

ENTRYPOINT ["/rosCatkinEntrypoint.sh"]
CMD ["roscore"]
