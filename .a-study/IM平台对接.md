## 核心理解

**每个 IM 平台都有自己的一套对接方式和协议，都不一样。**

## 主要平台对接方式（官方 API）

```
Telegram
    └── 官方 Bot API
    └── 协议: HTTP REST API + Webhook

Discord
    └── 官方 Gateway API
    └── 协议: WebSocket + Discord Gateway Protocol

Slack
    └── 官方 Bolt SDK
    └── 协议: Events API + Socket Mode

Microsoft Teams
    └── 官方 Bot Framework
    └── 协议: Bot Framework Protocol

Google Chat
    └── 官方 Chat API
    └── 协议: HTTP REST API + Pub/Sub

```

## Slack 对接详情

**使用技术**: SlackBolt SDK(官方)
**工作方式**:

- 使用Slack官方提供的BoltSDK
- 通过Socket Mode或Events API接收消息
- 使用Web API发送消息
- 完全官方支持，稳定可靠

**创建 Slack App**: 1.访问 https://api.slack.com/apps 2.创建新应用3.配置权限(BotToken Scopes) 4.安装到工作区5.获取 BotToken

**代码示例**:

```typescript
// src/slack/client.ts
import { App } from '@slack/bolt';

//创建Slack App
const app = new App({
    token: process.env.SLACK_B0T_TOKEN,
    socketMode: true,
    appToken:process. env.S ACK_APP_TOKEN
});

// 接收消息
app.message(async ({ message, say }) => {
    console.log('收到消息:'，message.text);

    //转发到 Gateway
    await handleInboundMessage(message);

    //回复消息
    await say('你好! ');
});
//启动
await app.start();
```

**需要的权限**:

- chat:write -发送消息
- channels:history -读取频道消息
- groups:history -读取私有频道消息
- im:history -读取私信 人
- users:read -读取用户信息

**配置示例**:

```json
{
  "channels": {
    "slack": {
      "enabled": true,
      "botToken": "xoxb-vour-bot-token",
      "appToken": "xapp-xxxxx",
      "socketMode": true
    }
  }
}
```

## 为什么每个平台都不一样

**技术栈不同**:

- Telegram: HTTP REST API
- Discord: WebSocket Gateway
- Slack: Socket Mode / Events API
- Microsoft Teams: Bot Framework

**认证方式不同**:

- Telegram: Bot Token
- Slack: 0Auth 2.0 + Bot Token
- Discord: Bot Token
- Google Chat: Service Account

**消息格式不同**:

- 每个平台的JSON结构都不同
- 字段名称、嵌套层级各异
- 需要单独话配.

## Moltbot 的解决方案

**插件化架构** - 每个平台一个插件

```
各种 IM 平台（协议各异）
        |
        ↓
Channel 插件（适配层）
        |
        ↓
Gateway（统一消息格式）
        |
        ↓
Agent（不关心来自哪个平台）
```

以 Slack 为例的完整流程：

```
用户在 Slack 发消息
        ↓
Slack 服务器推送事件（Socket Mode）
        ↓
Bolt SDK 接收消息
        ↓
Slack 插件处理（src/slack/）
        ↓
转换为统一格式
        ↓
发送到 Gateway（WebSocket）
        ↓
Gateway 路由到 Agent
        ↓
Agent 处理并调用工具(调用大模型和工具 ReAct模式)
        ↓
返回结果到 Gateway
        ↓
Slack 插件发送消息
        ↓
Bolt SDK 调用 Web API
        ↓
Slack 服务器推送给用户
        ↓
用户收到回复
```

**统一消息格式**:

```typescript
// Slack消息转换后
{
    channel:"slack",   //来自 Slack
    accountId: "wo.kspace1",  //哪个工作区
    peerId:"C1234567890", //频道ID
    text:"你好",  //消息内容
    sessionKey:"slack:workspace1:C1234567890" //Agent看到的都是这种格式，不关心来自哪个平台
}
```

// Agent 看到的都是这种格式，不关心来自哪个平台

## 代码示例对比

**Slack (Bolt SDK - Socket Mode)**:

```typescript
import { App } from '@slack/bolt';

//创建应用
const app = new App({
    token: process.env.SLACK_B0T_TOKEN,
    socketMode: true,
    appToken:process.env.SLACK_APP_TOKENH);

//接收消息
app.message(async ({ message, say }) => {
    console.log('收到消息:'，message.text);

    //转发到 Gateway
    await handleInboundMessage({
        channel:'slack',
        peerId: message.channel,
        text: message.textH;});
});

//启动
await app.start();
```

## 官方API平台对比

| 平台            | 接入方式      | SDK/库               | 通信方式                 | 认证方式          |
| --------------- | ------------- | -------------------- | ------------------------ | ----------------- |
| Slack           | Bolt SDK      | '@slack/bolt'        | Socket Mode / Events API | OAuth + Bot Token |
| Telegram        | Bot API       | 原生 HTTP            | HTTP REST                | Bot Token         |
| Discord Gateway | 'discord.js'  | WebSocket            | Bot Token                |
| Microsoft Teams | Bot Framework | 'botbuilder'         | WebSocket                | App ID + Password |
| Google Chat     | Chat API      | '@google-cloud/chat' | HTTP+ Pub/Sub            | Service Account   |

## 添加新平台的步骤

1.研究平台的API或协议2.创建插件目录(如src/newplatform/) 3.实现连接、收发消息4.转换为统一格式5.注册到Gateway

**代码位置**:

- Slack:`src/slack/`
- Telegram:`src/telegram/`
- Discord:`src/discord/`
- Microsoft Teams:`extensions/msteams/`
- Google Chat:需要单独实现

### Slack接入的优势

**为什么推荐 Slack**:

- 官方SDK支持完善
- 文档详细，社区活跃
- Socket Mode无需公网IP
- 功能丰富(频道、私信、线程、反应等)
- 企业级稳定性

**Socket Mode vs Events API**:

- \**Socket Mode*k:通过 WebSocket连接,无需公网服务器
- **Events API**:通过HTTPWebhook,需要公网可访问的服务器

Moltbot推荐使用 Socket Mode，因为更适合本地运行。

## 总结

- 每个IM平台都需要单独适配
- 官方API稳定可靠，推荐使用
- Slack是企业级应用的最佳选择
- 通过插件化架构统一管理
- Agent 不需要关心具体平台差异

# IM 平台对接方式

OpenClaw 支持多种 IM 平台，每个平台的对接方式因其 API 特性而异。本文档总结了主要平台的对接策略。

## 1. Slack

- **接入方式**: 官方 **Bolt for JavaScript** SDK。
- **连接模式**: **Socket Mode** (推荐)。
  - **优点**: 无需公网 IP，适合本地开发和防火墙后的部署。
  - **配置**: 需要 `App Token` (以 `xapp-` 开头) 和 `Bot Token` (以 `xoxb-` 开头)。
- **特性支持**:
  - 支持 Thread (线程) 回复。
  - 支持 Block Kit (富文本 UI)。
  - 支持 Slash Commands。

## 2. Discord

- **接入方式**: **Discord.js** 库。
- **连接模式**: **WebSocket Gateway**。
  - 需要保持长连接以接收事件。
- **权限**: 需要在 Developer Portal 开启 `MESSAGE CONTENT INTENT` 才能读取消息内容。
- **特性支持**:
  - 支持 Embeds (富文本卡片)。
  - 支持 Slash Commands。
  - 支持语音频道 (实验性)。

## 3. Telegram

- **接入方式**: **Telegram Bot API**。
- **连接模式**: 支持 **Long Polling** (默认) 和 **Webhook**。
  - Polling 适合本地运行，Webhook 适合生产环境（需要 HTTPS）。
- **特性支持**:
  - 支持 Inline Keyboards。
  - 支持文件/图片收发。

## 4. Signal

- **接入方式**: **signal-cli** (外部二进制工具) + DBus/JSON-RPC。
- **注意**: 需要在系统上安装并配置 Java 和 signal-cli。OpenClaw 通过子进程调用 signal-cli。
- **特性**: 端到端加密，隐私性极高。

## 5. iMessage (macOS Only)

- **接入方式**: 读取本地 `~/Library/Messages/chat.db` 数据库 + AppleScript 发送。
- **限制**:
  - 仅能在 macOS 上运行。
  - 需要授予终端/应用 "Full Disk Access" 权限。
- **原理**: 轮询 SQLite 数据库检测新消息，调用 `osascript` 发送回复。

## 平台差异对比表

| 平台         | 协议            | 实时性    | 部署难度      | 富文本能力       |
| :----------- | :-------------- | :-------- | :------------ | :--------------- |
| **Slack**    | Socket Mode     | 高        | 低 (无需公网) | 强 (Block Kit)   |
| **Discord**  | WebSocket       | 高        | 低            | 中 (Embeds)      |
| **Telegram** | Polling/Webhook | 中/高     | 低/中         | 中               |
| **Signal**   | signal-cli      | 中        | 高 (依赖环境) | 低 (纯文本/附件) |
| **iMessage** | Local DB        | 低 (轮询) | 仅 Mac        | 低               |
