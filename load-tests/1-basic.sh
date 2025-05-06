#!/bin/bash
# 基本负载测试
# 使用稳定的并发连接进行基本测试
# 目标: http://localhost:5000/
# 生成时间: 2025-05-06T14:09:19.967Z

echo "运行测试 1/3"
echo "node ddos-simulator.js -u http://localhost:5000/ -c 10 -r 100 -d 10"
node ddos-simulator.js -u http://localhost:5000/ -c 10 -r 100 -d 10
echo "等待30秒后继续..."
sleep 30

echo "运行测试 2/3"
echo "node ddos-simulator.js -u http://localhost:5000/ -c 20 -r 100 -d 10 -m POST --body '{"test":true}' --headers '{"Content-Type":"application/json"}'"
node ddos-simulator.js -u http://localhost:5000/ -c 20 -r 100 -d 10 -m POST --body '{"test":true}' --headers '{"Content-Type":"application/json"}'
echo "等待30秒后继续..."
sleep 30

echo "运行测试 3/3"
echo "node ddos-simulator.js -u http://localhost:5000//heavy -c 5 -r 20 -d 100"
node ddos-simulator.js -u http://localhost:5000//heavy -c 5 -r 20 -d 100
