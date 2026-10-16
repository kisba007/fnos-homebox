# fnos-homebox

> Homebox 家庭网络工具箱的 **飞牛 fnOS 原生直装版（非 Docker）**

Homebox 是一个家庭局域网调试、检测、测速、压测的工具集合（GitHub 开源项目 [XGHeaven/homebox](https://github.com/XGHeaven/homebox)）。
本仓库将其官方 Linux 二进制打包为飞牛原生应用（`.fpk`），**不依赖 Docker**，以系统原生进程运行。

- 打包版本：**1.0.0**
- 上游二进制：homebox **v0.1.3**
- 服务端：Rust(actix-web)，单二进制自带 Web 前端与测速 API
- 默认监听端口：**3300**
- 主要功能：单次测速（Ping/Download/Upload）、持续压测、自定义测速参数、最高 10G 测速

## 目录结构

```
fnos-homebox/
├── package/                 # FPK 应用包源文件（飞牛官方 FPK 工程结构）
│   ├── manifest             # 应用元数据
│   ├── ICON.PNG / ICON_256.PNG
│   ├── app/ui/              # 桌面入口（http://NAS:3300）+ 图标
│   ├── cmd/                 # 生命周期脚本（main 启停/状态 + 回调）
│   ├── config/              # privilege + resource
│   └── wizard/install       # 安装说明向导
├── build.sh                 # 一键打包脚本（自动下载 fnpack + homebox 二进制）
├── dist/                    # 打包产物（.fpk，可手动安装）
└── .github/workflows/       # 自动打包并发布 Release 的流水线
```

## 安装

1. 从 [Releases](https://github.com/kisba007/fnos-homebox/releases) 下载对应架构的 `.fpk`：
   - `homebox-1.0.0-x86_64.fpk`：Intel/AMD 的 x86 飞牛（最常见）
   - `homebox-1.0.0-x86_64-musl.fpk`：x86 机型兼容性问题时用（静态 musl）
   - `homebox-1.0.0-aarch64.fpk`：飞牛 ARM 机型
2. 把 `.fpk` 传到 NAS，打开「应用中心」→「手动安装」→ 选择文件。
3. 安装后桌面打开 **Homebox** 图标，或浏览器访问 `http://你的NAS地址:3300`。

> 安装时系统创建专用低权限用户 `homebox` 运行；默认端口 3300 被占用时请先释放。

## 从源码打包

要求：`curl`、`tar`、`gzip`（以及一个能运行 `fnpack` 的环境，Linux/macOS 均可）。

```bash
./build.sh              # 打包全部三个架构
./build.sh x86_64       # 只打包指定架构：x86_64 / x86_64-musl / aarch64
```

脚本会自动：
1. 下载飞牛官方 `fnpack`（v1.2.3）
2. 从 `XGHeaven/homebox` v0.1.3 Release 下载对应架构二进制
3. 按官方 FPK 规范组装、校验并打包，输出到 `dist/`

`package/app/homebox` 二进制不提交到仓库（见 `.gitignore`），由脚本按架构动态下载；如需手动放置，也可放到该路径后直接跑 `fnpack build`。

## 打标签自动发布

推送版本标签即可触发 GitHub Actions 自动打包并生成 Release：

```bash
git tag v1.0.0
git push origin v1.0.0
```

## 说明

- 本包为第三方打包，与飞牛官方无关；如遇使用问题请勿向飞牛官方反馈。
- 上游项目未提供独立 LICENSE 文件，版权归原作者 XGHeaven 所有，本包仅供个人使用。
