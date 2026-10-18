import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/note_block.dart';
import '../../theme/taskera_colors.dart';
import '../../util/input_limits.dart';
import 'block_types.dart';
import '../../theme/taskera_theme.dart';

/// A Notion-style block editor.
///
/// Operates on a [BlockDocument] and reports every edit through [onChanged].
/// Designed to live inside an outer scroll view (uses `shrinkWrap` internally),
/// so the host screen owns scrolling.
class BlockEditor extends StatefulWidget {
  final BlockDocument document;
  final ValueChanged<BlockDocument> onChanged;
  final TaskEraColors colors;
  final String hintText;

  const BlockEditor({
    super.key,
    required this.document,
    required this.onChanged,
    required this.colors,
    this.hintText = "Type '/' for commands…",
  });

  @override
  State<BlockEditor> createState() => _BlockEditorState();
}

class _BlockCtl {
  final NoteBlock block;
  final TextEditingController text;
  final FocusNode focus;
  final LayerLink link = LayerLink();
  _BlockCtl(this.block)
      : text = TextEditingController(text: block.text),
        focus = FocusNode();

  void dispose() {
    text.dispose();
    focus.dispose();
  }
}

class _BlockEditorState extends State<BlockEditor> {
  late List<_BlockCtl> _ctls;
  OverlayEntry? _slashEntry;
  int? _slashIndex;

  @override
  void initState() {
    super.initState();
    _ctls = widget.document.blocks.map(_makeCtl).toList();
    if (_ctls.isEmpty) _ctls = [_makeCtl(NoteBlock(id: newBlockId()))];
  }

  _BlockCtl _makeCtl(NoteBlock b) {
    final c = _BlockCtl(b);
    c.focus.addListener(() {
      if (mounted) setState(() {}); // toggle gutter chrome on focus change
    });
    return c;
  }

  @override
  void dispose() {
    _removeSlash();
    for (final c in _ctls) {
      c.dispose();
    }
    super.dispose();
  }

  void _emit() {
    widget.onChanged(BlockDocument(_ctls.map((c) => c.block).toList()));
  }

  // ── Structural edits ──────────────────────────────────────────────────────

  void _focusBlock(int index, {int? offset}) {
    if (index < 0 || index >= _ctls.length) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (index >= _ctls.length) return;
      final c = _ctls[index];
      c.focus.requestFocus();
      final o = offset ?? c.text.text.length;
      c.text.selection = TextSelection.collapsed(offset: o.clamp(0, c.text.text.length));
    });
  }

  void _handleEnter(int i, String value) {
    _removeSlash();
    final ctl = _ctls[i];
    final segments = value.split('\n');
    final before = segments.first;
    final rest = segments.sublist(1);

    // Pressing Enter on an empty list/todo item exits the list.
    if (before.isEmpty && rest.length == 1 && rest.first.isEmpty &&
        ctl.block.type.continuesOnEnter) {
      setState(() {
        ctl.block.type = BlockType.paragraph;
        ctl.text.text = '';
      });
      _emit();
      _focusBlock(i, offset: 0);
      return;
    }

    setState(() {
      ctl.block.text = before;
      ctl.text.text = before;
      final inheritType =
          ctl.block.type.continuesOnEnter ? ctl.block.type : BlockType.paragraph;
      var insertAt = i;
      for (final seg in rest) {
        insertAt++;
        _ctls.insert(
          insertAt,
          _makeCtl(NoteBlock(
            id: newBlockId(),
            type: inheritType,
            text: seg,
            indent: ctl.block.indent,
          )),
        );
      }
    });
    _emit();
    _focusBlock(i + rest.length, offset: rest.isEmpty ? null : 0);
  }

  /// Returns true if a merge happened.
  bool _mergeWithPrevious(int i) {
    if (i == 0) return false;
    final prev = _ctls[i - 1];
    final cur = _ctls[i];
    if (prev.block.type == BlockType.divider) {
      // Just remove the divider above.
      setState(() {
        _ctls.removeAt(i - 1).dispose();
      });
      _emit();
      _focusBlock(i - 1, offset: 0);
      return true;
    }
    final joinOffset = prev.text.text.length;
    setState(() {
      prev.block.text = prev.block.text + cur.block.text;
      prev.text.text = prev.block.text;
      _ctls.removeAt(i).dispose();
    });
    _emit();
    _focusBlock(i - 1, offset: joinOffset);
    return true;
  }

  void _setIndent(int i, int delta) {
    final b = _ctls[i].block;
    final next = (b.indent + delta).clamp(0, 6);
    if (next == b.indent) return;
    setState(() => b.indent = next);
    _emit();
  }

  void _setType(int i, BlockType type) {
    setState(() {
      final b = _ctls[i].block;
      b.type = type;
      if (type == BlockType.divider) {
        b.text = '';
        _ctls[i].text.text = '';
      }
    });
    _emit();
    if (type != BlockType.divider) _focusBlock(i);
  }

  void _insertBelow(int i) {
    _removeSlash();
    setState(() {
      _ctls.insert(i + 1, _makeCtl(NoteBlock(id: newBlockId())));
    });
    _emit();
    _focusBlock(i + 1, offset: 0);
  }

  void _duplicate(int i) {
    final b = _ctls[i].block;
    setState(() {
      _ctls.insert(
        i + 1,
        _makeCtl(NoteBlock(
          id: newBlockId(),
          type: b.type,
          text: b.text,
          checked: b.checked,
          indent: b.indent,
        )),
      );
    });
    _emit();
  }

  void _delete(int i) {
    if (_ctls.length == 1) {
      // Never leave the document empty — reset the sole block.
      setState(() {
        _ctls[0].block
          ..type = BlockType.paragraph
          ..text = ''
          ..checked = false
          ..indent = 0;
        _ctls[0].text.text = '';
      });
    } else {
      setState(() => _ctls.removeAt(i).dispose());
    }
    _emit();
  }

  // ── Text change handling ────────────────────────────────────────────────

  static const _mdPrefixes = <String, BlockType>{
    '### ': BlockType.heading3,
    '## ': BlockType.heading2,
    '# ': BlockType.heading1,
    '- ': BlockType.bulleted,
    '* ': BlockType.bulleted,
    '1. ': BlockType.numbered,
    '[] ': BlockType.todo,
    '[ ] ': BlockType.todo,
    '> ': BlockType.quote,
    '``` ': BlockType.code,
    '"" ': BlockType.quote,
  };

  bool _applyMarkdown(int i, String value) {
    final ctl = _ctls[i];
    if (ctl.block.type != BlockType.paragraph) return false;
    for (final entry in _mdPrefixes.entries) {
      if (value.startsWith(entry.key) && value.length >= entry.key.length) {
        final rest = value.substring(entry.key.length);
        setState(() {
          ctl.block.type = entry.value;
          ctl.block.text = rest;
          ctl.text.value = TextEditingValue(
            text: rest,
            selection: const TextSelection.collapsed(offset: 0),
          );
        });
        _emit();
        return true;
      }
    }
    return false;
  }

  void _onTextChanged(int i, String value) {
    if (value.contains('\n')) {
      _handleEnter(i, value);
      return;
    }
    if (_applyMarkdown(i, value)) return;
    _ctls[i].block.text = value;
    _maybeSlash(i, value);
    _emit();
  }

  // ── Slash command menu ────────────────────────────────────────────────────

  void _maybeSlash(int i, String value) {
    if (value == '/') {
      _openSlash(i);
    } else if (_slashIndex == i && !value.startsWith('/')) {
      _removeSlash();
    } else if (_slashIndex == i) {
      _slashEntry?.markNeedsBuild();
    }
  }

  void _openSlash(int i) {
    _removeSlash();
    _slashIndex = i;
    _slashEntry = OverlayEntry(builder: (_) => _buildSlashOverlay(i));
    Overlay.of(context).insert(_slashEntry!);
  }

  void _removeSlash() {
    _slashEntry?.remove();
    _slashEntry = null;
    _slashIndex = null;
  }

  void _pickSlash(int i, BlockType type) {
    _removeSlash();
    setState(() {
      final ctl = _ctls[i];
      ctl.block.type = type;
      ctl.block.text = '';
      ctl.text.text = '';
    });
    _emit();
    if (type != BlockType.divider) _focusBlock(i, offset: 0);
  }

  Widget _buildSlashOverlay(int i) {
    final colors = widget.colors;
    final query = _ctls[i].text.text.replaceFirst('/', '').toLowerCase().trim();
    final items = kBlockTypeMenu.where((d) {
      if (query.isEmpty) return true;
      return d.label.toLowerCase().contains(query) ||
          d.keywords.any((k) => k.contains(query));
    }).toList();

    return Stack(
      children: [
        // Outside-tap catcher.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _removeSlash,
          ),
        ),
        CompositedTransformFollower(
          link: _ctls[i].link,
          showWhenUnlinked: false,
          offset: const Offset(0, 30),
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 240,
                constraints: const BoxConstraints(maxHeight: 280),
                decoration: BoxDecoration(
                  color: colors.surf,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 0.5, color: colors.bdr),
                  boxShadow: const [
                    BoxShadow(color: Color(0x40000000), blurRadius: 24, offset: Offset(0, 8)),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: items.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text('No matches',
                            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3)),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shrinkWrap: true,
                        children: [
                          for (final d in items)
                            _SlashItem(desc: d, colors: colors, onTap: () => _pickSlash(i, d.type)),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Key handling ────────────────────────────────────────────────────────

  KeyEventResult _onKey(int i, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
    final ctl = _ctls[i];
    final key = e.logicalKey;

    if (key == LogicalKeyboardKey.tab) {
      _setIndent(i, HardwareKeyboard.instance.isShiftPressed ? -1 : 1);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.escape && _slashIndex == i) {
      _removeSlash();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.backspace) {
      final sel = ctl.text.selection;
      final atStart = sel.isValid && sel.isCollapsed && sel.baseOffset == 0;
      if (atStart) {
        if (ctl.block.indent > 0) {
          _setIndent(i, -1);
          return KeyEventResult.handled;
        }
        if (ctl.block.type != BlockType.paragraph) {
          _setType(i, BlockType.paragraph);
          return KeyEventResult.handled;
        }
        return _mergeWithPrevious(i)
            ? KeyEventResult.handled
            : KeyEventResult.ignored;
      }
    }
    return KeyEventResult.ignored;
  }

  // ── Rendering ─────────────────────────────────────────────────────────────

  int _numberFor(int i) {
    final indent = _ctls[i].block.indent;
    var n = 1;
    for (var k = i - 1; k >= 0; k--) {
      final b = _ctls[k].block;
      if (b.indent < indent) break;
      if (b.indent == indent) {
        if (b.type == BlockType.numbered) {
          n++;
        } else {
          break;
        }
      }
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: _ctls.length,
      onReorderItem: (oldIndex, newIndex) {
        setState(() {
          final c = _ctls.removeAt(oldIndex);
          _ctls.insert(newIndex, c);
        });
        _emit();
      },
      proxyDecorator: (child, index, animation) => Material(
        color: Colors.transparent,
        child: child,
      ),
      itemBuilder: (context, i) => _buildRow(context, i),
    );
  }

  Widget _buildRow(BuildContext context, int i) {
    final colors = widget.colors;
    final ctl = _ctls[i];
    final b = ctl.block;
    final active = ctl.focus.hasFocus;

    return Padding(
      key: ValueKey(b.id),
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gutter: + and drag handle (visible when the block is focused).
          SizedBox(
            width: 40,
            child: Opacity(
              opacity: active ? 1 : 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _GutterBtn(
                    icon: Icons.add_rounded,
                    colors: colors,
                    onTap: () => _insertBelow(i),
                  ),
                  ReorderableDragStartListener(
                    index: i,
                    child: _GutterBtn(
                      icon: Icons.drag_indicator_rounded,
                      colors: colors,
                      onTap: () => _showBlockMenu(i),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: b.indent * 22.0),
          Expanded(child: _buildContent(i)),
        ],
      ),
    );
  }

  Widget _buildContent(int i) {
    final colors = widget.colors;
    final ctl = _ctls[i];
    final b = ctl.block;

    if (b.type == BlockType.divider) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 1,
        color: colors.bdr,
      );
    }

    final marker = _marker(i);
    final field = CompositedTransformTarget(
      link: ctl.link,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: (_, e) => _onKey(i, e),
        child: TextField(
          controller: ctl.text,
          focusNode: ctl.focus,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          inputFormatters: maxLen(kMaxLongText),
          onChanged: (v) => _onTextChanged(i, v),
          style: _styleFor(b, colors),
          cursorColor: TaskEraColors.acc,
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 3),
            hintText: i == 0 && _ctls.length == 1 ? widget.hintText : null,
            hintStyle: TextStyle(
                fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, color: colors.ink3, height: 1.5),
          ),
        ),
      ),
    );

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (marker != null) ...[marker, const SizedBox(width: 8)],
        Expanded(child: field),
      ],
    );

    // Decorated wrappers for quote / callout / code.
    switch (b.type) {
      case BlockType.quote:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(width: 3, color: colors.ink3)),
          ),
          child: row,
        );
      case BlockType.callout:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: const Color(0x120A84FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 0.5, color: const Color(0x330A84FF)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 8),
              Expanded(child: field),
            ],
          ),
        );
      case BlockType.code:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: colors.surf2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 0.5, color: colors.bdr),
          ),
          child: field,
        );
      default:
        return row;
    }
  }

  Widget? _marker(int i) {
    final colors = widget.colors;
    final b = _ctls[i].block;
    switch (b.type) {
      case BlockType.bulleted:
        return Padding(
          padding: const EdgeInsets.only(top: 9),
          child: Container(
            width: 5, height: 5,
            decoration: BoxDecoration(color: colors.ink2, shape: BoxShape.circle),
          ),
        );
      case BlockType.numbered:
        return Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text('${_numberFor(i)}.',
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, color: colors.ink2, height: 1.5)),
        );
      case BlockType.todo:
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: GestureDetector(
            onTap: () {
              setState(() => b.checked = !b.checked);
              _emit();
            },
            child: Container(
              width: 17, height: 17,
              decoration: BoxDecoration(
                color: b.checked ? TaskEraColors.acc : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    width: 1.2, color: b.checked ? TaskEraColors.acc : colors.ink3),
              ),
              child: b.checked
                  ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                  : null,
            ),
          ),
        );
      default:
        return null;
    }
  }

  TextStyle _styleFor(NoteBlock b, TaskEraColors colors) {
    final struck = b.type == BlockType.todo && b.checked;
    final base = TextStyle(
      fontFamily: b.type == BlockType.code ? 'monospace' : 'Inter',
      color: struck ? colors.ink3 : colors.ink,
      decoration: struck ? TextDecoration.lineThrough : null,
    );
    switch (b.type) {
      case BlockType.heading1:
        return base.copyWith(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3);
      case BlockType.heading2:
        return base.copyWith(fontSize: 18, fontWeight: FontWeight.w700, height: 1.35);
      case BlockType.heading3:
        return base.copyWith(fontSize: 15, fontWeight: FontWeight.w700, height: 1.4);
      case BlockType.quote:
        return base.copyWith(fontSize: 14, fontStyle: FontStyle.italic, height: 1.55);
      case BlockType.code:
        return base.copyWith(fontSize: 13, height: 1.5);
      default:
        return base.copyWith(fontSize: 14, height: 1.55);
    }
  }

  Future<void> _showBlockMenu(int i) async {
    final colors = widget.colors;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.surf,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4, decoration: BoxDecoration(
                color: colors.bdr, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 8),
            _sheetRow(ctx, colors, Icons.swap_horiz_rounded, 'Turn into…', 'turn'),
            _sheetRow(ctx, colors, Icons.copy_rounded, 'Duplicate', 'dup'),
            _sheetRow(ctx, colors, Icons.delete_outline_rounded, 'Delete', 'del',
                danger: true),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted) return;
    switch (action) {
      case 'turn':
        _showTurnInto(i);
        break;
      case 'dup':
        _duplicate(i);
        break;
      case 'del':
        _delete(i);
        break;
    }
  }

  Future<void> _showTurnInto(int i) async {
    final colors = widget.colors;
    final type = await showModalBottomSheet<BlockType>(
      context: context,
      backgroundColor: colors.surf,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Text('Turn into',
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink3)),
            const SizedBox(height: 6),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final d in kBlockTypeMenu)
                    _SlashItem(desc: d, colors: colors, onTap: () => Navigator.pop(ctx, d.type)),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (type != null && mounted) _setType(i, type);
  }

  Widget _sheetRow(BuildContext ctx, TaskEraColors colors, IconData icon, String label,
      String value, {bool danger = false}) {
    final color = danger ? const Color(0xFFFF453A) : colors.ink;
    return InkWell(
      onTap: () => Navigator.pop(ctx, value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 15, color: color)),
          ],
        ),
      ),
    );
  }
}

class _GutterBtn extends StatelessWidget {
  final IconData icon;
  final TaskEraColors colors;
  final VoidCallback onTap;
  const _GutterBtn({required this.icon, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Icon(icon, size: 17, color: colors.ink3),
      ),
    );
  }
}

class _SlashItem extends StatelessWidget {
  final BlockTypeDesc desc;
  final TaskEraColors colors;
  final VoidCallback onTap;
  const _SlashItem({required this.desc, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: colors.surf2,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(width: 0.5, color: colors.bdr),
              ),
              child: Icon(desc.icon, size: 16, color: colors.ink2),
            ),
            const SizedBox(width: 11),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(desc.label,
                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13.5, fontWeight: FontWeight.w600, color: colors.ink, height: 1.2)),
                Text(desc.hint,
                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3, height: 1.3)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
