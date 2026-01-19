#!/bin/bash
# =============================================================================
# Claude Code macOS 通知脚本
# =============================================================================
#
# 配置说明：
# 1. IDE_APP: 点击通知后打开的应用
# 2. SOUND: 通知声音
#
# 支持的应用：
#   - terminal  : Terminal.app (macOS 自带终端，跳转到发出通知的窗口/标签)
#   - vscode    : vscode://file/path      (VS Code)
#   - cursor    : cursor://file/path      (Cursor)
#   - windsurf  : windsurf://file/path    (Windsurf)
#   - zed       : zed://file/path         (Zed)
#   - sublime   : subl://open?url=file:///path (Sublime Text, 需安装 URL handler)
#   - idea      : idea://open?file=/path  (IntelliJ IDEA)
#   - webstorm  : webstorm://open?file=/path (WebStorm)
#   - pycharm   : pycharm://open?file=/path (PyCharm)
#
# 如果你的应用不支持，可以设置 IDE_APP="" 禁用点击动作
#
# 可用的系统声音：
#   Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr,
#   Sosumi, Submarine, Tink
# =============================================================================

# ===================== 用户配置区域 =====================
IDE_APP="terminal"  # terminal / vscode / cursor / zed 等
SOUND="Tink"        # 修改为你喜欢的声音
# =======================================================

# 解析输入
INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Claude needs your attention"')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

# 生成标题
TITLE="Claude Code"
[ -n "$CWD" ] && TITLE="Claude:$(basename "$CWD")"

# 获取当前进程的 TTY（通过进程树向上查找）
get_current_tty() {
    local pid=$$
    while [ "$pid" != "1" ] && [ -n "$pid" ]; do
        local tty=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
        if [ -n "$tty" ] && [ "$tty" != "??" ]; then
            echo "/dev/$tty"
            return 0
        fi
        pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
    done
    return 1
}

# 构建 URL Scheme（IDE 用）
build_url() {
  case "$1" in
    vscode|cursor|windsurf|zed) echo "${1}://file${2}" ;;
    sublime) echo "subl://open?url=file://${2}" ;;
    idea|webstorm|pycharm) echo "${1}://open?file=${2}" ;;
  esac
}

# 构建通知参数
ARGS=(-title "$TITLE" -message "$MESSAGE" -sound "$SOUND")

if [ "$IDE_APP" = "terminal" ]; then
    # Terminal.app 模式：使用 -execute 激活对应窗口
    TTY=$(get_current_tty)
    if [ -n "$TTY" ]; then
        SCRIPT="osascript -e 'tell application \"Terminal\"' -e 'activate' -e 'repeat with w in windows' -e 'repeat with t in tabs of w' -e 'if tty of t is \"$TTY\" then' -e 'set index of w to 1' -e 'set selected of t to true' -e 'return' -e 'end if' -e 'end repeat' -e 'end repeat' -e 'end tell'"
        ARGS+=(-execute "$SCRIPT")
    fi
elif [ -n "$IDE_APP" ]; then
    # IDE 模式：使用 -open URL Scheme
    URL=$([ -n "$CWD" ] && build_url "$IDE_APP" "$CWD")
    [ -n "$URL" ] && ARGS+=(-open "$URL")
fi

# 发送通知
/opt/homebrew/bin/terminal-notifier "${ARGS[@]}"
