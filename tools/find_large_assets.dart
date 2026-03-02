import 'dart:io';
import 'package:image/image.dart';

// This tool helps locate large images.
void main() {
  Directory('../app/assets').list(recursive: true, followLinks: false).listen(
    (FileSystemEntity entity) {
      int dot = entity.path.lastIndexOf('.');
      if (dot != -1) {
        String extension = entity.path.substring(dot + 1).toLowerCase();
        if (extension == 'png') {
          final bytes = File(entity.path).readAsBytesSync();
          final image = decodeImage(bytes);
          if (image != null && image.width > 512 && image.height > 512) {
            print('Large image: ${image.width}x${image.height} - ${entity.path}');
          }
        }
      }
    },
  );
}