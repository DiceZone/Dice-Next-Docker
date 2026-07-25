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
  -v dice-next-config:/app/config \
  -v dice-next-data:/app/data \
  ghcr.io/dicezone/dice-next:latest
```

首次启动后访问 `http://localhost:18088`。`config` 与 `data` 是持久化 Docker 卷；升级镜像时请保留它们。

也可使用本项目的 `docker-compose.yml`：

```bash
docker compose up -d
```

## 构建触发

- 自动检查：每 6 小时一次；新 Release 才会构建。
- 手动检查：GitHub Actions → **Build Dice!Next Docker Image** → **Run workflow**。留空标签即重建最新 Release；填写标签可重建指定版本。

在 `DiceZone/Dice-Next-Docker` 设置以下机密：

- `DOCKERHUB_USERNAME`：Docker Hub 用户名或组织名。
- `DOCKERHUB_TOKEN`：Docker Hub access token，不要使用账户密码。

默认 Docker Hub 仓库是 `shiaworkshop/dice-next`。如需改名，在 Docker 项目的 GitHub Actions Variables 中创建 `DOCKERHUB_REPOSITORY`，例如 `dicezone/dice-next`。若 Dice!Next 主项目以后改为私有，还需在 Docker 项目设置可读取主项目 Release 的 `DICE_NEXT_READ_TOKEN`。
