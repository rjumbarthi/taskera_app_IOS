import 'package:flutter/services.dart';

/// Shared input length caps. Enforced as hard [LengthLimitingTextInputFormatter]s
/// so a giant paste can't bloat the local DB or the cloud sync payload. Values
/// are generous for real use but bounded.
const int kMaxTitle = 200; // task/goal/habit/note/database titles
const int kMaxCell = 2000; // a single database cell value
const int kMaxSearch = 100; // search query
const int kMaxLongText = 10000; // note body block, feedback, long free text

/// Convenience: `inputFormatters: maxLen(kMaxTitle)`.
List<TextInputFormatter> maxLen(int n) => [LengthLimitingTextInputFormatter(n)];
