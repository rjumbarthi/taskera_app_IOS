// One-off: produce a circle-cropped, full-bleed version of the app logo for use
// as the launcher / taskbar icon (Windows doesn't mask icons, so it must be
// pre-rounded). Run: dart run tool/make_round_logo.dart
import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

void main() {
  final src = img.decodePng(File('assets/logo/kaal_logo.png').readAsBytesSync());
  if (src == null) {
    stderr.writeln('could not decode assets/logo/kaal_logo.png');
    exit(1);
  }
  // Center-crop to a square, then ensure an alpha channel.
  final size = math.min(src.width, src.height);
  final sq = img
      .copyCrop(src,
          x: (src.width - size) ~/ 2,
          y: (src.height - size) ~/ 2,
          width: size,
          height: size)
      .convert(numChannels: 4);

  final r = size / 2.0;
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final dx = x + 0.5 - r;
      final dy = y + 0.5 - r;
      final dist = math.sqrt(dx * dx + dy * dy);
      double cover;
      if (dist <= r - 1.0) {
        cover = 1.0;
      } else if (dist >= r) {
        cover = 0.0;
      } else {
        cover = r - dist; // 1px antialiased edge
      }
      final p = sq.getPixel(x, y);
      sq.setPixelRgba(x, y, p.r, p.g, p.b, (p.a * cover).round());
    }
  }

  File('assets/logo/kaal_logo_round.png')
      .writeAsBytesSync(img.encodePng(sq));
  stdout.writeln('wrote assets/logo/kaal_logo_round.png (${size}x$size)');
}
