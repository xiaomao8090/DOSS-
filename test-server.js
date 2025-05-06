/**
 * DDoS测试用本地服务器
 * 用于安全测试DDoS模拟器而不影响实际网站
 */

const express = require('express');
const app = express();
const port = 3000;

// 解析JSON请求体
app.use(express.json());

// 添加延迟中间件，模拟服务器负载
const addDelay = (req, res, next) => {
  // 随机延迟0-100ms
  const delay = Math.floor(Math.random() * 100);
  setTimeout(next, delay);
};

app.use(addDelay);

// 请求计数器
let requestCount = 0;

// 每秒请求计数器和响应时间统计
let requestsPerSecond = 0;
let totalResponseTime = 0;
let responseCount = 0;

// 重置每秒计数器
setInterval(() => {
  console.log(`每秒请求数: ${requestsPerSecond} | 平均响应时间: ${responseCount > 0 ? (totalResponseTime / responseCount).toFixed(2) : 0}ms`);
  requestsPerSecond = 0;
  totalResponseTime = 0;
  responseCount = 0;
}, 1000);

// 记录请求的中间件
app.use((req, res, next) => {
  const startTime = Date.now();
  requestCount++;
  requestsPerSecond++;
  
  // 当请求完成时计算响应时间
  res.on('finish', () => {
    const responseTime = Date.now() - startTime;
    totalResponseTime += responseTime;
    responseCount++;
  });
  
  next();
});

// 基本路由
app.get('/', (req, res) => {
  res.send(`测试服务器正在运行 - 已处理 ${requestCount} 个请求`);
});

// POST路由示例
app.post('/', (req, res) => {
  res.json({ 
    received: true, 
    body: req.body,
    requestCount 
  });
});

// 资源密集型路由 - 用于测试服务器在高负载下的表现
app.get('/heavy', (req, res) => {
  // 模拟CPU密集型操作
  let result = 0;
  for (let i = 0; i < 1000000; i++) {
    result += Math.sqrt(i);
  }
  res.json({ result: result.toFixed(2), requestCount });
});

// 模拟内存占用路由
app.get('/memory', (req, res) => {
  const size = parseInt(req.query.size) || 1024 * 1024; // 默认1MB
  const buffer = Buffer.alloc(size);
  res.json({ 
    allocated: `${(size / 1024 / 1024).toFixed(2)}MB`, 
    requestCount 
  });
});

// 启动服务器
app.listen(port, () => {
  console.log(`测试服务器运行在 http://localhost:${port}`);
  console.log('可用路由:');
  console.log('  - GET  / : 基本响应');
  console.log('  - POST / : JSON响应');
  console.log('  - GET  /heavy : CPU密集型操作');
  console.log('  - GET  /memory?size=1048576 : 内存分配操作(大小以字节为单位)');
  console.log('\n按 Ctrl+C 停止服务器');
}); 