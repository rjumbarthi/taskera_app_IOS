// Generates white-silhouette PNG notification icons (the Kaal Focus compass) at
// all densities. flutter_local_notifications needs a PNG (not a vector) for the
// small icon. Run: dart run tool/make_notif_icon.dart
import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

// Base design is 24dp. Strokes are 1.6 wide.
const _lines = <List<double>>[
  [12, 1.5, 12, 6.5],
  [12, 17.5, 12, 22.5],
  [1.5, 12, 6.5, 12],
  [17.5, 12, 22.5, 12],
  [4.6, 4.6, 8.1, 8.1],
  [15.9, 15.9, 19.4, 19.4],
  [19.4, 4.6, 15.9, 8.1],
  [4.6, 19.4, 8.1, 15.9],
];

double _distToSeg(double px, double py, double ax, double ay, double bx, double by) {
  final dx = bx - ax, dy = by - ay;
  final len2 = dx * dx + dy * dy;
  var t = len2 == 0 ? 0.0 : ((px - ax) * dx + (py - ay) * dy) / len2;
  t = t.clamp(0.0, 1.0);
  final cx = ax + t * dx, cy = ay + t * dy;
  return math.sqrt((px - cx) * (px - cx) + (py - cy) * (py - cy));
}

void buildAt(int size, String dir) {
  final s = size / 24.0;
  final c = size / 2.0;
  final half = 1.6 * s / 2.0; // half stroke width
  final im = img.Image(width: size, height: size, numChannels: 4);

  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final px = x + 0.5, py = y + 0.5;
      final dist = math.sqrt((px - c) * (px - c) + (py - c) * (py - c));

      var d = double.infinity; // distance to nearest white feature edge
      // rings (stroked)
      d = math.min(d, (dist - 8 * s).abs() - half);
      d = math.min(d, (dist - 2.5 * s).abs() - half);
      // center dot (filled r=1)
      d = math.min(d, dist - 1.0 * s);
      // radial ticks
      for (final l in _lines) {
        d = math.min(d, _distToSeg(px, py, l[0] * s, l[1] * s, l[2] * s, l[3] * s) - half);
      }
      // d<=0 inside; antialias a 1px edge
      double a;
      if (d <= -0.5) {
        a = 1.0;
      } else if (d >= 0.5) {
        a = 0.0;
      } else {
        a = 0.5 - d;
      }
      if (a > 0) im.setPixelRgba(x, y, 255, 255, 255, (a * 255).round());
    }
  }
  final outDir = Directory('android/app/src/main/res/$dir')..createSync(recursive: true);
  File('${outDir.path}/ic_stat_focus.png').writeAsBytesSync(img.encodePng(im));
  stdout.writeln('wrote $dir/ic_stat_focus.png (${size}px)');
}

void main() {
  buildAt(24, 'drawable-mdpi');
  buildAt(36, 'drawable-hdpi');
  buildAt(48, 'drawable-xhdpi');
  buildAt(72, 'drawable-xxhdpi');
  buildAt(96, 'drawable-xxxhdpi');
}
