/// Maps animation asset files (.flr/.nma) to corresponding static image paths
/// Used to display static images as fallback when animations cannot be loaded
class StaticImageAsset {
  /// Mapping table from animation asset filename to static image path
  /// Keys are lowercase for case-insensitive lookup
  static final Map<String, String> _assetMap = {
    // .flr file mappings
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
    
    // .nma file mappings
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

  /// Gets the corresponding static image path for an animation asset filename
  /// 
  /// [assetName] Animation asset filename, e.g. 'Dinosaurs.flr' or 'Robot.nma'
  /// 
  /// Returns the corresponding static image path, or null if no mapping is found
  /// 
  /// Example:
  /// ```dart
  /// String? imagePath = StaticImageAsset.getPath('Dinosaurs.flr');
  /// // Returns: 'assets/Dinosaurs/Dinosaurs.png'
  /// ```
  static String? getPath(String? assetName) {
    if (assetName == null || assetName.isEmpty) {
      return null;
    }
    // Convert to lowercase for case-insensitive lookup
    return _assetMap[assetName.toLowerCase()];
  }

  /// Checks if the specified animation asset has a corresponding static image mapping
  /// 
  /// [assetName] Animation asset filename
  /// 
  /// Returns true if a mapping exists, otherwise false
  static bool hasStaticImage(String? assetName) {
    if (assetName == null || assetName.isEmpty) {
      return false;
    }
    return _assetMap.containsKey(assetName.toLowerCase());
  }

  /// Gets all mapped animation asset names
  static List<String> get allAssetNames => _assetMap.keys.toList();

  /// Gets all available static image paths
  static List<String> get allImagePaths => _assetMap.values.toList();
}