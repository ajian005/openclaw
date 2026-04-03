# OpenClaw 安装部署指南

## 1. 系统要求

在安装OpenClaw之前，请确保您的系统满足以下要求：

- **Node.js 22+**：OpenClaw需要Node.js 22或更高版本
- **操作系统**：macOS、Linux或Windows
- **包管理器**：pnpm（仅在从源代码构建时需要）

<Note>
在Windows上，强烈建议在[WSL2](https://learn.microsoft.com/en-us/windows/wsl/install)下运行OpenClaw。
</Note>

## 2. 安装方法

OpenClaw提供多种安装方法，您可以根据自己的需求选择最适合的方式。

### 2.1 推荐：安装脚本

安装脚本是最简单的安装方式，它会自动处理Node.js检测、安装和初始化向导。

#### macOS / Linux / WSL2

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

#### Windows (PowerShell)

```powershell
iwr -useb https://openclaw.ai/install.ps1 | iex
```

##### 跳过初始化向导

如果您只想安装二进制文件而跳过初始化向导，可以使用以下命令：

```bash
# macOS / Linux / WSL2
curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard

# Windows (PowerShell)
& ([scriptblock]::Create((iwr -useb https://openclaw.ai/install.ps1))) -NoOnboard
```

### 2.2 npm / pnpm 安装

如果您已经安装了Node.js 22+，可以使用npm或pnpm直接安装OpenClaw。

#### npm

```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

##### 解决sharp构建错误

如果您在安装过程中遇到sharp构建错误，可以尝试以下方法：

```bash
# 强制使用预构建的二进制文件
SHARP_IGNORE_GLOBAL_LIBVIPS=1 npm install -g openclaw@latest
```

#### pnpm

```bash
pnpm add -g openclaw@latest
pnpm approve-builds -g        # 批准openclaw, node-llama-cpp, sharp等包
openclaw onboard --install-daemon
```

<Note>
pnpm需要显式批准带有构建脚本的包。在第一次安装显示"Ignored build scripts"警告后，运行`pnpm approve-builds -g`并选择列出的包。
</Note>

### 2.3 从源代码安装

如果您是开发者或想要从本地仓库运行OpenClaw，可以从源代码安装。

```bash
# 克隆仓库
git clone https://github.com/openclaw/openclaw.git
cd openclaw

# 安装依赖
pnpm install

# 构建UI
pnpm ui:build

# 构建项目
pnpm build

# 全局链接CLI
pnpm link --global

# 运行初始化向导
openclaw onboard --install-daemon
```

<Note>
您也可以跳过全局链接，直接在仓库目录中使用`pnpm openclaw ...`命令。
</Note>

### 2.4 Docker 部署

Docker是可选的部署方式，适用于容器化或无头环境。

#### 快速开始（推荐）

从仓库根目录运行：

```bash
./docker-setup.sh
```

这个脚本会：

- 构建网关镜像
- 运行初始化向导
- 打印可选的提供商设置提示
- 通过Docker Compose启动网关
- 生成网关令牌并写入`.env`文件

#### 可选环境变量

```bash
# 安装额外的apt包
export OPENCLAW_DOCKER_APT_PACKAGES="ffmpeg build-essential"

# 添加额外的主机挂载
export OPENCLAW_EXTRA_MOUNTS="$HOME/.codex:/home/node/.codex:ro,$HOME/github:/home/node/github:rw"

# 持久化/home/node到命名卷
export OPENCLAW_HOME_VOLUME="openclaw_home"
```

#### 手动流程

```bash
# 构建镜像
docker build -t openclaw:local -f Dockerfile .

# 运行初始化向导
docker compose run --rm openclaw-cli onboard

# 启动网关
docker compose up -d openclaw-gateway
```

#### 容器化代理沙箱

当启用`agents.defaults.sandbox`时，非主会话会在Docker容器中运行工具：

```json5
{
  agents: {
    defaults: {
      sandbox: {
        mode: "non-main", // off | non-main | all
        scope: "agent", // session | agent | shared
        workspaceAccess: "none", // none | ro | rw
        docker: {
          image: "openclaw-sandbox:bookworm-slim",
          network: "none",
          user: "1000:1000",
          // 其他配置...
        },
      },
    },
  },
}
```

构建默认沙箱镜像：

```bash
scripts/sandbox-setup.sh
```

### 2.5 其他安装方法

- **Podman**：无root容器化部署
- **Nix**：声明式安装
- **Ansible**：自动化部署
- **Bun**：通过Bun运行时的CLI-only使用

## 3. 配置和初始化

安装完成后，您需要进行一些配置和初始化操作。

### 3.1 验证安装

```bash
# 检查配置问题
openclaw doctor

# 检查网关状态
openclaw status

# 打开浏览器UI
openclaw dashboard
```

### 3.2 环境变量

如果需要自定义运行时路径，可以使用以下环境变量：

- `OPENCLAW_HOME`：基于主目录的内部路径
- `OPENCLAW_STATE_DIR`：可变状态位置
- `OPENCLAW_CONFIG_PATH`：配置文件位置

### 3.3 通道配置

配置各种通信通道：

#### WhatsApp（QR码）

```bash
openclaw channels login
```

#### Telegram（机器人令牌）

```bash
openclaw channels add --channel telegram --token "<token>"
```

#### Discord（机器人令牌）

```bash
openclaw channels add --channel discord --token "<token>"
```

## 4. 启动和管理

### 4.1 启动OpenClaw

```bash
# 启动OpenClaw服务
openclaw start

# 开发模式启动
openclaw dev
```

### 4.2 管理网关

```bash
# 停止网关
openclaw stop

# 重启网关
openclaw restart

# 查看网关日志
openclaw logs
```

### 4.3 Docker管理

对于Docker部署，可以使用以下命令：

```bash
# 启动网关
docker compose up -d openclaw-gateway

# 停止网关
docker compose down

# 查看日志
docker compose logs -f openclaw-gateway

# 运行CLI命令
docker compose run --rm openclaw-cli <command>
```

#### Shell助手（可选）

安装ClawDock助手，以便更轻松地管理Docker部署：

```bash
mkdir -p ~/.clawdock && curl -sL https://raw.githubusercontent.com/openclaw/openclaw/main/scripts/shell-helpers/clawdock-helpers.sh -o ~/.clawdock/clawdock-helpers.sh

# 添加到zsh配置
echo 'source ~/.clawdock/clawdock-helpers.sh' >> ~/.zshrc && source ~/.zshrc
```

然后可以使用`clawdock-start`、`clawdock-stop`、`clawdock-dashboard`等命令。

## 5. 常见问题解决

### 5.1 `openclaw`命令未找到

如果您收到`openclaw: command not found`错误，请检查npm全局路径是否在您的PATH中：

```bash
# 查看npm全局前缀
npm prefix -g

# 检查PATH
echo "$PATH"
```

如果npm全局路径不在PATH中，请将其添加到您的shell启动文件中：

```bash
# 对于macOS/Linux
export PATH="$(npm prefix -g)/bin:$PATH"
```

### 5.2 Docker权限问题

如果您在Docker中遇到权限错误，请确保主机绑定挂载的所有者是uid 1000：

```bash
sudo chown -R 1000:1000 /path/to/openclaw-config /path/to/openclaw-workspace
```

### 5.3 网络问题

如果您的代理沙箱需要网络访问，可以在配置中启用：

```json5
{
  agents: {
    defaults: {
      sandbox: {
        docker: {
          network: "bridge", // 或其他网络名称
        },
      },
    },
  },
}
```

## 6. 更新和维护

### 6.1 更新OpenClaw

```bash
# 使用安装脚本更新
curl -fsSL https://openclaw.ai/install.sh | bash

# 使用npm更新
npm install -g openclaw@latest

# 使用pnpm更新
pnpm add -g openclaw@latest
```

### 6.2 迁移到新机器

1. 备份旧机器上的配置和工作区：`~/.openclaw/`
2. 在新机器上安装OpenClaw
3. 恢复备份的配置和工作区
4. 重新配置通道和提供商

### 6.3 卸载OpenClaw

```bash
# 使用npm卸载
npm uninstall -g openclaw

# 使用pnpm卸载
pnpm remove -g openclaw

# 删除配置和数据
rm -rf ~/.openclaw
```

## 7. 云平台部署

OpenClaw可以部署到各种云平台：

- **Hetzner**：通过Docker VPS部署
- **Fly.io**：无服务器部署
- **Google Cloud Platform**：GCP部署
- **Render**：全托管部署
- **Railway**：应用程序平台

详细的平台特定部署指南可以在[文档](https://openclaw.ai/docs/install/)中找到。

## 8. 开发环境设置

对于开发者，建议使用以下设置：

```bash
# 克隆仓库
git clone https://github.com/openclaw/openclaw.git
cd openclaw

# 安装依赖
pnpm install

# 启动开发模式
pnpm dev
```

更多开发工作流详情，请参考[开发设置](https://openclaw.ai/docs/start/setup/)文档。

## 9. 支持和反馈

如果您在安装或使用OpenClaw时遇到问题，可以通过以下方式获取支持：

- 查看[官方文档](https://openclaw.ai/docs/)
- 在[GitHub Issues](https://github.com/openclaw/openclaw/issues)中提交问题
- 加入[Discord社区](https://discord.gg/openclaw)获取帮助

---

感谢您使用OpenClaw！我们希望这份安装部署指南能够帮助您顺利开始使用我们的多通道AI网关。
