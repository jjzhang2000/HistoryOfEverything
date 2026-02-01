import 'package:flutter/material.dart';
import 'static_image_asset.dart';

/// 动画占位组件，用于替代原来的 Flare/Nima 动画
/// 显示渐变背景或静态图标
class AnimationPlaceholder extends StatelessWidget {
  final String? assetName;
  final double width;
  final double height;
  final BoxFit fit;
  final Alignment alignment;
  final bool useStaticImage;

  const AnimationPlaceholder({
    Key? key,
    this.assetName,
    this.width = 100.0,
    this.height = 100.0,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.useStaticImage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 尝试获取静态图片路径
    String? imagePath = StaticImageAsset.getPath(assetName);

    if (useStaticImage && imagePath != null) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          // 如果图片加载失败，显示占位符
          return _buildPlaceholder();
        },
      );
    }

    // 返回原来的占位符
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    // 根据 asset 名称返回不同的占位符
    IconData iconData = _getIconForAsset(assetName);
    Color color = _getColorForAsset(assetName);

    return Container(
      width: width,
      height: height,
      alignment: alignment,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(
        iconData,
        size: width * 0.5,
        color: color,
      ),
    );
  }

  IconData _getIconForAsset(String? assetName) {
    if (assetName == null) return Icons.image;

    final name = assetName.toLowerCase();
    if (name.contains('heart') || name.contains('favorite')) {
      return Icons.favorite;
    } else if (name.contains('dino') || name.contains('animal')) {
      return Icons.pets;
    } else if (name.contains('human') || name.contains('person')) {
      return Icons.person;
    } else if (name.contains('star') || name.contains('sun')) {
      return Icons.wb_sunny;
    } else if (name.contains('moon')) {
      return Icons.nights_stay;
    } else if (name.contains('war') || name.contains('battle')) {
      return Icons.security;
    } else if (name.contains('temple') || name.contains('building')) {
      return Icons.account_balance;
    } else if (name.contains('book') || name.contains('write')) {
      return Icons.menu_book;
    } else if (name.contains('fire')) {
      return Icons.local_fire_department;
    } else if (name.contains('tool')) {
      return Icons.build;
    }
    return Icons.image;
  }

  Color _getColorForAsset(String? assetName) {
    if (assetName == null) return Colors.grey;

    final name = assetName.toLowerCase();
    if (name.contains('red') || name.contains('heart')) {
      return Colors.red;
    } else if (name.contains('blue')) {
      return Colors.blue;
    } else if (name.contains('green')) {
      return Colors.green;
    } else if (name.contains('yellow') || name.contains('sun')) {
      return Colors.yellow;
    } else if (name.contains('purple')) {
      return Colors.purple;
    } else if (name.contains('orange')) {
      return Colors.orange;
    } else if (name.contains('dino')) {
      return Colors.brown;
    } else if (name.contains('moon') || name.contains('night')) {
      return Colors.indigo;
    }
    return Colors.teal;
  }
}

/// 用于时间线条目的小动画占位符
class TimelineAssetPlaceholder extends StatelessWidget {
  final String? filename;
  final double opacity;

  const TimelineAssetPlaceholder({
    Key? key,
    this.filename,
    this.opacity = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: AnimationPlaceholder(
        assetName: filename,
        width: 60.0,
        height: 60.0,
        fit: BoxFit.contain,
      ),
    );
  }
}
