# ROS 2 学习路径（为你定制 · Humble / Ubuntu 22.04）

> 定制依据：**编程基础较弱、Linux 不熟**，目标方向为 **① 移动机器人导航（SLAM + Nav2）** 与 **② 机械臂（MoveIt 2）** 两条线。
> 你的环境已确认：Ubuntu 22.04.5 + ROS 2 **Humble**（`/opt/ros/humble`）+ rviz2 / turtlesim / robot_state_publisher / tf2_tools 已安装。

---

## 一、总体节奏

| 项目 | 建议 |
|---|---|
| 总周期 | **24 周（约 6 个月）** |
| 每日投入 | 1.5 ~ 2 小时；每周 5~6 天 |
| 每周结构 | 学 2 天 → 动手 3 天 → 复盘 1 天 |
| 学习方式 | **每个知识点必须有一个能跑起来的程序**，禁止只看视频不动手 |
| 版本纪律 | 全程只看 **Humble** 的文档，别混看 Foxy/Galactic 教程 |

**三个阶段的大目标：**

```
第 1–2 周    能看懂报错、会写 Python 脚本       → 前置基础
第 3–8 周    能自己写节点，把数据跑通          → ROS 2 核心（必学，不跳过）
第 9–13 周   机器人在仿真里动起来              → 建模 + 仿真
第 14–24 周  导航 or 机械臂 专精 + 综合项目     → 方向深耕
```

> ⚠️ 阶段 1~4 是**所有方向的公共地基**，无论以后做导航还是机械臂都要过。阶段 5 之后才分叉。

---

## 阶段 0：前置基础（第 1–2 周）

**为什么先学这个**：ROS 2 的报错 90% 是「环境没 source」「路径写错」「Python 语法错」。基础不补，后面每天都在猜。

### 学习内容

1. **Linux 命令行**（重点，必须练到不用查）
   - `pwd / ls / cd / cp / mv / rm / mkdir / touch`
   - `cat / less / head / tail / grep / find`（看日志必备）
   - `chmod / chown / sudo / apt`
   - 管道与重定向：`|`、`>`、`>>`、`2>&1`
   - **环境变量**：`echo $ROS_DOMAIN_ID`、`export`、`~/.bashrc` 的作用
   - 进程管理：`ps aux | grep`、`top`、`kill`、`Ctrl+C`
   - 终端复用：`tmux`（跑 ROS 2 必须会，一个窗口开 4 个 pane）
2. **Python 基础**
   - 变量、类型、`if/for/while`、函数、`import`
   - **类与对象、`__init__`、`self`**（ROS 2 节点全是类，这是关键）
   - 模块与包、`if __name__ == '__main__':`
   - 异常处理 `try/except`、字典与列表
3. **工程工具**
   - `git`：`clone / add / commit / push`（你的学习代码要上 GitHub）
   - 编辑器：VS Code（装 `Python`、`ROS`、`C/C++`、`URDF` 插件）
   - `CMake` 只要「知道它是 C++ 的构建工具」即可，第 7 周再深入

### 动手任务（验收标准）

- [ ] 在终端里用 `tmux` 开出 2×2 四个 pane，并说明每个 pane 在干嘛
- [ ] 写 `py_basics/robot.py`：定义一个 `Robot` 类，有名字、电量属性，有 `move()` 方法，电量低于 0 抛异常
- [ ] 用 `grep` 从 `/var/log/syslog` 里找出最近 10 条含 `error` 的行
- [ ] 把以上代码 `git init` 后推到 GitHub（哪怕是私有库）
- [ ] 能解释：为什么每次开新终端要 `source /opt/ros/humble/setup.bash`？

### 资源

- Linux：https://missing.csail.mit.edu/ （只看前 2 讲，中文字幕）
- Python：https://www.runoob.com/python3/python3-tutorial.html （到「面向对象」为止）
- tmux 速查：`tmux` → `Ctrl+b %`（竖切）/ `Ctrl+b "`（横切）/ `Ctrl+b 方向键`

---

## 阶段 1：ROS 2 初体验（第 3 周）

**目标**：建立「节点 / 话题 / 工作空间」的直觉，先跑通官方例子，再写第一个节点。

### 学习内容

1. ROS 2 是什么：DDS 通信中间件、去中心化、无 `roscore`
2. **工作空间概念**：`src/` → `colcon build` → `install/` → `source install/setup.bash`
3. 官方 CLI 工具（**必须熟到闭眼敲**）
   ```bash
   ros2 run turtlesim turtlesim_node
   ros2 node list
   ros2 topic list
   ros2 topic echo /turtle1/pose
   ros2 topic pub /turtle1/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 2.0}}"
   ros2 interface show geometry_msgs/msg/Twist
   ros2 doctor
   ```
4. `rqt` 图形工具：`rqt_graph` 看节点连接关系
5. 第一个 Python 包
   ```bash
   mkdir -p ~/ros/ws_learn/src && cd ~/ros/ws_learn
   ros2 pkg create --build-type ament_python my_first_pkg --dependencies rclpy
   colcon build --symlink-install
   source install/setup.bash
   ```

### 动手任务（验收标准）

- [ ] 用键盘遥控小海龟：`ros2 run turtlesim turtle_teleop_key` + `turtlesim_node`
- [ ] 用 `ros2 topic pub` 让小海龟**画一个正方形**（提示：交替前进与转向，控制频率）
- [ ] 用 `ros2 topic echo` 观察 `/turtle1/pose`，说出 `x/y/theta` 的含义
- [ ] 写一个节点 `my_first_pkg/square.py`，让海龟自动画正方形（**这是你的第 1 个 ROS 2 程序**）
- [ ] 用 `rqt_graph` 截图，说出图里有几个节点、哪些话题

> 你工作区里的 `1/node_test.py` 是空文件，可以直接改成这个阶段的练习起点。

### 常见坑

- `ros2 run` 找不到包 → 忘了 `source install/setup.bash`
- 改了代码没生效 → `--symlink-install` 只对 Python 生效，C++ 必须重新 `colcon build`
- 两个终端话题对不上 → 检查 `echo $ROS_DOMAIN_ID` 是否一致

---

## 阶段 2：通信机制核心（第 4–5 周）★最关键

**目标**：能自己定义消息、写发布订阅/服务/动作，这是 ROS 2 的骨架。

### 2.1 话题 Topic（发布/订阅，异步、多对多）

- `create_publisher` / `create_subscription`、回调函数、`spin()`
- `timer` 定时器发布
- 内置消息：`std_msgs`、`geometry_msgs`、`sensor_msgs`
- **QoS 初识**：`reliable` vs `best_effort`（订阅不到数据的头号原因）

### 2.2 自定义消息 msg

```
my_interfaces/
  msg/RobotStatus.msg     ← 定义字段，如 string name / float32 battery / int32 mode
  srv/...
  action/...
```
- `package.xml` 加 `rosidl_default_generators`、`CMakeLists.txt` 写 `rosidl_generate_interfaces`
- 编译后用 `ros2 interface show my_interfaces/msg/RobotStatus` 验证

### 2.3 服务 Service（同步请求/响应）

- `create_service`、`create_client`、`call_async`
- 适合：查询状态、开关设备、一次性计算

### 2.4 动作 Action（长任务 + 反馈 + 可取消）

- `ActionServer` / `ActionClient`、`GoalResponse`、`Feedback`、`Result`
- 适合：导航到目标点、机械臂运动（**后面 Nav2 / MoveIt 全靠它**）
- 命令行：`ros2 action list / send_goal / info`

### 2.5 参数 Parameter

- 声明 `declare_parameter`、读取、`ros2 param set/get/list`
- 用参数写「可配置的节点」而不是硬编码

### 2.6 Launch 文件

- Python launch 文件：`LaunchDescription`、`Node`、`DeclareLaunchArgument`
- 一次启动多个节点、remap 话题、命名空间 `namespace`

### 动手任务（验收标准）

- [ ] 写 **发布者 + 订阅者**：发布自定义 `RobotStatus`，订阅端打印并在电量 <20 时告警
- [ ] 写一个**加法服务** `/add_two_ints`，客户端调用并打印结果
- [ ] 写一个**动作服务器** `/count_to`：从 1 数到 N，每步发 feedback，可被取消
- [ ] 给节点加 2 个参数（如 `publish_rate`、`robot_name`），用 `ros2 param set` 运行时修改
- [ ] 写 1 个 launch 文件，一条命令同时启动以上所有节点
- [ ] 用 `ros2 bag record` 录 10 秒话题，再 `ros2 bag play` 回放并用 `echo` 验证

### 资源

- 官方教程（Humble）Beginner: CLI Tools + Client Libraries：
  https://docs.ros.org/en/humble/Tutorials.html
- 鱼香 ROS 2 入门（中文，适合你）：https://fishros.com/d2lros2/

---

## 阶段 3：TF2 与 URDF 机器人建模（第 6–7 周）

**目标**：理解「坐标系」这件 ROS 2 里最反直觉、也最重要的事；把机器人模型在 RViz 里显示出来。

### 3.1 TF2 坐标变换

- 坐标系树：`map → odom → base_link → laser_link`
- 广播：`TransformBroadcaster`、静态变换 `StaticTransformBroadcaster`
- 监听：`Buffer` + `TransformListener`，`lookup_transform()`
- 命令行：`ros2 run tf2_tools view_frames`、`ros2 run tf2_ros tf2_echo base_link laser_link`
- **必须理解**：为什么机器人导航离不开 TF（传感器数据要转到统一坐标系）

### 3.2 URDF / XACRO 建模

- `link` / `joint`（`revolute`/`continuous`/`fixed`）、`visual` / `collision` / `inertial`
- `xacro` 宏与参数（真实项目不用裸 URDF）
- `robot_state_publisher` 从 URDF 自动发布 TF
- `joint_state_publisher_gui` 拖动关节验证模型
- RViz2 显示：Fixed Frame 选对、`RobotModel` 插件、`TF` 插件

### 动手任务（验收标准）

- [ ] 用 xacro 建一个**两轮差速小车**：`base_link` + 2 驱动轮 + 1 万向轮 + 1 激光雷达 link
- [ ] 在 RViz2 里正确显示模型，关节可拖动
- [ ] `view_frames` 生成的 tf 树截图，**能口头解释每条父子关系**
- [ ] 写一个节点，广播一个绕小车旋转的 `marker` 坐标系，并用 `tf2_echo` 验证
- [ ] 故意把 joint 名字写错，观察报错并独立修复（练排错）

> 参考视频（强烈推荐，英文但语速慢、图示清楚）：Articulated Robotics 系列
> https://articulatedrobotics.xyz/

---

## 阶段 4：工程化与调试工具（第 8 周）

**目标**：从「能跑」到「能维护、能排错」。

- `colcon` 进阶：`--packages-select`、`--symlink-install`、`--cmake-args -DCMAKE_BUILD_TYPE=Release`
- 工作空间叠加（overlay）与 `COLCON_IGNORE`
- 日志：`~/.ros/log`、`rqt_console`、`ros2 launch --screen`
- 可视化：`rqt_graph`、`rqt_plot`、`PlotJuggler`（建议安装）
- 测试：`pytest`（Python）、`launch_testing`、`colcon test`
- Git 工作流：一个功能一个分支；`.gitignore` 忽略 `build/ install/ log/`

### 动手任务

- [ ] 把前 4 周的代码整理成一个 `ws_learn` 工作空间，推到 GitHub
- [ ] 写 1 个 `launch_testing` 用例，验证节点启动后话题存在
- [ ] 用 `ros2 doctor --report` 检查环境，能解释输出
- [ ] 表演一次「现场排错」：杀掉某节点、改错话题名、制造 QoS 不匹配，各自定位并修复

---

## 阶段 5：仿真环境（第 9–11 周）

**目标**：不买硬件也能让机器人动起来。这是导航与机械臂的共同前提。

### 学习内容

1. **安装**（Humble 时代最省心的组合）
   ```bash
   sudo apt install ros-humble-gazebo-ros-pkgs \
                    ros-humble-xacro \
                    ros-humble-joint-state-publisher-gui \
                    ros-humble-ros2-control ros-humble-ros2-controllers \
                    ros-humble-turtlebot3 ros-humble-turtlebot3-simulations
   ```
   > 注：新 Gazebo（`ros_gz`）是趋势，但 Humble 期教程与 TurtleBot3 生态仍以 Gazebo Classic 为主，**先用 Classic 跑通，第 24 周再了解 ros_gz**。
2. **Gazebo + URDF**：把阶段 3 的小车加载进仿真世界
3. **传感器插件**：2D 激光雷达、深度相机、IMU、里程计（odom）
4. **ros2_control**：`diff_drive_controller` 差速控制器，把 `/cmd_vel` 变成轮子转速
5. 键盘遥控：`teleop_twist_keyboard` → `/cmd_vel`

### 动手任务（验收标准）

- [ ] 自己的 xacro 小车在 Gazebo 里出现，且不掉落、不抖动
- [ ] 键盘遥控能在仿真里开动，RViz2 里能看到激光雷达 `LaserScan` 与 TF 树
- [ ] `/odom` 话题有数据且移动时数值变化合理
- [ ] 用 `ros2 topic hz /scan` 检查雷达频率
- [ ] 写一个 launch 文件：一条命令启动 Gazebo + 机器人 + RViz2

---

## 🔀 分叉点：从这里开始按方向走

> **两条线都建议至少走一遍阶段 6A 和 6B 的前半段**（各 1 周），再选一条深挖——因为「会做移动机器人」和「会做机械臂」在就业市场上是两个不同的岗位，早点看清自己喜欢哪个。

---

## 阶段 6A：SLAM 建图（第 12–13 周）

- 概念：里程计漂移、回环检测、栅格地图、`map` 与 `odom` 的关系
- **slam_toolbox**（Humble 推荐）在线建图
  ```bash
  sudo apt install ros-humble-slam-toolbox
  ```
- 流程：遥控走一圈 → RViz2 看地图逐渐成形 → `map_saver_cli` 保存 `.pgm` + `.yaml`
- 对比了解：Cartographer、RTAB-Map（视觉/3D）

**验收**
- [ ] 用 TurtleBot3 或自己的小车，在仿真房子里建出一张完整地图
- [ ] 保存地图并能重新加载显示
- [ ] 能解释：为什么建图时 `map` 到 `odom` 的变换是 slam 节点发布的？

---

## 阶段 6B：MoveIt 2 机械臂入门（第 12–13 周）

- 安装
  ```bash
  sudo apt install ros-humble-moveit ros-humble-ros2-control ros-humble-ros2-controllers
  ```
- 机械臂建模：xacro 写多关节臂（或用现成模型如 Panda / UR5）
- **MoveIt Setup Assistant**：生成 SRDF，配置自碰撞矩阵、规划组、末端执行器
- RViz2 MotionPlanning 插件：拖动目标 → Plan → Execute
- 概念：规划组、关节空间 vs 笛卡尔空间、逆运动学（IK）、碰撞检测

**验收**
- [ ] 用 Setup Assistant 为自己的机械臂生成配置包
- [ ] 在 RViz 里完成「规划并执行」到指定位姿
- [ ] 能看到规划出的轨迹，并解释为什么会绕开某个障碍

---

## 阶段 7A：Nav2 自主导航（第 14–18 周）— 方向①

**目标**：让机器人自己从 A 点走到 B 点。这是移动机器人岗位的核心技能。

### 学习顺序

1. **Nav2 架构总览**：BT Navigator（行为树）、Planner Server、Controller Server、Behavior Server、Costmap 2D
2. 安装与跑通 Demo
   ```bash
   sudo apt install ros-humble-navigation2 ros-humble-nav2-bringup \
                    ros-humble-turtlebot3 ros-humble-turtlebot3-simulations
   export TURTLEBOT3_MODEL=burger
   ros2 launch nav2_bringup tb3_simulation_launch.py
   ```
3. **代价地图 Costmap**：静态层 / 障碍层 / 膨胀层，`inflation_radius` 调参
4. **AMCL 定位**：在已知地图上定位，`initialpose`、粒子云观察
5. **全局规划器**：NavFn / Smac Planner；**局部控制器**：DWB / MPPI
6. **行为树**：`navigate_to_pose`、`navigate_through_poses`、`FollowPath`
7. **调参**：机器人半径、速度限制、加减速、恢复行为
8. **Waypoint Following**：多点巡航
9. 进阶：多机器人命名空间、自定义规划器插件、Nav2 与 SLAM 同时运行

### 动手任务（验收标准）

- [ ] 在仿真中：先 slam_toolbox 建图 → 保存 → 用 AMCL + Nav2 在**同一张地图**上导航到目标点
- [ ] 用 `ros2 action send_goal /navigate_to_pose nav2_msgs/action/NavigateToPose ...` 用命令行发目标
- [ ] 写一个 Python 节点作为 Nav2 客户端，依次导航到 3 个航点
- [ ] 改 3 个参数（如 `max_vel_x`、`inflation_radius`、`controller_frequency`），说明各自效果
- [ ] 地图上人为放一个障碍，验证能绕行

### 资源

- Nav2 官方文档：https://docs.nav2.org/
- TurtleBot3 仿真手册：https://emanual.robotis.com/docs/en/platform/turtlebot3/overview/

---

## 阶段 7B：MoveIt 2 进阶与 ros2_control（第 14–18 周）— 方向②

1. **MoveIt 2 Python/C++ API**：`MoveGroupInterface`、设置目标位姿、执行
2. **笛卡尔路径规划**：直线/圆弧轨迹，`computeCartesianPath`
3. **夹爪与抓取**：GripperCommand action、抓取姿态生成、`MoveIt Grasps`
4. **ros2_control 硬件接口**：写 `SystemInterface` / `ActuatorInterface`，接真机或仿真
5. **Planning Scene**：添加障碍物、附加物体（attached collision object）
6. 进阶：MoveIt Servo（遥操作）、视觉引导抓取（相机 + 点云 + 手眼标定）

### 动手任务（验收标准）

- [ ] 写 Python 脚本：机械臂从 Home 位姿运动到 3 个指定末端位姿
- [ ] 用笛卡尔路径画一个「□」或「△」
- [ ] 在规划场景里放一个盒子，让机械臂绕开它
- [ ] 实现一个完整 pick & place：移动到物体上方 → 下降 → 闭合夹爪 → 抬起 → 放置
- [ ] 用 `ros2 control list_controllers` 检查控制器状态

### 资源

- MoveIt 2 教程：https://moveit.picknik.ai/humble/index.html
- ros2_control 文档：https://control.ros.org/humble/

---

## 阶段 8：综合项目（第 19–22 周）

**选一个做完，做到可以放进简历/答辩的程度。** 推荐三个梯度：

| 难度 | 项目 | 涵盖技能 |
|---|---|---|
| ⭐⭐ | **仿真自主巡检小车**：Gazebo 房子建图 → Nav2 多点巡航 → 到达后拍照存盘 | 阶段 5+6A+7A |
| ⭐⭐⭐ | **MoveIt 2 视觉抓取**：相机识别方块 → 计算抓取位姿 → 机械臂抓取摆放 | 阶段 3+6B+7B |
| ⭐⭐⭐⭐ | **移动操作臂**：底盘导航到目标前 → 机械臂抓取（两方向结合） | 全部 |

**交付物要求**
- [ ] GitHub 仓库：`README.md`（环境、依赖、编译、运行方法、演示 GIF）
- [ ] `launch` 文件一键启动整个系统
- [ ] 至少 3 个可调参数，并在 README 说明
- [ ] 一份 5 分钟演示视频 + 一份「遇到的问题与解决」记录（面试就聊这个）

---

## 阶段 9：进阶与真机（第 23–24 周）

- **C++ 重写**：用 `rclcpp` 重写一个前面用 Python 写的节点，理解编译与链接
- **QoS 深入**：`reliability` / `durability` / `history` / `deadline`，以及 sensor data 为什么要 `best_effort`
- **DDS 调优**：`ROS_DOMAIN_ID`、跨机通信、`ROS_LOCALHOST_ONLY`、组播问题
- **性能**：component 组合节点（intra-process 零拷贝）、执行器（executor）选择
- **micro-ROS**：把 MCU 接进 ROS 2 图
- **真机部署**：树莓派/Jetson + udev 规则 + systemd 自启 + 网络（WiFi 不稳定时的 QoS 设计）
- **参与开源**：给一个 ROS 2 包提 issue/PR，哪怕只改文档

---

## 二、避坑清单（新手 90% 的坑都在这）

| # | 现象 | 原因 | 解决 |
|---|---|---|---|
| 1 | `ros2: command not found` | 没 source 环境 | `source /opt/ros/humble/setup.bash` |
| 2 | `Package 'xxx' not found` | 只 source 了系统，没 source `install/` | `source ~/ros/ws_learn/install/setup.bash` |
| 3 | 改了 Python 代码没生效 | 用了普通 build | 用 `colcon build --symlink-install` |
| 4 | 订阅端收不到数据 | **QoS 不匹配**（发布者 reliable / 订阅者 best_effort 不兼容的反向） | `ros2 topic info /xxx --verbose` 查 QoS |
| 5 | 两个终端话题互相看不见 | `ROS_DOMAIN_ID` 不同 | 统一 export，或写进 `~/.bashrc` |
| 6 | 自定义 msg 编译失败 | `package.xml` 缺依赖 / CMake 没写 `rosidl_generate_interfaces` | 对照官方 `custom_msg` 教程逐行核对 |
| 7 | Gazebo 里模型乱飞/穿模 | `inertial` 参数缺失或不合理、碰撞体与视觉体重合 | 补齐质量与惯量，检查 collision |
| 8 | RViz 里 robot model 不显示 | Fixed Frame 选错 / 没发 TF / mesh 路径错 | 改 Fixed Frame 为 `base_link`，`view_frames` 查树 |
| 9 | 路径含中文导致编译异常 | 部分工具链不支持 | 工作空间放纯英文路径（**你现在 `/home/csq/ros` 没问题**） |
| 10 | 到处 `sudo ros2 ...` | 权限污染环境 | ROS 2 命令**永远不要用 sudo** |

---

## 三、每周执行模板（照着填）

```
第 __ 周  日期：____/____ ~ ____/____
目标：
学习内容：
动手产出（代码/截图/图）：
卡住的问题 & 解决方式：
自评掌握度（1-5）：
下周计划：
```

对应打卡表见 `进度打卡表.md`。

---

## 四、检验自己是否真的会了（阶段性自测）

**第 5 周末（核心机制）**
1. Topic、Service、Action 各适合什么场景？各举一个机器人的例子。
2. 为什么 ROS 2 需要 DDS？节点之间是怎么找到对方的？
3. 自定义一个消息需要改哪两个文件？

**第 7 周末（建模）**
4. 画出 `map → odom → base_link → laser` 的树，说明每段变换由谁发布。
5. 差速小车的 `base_footprint` 和 `base_link` 有什么区别？

**第 11 周末（仿真）**
6. 从键盘按下方向键到轮子转动，中间经过哪些话题和节点？
7. `ros2_control` 在其中的角色是什么？

**第 18 周末（方向）**
8. （导航）Nav2 中全局规划和局部控制的区别？代价地图为什么要膨胀？
9. （机械臂）关节空间规划和笛卡尔空间规划分别什么时候用？

> 答不上来就回去补，不要往前赶。**能讲清楚 > 跑得起来 > 看过教程。**

---

## 五、一句话总结优先级

```
Linux/Python 熟练  >  通信机制（Topic/Service/Action/QoS）  >  TF/URDF  >  仿真  >  方向专精  >  项目
     ↑ 地基                ↑ 决定你能不能独立开发                ↑ 决定方向的成败
```
