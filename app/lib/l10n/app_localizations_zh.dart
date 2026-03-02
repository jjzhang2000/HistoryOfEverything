import 'app_localizations.dart';

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh() : super('zh');

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
  String yearsAgo(String years) => '$years前';

  @override
  String billionYears(String value) => '$value亿年';

  @override
  String millionYears(String value) => '$value百万年';

  @override
  String thousandYears(String value) => '$value千年';

  @override
  String get years => '年';

  @override
  String get unknown => '未知';

  @override
  String get unknownAgo => '未知时间';
}