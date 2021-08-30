#!/bin/bash

# Source ROS distro environment and local catwin workspace
source "$HOME_WS/.profile" && source "/opt/ros/$ROS_DISTRO/setup.bash" && source "$CATKIN_WS/devel/setup.bash"

command="$@ argEndpoint:=preprod"
bash -c "$command"
