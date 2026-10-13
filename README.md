Photoshop 字体不识别修复脚本（Windows 10 / Windows 11）

使用：
1. 解压压缩包，保持「启动修复.cmd」与「Repair-PS-Fonts.ps1」在同一个文件夹。
2. 保存工作，彻底关闭 Photoshop 和 Adobe Creative Cloud。
3. 双击「启动修复.cmd」。先输入 1，使用基础修复。
4. 若仍然不识别，重新运行并输入 2，使用深度修复，系统可能弹出管理员授权提示。
5. 重启电脑，打开 Photoshop，使用文字工具搜索字体名称。

修复内容：
- 模式 1：只将 Photoshop 配置目录下名为「CT Font Cache」的文件夹改名为带时间戳的备份；不删除字体、不改 PS 首选项。
- 模式 2：除模式 1 外，停止 Windows FontCache 服务，仅删除其 FontCache*.dat 缓存文件，随后尝试恢复服务原有运行状态。
- 如果没找到缓存，会显示跳过，此情况不等于失败。

仍然无法识别时：
- 右键 .ttf/.otf 字体文件 → 为所有用户安装（Windows 管理员权限）。
- 检查 PS 字体下拉框的筛选选项、搜索的是「字体家族名」而不一定是文件名。
- 确认字体无损坏，使用受支持的字体格式，再重启 PS。

参考：Adobe 官方 Photoshop 字体疑难排查
https://helpx.adobe.com/photoshop/desktop/troubleshoot/tool-feature-issues/troubleshoot-fonts.html
