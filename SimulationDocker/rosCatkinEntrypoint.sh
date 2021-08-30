#!/bin/bash

# Source ROS distro environment and local catwin workspace
source "$HOME_WS/.profile" && source "/opt/ros/$ROS_DISTRO/setup.bash" && source "$CATKIN_WS/devel/setup.bash" && export GAZEBO_MODEL_PATH="$(rospack find gazebo_description)/models"w

command="$@ argSpawnLatitude:=41.86396490539318 argSpawnLongitude:=-4.792476461457779 argSpawnAltitude:=212 argSpawnHeading:=0.0 argUseDepth:=false"
bash -c "$command"
