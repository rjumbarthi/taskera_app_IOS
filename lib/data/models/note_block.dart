import 'dart:convert';

/// Notion-style block types supported by the TaskEra block editor (v1).
enum BlockType {
  paragraph,
  heading1,
  heading2,
  heading3,
  bulleted,
  numbered,
  todo,
  quote,
  callout,
  code,
  divider,
}

extension BlockTypeId on BlockType {
  /// Stable string id used in the JSON payload. Never rename these — they are
  /// persisted in `Notes.body`.
  String get id => switch (this) {
        BlockType.paragraph => 'p',
        BlockType.heading1 => 'h1',
        BlockType.heading2 => 'h2',
        BlockType.heading3 => 'h3',
        BlockType.bulleted => 'ul',
        BlockType.numbered => 'ol',
        BlockType.todo => 'todo',
        BlockType.quote => 'quote',
        BlockType.callout => 'callout',
        BlockType.code => 'code',
        BlockType.divider => 'hr',
      };

  static BlockType fromId(String id) => switch (id) {
        'h1' => BlockType.heading1,
        'h2' => BlockType.heading2,
        'h3' => BlockType.heading3,
        'ul' => BlockType.bulleted,
        'ol' => BlockType.numbered,
        'todo' => BlockType.todo,
        'quote' => BlockType.quote,
        'callout' => BlockType.callout,
        'code' => BlockType.code,
        'hr' => BlockType.divider,
        _ => BlockType.paragraph,
      };

  /// Blocks that carry no editable text (rendered as a standalone element).
  bool get isVoid => this == BlockType.divider;

  /// List-like blocks continue their own type when the user presses Enter.
  bool get continuesOnEnter =>
      this == BlockType.bulleted ||
      this == BlockType.numbered ||
      this == BlockType.todo;
}

/// A single editable block within a note document.
class NoteBlock {
  final String id;
  BlockType type;
  String text;
  bool checked; // todo blocks
  int indent; // nesting level (0..)

  NoteBlock({
    required this.id,
    this.type = BlockType.paragraph,
    this.text = '',
    this.checked = false,
    this.indent = 0,
  });

  NoteBlock copyWith({BlockType? type, String? text, bool? checked, int? indent}) =>
      NoteBlock(
        id: id,
        type: type ?? this.type,
        text: text ?? this.text,
        checked: checked ?? this.checked,
        indent: indent ?? this.indent,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        't': type.id,
        if (text.isNotEmpty) 'x': text,
        if (checked) 'c': true,
        if (indent > 0) 'i': indent,
      };

  factory NoteBlock.fromJson(Map<String, dynamic> j, {required String fallbackId}) =>
      NoteBlock(
        id: (j['id'] as String?) ?? fallbackId,
        type: BlockTypeId.fromId((j['t'] as String?) ?? 'p'),
        text: (j['x'] as String?) ?? '',
        checked: (j['c'] as bool?) ?? false,
        indent: (j['i'] as int?) ?? 0,
      );
}

/// An ordered list of blocks — the content model behind a note.
///
/// Serializes to a compact JSON envelope tagged with `kb:1`. Decoding is
/// tolerant: legacy plain-text note bodies (or anything that isn't our
/// envelope) are converted into paragraph blocks split on newlines, so no
/// existing note is ever lost when the editor is upgraded.
class BlockDocument {
  final List<NoteBlock> blocks;
  BlockDocument(this.blocks);

  factory BlockDocument.empty() =>
      BlockDocument([NoteBlock(id: _genId(0))]);

  bool get isEffectivelyEmpty =>
      blocks.every((b) => b.type != BlockType.divider && b.text.trim().isEmpty);

  String encode() => jsonEncode({
        'kb': 1,
        'blocks': blocks.map((b) => b.toJson()).toList(),
      });

  /// Flattened plain text — used for AI scan, previews, and search indexing.
  String get plainText => blocks
      .where((b) => b.type != BlockType.divider)
      .map((b) => b.text)
      .join('\n');

  static BlockDocument decode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return BlockDocument.empty();

    // Try the block envelope first.
    if (trimmed.startsWith('{')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map && decoded['kb'] == 1 && decoded['blocks'] is List) {
          final list = decoded['blocks'] as List;
          final blocks = <NoteBlock>[];
          for (var i = 0; i < list.length; i++) {
            final item = list[i];
            if (item is Map<String, dynamic>) {
              blocks.add(NoteBlock.fromJson(item, fallbackId: _genId(i)));
            }
          }
          if (blocks.isEmpty) return BlockDocument.empty();
          return BlockDocument(blocks);
        }
      } catch (_) {
        // Fall through to plain-text handling.
      }
    }

    // Legacy plain-text body → one paragraph per line.
    final lines = raw.split('\n');
    final blocks = <NoteBlock>[];
    for (var i = 0; i < lines.length; i++) {
      blocks.add(NoteBlock(id: _genId(i), text: lines[i]));
    }
    if (blocks.isEmpty) return BlockDocument.empty();
    return BlockDocument(blocks);
  }

  /// Decode [raw] and return its flattened plain text — for list previews,
  /// search, and AI summaries that shouldn't see the block JSON envelope.
  static String plainTextOf(String raw) => decode(raw).plainText;

  static int _idCounter = 0;
  static String _genId(int seed) =>
      'b${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}_$seed';
}

/// Convenience for generating a fresh block id at runtime (editor use).
String newBlockId() => BlockDocument._genId(0);
