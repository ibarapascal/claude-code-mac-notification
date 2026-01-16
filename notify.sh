#!/bin/bash
# =============================================================================
# Claude Code macOS 通知脚本
# =============================================================================
#
# 配置说明：
# 1. IDE_APP: 点击通知后打开的应用
# 2. SOUND: 通知声音
#
# 支持的 IDE/编辑器 URL Scheme：
#   - vscode    : vscode://file/path      (VS Code)
#   - cursor    : cursor://file/path      (Cursor)
#   - windsurf  : windsurf://file/path    (Windsurf)
#   - zed       : zed://file/path         (Zed)
#   - sublime   : subl://open?url=file:///path (Sublime Text, 需安装 URL handler)
#   - idea      : idea://open?file=/path  (IntelliJ IDEA)
#   - webstorm  : webstorm://open?file=/path (WebStorm)
#   - pycharm   : pycharm://open?file=/path (PyCharm)
#
# 如果你的 IDE 不支持 URL Scheme，可以设置 IDE_APP="" 禁用点击动作
#
# 可用的系统声音：
#   Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr,
#   Sosumi, Submarine, Tink
# =============================================================================

# ===================== 用户配置区域 =====================
IDE_APP="vscode"    # 修改为你使用的 IDE
SOUND="Tink"        # 修改为你喜欢的声音
# =======================================================

# 解析输入
INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Claude needs your attention"')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

# 生成标题
TITLE="Claude Code"
[ -n "$CWD" ] && TITLE="Claude:$(basename "$CWD")"

# 构建 URL Scheme
build_url() {
  case "$1" in
    vscode|cursor|windsurf|zed) echo "${1}://file${2}" ;;
    sublime) echo "subl://open?url=file://${2}" ;;
    idea|webstorm|pycharm) echo "${1}://open?file=${2}" ;;
  esac
}

# 构建通知参数
ARGS=(-title "$TITLE" -message "$MESSAGE" -sound "$SOUND")
URL=$([ -n "$CWD" ] && [ -n "$IDE_APP" ] && build_url "$IDE_APP" "$CWD")
[ -n "$URL" ] && ARGS+=(-open "$URL")

# 发送通知
/opt/homebrew/bin/terminal-notifier "${ARGS[@]}"
