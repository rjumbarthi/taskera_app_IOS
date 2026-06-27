// Audits seed_data.dart: every _s([...]) array must have exactly 19 string
// elements (one per language). Reports arrays with the wrong count — those
// shift languages and cause wrong-language text (e.g. Chinese where another
// language should be). Run: dart run tool/check_seed_langs.dart
import 'dart:io';

void main() {
  final src = File('lib/data/seed_data.dart').readAsStringSync();

  // Track byte offset → line number.
  final lineStarts = <int>[0];
  for (var i = 0; i < src.length; i++) {
    if (src[i] == '\n') lineStarts.add(i + 1);
  }
  int lineOf(int off) {
    var lo = 0, hi = lineStarts.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (lineStarts[mid] <= off) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo + 1;
  }

  var idx = 0;
  var problems = 0;
  while (true) {
    final start = src.indexOf('_s([', idx);
    if (start < 0) break;
    // Walk from the '[' counting elements at array depth 0.
    var i = start + 3; // points at '['
    var depth = 0;
    var inStr = false;
    var count = 0;
    var sawAny = false;
    for (; i < src.length; i++) {
      final ch = src[i];
      if (inStr) {
        if (ch == '\\') {
          i++; // skip escaped char
        } else if (ch == "'") {
          inStr = false;
        }
        continue;
      }
      if (ch == "'") {
        inStr = true;
        if (depth == 1) sawAny = true;
        continue;
      }
      if (ch == '[') {
        depth++;
      } else if (ch == ']') {
        depth--;
        if (depth == 0) break;
      } else if (ch == ',' && depth == 1) {
        count++;
      }
    }
    final elements = sawAny ? count + 1 : 0;
    if (elements != 19) {
      problems++;
      stdout.writeln('Line ${lineOf(start)}: $elements elements (expected 19)');
    }
    idx = i + 1;
  }
  stdout.writeln(problems == 0
      ? 'All _s([...]) arrays have 19 elements. ✓'
      : '$problems array(s) with wrong element count.');
}
