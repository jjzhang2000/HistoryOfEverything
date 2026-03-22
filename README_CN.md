# 关于本项目

本项目最初克隆自 https://github.com/2d-inc/HistoryOfEverything.git 。本项目的目标是：

1. 使其能够在当前 Flutter 版本下运行
2. 升级依赖包
3. 将其作为一组新应用的基础，其中大多数应用仍在构思中，将在未来尝试

## 近期改进

1. **依赖管理**：清理了未使用的依赖，并将必要的包更新到最新版本
2. **动画增强**：集成了 Rive 动画库以替代已弃用的 Flare/Nima 动画
3. **代码质量**：删除了所有注释掉的代码，优化了代码结构以提高可读性和可维护性
4. **错误处理**：添加了全面的错误处理机制以提高应用稳定性
5. **性能优化**：实现了视口裁剪以优化时间线渲染性能
6. **跨平台兼容性**：确保应用在所有支持的平台上正常运行
7. **代码重构**：改进了代码结构和模块化以提高可维护性

以下是原始 README.md：

# 万物简史

<img align="right" src="https://cdn.2dimensions.com/1_Start.gif" height="400">

《万物简史》是一个垂直时间线应用，让你可以导航、探索和比较从大爆炸到互联网诞生的事件。所有事件都配有精美的插图和动画。

这个应用的概念灵感来自 Kurzgesagt 的视频《时间：万物的历史与未来》[Time: The History & Future of Everything](https://www.youtube.com/watch?v=5TbUxGZtwGI)。

该应用由 [2Dimensions](https://www.2dimensions.com) 使用 [Flutter](https://flutter.io/) 构建，可在 [Android](https://play.google.com/store/apps/details?id=com.twodimensions.timeline) 和 [iOS](https://itunes.apple.com/us/app/the-history-of-everything/id1441257460) 下载。

## 使用方法

确保你的本地机器上已安装 Flutter。关于如何安装 Flutter 的更多说明，请查看[这里](https://flutter.io/docs/get-started/install)。

```
git clone https://github.com/2d-inc/HistoryOfEverything.git
cd HistoryOfEverything/app
git submodule init
git submodule update
flutter run
```

## 概览
<img align="right" src="https://cdn.2dimensions.com/2_Scroll.gif" height="400">

该应用由三个主要视图组成：

1. **主菜单** - /app/lib/main_menu<br />
这是应用打开时的初始视图。顶部显示一个搜索栏，三个菜单区域分别对应每个主要时代，底部有三个按钮用于访问收藏夹、分享商店链接和关于页面。<br />

2. **时间线** - /app/lib/timeline<br />
当从菜单中选择一个项目时显示此视图：用户会看到一个垂直时间线。可以上下滚动，也可以放大缩小。<br/>
当一个事件进入视野时，屏幕上会显示一个气泡，旁边有一个自定义动画小部件。点击其中任何一个，用户都可以进入文章页面。

3. **文章页面** - /app/lib/article<br />
文章页面显示事件动画，以及事件的完整描述。<br/>

## 动画小部件

<img align="right" src="https://cdn.2dimensions.com/3_Amelia.gif" height="400">

这在很大程度上依赖于 [2dimensions](https://www.2dimensions.com) 上构建的动画，并通过 [Flare](https://pub.dartlang.org/packages/flare_flutter) 和 [Nima](https://pub.dartlang.org/packages/nima) 库与 Flutter 无缝集成。

Flutter 最大的优势之一是其灵活性，因为它暴露了其组件的架构，可以完全从头构建：可以使用 SDK 最基本的元素创建自定义小部件。

一个例子可以在 /app/lib/article/timeline_entry_widget.dart 中找到<br/>
该文件包含两个类：<br/>
- `TimelineEntryWidget`，继承自 `LeafRenderObjectWidget`
- VignetteRenderObject，继承自 `RenderBox`

## LeafRenderObjectWidget

这个类（[文档](https://docs.flutter.io/flutter/widgets/LeafRenderObjectWidget-class.html)）是一个 `Widget`：它可以插入任何小部件树中，无需任何其他默认组件：

```
Container(
  child: TimelineEntryWidget(
        isActive: true,
        timelineEntry: widget.article,
        interactOffset: _interactOffset
    )
)
```

这段代码用于 /app/lib/article/article_widget.dart

`LeafRenderObjectWidget` 负责拥有构造函数并封装 `RenderObject` 所需的值。

以下两个重写方法也是基本的：
- `createRenderObject()` <br />
在小部件树中实例化实际的 `RenderObject`；
- `updateRenderObject()` <br />
传递给小部件的任何参数变化都可以在需要时反映到 UI 上。更新 `RenderObject` 会导致对象重绘。

## RenderObject

正如[文档](https://docs.flutter.io/flutter/rendering/RenderObject-class.html)中所述，这是渲染树中的一个对象，它定义了其创建者小部件将在屏幕上绘制什么以及如何绘制。

这里的关键重写是 `paint()`：<br />
&nbsp;&nbsp;&nbsp;&nbsp;当前的 `PaintingContext` 暴露了 `canvas`，这个类可以利用暴露的 API 进行绘制。<br />
[Flare 库](https://pub.dartlang.org/packages/flare_flutter)获得对 `canvas` 的访问权限后绘制动画。<br/>
要使动画正确播放，还需要在每一帧对当前的 `FlutterActor` 调用 `advance(elapsed)`。此外，当前的 `ActorAnimation` 需要调用 `apply(time)` 函数来显示正确的插值。<br/>
这一切都依赖于 Flutter 的 `SchedulerBinding.scheduleFrameCallback()` 实现。

这只是对如何为各种体验自定义 Flare 小部件的简要概述。

## 许可证
`/assets` 文件夹中的所有动画均在 **CC-BY** 许可下分发。

`assets/articles` 中的所有文章均来自 [维基百科](https://www.wikipedia.org/)，因此在 **GNU 自由文档许可证** 下分发。

本仓库的其余代码和内容在 **MIT** 许可下分发，如 [LICENSE](LICENSE) 中所述。