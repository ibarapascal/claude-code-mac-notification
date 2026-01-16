# Mac Notification for Claude Code

macOS 系统通知脚本，当 Claude Code 需要你关注时发送桌面通知。

## 功能

- 🔔 桌面通知提醒（标题显示 `Claude:<项目名>`）
- 🖱️ 点击通知跳转到对应 IDE
- 🔊 可自定义通知声音
- ⚡ **热更新**：修改脚本后立即生效，无需重启 Claude Code

## 依赖

```bash
brew install terminal-notifier jq
```

## 安装

1. 复制 `notify.sh` 到任意位置
2. 确保脚本有执行权限：`chmod +x notify.sh`
3. 在 `~/.claude/settings.json` 中添加 hook 配置：

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/notify.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

## 配置

编辑 `notify.sh` 顶部的用户配置区域：

```bash
IDE_APP="vscode"    # 你使用的 IDE
SOUND="Tink"        # 通知声音
```

### 支持的 IDE

| IDE | 配置值 | URL Scheme |
|-----|--------|------------|
| VS Code | `vscode` | `vscode://file/path` |
| Cursor | `cursor` | `cursor://file/path` |
| Windsurf | `windsurf` | `windsurf://file/path` |
| Zed | `zed` | `zed://file/path` |
| Sublime Text | `sublime` | `subl://open?url=file:///path` |
| IntelliJ IDEA | `idea` | `idea://open?file=/path` |
| WebStorm | `webstorm` | `webstorm://open?file=/path` |
| PyCharm | `pycharm` | `pycharm://open?file=/path` |

> 如果你的 IDE 不在列表中，可以在 `build_url()` 函数中添加支持。
> 设置 `IDE_APP=""` 可禁用点击跳转功能。

### 可用声音

```
Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse,
Ping, Pop, Purr, Sosumi, Submarine, Tink
```

## 热更新 & 调试

脚本支持**热更新**，修改 `notify.sh` 后立即生效，无需重启 Claude Code 会话。

**调试技巧**：在脚本中添加一行保存输入数据，方便查看 Claude Code 传递的完整 JSON：

```bash
echo "$INPUT" > /tmp/notification-debug.json
```

然后触发一次通知，查看数据：

```bash
cat /tmp/notification-debug.json | jq .
```

你也可以手动测试通知效果：

```bash
echo '{"message": "测试消息", "cwd": "/your/project/path"}' | ./notify.sh
```

## 通知数据

Claude Code 发送的 JSON 包含以下字段：

```json
{
  "session_id": "会话 ID",
  "transcript_path": "会话记录路径",
  "cwd": "当前工作目录",
  "hook_event_name": "Notification",
  "message": "通知消息",
  "notification_type": "通知类型 (permission_prompt 等)"
}
```

## License

MIT
