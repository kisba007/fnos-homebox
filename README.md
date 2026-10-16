## 安装包

| 文件 | 适用机型 |
| --- | --- |
| **homebox-0.1.3-x86_64.fpk** | Intel/AMD 的 x86 飞牛 |
| homebox-0.1.3-x86_64-musl.fpk | x86 机型遇到兼容问题时用（静态 musl，兼容性最好） |
| homebox-0.1.3-aarch64.fpk | 飞牛 ARM 机型（如 RK3588） |

## 安装方法

1. 把 `.fpk` 传到 NAS（文件管理或 SMB）
2. 应用中心 → 右上角「**手动安装**」→ 选文件 → 确认
3. 桌面打开 **Homebox** 图标，或浏览器访问 `http://你的NAS地址:3300`

## 关键点

- **不依赖 Docker**：包内是 homebox v0.1.3 官方 Release 的 Linux 二进制，以系统原生进程跑，走飞牛的应用启停 / 状态机制（PID 管理 + 端口检查）
- **架构与版本**：用 `github.com/XGHeaven/homebox` 的 v0.1.3 官方构建，服务端是 Rust (actix-web)，单二进制自带 Web 前端，默认端口 3300
- **安全**：以专用低权限用户 `homebox` 运行，非 root
- **验证情况**：三个包均通过 fnpack 官方校验（manifest / 权限 / 资源 / 图标 / 目录结构全部合规），且内部二进制已实测可执行（`homebox 0.1.3`）

## 说明

- 本包为**第三方打包**，与飞牛官方无关；项目仓库没有独立 LICENSE 文件，版权归原作者 XGHeaven 所有，仅供个人使用。
  
