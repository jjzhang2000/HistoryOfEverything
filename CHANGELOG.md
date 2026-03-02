# 变更日志

本文件记录了 History of Everything 项目的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [未发布]

### 新增
- Riverpod 状态管理集成（`flutter_riverpod: ^2.4.9`）
- `CONTRIBUTING.md` - 项目贡献指南
- `CHANGELOG.md` - 变更日志
- `app/lib/providers/app_providers.dart` - Riverpod 状态管理提供者
- `app/lib/timeline/timeline_constants.dart` - 从 Timeline 类提取的布局常量
- `app/lib/timeline/timeline_viewport.dart` - 视口状态管理类
- `app/lib/timeline/timeline_color_manager.dart` - 颜色管理类
- `app/lib/timeline/resource_cache.dart` - LRU 资源缓存
- `app/lib/l10n/` 国际化支持目录
- 时间线组件的单元测试

### 变更
- 将 `Timeline` 类重构为多个单一职责的小类
- 从 Flare/Nima 动画库迁移到 Rive
- 优化搜索性能，使用前缀索引
- 增强 `BlocProvider` 和 `ArticleWidget` 的错误处理
- 修复多文件的空安全问题
- 将代码注释统一为英语
- 移除未使用的代码和变量
- 修复 Web 平台兼容性

### 修复
- 修复 `main_menu.dart` 中 Web 平台兼容性问题
- 修复强制解包（`!`）导致的空指针异常
- 修复搜索索引性能问题
- 修复异步操作的错误处理
- 修复 `flutter analyze` 报告的代码风格问题

## [1.0.0] - 原始版本

### 新增
- 从宇宙大爆炸到互联网诞生的垂直时间线导航
- 使用 Flare/Nima 的事件动画
- 气泡式标签显示事件名称和时间
- Markdown 格式的文章内容
- 基于 SplayTreeMap 的搜索功能
- 使用 SharedPreferences 的收藏持久化
- 分享功能
- 支持 Android、iOS、Web 和 Windows 平台

---

## 版本历史摘要

| 版本 | 日期 | 描述 |
|---------|------|-------------|
| 未发布 | 2026-03 | 重大重构，Riverpod 集成，Rive 迁移 |
| 1.0.0 | 2019 | 2D Inc 原始版本 |

---

## 迁移指南

### 从 Flare/Nima 迁移到 Rive

项目已从废弃的 Flare/Nima 动画库迁移到 Rive。主要变更：

1. **资源加载**：`.flr` 和 `.nma` 文件现替换为 PNG 回退图片
2. **Rive 支持**：`.riv` 文件完全支持新动画
3. **资源缓存**：LRU 缓存实现，高效内存管理

### 迁移到 Riverpod 状态管理

新的 Riverpod 提供者与现有 `BlocProvider` 并存：

```dart
// 旧方式（仍然支持）
BlocProvider.getTimeline(context)

// 新方式（推荐）
ref.watch(timelineProvider)
```

### Timeline 类重构

`Timeline` 类已拆分为：
- `TimelineConstants` - 布局常量
- `TimelineViewport` - 视口管理
- `TimelineColorManager` - 颜色处理

通过静态 getter 访问常量（向后兼容）：
```dart
Timeline.lineWidth  // 仍然有效
```

---

[未发布]: https://github.com/jjzhang2000/HistoryOfEverything/compare/v1.0.0...Upgrade
[1.0.0]: https://github.com/2d-inc/HistoryOfEverything/releases/tag/v1.0.0