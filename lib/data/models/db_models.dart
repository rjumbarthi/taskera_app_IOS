import 'dart:convert';
import 'package:flutter/material.dart';

import '../database.dart' show DbProperty, DbRow;

/// Property (column) types supported by Kaal databases (v1).
enum DbPropType { text, number, select, multiSelect, date, checkbox, url }

extension DbPropTypeMeta on DbPropType {
  String get id => switch (this) {
        DbPropType.text => 'text',
        DbPropType.number => 'number',
        DbPropType.select => 'select',
        DbPropType.multiSelect => 'multiSelect',
        DbPropType.date => 'date',
        DbPropType.checkbox => 'checkbox',
        DbPropType.url => 'url',
      };

  String get label => switch (this) {
        DbPropType.text => 'Text',
        DbPropType.number => 'Number',
        DbPropType.select => 'Select',
        DbPropType.multiSelect => 'Multi-select',
        DbPropType.date => 'Date',
        DbPropType.checkbox => 'Checkbox',
        DbPropType.url => 'URL',
      };

  IconData get icon => switch (this) {
        DbPropType.text => Icons.notes_rounded,
        DbPropType.number => Icons.tag_rounded,
        DbPropType.select => Icons.expand_circle_down_outlined,
        DbPropType.multiSelect => Icons.check_circle_outline_rounded,
        DbPropType.date => Icons.calendar_today_rounded,
        DbPropType.checkbox => Icons.check_box_outlined,
        DbPropType.url => Icons.link_rounded,
      };

  bool get isSelectLike =>
      this == DbPropType.select || this == DbPropType.multiSelect;

  static DbPropType fromId(String id) => switch (id) {
        'number' => DbPropType.number,
        'select' => DbPropType.select,
        'multiSelect' => DbPropType.multiSelect,
        'date' => DbPropType.date,
        'checkbox' => DbPropType.checkbox,
        'url' => DbPropType.url,
        _ => DbPropType.text,
      };
}

DbPropType propTypeOf(DbProperty p) => DbPropTypeMeta.fromId(p.type);

/// Palette for select/status options. Kept as translucent tints so options read
/// well over the wallpaper (matches Kaal's tint-not-fill rule).
const kOptionColors = <Color>[
  Color(0xFF8E8E93), // grey
  Color(0xFF0A84FF), // blue
  Color(0xFF30D158), // green
  Color(0xFFFF9F0A), // orange
  Color(0xFFFF375F), // red/pink
  Color(0xFFBF5AF2), // purple
  Color(0xFF64D2FF), // teal
  Color(0xFFFFD60A), // yellow
];

class SelectOption {
  final String name;
  final int colorIdx;
  const SelectOption(this.name, this.colorIdx);

  Color get color => kOptionColors[colorIdx.clamp(0, kOptionColors.length - 1)];

  Map<String, dynamic> toJson() => {'name': name, 'color': colorIdx};
  factory SelectOption.fromJson(Map<String, dynamic> j) =>
      SelectOption(j['name'] as String? ?? '', (j['color'] as int?) ?? 0);
}

/// Parsed view over a [DbProperty]'s `config` JSON.
class PropConfig {
  final List<SelectOption> options;
  const PropConfig(this.options);

  static PropConfig parse(DbProperty p) {
    try {
      final m = jsonDecode(p.config);
      if (m is Map && m['options'] is List) {
        return PropConfig((m['options'] as List)
            .whereType<Map<String, dynamic>>()
            .map(SelectOption.fromJson)
            .toList());
      }
    } catch (_) {}
    return const PropConfig([]);
  }

  String encode() => jsonEncode({'options': options.map((o) => o.toJson()).toList()});
}

/// Decoded cell map for a row: property id → dynamic value.
Map<String, dynamic> decodeCells(DbRow row) {
  try {
    final m = jsonDecode(row.cells);
    if (m is Map) return Map<String, dynamic>.from(m);
  } catch (_) {}
  return {};
}

String encodeCells(Map<String, dynamic> cells) => jsonEncode(cells);

/// Human-readable rendering of a raw cell value for previews/sorting.
String cellDisplay(dynamic value, DbPropType type) {
  if (value == null) return '';
  switch (type) {
    case DbPropType.multiSelect:
      if (value is List) return value.join(', ');
      return value.toString();
    case DbPropType.checkbox:
      return (value == true) ? '✓' : '';
    case DbPropType.date:
      final d = DateTime.tryParse(value.toString());
      if (d == null) return value.toString();
      return '${d.year}-${_pad2(d.month)}-${_pad2(d.day)}';
    default:
      return value.toString();
  }
}

String _pad2(int n) => n.toString().padLeft(2, '0');

int _idSeq = 0;

/// Client-side unique id for properties and rows (text primary keys).
String genDbId(String prefix) =>
    '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${_idSeq++}';
