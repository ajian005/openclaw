# Channel 插件层

Channel 插件层是 OpenClaw 实现多平台支持的关键。它通过定义统一的接口 `ChannelDock`，将不同即时通讯平台的差异性封装起来，使得上层的 Agent 和 Gateway 无需关心具体的平台实现细节。

## 核心接口: ChannelDock

位于 `src/channels/dock.ts`，`ChannelDock` 定义了一个渠道必须具备的能力和行为：

```typescript
export type ChannelDock = {
  id: ChannelId;               // 渠道 ID (e.g., "slack", "discord")
  capabilities: ChannelCapabilities; // 能力描述 (e.g., 是否支持图片，是否支持编辑)
  commands?: ChannelCommandAdapter;  // 命令处理适配器
  outbound?: {
    textChunkLimit?: number;   // 发送消息的最大长度限制
  };
  streaming?: ChannelDockStreaming; // 流式传输配置
  // ... 其他高级特性适配
};
```

## 插件职责

一个完整的 Channel 插件（如 `src/slack/`）通常包含以下部分：

1.  **Monitor (监听器)**:
    *   负责接收来自平台的事件（消息、反应、文件上传）。
    *   实现方式：Webhook (HTTP) 或 Long Polling / WebSocket。
    *   **标准化**: 将平台特定的事件转换为 OpenClaw 的 `InboundMessage` 格式。

2.  **Sender (发送器)**:
    *   实现 `send` 方法，将 OpenClaw 的回复发送回平台。
    *   **格式转换**: 将 Markdown 转换为平台特定的格式（如 Slack Block Kit, Discord Embeds）。
    *   **分片**: 如果消息过长，自动拆分为多条。

3.  **Account Management (账号管理)**:
    *   管理 Bot Token、App ID 等认证信息。
    *   支持多账号/多工作区配置。

## 数据流向

```
[External Platform] (e.g. Slack)
       ↕
[Channel Plugin] (src/slack/)
   1. Normalize Inbound -> 标准化
   2. Adapt Outbound    <- 适配格式
       ↕
[Gateway]
       ↕
[Agent]
```

## 现有插件列表

*   **Slack**: `src/slack/` - 基于 Bolt SDK，支持 Socket Mode。
*   **Discord**: `src/discord/` - 基于 Discord.js，支持 Gateway API。
*   **Telegram**: `src/telegram/` - 基于 Bot API (Webhook/Polling)。
*   **Signal**: `src/signal/` - 通过 signal-cli 集成。
*   **Web**: `src/web/` - 网页版聊天组件。
*   **iMessage**: `src/imessage/` - 仅 macOS，通过本地数据库读取。

## 开发新插件

要添加一个新的渠道（例如 WeChat）：
1.  在 `src/` 下创建 `wechat/` 目录。
2.  实现 `Monitor` 接收微信消息。
3.  实现 `Sender` 发送微信消息。
4.  定义 `ChannelDock` 对象并导出。
5.  在 `src/channels/registry.ts` 中注册该插件。
