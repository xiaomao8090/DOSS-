/**
 * 代理池模块 - 管理和轮换HTTP/HTTPS代理
 */

class ProxyPool {
  constructor(proxies = []) {
    this.proxies = proxies;
    this.currentIndex = 0;
    this.stats = {
      total: proxies.length,
      used: 0,
      failed: 0
    };
  }

  /**
   * 添加代理到代理池
   * @param {string} proxy - 代理服务器地址，格式: "ip:port" 或 "username:password@ip:port"
   */
  addProxy(proxy) {
    if (typeof proxy === 'string' && proxy.trim() !== '') {
      this.proxies.push(proxy);
      this.stats.total = this.proxies.length;
    }
  }

  /**
   * 批量添加代理到代理池
   * @param {Array<string>} proxyList - 代理服务器地址列表
   */
  addProxies(proxyList) {
    if (Array.isArray(proxyList)) {
      proxyList.forEach(proxy => this.addProxy(proxy));
    }
  }

  /**
   * 从文件加载代理列表
   * @param {string} filePath - 代理列表文件路径
   */
  loadFromFile(filePath) {
    const fs = require('fs');
    try {
      const data = fs.readFileSync(filePath, 'utf8');
      const proxies = data
        .split('\n')
        .map(line => line.trim())
        .filter(line => line && !line.startsWith('#'));
      
      this.addProxies(proxies);
      return true;
    } catch (error) {
      console.error(`无法从文件加载代理: ${error.message}`);
      return false;
    }
  }

  /**
   * 获取下一个代理
   * @returns {string|null} 代理地址或null（如果没有可用代理）
   */
  getNext() {
    if (this.proxies.length === 0) {
      return null;
    }

    const proxy = this.proxies[this.currentIndex];
    this.currentIndex = (this.currentIndex + 1) % this.proxies.length;
    this.stats.used++;
    
    return proxy;
  }

  /**
   * 标记代理为失败状态
   * @param {string} proxy - 失败的代理地址
   */
  markAsFailed(proxy) {
    const index = this.proxies.indexOf(proxy);
    if (index !== -1) {
      this.stats.failed++;
      // 可选：从代理池中移除失败的代理
      // this.proxies.splice(index, 1);
      // this.stats.total = this.proxies.length;
    }
  }

  /**
   * 获取代理池统计信息
   * @returns {Object} 代理池统计信息
   */
  getStats() {
    return {
      ...this.stats,
      available: this.proxies.length
    };
  }

  /**
   * 将代理转换为http模块使用的代理配置
   * @param {string} proxyStr - 代理字符串 (ip:port 或 username:password@ip:port)
   * @returns {Object} 代理配置对象
   */
  static parseProxy(proxyStr) {
    if (!proxyStr) return null;

    let auth = null;
    let hostPort = proxyStr;

    // 检查是否有认证信息
    if (proxyStr.includes('@')) {
      const parts = proxyStr.split('@');
      auth = parts[0];
      hostPort = parts[1];
    }

    // 分割主机和端口
    const [host, port] = hostPort.split(':');
    
    return {
      host,
      port: parseInt(port, 10),
      auth: auth
    };
  }

  /**
   * 为HTTP请求创建代理选项
   * @param {string} proxyStr - 代理字符串
   * @returns {Object} 代理请求配置
   */
  static getProxyOptions(proxyStr) {
    const proxy = ProxyPool.parseProxy(proxyStr);
    if (!proxy) return {};

    const options = {
      host: proxy.host,
      port: proxy.port,
      method: 'CONNECT',
      path: 'www.example.com:443'  // 将在实际请求中被覆盖
    };

    if (proxy.auth) {
      options.headers = {
        'Proxy-Authorization': 'Basic ' + Buffer.from(proxy.auth).toString('base64')
      };
    }

    return options;
  }
}

module.exports = ProxyPool; 