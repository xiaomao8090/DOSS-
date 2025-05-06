/**
 * 命令行进度条工具
 * 用于在DDoS模拟测试期间显示直观的进度
 */

class ProgressBar {
  constructor(options = {}) {
    this.total = options.total || 100;
    this.current = 0;
    this.width = options.width || 40;
    this.complete = options.complete || '█';
    this.incomplete = options.incomplete || '░';
    this.prefix = options.prefix || '进度';
    this.suffix = options.suffix || '';
    this.showPercent = options.showPercent !== false;
    this.showCount = options.showCount !== false;
    this.stats = options.stats || {};
    this.lastRender = '';
  }

  /**
   * 更新进度条
   * @param {number} current - 当前进度值
   * @param {Object} stats - 统计信息对象
   */
  update(current, stats = {}) {
    this.current = current;
    this.stats = stats;
    this.render();
  }

  /**
   * 渲染进度条
   */
  render() {
    // 计算完成百分比
    const percent = Math.min(Math.floor((this.current / this.total) * 100), 100);
    
    // 计算已完成和未完成的字符数
    const completeLength = Math.floor((percent / 100) * this.width);
    const incompleteLength = this.width - completeLength;
    
    // 构建进度条
    const completeStr = this.complete.repeat(completeLength);
    const incompleteStr = this.incomplete.repeat(incompleteLength);
    const bar = completeStr + incompleteStr;
    
    // 拼接完整的进度信息
    let progressLine = `${this.prefix} |${bar}|`;
    
    if (this.showPercent) {
      progressLine += ` ${percent}%`;
    }
    
    if (this.showCount) {
      progressLine += ` ${this.current}/${this.total}`;
    }
    
    if (this.suffix) {
      progressLine += ` ${this.suffix}`;
    }
    
    // 添加统计信息
    const statsInfo = Object.entries(this.stats)
      .map(([key, value]) => `${key}: ${value}`)
      .join(' | ');
    
    if (statsInfo) {
      progressLine += ` | ${statsInfo}`;
    }
    
    // 避免闪烁，只有在内容变化时才更新
    if (this.lastRender !== progressLine) {
      process.stdout.clearLine(0);
      process.stdout.cursorTo(0);
      process.stdout.write(progressLine);
      this.lastRender = progressLine;
    }
  }

  /**
   * 完成进度条
   */
  complete() {
    this.update(this.total);
    process.stdout.write('\n');
  }
}

module.exports = ProgressBar; 