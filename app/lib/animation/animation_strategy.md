# 动画迁移策略

## 背景
原始项目使用 Flare/Nima 动画库，但这些库已停止维护且无法获取。

## 迁移方案

### 1. 收藏按钮动画 (Favorite.flr)
**替代方案**: 使用 Flutter 原生 `AnimatedSwitcher` + `Icon`
- 已实施: 使用 `Icons.favorite` / `Icons.favorite_border`

### 2. 时间线角色动画 (.flr/.nma)
**替代方案**: 使用 Rive 动画库
- 已实施 Rive 支持:
  - `TimelineRive` 类用于存储 Rive 动画数据
  - `VignetteRenderObject` 支持渲染 Rive artboard
  - 动画帧调度在 `timeline.dart` 中实现
- 支持格式: `.riv` 文件

### 3. 菜单小插图 (Menu Vignette)
**替代方案**: 使用静态图片或渐变背景

## 资源映射

| 原动画文件 | 替代方案 | 状态 |
|-----------|---------|------|
| Favorite.flr | Flutter 原生动画 | ✅ 完成 |
| heart_toolbar.flr | Flutter 原生动画 | ✅ 完成 |
| Broken Heart.flr | 静态图标 | 待实施 |
| .flr/.nma 角色 | Rive (.riv) 或静态图片 | ✅ 框架完成 |

## 实施状态
- [x] 移除 Flare/Nima 依赖
- [x] 添加 Rive 依赖
- [x] 实现 `TimelineRive` 资源类
- [x] 更新 `timeline.dart` 加载 Rive 文件
- [x] 实现 `VignetteRenderObject` 渲染 Rive 动画
- [x] 实现动画帧调度
- [ ] 创建/转换 .riv 动画文件
- [ ] 测试动画渲染效果

## 技术实现

### TimelineRive 类
```dart
class TimelineRive extends TimelineAnimatedAsset {
  Artboard? artboard;
  RiveAnimationController? controller;
}
```

### Rive 文件加载
```dart
ByteData data = await rootBundle.load(filename);
final riveFile = RiveFile.import(data);
final artboard = riveFile.mainArtboard;
riveAsset.artboard = artboard;
```

### 渲染实现
```dart
// 在 VignetteRenderObject.paint() 中
if (asset is TimelineRive && asset.artboard != null) {
  canvas.translate(x, y);
  artboard.draw(canvas);
}
```
