# DDoS 模拟测试工具

**仅用于教育目的和经授权的测试环境**

这是一个用于学习和测试的 DDoS 模拟工具，帮助理解 HTTP 请求、负载测试和网络安全原理。未经授权对任何网站或服务进行 DDoS 攻击是违法的。

## 免责声明

本工具仅供学习和授权测试使用。使用此工具对未经授权的系统进行测试是非法的，可能导致严重的法律后果。作者不对使用者的任何行为负责。

## 安装

```bash
# 克隆仓库
git clone [仓库URL]
cd ddos-simulator

# 安装依赖
npm install

# 使工具全局可用（可选）
npm link
```

## 使用方法

```bash
node ddos-simulator.js -u http://localhost:3000 -c 10 -r 100
```

或者如果已全局安装：

```bash
ddos-simulator -u http://localhost:3000 -c 10 -r 100
```

### 参数说明

| 参数 | 简写 | 说明 | 默认值 |
|------|------|------|--------|
| --url | -u | 目标 URL (必须包含 http:// 或 https://) | 无（必填） |
| --connections | -c | 并发连接数 | 100 |
| --requests | -r | 每个连接的请求数 | 100 |
| --timeout | -t | 请求超时时间(ms) | 5000 |
| --delay | -d | 请求间隔时间(ms) | 10 |
| --method | -m | 请求方法 | GET |
| --workers | -w | 工作进程数 (默认为 CPU 核心数) | CPU 核心数 |
| --headers | 无 | 请求头 (JSON 格式) | {} |
| --body | 无 | 请求体 (POST/PUT 请求) | 无 |

### 示例

1. 对本地服务器进行基础测试:
```bash
node ddos-simulator.js -u http://localhost:3000
```

2. 使用 POST 请求并自定义头信息:
```bash
node ddos-simulator.js -u http://localhost:3000 -m POST --body '{"test":true}' --headers '{"Content-Type":"application/json"}'
```

3. 调整并发和请求数:
```bash
node ddos-simulator.js -u http://localhost:3000 -c 50 -r 1000 -d 5
```

## 注意事项

1. 仅在您拥有或已获得明确授权的系统上使用此工具
2. 在使用前先了解您所在国家/地区关于网络安全测试的法律法规
3. 在测试生产环境前，先在开发环境进行测试，避免意外中断服务
4. 保持较低的并发和请求数开始测试，再逐渐增加负载

## 对测试目标的建议

建议创建一个简单的本地服务器用于测试，例如使用 Express.js：

```javascript
// test-server.js
const express = require('express');
const app = express();
const port = 3000;

app.use(express.json());

app.get('/', (req, res) => {
  res.send('测试服务器正在运行');
});

app.post('/', (req, res) => {
  res.json({ received: true, body: req.body });
});

app.listen(port, () => {
  console.log(`测试服务器运行在 http://localhost:${port}`);
});
```

安装和启动测试服务器：
```bash
npm install express
node test-server.js
```

## 技术说明

此工具使用了以下技术和概念：

- Node.js 的 HTTP/HTTPS 模块处理网络请求
- 集群模式 (Cluster) 实现多进程并发
- 进程间通信 (IPC) 收集统计数据
- Promise 和异步函数实现非阻塞操作
- 命令行参数解析

## 许可证

MIT 