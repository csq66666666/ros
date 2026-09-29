# 建包命令速查（阶段 1–2）

## 1. 创建工作空间

```bash
mkdir -p ~/ros/ws_learn/src
cd ~/ros/ws_learn
```

工作空间结构（`build/` `install/` `log/` 由 colcon 生成，**不要提交到 git**）：

```
ws_learn/
├── src/          ← 你的源码放这里
├── build/        ← 编译中间文件
├── install/      ← 编译产物（要 source 这里）
└── log/          ← 编译日志
```

---

## 2. 创建 Python 包

```bash
cd ~/ros/ws_learn/src
ros2 pkg create --build-type ament_python my_pkg --dependencies rclpy std_msgs
```

创建带自定义消息的接口包：

```bash
ros2 pkg create --build-type ament_cmake my_interfaces
```

创建 C++ 包：

```bash
ros2 pkg create --build-type ament_cmake my_cpp_pkg --dependencies rclcpp std_msgs
```

---

## 3. 编译与 source

```bash
cd ~/ros/ws_learn
colcon build --symlink-install          # Python 包必须加 --symlink-install，改代码才免编译
source install/setup.bash               # ★每次新终端都要执行
```

常用变体：

```bash
colcon build --packages-select my_pkg              # 只编译一个包（快）
colcon build --symlink-install --packages-up-to my_pkg
colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release
rm -rf build install log && colcon build --symlink-install   # 彻底重编（玄学问题先试这个）
```

---

## 4. Python 包的关键文件

**`setup.py`** —— 必须注册可执行文件，否则 `ros2 run` 找不到：

```python
entry_points={
    'console_scripts': [
        'my_node = my_pkg.my_node:main',      # ros2 run my_pkg my_node
    ],
},
```

同时把 launch / rviz / config 目录安装到 share：

```python
from glob import glob
import os

data_files=[
    ('share/ament_index/resource_index/packages', ['resource/' + package_name]),
    ('share/' + package_name, ['package.xml']),
    (os.path.join('share', package_name, 'launch'), glob('launch/*.launch.py')),
    (os.path.join('share', package_name, 'rviz'),   glob('rviz/*.rviz')),
    (os.path.join('share', package_name, 'config'), glob('config/*.yaml')),
],
```

**`package.xml`** —— 用到什么依赖就声明什么，否则运行时找不到：

```xml
<exec_depend>rclpy</exec_depend>
<exec_depend>std_msgs</exec_depend>
```

---

## 5. 自定义消息（`my_interfaces` 包）

```
my_interfaces/
├── msg/RobotStatus.msg       # string name\nfloat32 battery\nint32 mode
├── srv/AddTwoInts.srv        # int64 a\nint64 b\n---\nint64 sum
├── action/CountTo.action     # int32 target\n---\n---\nint32 result
├── CMakeLists.txt
└── package.xml
```

`CMakeLists.txt` 关键部分：

```cmake
find_package(rosidl_default_generators REQUIRED)
rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/RobotStatus.msg"
  "srv/AddTwoInts.srv"
  "action/CountTo.action"
)
```

`package.xml` 关键部分：

```xml
<buildtool_depend>ament_cmake</buildtool_depend>
<build_depend>rosidl_default_generators</build_depend>
<exec_depend>rosidl_default_runtime</exec_depend>
<member_of_group>rosidl_interface_packages</member_of_group>
```

编译后验证：

```bash
source install/setup.bash
ros2 interface show my_interfaces/msg/RobotStatus
ros2 interface list | grep my_interfaces
```

> 其他包要用这个自定义消息，必须在它的 `package.xml` 加 `<depend>my_interfaces</depend>`。

---

## 6. 命令行速查

```bash
# 节点
ros2 node list
ros2 node info /my_node

# 话题
ros2 topic list -t
ros2 topic echo /chatter
ros2 topic hz /scan
ros2 topic info /scan --verbose      # ★看 QoS，排查收不到数据
ros2 topic pub /cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.5}}"

# 服务
ros2 service list -t
ros2 service call /add_two_ints example_interfaces/srv/AddTwoInts "{a: 3, b: 4}"

# 动作
ros2 action list -t
ros2 action send_goal /count_to my_interfaces/action/CountTo "{target: 5}" --feedback

# 参数
ros2 param list
ros2 param get /my_node publish_rate
ros2 param set /my_node publish_rate 5.0
ros2 param dump /my_node > params.yaml

# 接口
ros2 interface show geometry_msgs/msg/Twist
ros2 interface packages

# 调试
ros2 doctor --report
ros2 run rqt_graph rqt_graph
ros2 run tf2_tools view_frames
```

---

## 7. 极简排错流程

1. `ros2: command not found` → `source /opt/ros/humble/setup.bash`
2. `Package 'xxx' not found` → `source install/setup.bash`
3. 改代码没生效 → `colcon build --symlink-install`
4. 收不到话题数据 → `ros2 topic info /t --verbose` 对比两端 QoS
5. 玄学失败 → `rm -rf build install log && colcon build --symlink-install`
6. 还是不行 → 看 `~/.ros/log/` 最新日志，把英文报错原样搜索
