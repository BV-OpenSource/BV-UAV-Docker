#FROM phusion/baseimage:master-amd64 as base
FROM ubuntu:20.04 as base

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
RUN DEBIAN_FRONTEND=noninteractive apt install ros-noetic-desktop-full -y -q
RUN apt install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential python3-pip -y -q
RUN /bin/bash -c "source /opt/ros/noetic/setup.bash"
RUN rosdep init

RUN adduser --disabled-password -q user
RUN echo 'user ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN apt update -q
RUN apt-get install -y ros-noetic-catkin python3-catkin-tools
RUN apt-get install -y ros-noetic-joy ros-noetic-joy-teleop ros-noetic-mavlink libgeographic-dev ros-noetic-geographic-msgs gdal-bin libgdal-dev wget geographiclib-tools libgeographic-dev gstreamer1.0-tools libgstreamer1.0-dev ros-noetic-mavros ros-noetic-ntpd-driver ros-noetic-vision-msgs
RUN apt-get install -y -q python3-gst-1.0 libgstrtspserver-1.0
#RUN wget https://gitlab.pdmfc.com/drones/ros1/heifu/-/raw/master/heifu_scripts_firmware/loader.py
#RUN cp loader.py /opt/ros/noetic/lib/python3/dist-packages/roslaunch/

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
RUN git config --global user.email "docker@beyond-vision.pt"
RUN git config --global user.name "Docker"
RUN git config --global http.sslVerify false


WORKDIR /home/user/catkin_ws/src
RUN git clone git@gitlab.pdmfc.com:drones/ros1/heifu-uav/heifu.git -b dev
WORKDIR /home/user/catkin_ws/src/heifu
RUN git submodule update --init --recursive

USER root
RUN /opt/ros/noetic/lib/mavros/install_geographiclib_datasets.sh
USER user

ENV HOME_WS /home/user
ENV CATKIN_WS /home/user/catkin_ws
ENV ROS_DISTRO noetic
ENV USER user

WORKDIR /home/user/catkin_ws/src/heifu/bev_uav_interface/bev_uav_gcs_interface
RUN mv requirements.txt requirements_orig.txt
RUN sed '/^rospy.*/d' < requirements_orig.txt > requirements.txt
RUN python3 -m pip install -r requirements.txt
# RUN python -m pip install pygdal==2.2.3.6
RUN mkdir -p /home/user/Desktop/logs

RUN git fetch
WORKDIR /home/user/catkin_ws/src/heifu
RUN git fetch
RUN git checkout dev
RUN git pull origin dev
RUN git submodule update --init --recursive

RUN catkin config --blacklist bev_uav_collision_avoidance gpu_voxels_ros bev_uav_planner bev_uav_planners_manager bev_uav_rrt
RUN source /opt/ros/noetic/setup.bash && catkin build

ARG GITHASH
RUN echo $GITHASH
RUN git fetch
RUN git pull origin dev
RUN git submodule update --init --recursive
WORKDIR /home/user/catkin_ws/src/heifu
RUN source /opt/ros/noetic/setup.bash && catkin build

COPY ./rosCatkinEntrypoint.sh /
COPY ./config.bext /home/user/config.bext

USER root
RUN chmod +x /rosCatkinEntrypoint.sh
USER user

ENTRYPOINT ["/rosCatkinEntrypoint.sh"]
CMD ["roscore"]
