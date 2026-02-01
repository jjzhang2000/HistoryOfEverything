/// 将动画资源文件 (.flr/.nma) 映射到对应的静态图片路径
/// 用于在动画无法加载时显示静态图片作为回退
class StaticImageAsset {
  /// 动画资源文件名到静态图片路径的映射表
  /// 键名统一使用小写以便不区分大小写查询
  static final Map<String, String> _assetMap = {
    // .flr 文件映射
    'dinosaurs.flr': 'assets/Dinosaurs/Dinosaurs.png',
    'trex.flr': 'assets/Dinosaurs/Dinosaurs.png',
    'sun.flr': 'assets/Big_Bang/Big_Bang.png',
    'humans.flr': 'assets/Homo_Sapiens_Sapiens/Homo_Sapiens_Sapiens.png',
    'animals.flr': 'assets/Mammals/Mammals.png',
    'heavybombardment.flr': 'assets/Dinosaur_Demise/Dinosaur_Demise.png',
    'big_bang.flr': 'assets/Big_Bang/Big_Bang.png',
    'milky way.flr': 'assets/Milky Way/Milky Way.png',
    'expandcollapse.flr': 'assets/Big_Bang/Big_Bang.png',
    'favorite.flr': 'assets/heart_icon.png',
    'heart_toolbar.flr': 'assets/heart_icon.png',
    'broken heart.flr': 'assets/heart_outline.png',
    
    // .nma 文件映射
    'robot.nma': 'assets/Robot.png',
    'apes.nma': 'assets/Apes/Apes0.png',
    'cells.nma': 'assets/Cells/Cells.png',
    'blackplague.nma': 'assets/BlackPlague/BlackPlague.png',
    'cold_war.nma': 'assets/Cold_war/Cold_war.png',
    'constantinople.nma': 'assets/Constantinople/Constantinople0.png',
    'constructive_tools.nma': 'assets/Constructive_Tools/Constructive_Tools.png',
    'crusades.nma': 'assets/Crusades/Crusades.png',
    'darwin 2.nma': 'assets/Darwin 2/Darwin 2.png',
    'dinosaur_demise.nma': 'assets/Dinosaur_Demise/Dinosaur_Demise.png',
    'dinosaurs.nma': 'assets/Dinosaurs/Dinosaurs.png',
    'fire.nma': 'assets/Fire/Fire.png',
    'first_temple.nma': 'assets/First_Temple/First_Temple.png',
    'fish_and_stuff.nma': 'assets/Fish_and_Stuff/Fish_and_Stuff.png',
    'homo_sapiens_sapiens.nma': 'assets/Homo_Sapiens_Sapiens/Homo_Sapiens_Sapiens.png',
    'industrialization.nma': 'assets/Industrialization/Industrialization.png',
    'insects.nma': 'assets/Insects/Insects.png',
    'internet.nma': 'assets/Internet/Internet.png',
    'mammals.nma': 'assets/Mammals/Mammals.png',
    'marie_curie.nma': 'assets/Marie_Curie/Marie_Curie.png',
    'martin luther king.nma': 'assets/Martin Luther king/Martin Luther king0.png',
    'moon.nma': 'assets/Moon/Moon.png',
    'nelson mandela_v2.nma': 'assets/Nelson Mandela_v2/Nelson Mandela_v2.png',
    'newton_v2.nma': 'assets/Newton/Newton_v2.png',
    'pyramid.nma': 'assets/Pyramid/Pyramid.png',
    'recorded_history.nma': 'assets/Recorded_history/Recorded_history.png',
    'reptiles.nma': 'assets/Reptiles/Reptiles.png',
    'roma.nma': 'assets/Roma/Roma.png',
    'sufraggette_movement.nma': 'assets/Sufraggette_movement/Sufraggette_movement.png',
    'world_war_i.nma': 'assets/World_War_I/World_War_I.png',
    'world_war_ii.nma': 'assets/World_War_II/World_War_II.png',
    'writing.nma': 'assets/Writing/Writing.png',
    'agricultural_evolution.nma': 'assets/Agricultural_evolution/Agricultural_evolution.png',
    'alan_turing.nma': 'assets/Alan_Turing/Alan_Turing.png',
    'amelia_earhart.nma': 'assets/Amelia_Earhart/Amelia_Earhart.png',
  };

  /// 根据动画资源文件名获取对应的静态图片路径
  /// 
  /// [assetName] 动画资源文件名，如 'Dinosaurs.flr' 或 'Robot.nma'
  /// 
  /// 返回对应的静态图片路径，如果未找到映射则返回 null
  /// 
  /// 示例:
  /// ```dart
  /// String? imagePath = StaticImageAsset.getPath('Dinosaurs.flr');
  /// // 返回: 'assets/Dinosaurs/Dinosaurs.png'
  /// ```
  static String? getPath(String? assetName) {
    if (assetName == null || assetName.isEmpty) {
      return null;
    }
    // 转换为小写进行不区分大小写的查询
    return _assetMap[assetName.toLowerCase()];
  }

  /// 检查指定的动画资源是否有对应的静态图片映射
  /// 
  /// [assetName] 动画资源文件名
  /// 
  /// 返回 true 如果存在映射，否则返回 false
  static bool hasStaticImage(String? assetName) {
    if (assetName == null || assetName.isEmpty) {
      return false;
    }
    return _assetMap.containsKey(assetName.toLowerCase());
  }

  /// 获取所有已映射的动画资源名称列表
  static List<String> get allAssetNames => _assetMap.keys.toList();

  /// 获取所有可用的静态图片路径列表
  static List<String> get allImagePaths => _assetMap.values.toList();
}
