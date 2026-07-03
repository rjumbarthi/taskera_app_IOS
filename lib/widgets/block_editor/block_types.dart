import 'package:flutter/material.dart';

import '../../data/models/note_block.dart';

/// Descriptor for a block type shown in the slash menu and the "turn into" menu.
class BlockTypeDesc {
  final BlockType type;
  final String label;
  final String hint;
  final IconData icon;
  final List<String> keywords;
  const BlockTypeDesc(this.type, this.label, this.hint, this.icon, this.keywords);
}

const kBlockTypeMenu = <BlockTypeDesc>[
  BlockTypeDesc(BlockType.paragraph, 'Text', 'Plain paragraph',
      Icons.notes_rounded, ['text', 'paragraph', 'p']),
  BlockTypeDesc(BlockType.heading1, 'Heading 1', 'Big section heading',
      Icons.title_rounded, ['h1', 'heading', 'title', 'big']),
  BlockTypeDesc(BlockType.heading2, 'Heading 2', 'Medium heading',
      Icons.title_rounded, ['h2', 'heading', 'subtitle']),
  BlockTypeDesc(BlockType.heading3, 'Heading 3', 'Small heading',
      Icons.title_rounded, ['h3', 'heading']),
  BlockTypeDesc(BlockType.bulleted, 'Bulleted list', 'Simple bullet point',
      Icons.format_list_bulleted_rounded, ['bullet', 'list', 'ul', 'unordered']),
  BlockTypeDesc(BlockType.numbered, 'Numbered list', 'List with numbers',
      Icons.format_list_numbered_rounded, ['number', 'ordered', 'ol', 'list']),
  BlockTypeDesc(BlockType.todo, 'To-do', 'Checkbox task',
      Icons.check_box_outlined, ['todo', 'task', 'checkbox', 'check']),
  BlockTypeDesc(BlockType.quote, 'Quote', 'Callout a quotation',
      Icons.format_quote_rounded, ['quote', 'blockquote']),
  BlockTypeDesc(BlockType.callout, 'Callout', 'Highlighted note',
      Icons.lightbulb_outline_rounded, ['callout', 'highlight', 'info', 'note']),
  BlockTypeDesc(BlockType.code, 'Code', 'Monospaced code block',
      Icons.code_rounded, ['code', 'snippet', 'mono']),
  BlockTypeDesc(BlockType.divider, 'Divider', 'Horizontal rule',
      Icons.horizontal_rule_rounded, ['divider', 'hr', 'line', 'separator']),
];

BlockTypeDesc descFor(BlockType type) =>
    kBlockTypeMenu.firstWhere((d) => d.type == type);
