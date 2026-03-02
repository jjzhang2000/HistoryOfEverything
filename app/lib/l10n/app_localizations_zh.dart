// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '万物的历史与未来';

  @override
  String get historyOfEverything => '万物的历史';

  @override
  String get yourFavorites => '我的收藏';

  @override
  String get noFavoritesYet => '您还没有收藏任何内容。';

  @override
  String get about => '关于';

  @override
  String get retry => '重试';

  @override
  String get loading => '加载中...';

  @override
  String get errorLoadingData => '数据加载失败';

  @override
  String get search => '搜索';

  @override
  String get share => '分享';

  @override
  String get addToFavorites => '添加到收藏';

  @override
  String get removeFromFavorites => '从收藏中移除';

  @override
  String yearsAgo(String years) {
    return '$years前';
  }

  @override
  String billionYears(String value) {
    return '$value亿年';
  }

  @override
  String millionYears(String value) {
    return '$value百万年';
  }

  @override
  String thousandYears(String value) {
    return '$value千年';
  }

  @override
  String get years => '年';

  @override
  String get unknown => '未知';

  @override
  String get unknownAgo => '未知时间';

  @override
  String get aboutPageTitle => '万物的历史';

  @override
  String get version => 'v1.0';

  @override
  String get aboutDescription1 => '《万物的历史》使用 ';

  @override
  String get aboutDescription2 => ' 开发，由 ';

  @override
  String get aboutDescription3 => ' 制作。图形和动画使用 ';

  @override
  String get aboutDescription4 => ' 的工具创建。\n\n灵感来源于 Kurzgesagt 视频 ';

  @override
  String get aboutDescription5 => '。';

  @override
  String get flutter => 'Flutter';

  @override
  String get twoDimensions => '2Dimensions';

  @override
  String get historyAndFutureVideo => '万物的历史与未来';

  @override
  String get designedBy => '设计者';

  @override
  String get builtWith => '使用技术';

  @override
  String get universe => '宇宙';

  @override
  String get earth => '地球';

  @override
  String get life => '生命';

  @override
  String get humanity => '人类';

  @override
  String get showAll => '显示全部';

  @override
  String get collapse => '收起';

  @override
  String get expand => '展开';

  @override
  String get noResults => '未找到结果';

  @override
  String get searchHint => '搜索事件...';

  @override
  String get close => '关闭';

  @override
  String get back => '返回';

  @override
  String get readMore => '阅读更多';

  @override
  String get articleError => '文章加载失败';
}