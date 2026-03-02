# 贡献指南

感谢您对 History of Everything 项目的关注！本文档提供了贡献的指南和说明。

## 目录

- [行为准则](#行为准则)
- [快速开始](#快速开始)
- [开发环境设置](#开发环境设置)
- [项目结构](#项目结构)
- [编码规范](#编码规范)
- [提交规范](#提交规范)
- [Pull Request 流程](#pull-request-流程)
- [问题反馈](#问题反馈)

## 行为准则

参与本项目即表示您同意为所有贡献者维护一个尊重和包容的环境。

## 快速开始

1. Fork 本仓库
2. 克隆您的 Fork 到本地：
   ```bash
   git clone https://github.com/YOUR_USERNAME/HistoryOfEverything.git
   cd HistoryOfEverything
   ```
3. 添加上游仓库：
   ```bash
   git remote add upstream https://github.com/jjzhang2000/HistoryOfEverything.git
   ```

## 开发环境设置

### 前提条件

- Flutter SDK (>=3.0.0 <4.0.0)
- Dart SDK（随 Flutter 一起安装）
- Android Studio / 带 Flutter 扩展的 VS Code
- Xcode（用于 iOS 开发，仅 macOS）
- Android SDK（用于 Android 开发）

### 安装步骤

1. 进入应用目录：
   ```bash
   cd app
   ```

2. 安装依赖：
   ```bash
   flutter pub get
   ```

3. 运行应用：
   ```bash
   flutter run
   ```

### 运行测试

```bash
flutter test
```

### 代码分析

```bash
flutter analyze
```

## 项目结构

```
app/lib/
├── main.dart                    # 应用入口
├── bloc_provider.dart           # 状态管理核心（InheritedWidget）
├── colors.dart                  # 颜色常量定义
├── search_manager.dart          # 搜索管理器
│
├── animation/                   # 动画模块
├── article/                     # 文章详情模块
├── blocs/                       # BLoC 状态管理
├── main_menu/                   # 主菜单模块
├── providers/                   # Riverpod 状态管理
├── l10n/                        # 国际化
└── timeline/                    # 时间线核心模块
    ├── timeline.dart            # 核心逻辑
    ├── timeline_constants.dart  # 布局常量
    ├── timeline_viewport.dart   # 视口管理
    └── timeline_color_manager.dart  # 颜色管理
```

## 编码规范

### Dart 风格指南

- 遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 指南
- 使用 `dart format` 格式化代码
- 最大行长度：80 字符

### 命名约定

- **文件**：`snake_case.dart`
- **类**：`PascalCase`
- **变量/函数**：`camelCase`
- **常量**：`camelCase`（编译时常量优先使用 `const`）

### 文档注释

- 使用 dartdoc 注释（`///`）记录所有公共 API
- 注释保持使用英语（代码层面）
- 避免解释代码做什么的行内注释；应该解释为什么

示例：
```dart
/// 计算给定位置处的插值颜色。
///
/// 如果没有可插值的颜色，返回 null。
Color? interpolateColor(double position) {
  // 实现...
}
```

### 错误处理

- 异步操作使用 try-catch 进行适当的错误处理
- 提供用户友好的错误消息
- 使用 `debugPrint` 记录错误以便调试

### 空安全

- 除非绝对必要，不要使用 `!`（强制解包）
- 使用 `?.` 进行安全访问
- 使用 `??` 提供合理的默认值

## 提交规范

我们遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

### 格式

```
<类型>(<范围>): <描述>

[可选的正文]

[可选的页脚]
```

### 类型

- `feat`：新功能
- `fix`：Bug 修复
- `docs`：文档变更
- `style`：代码样式变更（格式化等）
- `refactor`：代码重构
- `perf`：性能改进
- `test`：添加或修改测试
- `chore`：构建过程或辅助工具的变更

### 示例

```
feat(timeline): 添加时间线导航的缩放动画

fix(search): 修复空查询搜索时的崩溃问题

docs(readme): 更新安装说明
```

## Pull Request 流程

1. 从 `Upgrade` 分支创建功能分支：
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. 进行更改并按照提交规范提交。

3. 推送分支到您的 Fork：
   ```bash
   git push origin feature/your-feature-name
   ```

4. 在 GitHub 上创建 Pull Request。

5. 确保所有检查通过：
   - 代码分析（`flutter analyze`）
   - 测试（`flutter test`）
   - 构建验证

6. 请求维护者审核。

7. 处理审核反馈。

### PR 检查清单

- [ ] 代码遵循项目的编码规范
- [ ] 所有测试通过
- [ ] 新代码有适当的文档
- [ ] 提交消息遵循规范
- [ ] PR 描述清楚地描述了更改

## 问题反馈

### Bug 报告

报告 Bug 时，请包含：

1. **描述**：清晰描述 Bug
2. **复现步骤**：详细的复现步骤
3. **期望行为**：您期望发生什么
4. **实际行为**：实际发生了什么
5. **环境信息**：
   - Flutter 版本（`flutter --version`）
   - 设备/平台
   - 应用版本
6. **截图**：如适用
7. **日志**：任何相关的错误日志

### 功能请求

对于功能请求，请包含：

1. **描述**：清晰描述功能
2. **使用场景**：为什么这个功能有用
3. **建议方案**：如果您有实现想法
4. **替代方案**：考虑过的任何替代方案

## 有问题？

如果您对贡献有任何疑问，请随时打开带有 `question` 标签的 Issue。

感谢您对 History of Everything 的贡献！