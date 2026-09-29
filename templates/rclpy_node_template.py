#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
rclpy 节点模板（阶段 2 用）
============================
这是一个「带定时器 + 参数 + 发布/订阅」的最小骨架。
用法：复制到你的包里，改类名和话题名，然后：

  cd ~/ros/ws_learn
  colcon build --symlink-install --packages-select <你的包名>
  source install/setup.bash
  ros2 run <你的包名> <节点可执行名> --ros-args -p publish_rate:=2.0

注意：Python 包的入口点在 setup.py 的 entry_points['console_scripts'] 里注册。
"""

import rclpy
from rclpy.node import Node
from rclpy.qos import QoSProfile, ReliabilityPolicy, HistoryPolicy

from std_msgs.msg import String


class MyNode(Node):  # ROS 2 节点都是一个继承自 Node 的类
    def __init__(self):
        super().__init__('my_node')  # ← 节点名（ros2 node list 里看到的）

        # ---------- 参数：永远不要把可配置值硬编码 ----------
        self.declare_parameter('publish_rate', 1.0)   # 每秒发布次数
        self.declare_parameter('topic_name', 'chatter')
        self.declare_parameter('prefix', 'hello')

        self.rate = self.get_parameter('publish_rate').value
        self.topic = self.get_parameter('topic_name').value
        self.prefix = self.get_parameter('prefix').value

        # ---------- QoS：收不到数据时，第一个要检查的地方 ----------
        qos = QoSProfile(
            reliability=ReliabilityPolicy.RELIABLE,   # 传感器数据常用 BEST_EFFORT
            history=HistoryPolicy.KEEP_LAST,
            depth=10,
        )

        # ---------- 发布者 ----------
        self.pub = self.create_publisher(String, self.topic, qos)

        # ---------- 订阅者 ----------
        self.sub = self.create_subscription(
            String, self.topic + '_reply', self.on_reply, qos
        )

        # ---------- 定时器 ----------
        self.count = 0
        self.timer = self.create_timer(1.0 / self.rate, self.on_timer)

        self.get_logger().info(
            f'节点已启动: topic={self.topic}, rate={self.rate}Hz'
        )

    # 定时器回调：周期性执行
    def on_timer(self):
        msg = String()
        msg.data = f'{self.prefix} #{self.count}'
        self.pub.publish(msg)
        self.count += 1
        # 日志级别: debug / info / warn / error / fatal
        self.get_logger().info(f'发布: {msg.data}')

    # 订阅回调：收到消息时执行（不要在这里做耗时操作，会阻塞整个节点）
    def on_reply(self, msg):
        self.get_logger().info(f'收到回复: {msg.data}')


def main(args=None):
    rclpy.init(args=args)          # 初始化 rclpy
    node = MyNode()
    try:
        rclpy.spin(node)           # 阻塞，持续处理回调，直到 Ctrl+C
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()        # 释放资源
        rclpy.shutdown()           # 关闭 rclpy


if __name__ == '__main__':
    main()
