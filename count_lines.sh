#!/bin/bash

# ========================================================================
# 代码行数统计脚本
# ========================================================================
# 功能：统计指定目录下所有 .sh 和 .py 文件的代码行数（不包括空行）
# 用法：./count_lines.sh [目录路径] [-e 排除目录 1,排除目录 2,...] [-t 文件类型]
# 示例：./count_lines.sh /path/to/dir
#       ./count_lines.sh . -e /path/to/dir/node_modules,/path/to/dir/.git
#       ./count_lines.sh /path/to/dir -t sh,py,js      # 统计多种类型
#       ./count_lines.sh /path/to/dir -t java,cpp,h    # C/C++项目
#       ./count_lines.sh /path/to/dir --types js,ts,jsx,tsx  # 前端项目
# ========================================================================

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 是否显示进度条
SHOW_PROGRESS=false

# 单行进度条函数
show_progress() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))

    printf "\r${GREEN}[${NC}"
    printf "${GREEN}%${filled}s${NC}" "" | tr ' ' '='
    printf "${GREEN}%${empty}s${NC}" "" | tr ' ' '-'
    printf "${GREEN}]${NC} %3d%% (%d/%d)" "$percentage" "$current" "$total"
}

# 默认参数
TARGET_DIR=""
EXCLUDE_DIRS=""
FILE_TYPES="sh,py"  # 默认统计 .sh 和 .py 文件

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--exclude)
            EXCLUDE_DIRS="$2"
            shift 2
            ;;
        -t|--types)
            FILE_TYPES="$2"
            shift 2
            ;;
        -p|--progress)
            SHOW_PROGRESS=true
            shift
            ;;
        -h|--help)
            echo "用法：$0 [目录路径] [-e 排除目录列表] [-t 文件类型列表]"
            echo ""
            echo "选项:"
            echo "  -e, --exclude DIRS   排除指定的目录（逗号分隔，使用绝对路径）"
            echo "  -t, --types TYPES    统计的文件类型（逗号分隔，不含点）"
            echo "  -p, --progress      显示进度条"
            echo "  -v, --version        显示版本信息"
            echo "  -h, --help           显示帮助信息"
            echo ""
            echo "注意：排除的目录必须是目标目录的子目录"
            echo ""
            echo "示例:"
            echo "  $0 ."
            echo "  $0 /path/to/dir -e /path/to/dir/node_modules,/path/to/dir/.git"
            echo "  $0 . -t sh,py,js                      # 统计 shell/python/javascript"
            echo "  $0 /project -t java,kotlin,gradle     # Java/Kotlin 项目"
            echo "  $0 /project -t c,cpp,h,hpp            # C/C++ 项目"
            exit 0
            ;;
        -v|--version)
            echo "代码行数统计工具 v1.0.0"
            echo "功能：统计指定目录下代码文件的行数（不包括空行）"
            exit 0
            ;;
        *)
            if [ -d "$1" ]; then
                TARGET_DIR="$1"
            else
                echo -e "${RED}[ERROR]${NC} 无效的目录：$1"
                echo ""
                echo "使用 '$0 --help' 查看用法"
                exit 1
            fi
            shift
            ;;
    esac
done

# 如果没有指定目标目录，显示帮助信息
if [ -z "$TARGET_DIR" ]; then
    echo -e "${BLUE}代码行数统计工具${NC}"
    echo ""
    echo "未指定目标目录，请使用以下格式："
    echo ""
    echo "  $0 <目录路径> [选项]"
    echo ""
    echo "常用示例:"
    echo "  $0 .                           # 统计当前目录"
    echo "  $0 /path/to/dir                # 统计指定目录"
    echo "  $0 . -t py                     # 只统计 Python 文件"
    echo "  $0 . -e ./venv                 # 排除 venv 目录"
    echo "  $0 . -p                       # 显示进度条"
    echo ""
    echo "使用 '$0 --help' 查看完整帮助"
    exit 0
fi

# 检查目录是否存在
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}[ERROR]${NC} 目录不存在：$TARGET_DIR"
    exit 1
fi

# 获取目标目录的绝对路径
TARGET_DIR_ABS=$(cd "$TARGET_DIR" && pwd)

# 获取脚本自身的绝对路径（用于自排除）
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

# 构建文件类型匹配模式
IFS=',' read -ra TYPE_ARRAY <<< "$FILE_TYPES"
FILE_PATTERN=""
for type in "${TYPE_ARRAY[@]}"; do
    type=$(echo "$type" | xargs)  # 去除首尾空格
    if [ -z "$FILE_PATTERN" ]; then
        FILE_PATTERN="-name '*.$type'"
    else
        FILE_PATTERN="$FILE_PATTERN -o -name '*.$type'"
    fi
done

# 构建 find 命令的排除参数
FIND_EXCLUDE_ARGS=""
if [ -n "$EXCLUDE_DIRS" ]; then
    IFS=',' read -ra EXCLUDE_ARRAY <<< "$EXCLUDE_DIRS"
    
    for dir in "${EXCLUDE_ARRAY[@]}"; do
        dir=$(echo "$dir" | xargs)  # 去除首尾空格
        
        # 移除末尾的斜杠（如果有）
        dir="${dir%/}"
        
        # 转换为绝对路径
        if [[ "$dir" = /* ]]; then
            # 已经是绝对路径
            exclude_abs="$dir"
        elif [[ "$dir" = ~* ]]; then
            # 以~开头的路径，需要展开
            exclude_abs="${dir/#\~/$HOME}"
        else
            # 相对路径转换为绝对路径
            exclude_abs="$(cd "$(dirname "$dir")" 2>/dev/null && pwd)/$(basename "$dir")"
        fi
        
        # 再次移除末尾斜杠（确保一致性）
        exclude_abs="${exclude_abs%/}"
        
        # 检查排除的目录是否存在
        if [ ! -d "$exclude_abs" ]; then
            echo -e "${RED}[ERROR]${NC} 排除的目录不存在：$exclude_abs"
            echo -e "${YELLOW}[提示]${NC} 排除的目录必须是目标目录 ($TARGET_DIR_ABS) 的子目录"
            echo ""
            echo -e "${YELLOW}原始输入:${NC} $dir"
            echo -e "${YELLOW}转换后:${NC} $exclude_abs"
            exit 1
        fi
        
        # 验证排除目录是否为目标目录的子目录
        case "$exclude_abs" in
            "$TARGET_DIR_ABS"|"$TARGET_DIR_ABS"/*)
                # 是目标目录本身或其子目录，合法
                ;;
            *)
                # 不是目标目录的子目录，报错退出
                echo -e "${RED}[ERROR]${NC} 排除的目录不在目标目录内"
                echo -e "${YELLOW}目标目录:${NC} $TARGET_DIR_ABS"
                echo -e "${YELLOW}排除目录:${NC} $exclude_abs"
                echo -e "${YELLOW}[提示]${NC} 排除的目录必须是目标目录的子目录"
                exit 1
                ;;
        esac
        
        # 构建排除参数（正确的 find -prune 逻辑）
        if [ -z "$FIND_EXCLUDE_ARGS" ]; then
            FIND_EXCLUDE_ARGS="\( -path '$exclude_abs' -prune \)"
        else
            FIND_EXCLUDE_ARGS="$FIND_EXCLUDE_ARGS -o \( -path '$exclude_abs' -prune \)"
        fi
    done
    
    # 最后添加文件类型匹配和输出（关键！）
    FIND_EXCLUDE_ARGS="$FIND_EXCLUDE_ARGS -o ! -path '$SCRIPT_PATH' -type f \\( $FILE_PATTERN \\) -print0"
fi

# 显示文件类型信息
echo "========================================"
echo -e "${BLUE}代码行数统计工具${NC}"
echo "========================================"
echo -e "目标目录：${YELLOW}$TARGET_DIR_ABS${NC}"
if [ -n "$EXCLUDE_DIRS" ]; then
    echo -e "排除目录：${RED}$EXCLUDE_DIRS${NC}"
fi
echo -e "文件类型：${GREEN}$FILE_TYPES${NC}"
echo "统计规则：不包括空行"
echo "========================================"
echo ""

# 临时文件存储所有文件信息
temp_file=$(mktemp)

# 构建并执行 find 命令
if [ -n "$FIND_EXCLUDE_ARGS" ]; then
    # 使用 eval 来处理动态构建的排除参数
    FIND_CMD="find \"$TARGET_DIR_ABS\" $FIND_EXCLUDE_ARGS -o ! -path '$SCRIPT_PATH' -type f \\( $FILE_PATTERN \\) -print0 2>/dev/null"
    
    # 先统计总文件数
    total_files=$(eval "$FIND_CMD" | grep -c ".")
    
    # 如果指定了 -p 选项，显示进度条
    if [ "$SHOW_PROGRESS" = true ]; then
        echo -e "${BLUE}正在统计 $total_files 个文件...${NC}"
        processed=0
    fi
    
    eval "$FIND_CMD" | sort -z | \
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            lines=$(grep -v '^[[:space:]]*$' "$file" | wc -l)
            if [ $lines -gt 0 ]; then
                echo "$lines|$file" >> "$temp_file"
            fi
        fi
        # 更新进度条
        if [ "$SHOW_PROGRESS" = true ]; then
            processed=$((processed + 1))
            show_progress $processed $total_files
        fi
    done
    
    # 换行并清除进度条
    if [ "$SHOW_PROGRESS" = true ]; then
        echo ""
    fi
else
    # 没有排除目录时的简单查找（但仍需排除脚本自身）
    FIND_CMD="find \"$TARGET_DIR_ABS\" ! -path '$SCRIPT_PATH' -type f \\( $FILE_PATTERN \\) -print0 2>/dev/null"
    
    # 先统计总文件数
    total_files=$(eval "$FIND_CMD" | grep -c ".")
    
    # 如果指定了 -p 选项，显示进度条
    if [ "$SHOW_PROGRESS" = true ]; then
        echo -e "${BLUE}正在统计 $total_files 个文件...${NC}"
        processed=0
    fi
    
    eval "$FIND_CMD" | sort -z | \
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            lines=$(grep -v '^[[:space:]]*$' "$file" | wc -l)
            if [ $lines -gt 0 ]; then
                echo "$lines|$file" >> "$temp_file"
            fi
        fi
        # 更新进度条
        if [ "$SHOW_PROGRESS" = true ]; then
            processed=$((processed + 1))
            show_progress $processed $total_files
        fi
    done
    
    # 换行并清除进度条
    if [ "$SHOW_PROGRESS" = true ]; then
        echo ""
    fi
fi

# 检查是否找到文件
if [ ! -s "$temp_file" ]; then
    echo -e "${RED}未找到任何 .sh 或 .py 文件${NC}"
    rm -f "$temp_file"
    exit 0
fi

# 输出表头
echo "================================================================================"
printf "%-8s %-60s\n" "行数" "文件路径"
echo "================================================================================"

# 按文件名排序并输出每个文件的行数
sort -t'|' -k2 "$temp_file" | while IFS='|' read -r lines filepath; do
    printf "%-8d %-60s\n" "$lines" "$filepath"
done

echo "================================================================================"
echo ""

# 计算总行数
total_lines=0
file_count=0

while IFS='|' read -r lines filepath; do
    total_lines=$((total_lines + lines))
    file_count=$((file_count + 1))
done < "$temp_file"

# 输出汇总
echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}汇总统计${NC}"
echo -e "${GREEN}========================================${NC}"
echo "文件总数：$file_count"
echo -e "${BLUE}总行数：${GREEN}$total_lines${NC}"
echo "========================================"
echo "代码统计工具 v1.0.0"

# 清理临时文件
rm -f "$temp_file"

exit 0
