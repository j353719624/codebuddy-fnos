# CodeBuddy for fnOS

腾讯 [CodeBuddy Code](https://www.codebuddy.cn) 引擎的飞牛 fnOS 原生应用包。把 CodeBuddy 的 Agent 守护进程以常驻服务方式跑在 NAS 上，提供完整的浏览器 Agent 界面：对话 / 编辑器 / 终端 / Worker / 定时任务 / 插件 / 监控。

> 本仓库与腾讯官方无关，只是把官方 npm 发行版（`@tencent-ai/codebuddy-code`）打包成 fnOS 应用。

## 特性

- **常驻在线**：daemon 监听 `0.0.0.0:7890`，进程异常退出自动拉起（watchdog），随开机自启
- **免密直达**：已关闭访问密码认证，内网外网打开即用（如需认证可在 `settings.json` 的 `gateway.auth` 改回 `password`）
- **稳定优先**：禁用 CLI 内置的自动更新（避免后台自杀式更新导致服务中断），启动时等待端口就绪才算成功
- **应用内更新**：SSH 执行 `/var/apps/codebuddy/cmd/main update`，多镜像容错（npmmirror → npmjs），新包校验失败自动回滚
- **工作区独立**：Agent 工作目录位于 `/vol2/@appshare/codebuddy/workspace`（fnOS data-share），文件管理器可见、升级卸载不丢

## 安装

1. 下载 [Releases](../../releases) 里的 `codebuddy-x86.fpk`
2. 飞牛应用中心 → 手动安装 → 上传 FPK（或 CLI：`appcenter-cli install-fpk`）
3. 安装后从飞牛桌面点「CodeBuddy」，或浏览器访问 `http://NAS-IP:7890`
4. 首次使用登录腾讯账号（与 CodeBuddy / WorkBuddy 官方账号体系一致），并在设置里配置模型

依赖：应用自动关联安装 Node.js 运行时（fnOS 应用中心的 nodejs_v22）。

## 从源码构建

在 fnOS 本机（`fnpack` 已内置）：

```bash
git clone https://github.com/j353719624/codebuddy-fnos.git
cd codebuddy-fnos
./build.sh                # 自动从 npmmirror 拉取 npm 包并打包
# 产出：codebuddy.fpk
```

指定版本：`CBC_VERSION=2.182.0 ./build.sh`

## 应用内更新

新版本发布后，SSH 到 NAS 执行：

```bash
/var/apps/codebuddy/cmd/main update
```

流程：npmmirror → npmjs 官方源逐个尝试 → 下载新版到临时目录 → 校验可执行 → 停止 daemon → 旧目录备份 → 覆盖 → 重启；新包异常自动回滚。

## 目录结构

```
/var/apps/codebuddy/            程序目录（应用中心管理，升级整体替换）
├── bin/codebuddy               wrapper（node 启动器）
├── lib/codebuddy/              托管代码目录（npm 包，应用内更新覆盖这里）
├── cmd/  ui/
/vol2/@appdata/codebuddy/       状态目录（TRIM_PKGVAR，升级保留）
├── config/settings.json        daemon 配置（auth / autoUpdates）
├── info.log  daemon.log  daemon.pid
/vol2/@appshare/codebuddy/      数据工作区（fnOS data-share，文件管理器可见）
└── workspace/                  Agent 默认工作目录
```

## 常用命令

```bash
/var/apps/codebuddy/cmd/main status    # 运行状态
/var/apps/codebuddy/cmd/main stop      # 停止
/var/apps/codebuddy/cmd/main start     # 启动
/var/apps/codebuddy/cmd/main update    # 应用内更新
```

## License

MIT
