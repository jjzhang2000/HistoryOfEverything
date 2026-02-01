# Windows 开发者模式启用指南

## 目标
启用 Windows 开发者模式，使 Flutter 能够创建符号链接（symlinks）。

---

## ⚡ 快速启用（推荐）

### 方法 1: 使用设置应用

1. 按 `Win + I` 打开设置
2. 点击 `更新和安全`（Windows 10）或 `隐私和安全性` → `开发者选项`（Windows 11）
3. 在左侧选择 `开发者选项`
4. 开启 `开发人员模式` 开关
5. 在弹出的确认对话框中点击 `是`

**或**

1. 按 `Win + R`，输入 `ms-settings:developers`，回车
2. 直接跳转到开发者选项页面
3. 开启 `开发人员模式`

---

### 方法 2: 使用 PowerShell（管理员）

1. 右键点击开始菜单，选择 `Windows PowerShell (管理员)` 或 `终端(管理员)`
2. 运行以下命令：

```powershell
# 启用开发者模式
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
```

3. 重启电脑（建议）

---

### 方法 3: 使用组策略（专业版/企业版）

1. 按 `Win + R`，输入 `gpedit.msc`，回车
2. 导航到：`计算机配置 → 管理模板 → Windows 组件 → 应用程序包部署`
3. 启用以下策略：
   - `允许安装所有受信任的应用程序`
   - `允许开发 Windows 应用商店应用并从集成开发环境 (IDE) 安装它们`

---

## ✅ 验证启用

### 验证开发者模式状态

打开 PowerShell，运行：
```powershell
# 检查注册表值
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense"
```

**期望输出：**
```
AllowDevelopmentWithoutDevLicense : 1
```

### 验证符号链接支持

运行：
```powershell
# 创建测试符号链接
cd $env:TEMP
New-Item -ItemType SymbolicLink -Path "test_link" -Target "$env:USERPROFILE"

# 如果能成功创建，说明符号链接支持已启用
# 删除测试链接
Remove-Item "test_link"
```

---

## 🔨 验证 Flutter Windows 构建

启用开发者模式后，运行：

```powershell
cd d:\Projects\HistoryOfEverything\app
flutter doctor
```

**期望输出：**
```
[✓] Windows (desktop) • windows • windows-x64 • Microsoft Windows [版本 10.0.xxxxx.xxxx]
```

如果没有 `[!]` 警告，说明配置成功。

---

## 🏗️ 构建 Windows 应用

```powershell
cd d:\Projects\HistoryOfEverything\app
flutter build windows --release
```

可执行文件将生成在：`build\windows\x64\runner\Release\timeline.exe`

---

## 🐛 常见问题

### 问题 1: "Building with plugins requires symlink support"
**原因**: 开发者模式未启用
**解决**: 按照上述方法启用开发者模式，并重启终端

### 问题 2: "无法创建符号链接，客户端没有所需的特权"
**原因**: 没有管理员权限
**解决**: 以管理员身份运行 PowerShell，或启用开发者模式

### 问题 3: 启用后仍提示需要 symlink 支持
**解决**: 
1. 完全关闭所有终端窗口
2. 重启电脑
3. 再次尝试 `flutter build windows`

---

## 📋 启用前后对比

| 功能 | 启用前 | 启用后 |
|------|--------|--------|
| Flutter Windows 构建 | ❌ 失败 | ✅ 成功 |
| 符号链接创建 | ❌ 需要管理员 | ✅ 普通用户可用 |
| UWP 应用开发 | ❌ 不可行 | ✅ 可行 |
| PowerShell 脚本执行 | ⚠️ 受限 | ✅ 完整权限 |

---

## ✅ 验证清单

- [ ] 设置中显示开发者模式已开启
- [ ] 注册表 `AllowDevelopmentWithoutDevLicense` = 1
- [ ] `flutter doctor` 无 Windows 警告
- [ ] `flutter build windows` 成功
- [ ] 生成的 exe 可以正常运行

---

*启用耗时: 约 5 分钟（含重启）*
