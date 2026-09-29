# ROS 2 学习工作区

这里是为你定制的 ROS 2（Humble）学习路径与配套工具。

**环境**：Ubuntu 22.04.5 · ROS 2 Humble（`/opt/ros/humble`）· Python 3.10

---

## 从哪开始

1. **先跑一次自检**，看环境缺什么：
   ```bash
   bash ~/ros/setup/check_env.sh
   ```
2. **读主路径**：`ROS2学习路径.md` —— 24 周完整规划，从阶段 0 开始
3. **按周打卡**：`进度打卡表.md` —— 每完成一项改 `[x]`
4. **查资料**：`学习资源.md` —— 官方文档 / 中文教程 / 方向专精
5. **补装依赖**（按阶段装，不必一次全装）：
   ```bash
   bash ~/ros/setup/install_packages.sh list     # 先看清单
   bash ~/ros/setup/install_packages.sh stage1   # 装阶段 1~4 的包
   bash ~/ros/setup/install_packages.sh nav      # 导航方向
   bash ~/ros/setup/install_packages.sh arm      # 机械臂方向
   ```

---

## 文件说明

| 路径 | 内容 |
|---|---|
| `ROS2学习路径.md` | **主文档**：10 个阶段的学习内容、动手任务、验收标准、避坑清单 |
| `进度打卡表.md` | 可勾选的详细 checklist + 每周复盘表 |
| `学习资源.md` | 官方文档、中文教程、视频、方向专精链接、求职信息 |
| `setup/check_env.sh` | 环境自检（只读，不改系统） |
| `setup/install_packages.sh` | 按阶段安装 ROS 2 依赖包 |
| `templates/rclpy_node_template.py` | 带注释的 rclpy 节点骨架（写代码时复制） |
| `templates/launch_template.py` | launch 文件骨架 |
| `templates/package_setup.md` | 建包命令速查 |
| `1/node_test.py` | 你原有的空文件，可当作阶段 1 的练习起点 |

---

## 路径速览

```
阶段 0  (1–2 周)   Linux + Python 前置
阶段 1  (3 周)     小海龟、CLI 工具、第一个节点
阶段 2  (4–5 周)   Topic / Service / Action / 自定义消息 / 参数 / Launch  ★核心
阶段 3  (6–7 周)   TF2 坐标变换 + URDF/XACRO 建模
阶段 4  (8 周)     工程化、调试、测试、Git
阶段 5  (9–11 周)  Gazebo 仿真 + 传感器 + ros2_control
──────────────── 分叉 ────────────────
阶段 6A (12–13 周) slam_toolbox 建图     │  6B MoveIt 2 入门
阶段 7A (14–18 周) Nav2 自主导航         │  7B MoveIt 2 进阶 + 抓取
──────────────── 汇合 ────────────────
阶段 8  (19–22 周) 综合项目（巡检小车 / 视觉抓取 / 移动操作臂）
阶段 9  (23–24 周) C++、QoS/DDS、真机部署、开源贡献
```

---

## 三条铁律

1. **每个知识点必须有一个能跑起来的程序** —— 只看不写等于没学
2. **能讲清楚 > 跑得起来 > 看过教程** —— 阶段自测题答不上就回去补
3. **卡住超过 1 小时就记录并跳过** —— 建立全局理解后很多问题会自动消失

---

## 快速开始（现在就能做）

```bash
# 1. 检查环境
bash ~/ros/setup/check_env.sh

# 2. 跑通小海龟（开两个终端，或一个 tmux 两个 pane）
source /opt/ros/humble/setup.bash
ros2 run turtlesim turtlesim_node
# 另一个终端：
ros2 run turtlesim turtle_teleop_key
```

然后打开 `ROS2学习路径.md`，从「阶段 0」开始。
