# Photoshop Font Fix | Photoshop 字体不识别一键修复工具

**安装字体后，Photoshop 找不到？** 本项目提供一个适用于 Windows 的字体缓存修复脚本，帮助排查 **系统已安装字体、但 Photoshop 字体列表不显示** 的问题。

![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-5391FE?logo=powershell&logoColor=white)
![Photoshop](https://img.shields.io/badge/Adobe-Photoshop-31A8FF?logo=adobephotoshop&logoColor=white)
![Version](https://img.shields.io/badge/Version-1.0.0-555555)

> 💡 **无需安装第三方软件。** 脚本使用 Windows 自带的 PowerShell。建议先使用基础修复；仅在无效时尝试需要管理员权限的深度修复。

## 📥 下载安装

**[⬇️ 下载完整 ZIP 压缩包](https://github.com/8820387-byte/Photoshop-Font-Fix/raw/refs/heads/main/Photoshop%20%E5%AD%97%E4%BD%93%E4%B8%8D%E8%AF%86%E5%88%AB%E4%B8%80%E9%94%AE%E4%BF%AE%E5%A4%8D%E5%B7%A5%E5%85%B7.zip)**

也可以点击仓库上方 **Code → Download ZIP** 获取整个仓库，并查看源代码。

## ✨ 功能特点

- 🔍 自动查找当前用户的 Photoshop 配置目录及其 `CT Font Cache` 文件夹。
- 🛡️ **基础修复**：将找到的 PS 字体缓存文件夹重命名为带时间戳的备份，让 Photoshop 在下次启动时重新生成。
- 🧰 **深度修复**：在基础修复之上，尝试停止 Windows `FontCache` 服务、删除匹配的字体缓存 `.dat` 文件，再恢复服务原先的运行状态。
- 📦 不卸载已安装字体，不重置 Photoshop 首选项。
- 🧩 自动处理当前用户配置目录中的多个 Photoshop 版本（如存在对应缓存）。

## 🖥️ 适用环境

| 项目 | 说明 |
| --- | --- |
| 操作系统 | Windows 10 / Windows 11 |
| 脚本环境 | Windows PowerShell 5.1 或更高的兼容环境 |
| 修复对象 | Adobe Photoshop 本地字体缓存及可选的 Windows 字体缓存 |
| 权限 | 基础修复通常无需管理员；深度修复需要管理员授权 |

**注意：** 该脚本尚未覆盖验证所有 Photoshop / Windows 版本，不保证修复所有字体显示问题；不适用于 macOS。

## 🚀 使用方法

1. 下载并解压 ZIP，确保 `启动修复.cmd` 和 `Repair-PS-Fonts.ps1` **放在同一个文件夹**。
2. **保存所有设计文件**，完全退出 Photoshop 和 Adobe Creative Cloud。
3. 双击运行 **`启动修复.cmd`**。
4. 根据菜单输入：
   - `1`：**基础修复（推荐先用）**，备份并重建 Photoshop 字体缓存。
   - `2`：**深度修复**，同时清理 Windows 字体缓存；按系统提示授权管理员权限。
   - `0`：退出，不做修改。
5. 完成后**重启电脑**，再打开 Photoshop，在文字工具中搜索字体。

> 📌 如果提示“未找到需要重建的 CT Font Cache”，并不一定代表异常，可能当前版本尚未生成对应缓存。

## 📁 项目文件

```text
Photoshop-Font-Fix/
├── 启动修复.cmd                # Windows 启动入口
├── Repair-PS-Fonts.ps1        # PowerShell 修复逻辑
├── 使用说明.txt                # 简明操作说明
├── README.md                  # 项目介绍
└── Photoshop 字体不识别一键修复工具.zip
```

## ❓ 常见问题

### Q1：修复后 Photoshop 仍找不到字体？

请继续排查：

1. 右键 `.ttf` 或 `.otf` 字体文件，尝试选择 **“为所有用户安装”**（需管理员权限）。
2. 关闭 Photoshop 后重新打开，清除字体列表中的筛选条件。
3. Photoshop 中的字体名称可能是**字体家族名**，不一定与文件名相同。
4. 检查字体文件是否完整、格式是否受支持、是否与其他字体冲突。
5. 如果问题只发生在特定字体，可先换一款正常字体对比验证。

### Q2：会删除我安装的字体吗？

**不会。** 基础模式重命名 Photoshop 的 `CT Font Cache` 目录作为备份；深度模式额外删除符合条件的 Windows 字体缓存数据文件。已安装的字体文件不属于脚本的清理目标。

### Q3：修复过程可以恢复吗？

基础修复会在原位置留下形如 `CT Font Cache.backup.时间戳.随机字符` 的备份文件夹。若需要手动恢复，请先退出 Photoshop，妥善处理新生成的缓存，再将原备份目录改回 `CT Font Cache`。**深度模式清除的 Windows 缓存不会备份**，通常由系统重新生成。

### Q4：为什么需要管理员权限？

只有**深度修复**需要调整 Windows 字体缓存服务和相关系统缓存文件。若不希望授权管理员权限，可只执行基础修复。

## ⚠️ 使用须知

- 执行前请保存工作、关闭 Adobe 程序；操作系统级缓存前建议创建系统还原点。
- 深度模式会暂时操作 Windows 字体缓存服务，部分缓存文件可能由于占用或权限原因无法删除。
- 请阅读脚本源码并确认其行为后运行；建议仅从本项目页面获取文件。
- 本工具为社区排障脚本，**非 Adobe 官方产品**，不保证对所有字体问题有效。

## 🔗 官方参考

[Adobe Photoshop 官方字体故障排查说明](https://helpx.adobe.com/photoshop/desktop/troubleshoot/tool-feature-issues/troubleshoot-fonts.html)

## 🤝 反馈与贡献

如果遇到问题，可以前往 [Issues](https://github.com/8820387-byte/Photoshop-Font-Fix/issues) 描述 Windows 和 Photoshop 版本、操作步骤，以及运行时的提示信息。提交日志或截图前请隐藏个人信息。

欢迎通过 Pull Request 提交改进。

---

如果这个项目帮到了你，欢迎点个 ⭐ **Star** 支持项目！

**项目地址：** https://github.com/8820387-byte/Photoshop-Font-Fix

> 许可证：仓库当前未包含 LICENSE 文件。请勿将“公开可见”理解为已自动授予开源许可证。
