# Android SDK 配置指南

## 目标
配置 Android 开发环境，使 Flutter 能够构建 Android APK。

---

## 📋 系统要求

- **操作系统**: Windows 10/11 (64-bit)
- **磁盘空间**: 至少 4GB 可用空间
- **内存**: 建议 8GB+

---

## 🔧 安装步骤

### 步骤 1: 下载并安装 Android Studio

1. 访问 [Android Studio 官网](https://developer.android.com/studio)
2. 下载 Windows 版本
3. 运行安装程序，按向导完成安装
4. **注意**: 记住安装路径，默认是 `C:\Program Files\Android\Android Studio`

---

### 步骤 2: 安装 Android SDK

**首次启动 Android Studio 时：**
1. 选择 "Standard" 安装类型
2. 等待 SDK 自动下载安装

**或手动安装：**
1. 打开 Android Studio
2. 点击菜单 `File → Settings` (或 `Ctrl+,`)
3. 导航到 `Appearance & Behavior → System Settings → Android SDK`
4. 选择以下 SDK 平台：
   - ✅ Android 14.0 (API 34)
   - ✅ Android 13.0 (API 33)
5. 选择以下 SDK 工具：
   - ✅ Android SDK Build-Tools
   - ✅ Android SDK Platform-Tools
   - ✅ Android SDK Tools
   - ✅ Android Emulator
   - ✅ Android SDK Command-line Tools
6. 点击 "Apply" 下载安装

---

### 步骤 3: 配置环境变量

**打开环境变量设置：**
1. 按 `Win + R`，输入 `sysdm.cpl`，回车
2. 点击 "高级" 选项卡 → "环境变量"

**添加 ANDROID_HOME：**
1. 点击 "新建"（用户变量）
2. 变量名：`ANDROID_HOME`
3. 变量值：`C:\Users\你的用户名\AppData\Local\Android\Sdk`
   - 如果找不到，在 Android Studio 中查看：File → Settings → Android SDK → Android SDK Location

**添加 PATH：**
1. 找到 "Path" 变量，点击 "编辑"
2. 添加以下路径：
   ```
   %ANDROID_HOME%\platform-tools
   %ANDROID_HOME%\cmdline-tools\latest\bin
   ```

**验证配置：**
打开 PowerShell，运行：
```powershell
adb --version
flutter doctor
```

---

### 步骤 4: 安装 Java JDK

1. 访问 [Oracle JDK](https://www.oracle.com/java/technologies/downloads/) 或 [OpenJDK](https://adoptium.net/)
2. 下载 JDK 17 (推荐)
3. 安装并记住安装路径

**配置 JAVA_HOME：**
1. 添加环境变量 `JAVA_HOME`
2. 值为 JDK 安装路径，如：`C:\Program Files\Java\jdk-17`

---

### 步骤 5: 验证 Flutter 配置

打开 PowerShell，运行：
```powershell
cd d:\Projects\HistoryOfEverything\app
flutter doctor
```

**期望输出：**
```
[✓] Flutter (Channel stable, 3.38.3, ...)
[✓] Android toolchain - develop for Android devices
[✓] Java binary at: ...
```

如果有 `[!]` 或 `[✗]`，按照提示修复。

---

## 📱 构建 APK

配置完成后，运行：
```powershell
cd d:\Projects\HistoryOfEverything\app
flutter build apk --release
```

APK 将生成在：`build\app\outputs\flutter-apk\app-release.apk`

---

## 🐛 常见问题

### 问题 1: "Android SDK not found"
**解决**: 确保 ANDROID_HOME 设置正确，并重启终端

### 问题 2: "Android licenses not accepted"
**解决**: 运行 `flutter doctor --android-licenses`，按 y 接受所有许可

### 问题 3: "cmdline-tools component is missing"
**解决**: 在 Android Studio 的 SDK Manager 中安装 "Android SDK Command-line Tools"

---

## ✅ 验证清单

- [ ] Android Studio 安装完成
- [ ] Android SDK (API 33/34) 下载完成
- [ ] ANDROID_HOME 环境变量设置
- [ ] PATH 包含 platform-tools
- [ ] Java JDK 安装并配置 JAVA_HOME
- [ ] `flutter doctor` 显示全绿
- [ ] `flutter build apk` 成功

---

*配置完成时间: 预计 30-60 分钟 (取决于下载速度)*
