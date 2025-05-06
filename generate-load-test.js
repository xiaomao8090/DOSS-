#!/usr/bin/env node

/**
 * 负载测试生成器
 * 用于生成不同类型的负载测试命令
 */

const { program } = require('commander');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// 配置命令行选项
program
  .version('1.0.0')
  .description('DDoS模拟器负载测试生成器')
  .option('-t, --target <url>', '目标URL', 'http://localhost:3000')
  .option('-n, --name <name>', '测试名称', 'test')
  .option('-s, --scenario <type>', '测试场景 (basic, increasing, spike, long)', 'basic')
  .option('-o, --output <dir>', '输出目录', './load-tests')
  .parse(process.argv);

const options = program.opts();

// 确保输出目录存在
if (!fs.existsSync(options.output)) {
  fs.mkdirSync(options.output, { recursive: true });
}

// 基本测试场景
const scenarios = {
  // 基本测试 - 稳定的并发请求
  basic: {
    name: '基本负载测试',
    description: '使用稳定的并发连接进行基本测试',
    commands: [
      `node ddos-simulator.js -u ${options.target} -c 10 -r 100 -d 10`,
      `node ddos-simulator.js -u ${options.target} -c 20 -r 100 -d 10 -m POST --body '{"test":true}' --headers '{"Content-Type":"application/json"}'`,
      `node ddos-simulator.js -u ${options.target}/heavy -c 5 -r 20 -d 100`
    ]
  },
  
  // 递增测试 - 逐渐增加负载
  increasing: {
    name: '递增负载测试',
    description: '逐渐增加并发连接数和请求数',
    commands: [
      `node ddos-simulator.js -u ${options.target} -c 5 -r 50 -d 50`,
      `node ddos-simulator.js -u ${options.target} -c 10 -r 50 -d 40`,
      `node ddos-simulator.js -u ${options.target} -c 20 -r 50 -d 30`,
      `node ddos-simulator.js -u ${options.target} -c 30 -r 50 -d 20`,
      `node ddos-simulator.js -u ${options.target} -c 50 -r 50 -d 10`,
      `node ddos-simulator.js -u ${options.target} -c 100 -r 50 -d 5`
    ]
  },
  
  // 突发测试 - 模拟突发流量
  spike: {
    name: '突发负载测试',
    description: '模拟突发流量',
    commands: [
      `node ddos-simulator.js -u ${options.target} -c 5 -r 20 -d 100`,
      `node ddos-simulator.js -u ${options.target} -c 100 -r 20 -d 1`,
      `node ddos-simulator.js -u ${options.target} -c 5 -r 20 -d 100`,
      `node ddos-simulator.js -u ${options.target} -c 150 -r 20 -d 1`,
      `node ddos-simulator.js -u ${options.target} -c 5 -r 20 -d 100`
    ]
  },
  
  // 长时间测试 - 长时间持续低强度请求
  long: {
    name: '长时间负载测试',
    description: '长时间持续的低强度测试',
    commands: [
      `node ddos-simulator.js -u ${options.target} -c 5 -r 1000 -d 100`,
      `node ddos-simulator.js -u ${options.target}/heavy -c 2 -r 200 -d 200`,
      `node ddos-simulator.js -u ${options.target} -c 10 -r 500 -d 50`
    ]
  }
};

// 选择场景
const selectedScenario = scenarios[options.scenario] || scenarios.basic;

console.log(`生成 ${selectedScenario.name} 场景`);
console.log(selectedScenario.description);

// 创建测试脚本
const testFileName = `${options.name}-${options.scenario}.sh`;
const testFilePath = path.join(options.output, testFileName);

// 生成脚本内容
let scriptContent = `#!/bin/bash\n`;
scriptContent += `# ${selectedScenario.name}\n`;
scriptContent += `# ${selectedScenario.description}\n`;
scriptContent += `# 目标: ${options.target}\n`;
scriptContent += `# 生成时间: ${new Date().toISOString()}\n\n`;

// 添加命令
selectedScenario.commands.forEach((cmd, index) => {
  scriptContent += `echo "运行测试 ${index + 1}/${selectedScenario.commands.length}"\n`;
  scriptContent += `echo "${cmd}"\n`;
  scriptContent += `${cmd}\n`;
  if (index < selectedScenario.commands.length - 1) {
    scriptContent += `echo "等待30秒后继续..."\n`;
    scriptContent += `sleep 30\n\n`;
  }
});

// 写入文件
fs.writeFileSync(testFilePath, scriptContent);
fs.chmodSync(testFilePath, 0o755); // 添加执行权限

console.log(`\n测试脚本已生成: ${testFilePath}`);
console.log(`使用以下命令运行测试:`);
console.log(`  ${testFilePath}`);

// 生成测试报告目录
const reportDir = path.join(options.output, `${options.name}-report`);
if (!fs.existsSync(reportDir)) {
  fs.mkdirSync(reportDir, { recursive: true });
}

console.log(`\n测试报告将保存在: ${reportDir}`);
console.log(`完成后，查看报告目录中的结果`);

// 创建简单的 HTML 报告模板
const htmlTemplate = `
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${options.name} - 负载测试报告</title>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 20px; color: #333; }
    h1, h2, h3 { color: #2c3e50; }
    .container { max-width: 1000px; margin: 0 auto; }
    .summary { background-color: #f8f9fa; border-left: 4px solid #4285f4; padding: 15px; margin-bottom: 20px; }
    .chart { margin: 30px 0; height: 400px; }
    table { width: 100%; border-collapse: collapse; margin: 20px 0; }
    th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #ddd; }
    th { background-color: #4285f4; color: white; }
    tr:hover { background-color: #f5f5f5; }
    .footer { margin-top: 40px; font-size: 0.8em; color: #777; border-top: 1px solid #eee; padding-top: 20px; }
  </style>
</head>
<body>
  <div class="container">
    <h1>${options.name} - 负载测试报告</h1>
    
    <div class="summary">
      <h2>测试概述</h2>
      <p><strong>场景:</strong> ${selectedScenario.name}</p>
      <p><strong>描述:</strong> ${selectedScenario.description}</p>
      <p><strong>目标 URL:</strong> ${options.target}</p>
      <p><strong>测试时间:</strong> <span id="testDate">-</span></p>
    </div>
    
    <div class="chart">
      <h2>结果图表</h2>
      <p>此处将显示测试结果的图表</p>
      <!-- 这里可以添加图表库如Chart.js来可视化测试结果 -->
    </div>
    
    <h2>测试详情</h2>
    <table>
      <thead>
        <tr>
          <th>测试编号</th>
          <th>请求总数</th>
          <th>成功请求</th>
          <th>失败请求</th>
          <th>平均响应时间</th>
          <th>请求/秒</th>
        </tr>
      </thead>
      <tbody id="resultsTable">
        <!-- 这里将填充测试结果 -->
        <tr>
          <td colspan="6">测试尚未运行或数据未收集</td>
        </tr>
      </tbody>
    </table>
    
    <h2>命令详情</h2>
    <ul>
      ${selectedScenario.commands.map((cmd, i) => `<li><code>${cmd}</code></li>`).join('\n      ')}
    </ul>
    
    <div class="footer">
      <p>报告生成于 <span id="generationDate">-</span> | DDoS模拟测试工具</p>
    </div>
  </div>
  
  <script>
    document.getElementById('generationDate').textContent = new Date().toLocaleString();
    document.getElementById('testDate').textContent = new Date().toLocaleString();
  </script>
</body>
</html>
`;

// 写入 HTML 报告模板
fs.writeFileSync(path.join(reportDir, 'report.html'), htmlTemplate);
console.log(`HTML报告模板已创建: ${path.join(reportDir, 'report.html')}`); 