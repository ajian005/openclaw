# Agent 处理流程

OpenClaw 的 Agent 是一个智能体，能够理解自然语言、维护对话上下文、并使用工具完成任务。

## 核心组件

### 1. 上下文管理 (`src/agents/context.ts`)
Agent 的“记忆”依赖于上下文窗口 (Context Window)。
*   **Token 预算**: 自动计算当前模型的最大 Token 数（如 Claude 3 Opus 的 200k）。
*   **滑动窗口**: 当对话过长时，自动修剪旧的消息，保留系统提示词 (System Prompt) 和最近的对话。
*   **压缩**: 可能使用摘要或关键信息提取来压缩历史记录。

### 2. 身份与设定 (`src/agents/identity.ts`)
每个 Agent 都有独特的身份。
*   **System Prompt**: 定义了 Agent 的性格、职责和行为准则。
*   **名称与头像**: 在不同渠道中展示的形象。

### 3. 技能系统 (`src/agents/skills.ts`)
Agent 的“手和脚”。
*   **技能注册**: Agent 启动时会加载 `skills/` 目录下配置的技能。
*   **权限控制**: 并非所有 Agent 都能使用所有技能，可以通过配置进行限制。
*   **动态加载**: 支持运行时加载新的技能定义。

### 4. 执行引擎 (Runner)
位于 `src/agents/pi-embedded-runner/` (或类似路径)，负责驱动 LLM 交互循环。
*   **ReAct 模式**: Reasoning + Acting。Agent 先思考 (Reasoning)，然后行动 (Acting)，再观察结果。
*   **工具调用**: 解析 LLM 输出的工具调用指令，执行本地代码（TypeScript/Python/Bash），并将结果反馈给 LLM。

## 处理生命周期

1.  **初始化 (Init)**:
    *   加载配置 (`openclaw.toml`)。
    *   加载 Session 状态。
    *   初始化 SandBox（如果需要）。

2.  **感知 (Perceive)**:
    *   接收用户输入（文本、图片、文件）。
    *   读取当前环境状态（时间、操作系统信息）。

3.  **决策 (Decide)**:
    *   构建 Prompt：`System Prompt` + `Tools Description` + `Conversation History` + `User Input`.
    *   调用 LLM API。

4.  **行动 (Act)**:
    *   **文本回复**: 直接生成回答。
    *   **工具调用**: 执行 `fs.read_file`, `browser.open` 等操作。
    *   **思维链 (Chain of Thought)**: 输出 `<thinking>` 标签的内容，展示推理过程。

5.  **反馈 (Feedback)**:
    *   将行动结果（如文件内容、命令输出）作为新的观察 (Observation) 添加到上下文中。
    *   回到“决策”步骤，直到任务完成或需要用户输入。

## 沙箱环境 (`src/agents/sandbox.ts`)
为了安全，Agent 的代码执行（特别是生成的代码）通常在沙箱中运行。
*   **Docker/容器**: 隔离文件系统和网络。
*   **权限限制**: 限制 Agent 对宿主机的访问。

## 关键代码位置
*   `src/agents/context.ts`: 上下文管理。
*   `src/agents/skills.ts`: 技能管理。
*   `src/auto-reply/reply/agent-runner.ts`: Agent 运行主循环。
*   `src/gateway/server-chat.ts`: 聊天会话管理。
