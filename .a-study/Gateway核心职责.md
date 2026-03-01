# Gateway 核心职责

Gateway 是 OpenClaw 的心脏，负责连接所有外部渠道、客户端、代理引擎和基础设施。它不仅仅是一个简单的 API 服务器，还是整个系统的协调者。

## 1. 统一接入与路由 (Access & Routing)
Gateway 提供了统一的 API 接口，屏蔽了底层通信协议的差异。
*   **WebSocket 服务 (`src/gateway/server-ws-runtime.ts`)**: 处理实时双向通信，主要用于 Web 控制台、CLI 和桌面客户端。
*   **HTTP API (`src/gateway/server-methods.ts`)**: 提供 RESTful 接口，支持标准的消息发送、历史记录查询等。
*   **渠道适配 (`src/gateway/server-channels.ts`)**: 管理所有已加载的 Channel 插件（如 Slack, Discord），并负责将外部消息路由到内部处理逻辑。
*   **Webhook 处理**: 接收来自第三方平台（如 GitHub, Stripe）的 Webhook 事件。

## 2. 认证与安全 (Auth & Security)
*   **认证 (`src/gateway/auth.ts`)**: 验证客户端连接的合法性，支持 Token 认证。
*   **速率限制 (`src/gateway/auth-rate-limit.ts`)**: 防止滥用，对 API 调用频率进行限制。
*   **执行审批 (`src/gateway/exec-approval-manager.ts`)**: 对于敏感操作（如执行 Shell 命令），Gateway 负责拦截并请求用户批准。
*   **Secrets 管理 (`src/gateway/server-methods/secrets.ts`)**: 安全地管理和分发 API 密钥等敏感信息。

## 3. 节点管理 (Node Management)
OpenClaw 支持分布式节点（如移动端节点），Gateway 负责管理这些节点的生命周期。
*   **节点注册 (`src/gateway/node-registry.ts`)**: 跟踪所有连接的节点（iOS, Android, Desktop）。
*   **能力发现**: 识别节点具备的能力（如“能否拍照”、“能否定位”）。
*   **消息转发**: 将特定指令（如“拍照”）路由到正确的节点执行。

## 4. 任务调度 (Task Scheduling)
*   **Cron 服务 (`src/gateway/server-cron.ts`)**: 内置 Cron 调度器，允许 Agent 设置定时任务（如“每天早上 8 点汇报天气”）。
*   **心跳检测 (`src/gateway/server/health-state.ts`)**: 监控各组件和渠道的健康状态。

## 5. 代理协调 (Agent Coordination)
虽然 Agent 的具体逻辑在 `src/agents/` 中，但 Gateway 负责触发 Agent 的运行。
*   **会话管理**: 维护用户会话状态 (`SessionKey`)。
*   **上下文组装**: 在调用 Agent 前，Gateway 负责收集必要的上下文信息（历史消息、用户信息）。
*   **并发控制 (`src/gateway/server-lanes.ts`)**: 管理并发执行的任务通道 (Lanes)，防止资源冲突。

## 6. 基础设施集成
*   **日志系统**: 统一收集各模块的日志。
*   **更新检查 (`src/infra/update-startup.ts`)**: 自动检查 OpenClaw 版本更新。

## 代码映射
| 职责 | 关键文件 |
| :--- | :--- |
| 服务器入口 | `src/gateway/server.ts` |
| 路由与方法 | `src/gateway/server-methods.ts` |
| WebSocket 处理 | `src/gateway/server-ws-runtime.ts` |
| 认证 | `src/gateway/auth.ts` |
| 渠道管理 | `src/gateway/server-channels.ts` |
| 节点注册 | `src/gateway/node-registry.ts` |
| Cron 服务 | `src/gateway/server-cron.ts` |
