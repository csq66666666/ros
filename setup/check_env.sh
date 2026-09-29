#!/usr/bin/env bash
# ROS 2 学习环境自检脚本
# 用法: bash ~/ros/setup/check_env.sh
# 只读检查，不会安装或修改任何东西。

ROS_DISTRO_EXPECTED="humble"
OK=0; MISS=0

green() { printf '\033[32m%s\033[0m\n' "$1"; }
red()   { printf '\033[31m%s\033[0m\n' "$1"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$1"; }
blue()  { printf '\033[36m%s\033[0m\n' "$1"; }

blue "=============================================="
blue "  ROS 2 学习环境自检"
blue "=============================================="
echo

# ---------- 1. 系统 ----------
echo "【1】系统信息"
if [ -f /etc/os-release ]; then
  . /etc/os-release
  echo "   发行版   : $PRETTY_NAME"
fi
echo "   内核     : $(uname -r)"
echo "   Python   : $(python3 --version 2>/dev/null || echo '未安装')"
echo

# ---------- 2. ROS 2 本体 ----------
echo "【2】ROS 2 本体"
if [ -f "/opt/ros/${ROS_DISTRO_EXPECTED}/setup.bash" ]; then
  green "   ✓ /opt/ros/${ROS_DISTRO_EXPECTED} 存在"
  # shellcheck disable=SC1090
  source "/opt/ros/${ROS_DISTRO_EXPECTED}/setup.bash"
  echo "   ROS_DISTRO = ${ROS_DISTRO}"
  echo "   ROS_VERSION = ${ROS_VERSION:-<未设置>}"
  if command -v ros2 >/dev/null 2>&1; then
    green "   ✓ ros2 CLI 可用"
  else
    red "   ✗ ros2 命令不可用（source 后仍找不到）"
    MISS=$((MISS+1))
  fi
else
  red "   ✗ 未找到 /opt/ros/${ROS_DISTRO_EXPECTED}，请先安装 ROS 2 Humble"
  MISS=$((MISS+1))
fi
echo

# ---------- 3. 基础构建工具 ----------
echo "【3】基础构建/开发工具"
for c in colcon rosdep cmake g++ git python3 tmux; do
  if command -v "$c" >/dev/null 2>&1; then
    green "   ✓ $(printf '%-8s' "$c") $(command -v "$c")"
    OK=$((OK+1))
  else
    red "   ✗ $(printf '%-8s' "$c") 未安装"
    MISS=$((MISS+1))
  fi
done
echo

# ---------- 4. 学习相关 ROS 包 ----------
check_pkg() {
  local pkg="$1" stage="$2"
  if [ -d "/opt/ros/${ROS_DISTRO_EXPECTED}/share/${pkg}" ]; then
    green "   ✓ $(printf '%-34s' "$pkg") [$stage]"
    OK=$((OK+1))
  else
    red   "   ✗ $(printf '%-34s' "$pkg") [$stage] 未安装"
    MISS=$((MISS+1))
  fi
}

echo "【4】学习所需 ROS 包（按阶段）"
check_pkg turtlesim                        "阶段1"
check_pkg demo_nodes_py                    "阶段2"
check_pkg demo_nodes_cpp                   "阶段2"
check_pkg examples_rclpy_minimal_publisher "阶段2"
check_pkg rviz2                            "阶段3"
check_pkg robot_state_publisher            "阶段3"
check_pkg tf2_tools                        "阶段3"
check_pkg xacro                            "阶段3"
check_pkg joint_state_publisher_gui        "阶段3"
check_pkg teleop_twist_keyboard            "阶段5"
check_pkg ros2controlcli                   "阶段5"
check_pkg controller_manager               "阶段5"
check_pkg gazebo_ros                       "阶段5"
check_pkg turtlebot3_gazebo                "阶段5"
check_pkg slam_toolbox                     "阶段6A"
check_pkg nav2_bringup                     "阶段7A"
check_pkg moveit                           "阶段6B/7B"
check_pkg plotjuggler_ros                  "阶段4"
echo

# ---------- 5. 环境变量 ----------
echo "【5】环境变量与 shell 配置"
echo "   ROS_DOMAIN_ID     = ${ROS_DOMAIN_ID:-<未设置，默认 0>}"
echo "   ROS_LOCALHOST_ONLY= ${ROS_LOCALHOST_ONLY:-<未设置>}"
if grep -q "source /opt/ros/${ROS_DISTRO_EXPECTED}/setup.bash" "$HOME/.bashrc" 2>/dev/null; then
  green "   ✓ ~/.bashrc 已自动 source ROS 2"
else
  yellow "   ! ~/.bashrc 未自动 source，建议添加："
  echo "     echo 'source /opt/ros/${ROS_DISTRO_EXPECTED}/setup.bash' >> ~/.bashrc"
fi
echo

# ---------- 6. 工作空间 ----------
echo "【6】学习工作空间"
for ws in "$HOME/ros/ws_learn" "$HOME/ros/ws_nav" "$HOME/ros/ws_arm"; do
  if [ -d "$ws/install" ]; then
    green "   ✓ $ws （已编译过）"
  elif [ -d "$ws/src" ]; then
    yellow "   ! $ws/src 存在但没编译，运行: cd $ws && colcon build --symlink-install"
  else
    yellow "   - $ws 尚未创建"
  fi
done
echo

# ---------- 汇总 ----------
blue "=============================================="
echo "  通过: $OK    缺失: $MISS"
if [ "$MISS" -gt 0 ]; then
  yellow "  有缺失项属于正常——按学习阶段安装即可，不必一次全装。"
  echo "  一键补齐脚本见: ~/ros/setup/install_packages.sh"
else
  green "  环境完整，可以直接开始学习！"
fi
blue "=============================================="
echo
echo "下一步：阅读 ~/ros/ROS2学习路径.md 的阶段 1，跑通小海龟。"
