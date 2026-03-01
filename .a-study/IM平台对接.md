# IM 平台对接方式

OpenClaw 支持多种 IM 平台，每个平台的对接方式因其 API 特性而异。本文档总结了主要平台的对接策略。

## 1. Slack
*   **接入方式**: 官方 **Bolt for JavaScript** SDK。
*   **连接模式**: **Socket Mode** (推荐)。
    *   **优点**: 无需公网 IP，适合本地开发和防火墙后的部署。
    *   **配置**: 需要 `App Token` (以 `xapp-` 开头) 和 `Bot Token` (以 `xoxb-` 开头)。
*   **特性支持**:
    *   支持 Thread (线程) 回复。
    *   支持 Block Kit (富文本 UI)。
    *   支持 Slash Commands。

## 2. Discord
*   **接入方式**: **Discord.js** 库。
*   **连接模式**: **WebSocket Gateway**。
    *   需要保持长连接以接收事件。
*   **权限**: 需要在 Developer Portal 开启 `MESSAGE CONTENT INTENT` 才能读取消息内容。
*   **特性支持**:
    *   支持 Embeds (富文本卡片)。
    *   支持 Slash Commands。
    *   支持语音频道 (实验性)。

## 3. Telegram
*   **接入方式**: **Telegram Bot API**。
*   **连接模式**: 支持 **Long Polling** (默认) 和 **Webhook**。
    *   Polling 适合本地运行，Webhook 适合生产环境（需要 HTTPS）。
*   **特性支持**:
    *   支持 Inline Keyboards。
    *   支持文件/图片收发。

## 4. Signal
*   **接入方式**: **signal-cli** (外部二进制工具) + DBus/JSON-RPC。
*   **注意**: 需要在系统上安装并配置 Java 和 signal-cli。OpenClaw 通过子进程调用 signal-cli。
*   **特性**: 端到端加密，隐私性极高。

## 5. iMessage (macOS Only)
*   **接入方式**: 读取本地 `~/Library/Messages/chat.db` 数据库 + AppleScript 发送。
*   **限制**: 
    *   仅能在 macOS 上运行。
    *   需要授予终端/应用 "Full Disk Access" 权限。
*   **原理**: 轮询 SQLite 数据库检测新消息，调用 `osascript` 发送回复。

## 平台差异对比表

| 平台 | 协议 | 实时性 | 部署难度 | 富文本能力 |
| :--- | :--- | :--- | :--- | :--- |
| **Slack** | Socket Mode | 高 | 低 (无需公网) | 强 (Block Kit) |
| **Discord** | WebSocket | 高 | 低 | 中 (Embeds) |
| **Telegram** | Polling/Webhook | 中/高 | 低/中 | 中 |
| **Signal** | signal-cli | 中 | 高 (依赖环境) | 低 (纯文本/附件) |
| **iMessage** | Local DB | 低 (轮询) | 仅 Mac | 低 |
