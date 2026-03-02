import 'dart:io';
import 'package:image/image.dart';

// This tool resizes large images.
const String source = '../app/full_quality';
const String dest = '../app/assets';

const int thresholdSize = 1024;

void main() {
  Directory('../app/full_quality').list(recursive: true, followLinks: false).listen(
    (FileSystemEntity entity) {
      int dot = entity.path.lastIndexOf('.');
      if (dot != -1) {
        String extension = entity.path.substring(dot + 1).toLowerCase();
        if (extension == 'png') {
          final bytes = File(entity.path).readAsBytesSync();
          final image = decodeImage(bytes);
          if (image != null) {
            if (image.width > thresholdSize || image.height > thresholdSize) {
              print('Large image: ${image.width}x${image.height} - ${entity.path}');
              String destFilename = dest + entity.path.substring(source.length);

              final thumbnail = image.width > thresholdSize
                  ? copyResize(image, width: thresholdSize)
                  : copyResize(image, height: thresholdSize);
              File(destFilename).writeAsBytesSync(encodePng(thumbnail));
              print('Wrote to: $destFilename');
            }
          }
        }
      }
    },
  );
}