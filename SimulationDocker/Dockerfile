#FROM phusion/baseimage:master-amd64 as base
FROM ubuntu:20.04 as base

SHELL ["/bin/bash", "-c"]

ENV TZ=Europe/Lisbon
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -q update && apt-get install alien -y
RUN apt-get install lsb-core -y -q
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN apt update -q
RUN DEBIAN_FRONTEND=noninteractive apt install ros-noetic-desktop -y -q
RUN apt install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential -y -q
RUN apt install -y -q libgazebo11-dev gazebo11 ros-noetic-gazebo-ros-pkgs ros-noetic-gazebo-ros-control
RUN /bin/bash -c "source /opt/ros/noetic/setup.bash"
RUN rosdep init

RUN adduser --disabled-password -q user
RUN echo 'user ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN apt-get install -y ros-noetic-catkin python3-catkin-tools

USER user
RUN rosdep update
RUN echo "source /opt/ros/noetic/setup.bash" >> /home/user/.bashrc
RUN mkdir -p /home/user/catkin_ws/src
WORKDIR /home/user/catkin_ws/
RUN cat ~/.bashrc
ARG CPU_CORE
RUN source /opt/ros/noetic/setup.bash && catkin_init_workspace && catkin build -j $CPU_CORE
RUN echo "source /home/user/catkin_ws/devel/setup.bash" >> /home/user/.bashrc

RUN git config --global url."https://docker:gldt-bBcdv48kNdpsWc67Exib@gitlab.pdmfc.com/".insteadOf git@gitlab.pdmfc.com:
RUN git config --global http.sslverify false
RUN git config --global url."https://github".insteadOf git://github
RUN git config --global url."https://github.com/".insteadOf git@github.com:

ENV HOME_WS /home/user
ENV CATKIN_WS /home/user/catkin_ws
ENV ROS_DISTRO noetic
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
RUN source /opt/ros/noetic/setup.bash && catkin build -j $CPU_CORE

ARG GITHASH
RUN echo $GITHASH
RUN git fetch
RUN git pull origin melodic-dev
RUN git submodule update --init --recursive
RUN source /opt/ros/noetic/setup.bash && catkin build -j $CPU_CORE

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
