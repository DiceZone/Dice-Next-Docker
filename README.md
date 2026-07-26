# Dice!Next Docker

Dice!Next 的独立 Docker 镜像项目。工作流每 6 小时检查一次 `DiceZone/Dice-Next` 的最新 Release；只有发现新标签时才构建镜像。也可手动触发，立即重建最新或指定标签。

同一次多架构构建会同时发布到 GitHub Container Registry 与 Docker Hub：

```text
ghcr.io/dicezone/dice-next:latest
ghcr.io/dicezone/dice-next:beta
ghcr.io/dicezone/dice-next:v3.0.0-beta.NNN

shiaworkshop/dice-next:latest
shiaworkshop/dice-next:beta
shiaworkshop/dice-next:v3.0.0-beta.NNN
```

每个标签都是同时支持 `linux/amd64` 与 `linux/arm64` 的多架构镜像。镜像构建时只下载对应 Dice!Next Release 的 Linux 包。

## 运行

```bash
docker run -d --name dice-next --restart unless-stopped \
  -p 18088:18088 \
  -v "$(pwd)/config:/app/config" \
  -v "$(pwd)/data:/app/data" \
  ghcr.io/dicezone/dice-next:latest
```

默认 Compose 会同时启动 Dice!Next 与 NapCat：

- Dice!Next WebUI：`http://localhost:18088`
- NapCat WebUI：`http://localhost:6099/webui`

首次启动后在 NapCat WebUI 登录 QQ。Dice!Next 的 QQ OneBot 适配器已预设为反向 WebSocket `3002`，NapCat 已预设为连接同一 Compose 网络内的 `ws://dice-next:3002`。`config`、`data`、`napcat/QQ_DATA` 和 `qrcode` 都保存在 Compose 文件所在目录；升级镜像时请保留这些目录。镜像会在首次启动时把内置规则、帮助和示例资源初始化到空的 `./data` 中。

也可使用本项目的 `docker-compose.yml`：

```bash
docker compose up -d
```

## NapCat 反向 WebSocket 模式

默认 Compose 已启用与旧 Docker 项目相同的 `MODE=napcat` 行为，会在启动时自动整理 Dice!Next 的 QQ / OneBot 配置：

```bash
docker compose up -d
```

该模式会把 QQ OneBot 适配器设为 **反向 WebSocket**，监听容器内 `3002` 端口。首次运行会写入 `config/default_config.json`；已有安装还会同步更新 `data/dice.db` 中的运行时适配器配置。原配置分别保留为 `.pre-napcat` 备份。由于一个反向监听端口只能对应一个 QQ OneBot 适配器，此模式会保留一个 QQ 适配器，其余平台适配器不受影响。

仓库内的 `napcat/config/onebot11.json` 是 NapCat 的默认 OneBot 网络配置，会自动创建反向 WS 客户端并连接 `ws://dice-next:3002`。若改用外部 NapCat，请在其网络配置中新建“WebSocket 客户端”，填写 Dice!Next 可访问地址；`3002` 默认不暴露给宿主机。

使用 `docker run` 时追加 `-e MODE=napcat` 即可启用相同逻辑。

## 构建触发

- 自动检查：每 6 小时一次；新 Release 才会构建。
- 手动检查：GitHub Actions → **Build Dice!Next Docker Image** → **Run workflow**。留空标签即重建最新 Release；填写标签可重建指定版本。

在 `DiceZone/Dice-Next-Docker` 设置以下机密：

- `DOCKERHUB_USERNAME`：Docker Hub 用户名或组织名。
- `DOCKERHUB_TOKEN`：Docker Hub access token，不要使用账户密码。

默认 Docker Hub 仓库是 `shiaworkshop/dice-next`。如需改名，在 Docker 项目的 GitHub Actions Variables 中创建 `DOCKERHUB_REPOSITORY`，例如 `dicezone/dice-next`。若 Dice!Next 主项目以后改为私有，还需在 Docker 项目设置可读取主项目 Release 的 `DICE_NEXT_READ_TOKEN`。
