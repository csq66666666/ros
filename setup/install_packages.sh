#!/usr/bin/env bash
# 按学习阶段安装 ROS 2 Humble 依赖包
# 用法:
#   bash ~/ros/setup/install_packages.sh list      # 只列出将要安装的包
#   bash ~/ros/setup/install_packages.sh stage1    # 安装阶段1~4 的包
#   bash ~/ros/setup/install_packages.sh nav       # 安装导航方向（含仿真）
#   bash ~/ros/setup/install_packages.sh arm       # 安装机械臂方向
#   bash ~/ros/setup/install_packages.sh all       # 全部安装
#
# 需要 sudo 权限，脚本会先打印清单再执行。

set -euo pipefail

DISTRO="humble"

# ---- 阶段 1~4：核心开发必备 ----
STAGE1=(
  ros-${DISTRO}-turtlesim
  ros-${DISTRO}-rqt
  ros-${DISTRO}-rqt-common-plugins
  ros-${DISTRO}-rqt-graph
  ros-${DISTRO}-rqt-console
  ros-${DISTRO}-rqt-plot
  ros-${DISTRO}-demo-nodes-py
  ros-${DISTRO}-demo-nodes-cpp
  ros-${DISTRO}-examples-rclpy-minimal-publisher
  ros-${DISTRO}-examples-rclpy-minimal-subscriber
  ros-${DISTRO}-example-interfaces
)

STAGE3=(
  ros-${DISTRO}-xacro
  ros-${DISTRO}-joint-state-publisher
  ros-${DISTRO}-joint-state-publisher-gui
  ros-${DISTRO}-tf2-tools
  ros-${DISTRO}-urdf
  ros-${DISTRO}-rviz2
)

STAGE4=(
  ros-${DISTRO}-plotjuggler-ros
  python3-colcon-common-extensions
  python3-rosdep
  python3-vcstool
  tmux
)

# ---- 阶段 5：仿真（两条线都要） ----
SIM=(
  ros-${DISTRO}-gazebo-ros-pkgs
  ros-${DISTRO}-gazebo-plugins
  ros-${DISTRO}-ros2-control
  ros-${DISTRO}-ros2-controllers
  ros-${DISTRO}-controller-manager
  ros-${DISTRO}-teleop-twist-keyboard
  ros-${DISTRO}-turtlebot3
  ros-${DISTRO}-turtlebot3-msgs
  ros-${DISTRO}-turtlebot3-simulations
  ros-${DISTRO}-robot-localization
  ros-${DISTRO}-slam-toolbox
)

# ---- 方向①：导航 ----
NAV=(
  ros-${DISTRO}-navigation2
  ros-${DISTRO}-nav2-bringup
  ros-${DISTRO}-nav2-simple-commander
  ros-${DISTRO}-cartographer-ros
  ros-${DISTRO}-slam-toolbox
)

# ---- 方向②：机械臂 ----
ARM=(
  ros-${DISTRO}-moveit
  ros-${DISTRO}-moveit-servo
  ros-${DISTRO}-moveit-visual-tools
  ros-${DISTRO}-ros2-control
  ros-${DISTRO}-ros2-controllers
  ros-${DISTRO}-gripper-controllers
  ros-${DISTRO}-joint-trajectory-controller
  ros-${DISTRO}-realsense2-camera
  ros-${DISTRO}-cv-bridge
)

usage() {
  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
}

pick() {
  case "${1:-}" in
    list)   echo "STAGE1 STAGE3 STAGE4 SIM NAV ARM" ;;
    stage1) echo "STAGE1 STAGE3 STAGE4" ;;
    sim)    echo "SIM" ;;
    nav)    echo "SIM NAV" ;;
    arm)    echo "SIM ARM" ;;
    all)    echo "STAGE1 STAGE3 STAGE4 SIM NAV ARM" ;;
    *)      usage ;;
  esac
}

PKGS=()
for grp in $(pick "${1:-}"); do
  eval "arr=(\"\${${grp}[@]}\")"
  PKGS+=("${arr[@]}")
done

# 去重
mapfile -t PKGS < <(printf '%s\n' "${PKGS[@]}" | sort -u)

echo "=============================================="
echo " 将安装以下 ${#PKGS[@]} 个 apt 包（ROS 2 ${DISTRO}）"
echo "=============================================="
printf '  %s\n' "${PKGS[@]}"
echo
echo "注意：需要联网 + sudo 权限，可能下载数百 MB ~ 数 GB。"
read -r -p "确认继续？[y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] || { echo "已取消。"; exit 0; }

sudo apt update
sudo apt install -y "${PKGS[@]}"

echo
echo "✓ 安装完成。请重新打开终端（或 source ~/.bashrc）后运行自检："
echo "  bash ~/ros/setup/check_env.sh"
