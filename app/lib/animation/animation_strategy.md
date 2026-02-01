# 动画迁移策略

## 背景
原始项目使用 Flare/Nima 动画库，但这些库已停止维护且无法获取。

## 迁移方案

### 1. 收藏按钮动画 (Favorite.flr)
**替代方案**: 使用 Flutter 原生 `AnimatedSwitcher` + `Icon`
- 已实施: 使用 `Icons.favorite` / `Icons.favorite_border`

### 2. 时间线角色动画 (.flr/.nma)
**替代方案**: 使用静态图片
- 从原始动画提取关键帧作为缩略图
- 或使用占位图标

### 3. 菜单小插图 (Menu Vignette)
**替代方案**: 使用静态图片或渐变背景

## 资源映射

| 原动画文件 | 建议替代 | 优先级 |
|-----------|---------|--------|
| Favorite.flr | Flutter 原生动画 | 高 |
| heart_toolbar.flr | Flutter 原生动画 | 高 |
| Broken Heart.flr | 静态图标 | 中 |
| 其他角色动画 | 静态图片 | 低 |

## 实施状态
- [x] 移除 Flare/Nima 依赖
- [x] 添加 Rive 依赖（备用）
- [ ] 创建静态图片资源
- [ ] 实现原生动画替代
