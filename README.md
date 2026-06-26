# 废话人设鉴定所

> 粘进一段文字，让 AI 告诉你这篇到底有多少干货。

一个基于本地大模型的文本含水量鉴定工具。输入网址或粘贴文字，AI 会从含水量、干货值、黑话密度等维度分析内容，生成人设标签、TLDR 摘要、精华碎片和可分享的鉴定海报。

## 功能一览

- **网址抓取 / 文本粘贴** — 支持直接输入文章 URL（本地代理抓取）或手动粘贴文本
- **多维度量化鉴定** — 含水量、干货值、黑话密度、土壤肥力等指标
- **人设标签** — 给文字打上「互联网翻译官」「废话文学大使」等人设
- **TLDR 摘要** — 一句话总结文章核心内容
- **黑话翻译** — 把「赋能」「抓手」「闭环」翻译成人话
- **鉴定海报** — 一键生成可保存的 PNG 鉴定结果海报

## 技术栈

| 组件 | 说明 |
|------|------|
| 前端 | Vue 3 (CDN) + Tailwind CSS，单 HTML 文件，零构建 |
| AI 模型 | Ollama 本地运行 `qwen3.5:4b` |
| URL 代理 | Python 轻量 CORS 代理，带反爬检测 |

## 环境要求

1. **Ollama** — 本地大模型运行环境
2. **Python 3.8+** — 运行 URL 代理服务
3. **现代浏览器** — Chrome / Edge / Firefox

## 快速开始

### 1. 安装 Ollama 并下载模型

前往 [Ollama 官网](https://ollama.com) 下载安装，然后拉取模型：

```bash
ollama pull qwen3.5:4b
```

> 模型大小约 2.5GB，首次下载需要一些时间。也可以在 [Ollama 模型库](https://ollama.com/library/qwen3.5) 查看 `qwen3.5` 系列的所有可用版本。

### 2. 获取项目代码

```bash
git clone https://github.com/lepiai/fluff-persona-lab.git
cd fluff-persona-lab
```

### 3. 一键启动（Windows）

双击 `启动.bat` 即可。脚本会自动：

1. 启动 Ollama 服务（端口 11434）
2. 启动 URL 代理服务（端口 8081）
3. 启动 HTTP 静态服务器（端口 8765）
4. 打开浏览器访问 `http://localhost:8765/index.html`

### 手动启动（macOS / Linux）

```bash
# 终端 1：启动 Ollama
ollama serve

# 终端 2：启动 URL 代理
python proxy.py

# 终端 3：启动 HTTP 服务器
python -m http.server 8765
```

然后在浏览器打开 `http://localhost:8765/index.html`。

## 项目结构

```
fluff-persona-lab/
├── index.html       # 主应用（Vue 3 单文件）
├── proxy.py         # URL 抓取代理（反爬检测）
├── 启动.bat          # Windows 一键启动入口
├── 启动.ps1          # 启动脚本实际逻辑
└── .gitignore
```

## 使用说明

1. 打开页面后，在输入框中粘贴文章文本，或输入文章 URL
2. 点击「开始鉴定」按钮
3. 等待 AI 分析（约 10-15 秒，取决于文本长度和硬件性能）
4. 查看鉴定结果：人设标签、维度评分、TLDR、精华碎片、黑话翻译
5. 点击「保存海报」可下载鉴定结果图片

## 关于模型

本项目使用 `qwen3.5:4b` 模型，经实测在 JSON 输出稳定性（100% 成功率）和响应速度（平均 15 秒）之间取得了最佳平衡。如需更换模型，修改 `index.html` 中的 `LLM_CONFIG.MODEL` 字段即可。

可选模型对比：

| 模型 | 大小 | JSON 成功率 | 平均响应 | 含水量准确度 |
|------|------|-------------|----------|-------------|
| qwen3.5:2b | ~1.6GB | 88% | ~10s | 偏高（虚报） |
| **qwen3.5:4b** | ~2.5GB | **100%** | **~15s** | **准确** |
| qwen3.5:9b | ~5.5GB | 75%* | ~30s+ | 准确 |

> *9b 模型在长文本下容易出现超时。

## License

MIT
