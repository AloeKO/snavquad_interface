#!/bin/sh

if [ $# -eq 0 ]; then
  echo "Input mav number(integer) as first argument"
  exit 1
fi

MAV_ID=$1
if echo $MAV_ID | grep -Eq '^[+-]?[0-9]+$'
then
  echo "Recording bag file for MAV $MAV_ID"
else
  echo "Input mav number(integer) as first argument"
  exit 1
fi

suffix=$2
if [ $# -eq 2 ]; then
  suffix=-$2
fi

MAV_NAME="dragonfly$MAV_ID"
echo "MAV Name $MAV_NAME"

bag_folder="/media/sdcard"

if [ ! -d "$bag_folder" ]; then
  echo "*** WARNING *** SD card not present, recording locally"
  cd /data
else
  echo 'Bag files stored at' $bag_folder
  cd $bag_folder

  #Print out %Used SD card
  USED_PERCENT=$(df --output=pcent $bag_folder | awk '/[0-9]%/{print $(NF)}' | awk '{print substr($1, 1, length($1)-1)}')
  echo 'SD card' ${USED_PERCENT} '% Full'
fi

TOPICS="
/tf
/tf_static"

PLANNER_TOPICS="
/octomap_full
/waypoint_nav/feedback
/waypoint_nav/update
/$MAV_NAME/global_trajectory
/$MAV_NAME/optimal_trajectory
/$MAV_NAME/ring_buffer/free
/$MAV_NAME/ring_buffer/distance
/$MAV_NAME/ring_buffer/occupied
/$MAV_NAME/ring_buffer/free_array
/$MAV_NAME/ring_buffer/distance_array
/$MAV_NAME/ring_buffer/occupied_array
/$MAV_NAME/radius_outlier_removal/output
/$MAV_NAME/dmp_path
/$MAV_NAME/lookahead_cost"

CONTROL_TOPICS="
/$MAV_NAME/position_cmd
/$MAV_NAME/so3_cmd
/$MAV_NAME/trpy_cmd"

UKF_TOPICS="
/$MAV_NAME/quadrotor_ukf/control_odom
/$MAV_NAME/quadrotor_ukf/control_odom_throttled
/$MAV_NAME/quadrotor_ukf/imu_bias"

SNAV_TOPICS="
/$MAV_NAME/imu
/$MAV_NAME/imu_raw_array
/$MAV_NAME/imu_accel_offset
/$MAV_NAME/vio/internal_states
/$MAV_NAME/vio/map_points
/$MAV_NAME/vio/odometry
/$MAV_NAME/vio/point_cloud
/$MAV_NAME/vio/pose
/$MAV_NAME/attitude_estimate"

DFC_TOPICS="
/$MAV_NAME/fisheye/camera_info
/$MAV_NAME/dfc/camera_info
/$MAV_NAME/dfc/image_raw/compressed
/$MAV_NAME/dfc/image_overlay/compressed"

TOF_TOPICS="
/$MAV_NAME/tof/camera_info
/$MAV_NAME/tof/image_raw/compressed
/$MAV_NAME/tof/image_raw/compressedDepth
/$MAV_NAME/tof/ir/camera_info
/$MAV_NAME/tof/ir/image_raw/compressed
/$MAV_NAME/tof/ir/image_raw/compressedDepth
/$MAV_NAME/tof/points
/$MAV_NAME/tof/scan"

STEREO_TOPICS="
/$MAV_NAME/stereo/left/image_raw/compressed
/$MAV_NAME/stereo/left/camera_info
/$MAV_NAME/stereo/right/image_raw/compressed
/$MAV_NAME/stereo/right/camera_info"

STEREO_DEPTH_TOPICS="
/$MAV_NAME/stereo/dfs/depth/image_raw/compressedDepth
/$MAV_NAME/stereo/dfs/depth/camera_info"

ALL_TOPICS=$TOPICS$CONTROL_TOPICS$PLANNER_TOPICS$UKF_TOPICS$SNAV_TOPICS$DFC_TOPICS$STEREO_TOPICS$TOF_TOPICS

BAG_STAMP=$(date +%F-%H-%M-%S-%Z)
CURR_TIMEZONE=$(date +%Z)

BAG_NAME=$BAG_STAMP-V${MAV_ID}.bag
BAG_PREFIX=V${MAV_ID}-${CURR_TIMEZONE}

eval rosbag record -b512 $ALL_TOPICS -o $BAG_PREFIX

