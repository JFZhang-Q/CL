# CL - Code Line Counter

<div align="center">

**一个灵活、高效的代码行数统计工具**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)](README.md)

</div>

---

## 📖 简介

CL (Code Line Counter) 是一个功能强大的 Shell 脚本工具，用于统计项目中的代码行数。支持灵活的文件类型指定、目录排除、自排除等功能，帮助开发者快速了解项目规模。

### ✨ 主要特性

- 🎯 **灵活的文件类型支持** - 支持任意文件类型组合统计
- 🚫 **智能目录排除** - 支持排除 node_modules、venv 等依赖目录
- 🔄 **自动自排除** - 脚本不会统计自身
- 📊 **详细统计报告** - 分文件显示 + 汇总统计
- 🎨 **彩色输出** - 清晰易读的终端显示
- ⚡ **高性能** - 基于 find 命令，支持大型项目
- 🔍 **精确统计** - 自动排除空行，只统计有效代码

---

## 🚀 快速开始

### 安装

1. **下载脚本**
```bash
git clone https://github.com/yourusername/CL.git
cd CL
chmod +x count_lines.sh
```

2. **或者直接使用**
```bash
curl -O https://raw.githubusercontent.com/yourusername/CL/main/count_lines.sh
chmod +x count_lines.sh
```

### 基础用法

```bash
# 统计当前目录（默认 .sh 和 .py 文件）
./count_lines.sh .

# 统计指定目录
./count_lines.sh /path/to/project

# 查看帮助信息
./count_lines.sh --help
```

---

## 📋 功能详解

### 1. 自定义文件类型

使用 `-t` 或 `--types` 参数指定要统计的文件类型：

```bash
# 只统计 Python 文件
./count_lines.sh . -t py

# 统计多种文件类型
./count_lines.sh . -t sh,py,js

# Java/Kotlin 项目
./count_lines.sh /android/project -t java,kotlin,gradle,xml

# C/C++ 项目
./count_lines.sh /cpp/project -t c,cpp,h,hpp

# 前端项目
./count_lines.sh /web/project -t js,ts,jsx,tsx,vue,html,css
```

### 2. 排除目录

使用 `-e` 或 `--exclude` 参数排除不需要的目录：

```bash
# 排除虚拟环境
./count_lines.sh . -e ./venv

# 排除多个目录
./count_lines.sh . \
  -e ./node_modules,./dist,./.git

# 使用绝对路径
./count_lines.sh ~/project \
  -e ~/project/venv,~/project/build

# 支持波浪符展开
./count_lines.sh . -e ~/opencode/Prism/RAG_LLM/venv
```

### 3. 组合使用

```bash
# 统计 Python 项目，排除测试和虚拟环境
./count_lines.sh /myproject \
  -e /myproject/tests,/myproject/venv \
  -t py,sh,sql

# 统计 Web 项目，排除依赖和构建目录
./count_lines.sh /webapp \
  -e /webapp/node_modules,/webapp/dist \
  -t js,ts,tsx,vue,py
```

---

## 📊 输出示例

### 标准输出

```bash
$ ./count_lines.sh . -t sh,py

========================================
代码行数统计工具
========================================
目标目录：/home/user/project
文件类型：sh,py
统计规则：不包括空行
========================================

================================================================================
行数     文件路径
================================================================================
245      /home/user/project/src/main.py
189      /home/user/project/utils/helper.py
156      /home/user/project/scripts/deploy.sh
89       /home/user/project/test.sh
================================================================================

========================================
汇总统计
========================================
文件总数：4
总行数：679
========================================
```

### 带排除目录

```bash
$ ./count_lines.sh . -e ./venv,./build

========================================
代码行数统计工具
========================================
目标目录：/home/user/project
排除目录：./venv,./build
文件类型：sh,py
统计规则：不包括空行
========================================

================================================================================
行数     文件路径
================================================================================
245      /home/user/project/src/main.py
189      /home/user/project/utils/helper.py
[DEBUG] 将排除：/home/user/project/venv
[DEBUG] 将排除：/home/user/project/build
...
```

---

## 🔧 高级用法

### DEBUG 模式

启用 DEBUG 模式查看详细执行的命令：

```bash
DEBUG=1 ./count_lines.sh . -e ./venv
```

输出：
```
[DEBUG] FIND 命令：find /home/user/project \( -path '/home/user/project/venv' -prune \) -o ! -path '/home/user/project/count_lines.sh' -type f \( -name '*.sh' -o -name '*.py' \) -print0
[DEBUG] 找到 15 个文件
```

### 常用文件类型组合

| 项目类型 | 命令示例 |
|---------|---------|
| **Python 项目** | `-t py,pyx,pxd` |
| **Shell 脚本** | `-t sh,bash,zsh,fish` |
| **Java 项目** | `-t java,kotlin,gradle,xml` |
| **C/C++** | `-t c,cpp,h,hpp,cxx,hxx` |
| **Go 语言** | `-t go` |
| **Rust** | `-t rs` |
| **前端项目** | `-t js,ts,jsx,tsx,vue,svelte` |
| **Web 开发** | `-t html,css,scss,less,js` |
| **配置文件** | `-t json,yaml,yml,toml,ini` |
| **文档** | `-t md,rst,txt` |
| **SQL** | `-t sql` |

### 创建别名

在 `~/.bashrc` 或 `~/.zshrc` 中添加：

```bash
# Python 项目统计
alias countpy='./count_lines.sh . -t py'

# 前端项目统计
alias countjs='./count_lines.sh . -t js,ts,jsx,tsx'

# C++ 项目统计
alias countcpp='./count_lines.sh . -t c,cpp,h,hpp'

# Web 全栈统计
alias countweb='./count_lines.sh . -t html,css,js,ts,vue'
```

加载配置：
```bash
source ~/.bashrc
```

使用：
```bash
countpy
countjs
```

---

## 💡 实际应用场景

### 1. CI/CD集成

在 `.github/workflows/code_stats.yml` 中：

```yaml
name: Code Statistics

on: [push, pull_request]

jobs:
  stats:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Count Lines of Code
        run: |
          curl -O https://raw.githubusercontent.com/yourusername/CL/main/count_lines.sh
          chmod +x count_lines.sh
          ./count_lines.sh . -t py,sh -e .venv,tests
```

### 2. 项目报告生成

```bash
#!/bin/bash
# generate_report.sh

PROJECT_NAME="MyProject"
DATE=$(date +%Y-%m-%d)

echo "# $PROJECT_NAME 代码统计报告" > report.md
echo "统计日期：$DATE" >> report.md
echo "" >> report.md

./count_lines.sh . -t py,sh,sql -e tests,venv >> report.md

echo "报告已生成：report.md"
```

### 3. 多项目对比

```bash
#!/bin/bash
# compare_projects.sh

echo "项目 A 统计:"
./count_lines.sh /path/to/projectA -t py

echo ""
echo "项目 B 统计:"
./count_lines.sh /path/to/projectB -t py
```

---

## ⚙️ 技术细节

### 路径处理

- ✅ 支持绝对路径
- ✅ 支持相对路径
- ✅ 支持波浪符 `~` 展开
- ✅ 自动移除末尾斜杠
- ✅ 强制要求排除目录是目标目录的子目录

### 自排除机制

脚本会自动检测自身位置并从统计中排除：

```bash
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
# find 命令中使用 ! -path '$SCRIPT_PATH' 排除
```

### Find 命令结构

```bash
find "$TARGET_DIR_ABS" \
  \( -path '/exclude/dir1' -prune \) \
  -o \( -path '/exclude/dir2' -prune \) \
  -o ! -path '$SCRIPT_PATH' -type f \( -name '*.ext' \) -print0
```

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

## 🙏 致谢

感谢所有为本项目做出贡献的开发者！

---

<div align="center">

**如果这个工具对您有帮助，请给个 ⭐️ Star 支持一下！**

Made with ❤️ by [Your Name]

</div>
