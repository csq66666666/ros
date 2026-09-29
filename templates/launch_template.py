# -*- coding: utf-8 -*-
"""
launch 文件模板（阶段 2 用）
=============================
放在包的 launch/ 目录下，例如 my_pkg/launch/bringup.launch.py

运行：
  ros2 launch my_pkg bringup.launch.py rate:=5.0 use_rviz:=true

别忘了在 setup.py 的 data_files 里安装 launch 目录：
  (os.path.join('share', package_name, 'launch'), glob('launch/*.launch.py')),
"""

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, ExecuteProcess, TimerAction
from launch.conditions import IfCondition
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution
from launch_ros.actions import Node
from launch_ros.substitutions import FindPackageShare


def generate_launch_description():
    # ---------- 1. 声明可传入的参数 ----------
    rate_arg = DeclareLaunchArgument(
        'rate', default_value='1.0', description='发布频率 (Hz)'
    )
    use_rviz_arg = DeclareLaunchArgument(
        'use_rviz', default_value='false', description='是否启动 RViz2'
    )

    rate = LaunchConfiguration('rate')
    use_rviz = LaunchConfiguration('use_rviz')

    # ---------- 2. 节点 ----------
    talker = Node(
        package='my_pkg',                 # 包名
        executable='my_node',             # setup.py 里注册的可执行名
        name='talker',                    # 重命名节点实例
        namespace='demo',                 # 命名空间 → /demo/chatter
        output='screen',                  # 日志打印到终端
        parameters=[{
            'publish_rate': rate,         # 用 LaunchConfiguration 传参
            'topic_name': 'chatter',
        }],
        remappings=[('chatter', 'chatter_remapped')],  # 话题重映射
    )

    listener = Node(
        package='my_pkg',
        executable='my_node',
        name='listener',
        output='screen',
        parameters=[{'publish_rate': 0.5}],
    )

    rviz = Node(
        package='rviz2',
        executable='rviz2',
        name='rviz2',
        condition=IfCondition(use_rviz),  # 条件启动
        arguments=['-d', PathJoinSubstitution(
            [FindPackageShare('my_pkg'), 'rviz', 'default.rviz'])],
    )

    # ---------- 3. 延迟启动（等前一个节点就绪） ----------
    delayed = TimerAction(period=3.0, actions=[listener])

    # ---------- 4. 启动任意命令（如播放 rosbag） ----------
    bag_play = ExecuteProcess(
        cmd=['ros2', 'bag', 'play', 'my_bag'],
        output='screen',
    )

    return LaunchDescription([
        rate_arg,
        use_rviz_arg,
        talker,
        delayed,
        rviz,
        # bag_play,
    ])
