#FROM phusion/baseimage:master-amd64 as base
FROM ubuntu:18.04 as base

SHELL ["/bin/bash", "-c"]

ENV TZ=Europe/Lisbon
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -q update
RUN apt-get install software-properties-common -y -q
RUN add-apt-repository universe
RUN add-apt-repository multiverse
RUN add-apt-repository restricted
RUN apt-get -q update
RUN apt-get install lsb-core --fix-missing -y -q
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN apt update -q
RUN apt install ros-melodic-desktop-full -y -q
RUN apt install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential python-pip -y -q
RUN /bin/bash -c "source /opt/ros/melodic/setup.bash"
RUN rosdep init

RUN adduser --disabled-password -q user
RUN echo 'user ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN apt update -q
RUN apt-get install -y ros-melodic-catkin python-catkin-tools
RUN apt-get install -y ros-melodic-joy ros-melodic-joy-teleop ros-melodic-mavlink libgeographic-dev ros-melodic-geographic-msgs gdal-bin libgdal-dev wget geographiclib-tools libgeographic-dev gstreamer1.0-tools libgstreamer1.0-dev
RUN wget https://gitlab.pdmfc.com/drones/ros1/heifu/-/raw/master/heifu_scripts_firmware/loader.py
RUN cp loader.py /opt/ros/melodic/lib/python2.7/dist-packages/roslaunch/

USER user
RUN rosdep update
RUN echo "source /opt/ros/melodic/setup.bash" >> /home/user/.bashrc
RUN mkdir -p /home/user/catkin_ws/src
WORKDIR /home/user/catkin_ws/
RUN cat ~/.bashrc
ARG CPU_CORE
RUN source /opt/ros/melodic/setup.bash && catkin_init_workspace && catkin build -j $CPU_CORE
RUN echo "source /home/user/catkin_ws/devel/setup.bash" >> /home/user/.bashrc

RUN git config --global url."https://heifu:1_oQUkWQjxZSrHPm7NLP@gitlab.pdmfc.com/".insteadOf git@gitlab.pdmfc.com:

WORKDIR /home/user/catkin_ws/src
RUN git clone git@gitlab.pdmfc.com:drones/ros1/heifu-uav/heifu.git
WORKDIR /home/user/catkin_ws/src/heifu
RUN git checkout origin/newVersion
RUN git submodule update --init --recursive

USER root
RUN ./control/mavros/mavros/scripts/install_geographiclib_datasets.sh
USER user

ENV HOME_WS /home/user
ENV CATKIN_WS /home/user/catkin_ws
ENV ROS_DISTRO melodic
ENV USER user

WORKDIR /home/user/catkin_ws/src/heifu/interface/gcs-interface
RUN python -m pip install -r requirements.txt
RUN python -m pip install pygdal==2.2.3.6
RUN mkdir -p /home/user/Desktop/logs

RUN git fetch
WORKDIR /home/user/catkin_ws/src/heifu
RUN git fetch
RUN git pull origin newVersion
RUN git submodule update --init --recursive

RUN catkin config --blacklist collision_avoidance gpu_voxels_ros planner planners_manager rrt
RUN source /opt/ros/melodic/setup.bash && catkin build

ARG GITHASH
RUN echo $GITHASH
RUN git fetch
RUN git pull origin newVersion
RUN git submodule update --init --recursive
RUN source /opt/ros/melodic/setup.bash && catkin build

COPY ./rosCatkinEntrypoint.sh /
COPY ./config.bext /home/user/config.bext

USER root
RUN chmod +x /rosCatkinEntrypoint.sh
USER user

ENTRYPOINT ["/rosCatkinEntrypoint.sh"]
CMD ["roscore"]
