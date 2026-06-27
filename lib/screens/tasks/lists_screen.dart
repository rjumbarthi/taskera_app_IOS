import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import '../../l10n/app_l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../data/providers/database_provider.dart';
import '../../data/providers/lists_provider.dart';
import '../../services/activity_log_service.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String _fmtDate(DateTime dt) {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

bool _datePassed(DateTime? d) =>
    d != null && d.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

// ── List create / edit sheet ──────────────────────────────────────────────────

Future<void> _showListSheet(
  BuildContext context,
  WidgetRef ref, {
  CustomList? existing,
}) async {
  final colors = KaalTheme.of(context).colors;
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final emojiCtrl = TextEditingController(text: existing?.emoji ?? '📋');
  DateTime? selectedDate = existing?.dueDate;
  String? selectedRepeat = existing?.recurrenceLabel;

  const repeats = ['Weekly', 'Monthly', 'Quarterly', 'Yearly'];

  const templates = [
    ('🛒', 'Shopping'),
    ('💳', 'Pay Bills'),
    ('🛍️', 'Wish List'),
    ('🧳', 'Packing List'),
    ('✅', 'To-Do'),
  ];

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetCtx) => StatefulBuilder(
      builder: (_, setSS) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          decoration: BoxDecoration(
            color: colors.surf,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 0.5, color: colors.bdr),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(existing == null ? 'New Checklist' : 'Edit Checklist',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: colors.ink)),
                const SizedBox(height: 10),

                // Templates (only on create)
                if (existing == null) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: templates.map((t) => GestureDetector(
                        onTap: () { setSS(() { emojiCtrl.text = t.$1; titleCtrl.text = t.$2; }); },
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                          decoration: BoxDecoration(
                            color: colors.surf2,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(width: 0.5, color: colors.bdr),
                          ),
                          child: Text('${t.$1} ${t.$2}',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink2, height: 1)),
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Emoji + Title
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: colors.surf2, borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: emojiCtrl,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20),
                        decoration: const InputDecoration(border: InputBorder.none),
                        maxLength: 2,
                        buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: titleCtrl,
                        autofocus: existing == null,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: colors.ink),
                        decoration: InputDecoration(
                          hintText: AppL10n.of(context).listNameHint,
                          hintStyle: TextStyle(fontFamily: 'Inter', color: colors.ink3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.bdr)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.bdr)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: KaalColors.acc)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: colors.surf2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Date picker row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: sheetCtx,
                          initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                        );
                        if (picked != null) setSS(() => selectedDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                        decoration: BoxDecoration(
                          color: selectedDate != null ? KaalColors.accBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 0.5, color: selectedDate != null ? const Color(0x330A84FF) : colors.bdr),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 12, color: selectedDate != null ? KaalColors.acc2 : colors.ink3),
                            const SizedBox(width: 5),
                            Text(
                              selectedDate != null ? _fmtDate(selectedDate!) : 'Add date',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: selectedDate != null ? KaalColors.acc2 : colors.ink3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (selectedDate != null) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setSS(() => selectedDate = null),
                        child: Text('×', style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: colors.ink3, height: 1)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),

                // Repeat chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: repeats.map((r) {
                      final active = selectedRepeat == r;
                      return GestureDetector(
                        onTap: () => setSS(() => selectedRepeat = active ? null : r),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                          decoration: BoxDecoration(
                            color: active ? KaalColors.accBg : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              width: 0.5,
                              color: active ? const Color(0x330A84FF) : colors.bdr,
                            ),
                          ),
                          child: Text(
                            '↻ $r',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: active ? KaalColors.acc2 : colors.ink3,
                              height: 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),

                // Confirm button
                GestureDetector(
                  onTap: () async {
                    final t = titleCtrl.text.trim();
                    if (t.isEmpty) return;
                    if (existing == null) {
                      await ref.read(appDatabaseProvider).listsDao.createList(CustomListsCompanion(
                        title: Value(t),
                        emoji: Value(emojiCtrl.text.trim().isEmpty ? '📋' : emojiCtrl.text.trim()),
                        dueDate: Value(selectedDate),
                        recurrenceLabel: Value(selectedRepeat),
                      ));
                      ref.logActivity('Checklist "$t" created', type: 'checklist');
                    } else {
                      await ref.read(appDatabaseProvider).listsDao.updateList(
                        existing.id,
                        CustomListsCompanion(
                          title: Value(t),
                          emoji: Value(emojiCtrl.text.trim().isEmpty ? '📋' : emojiCtrl.text.trim()),
                          dueDate: Value(selectedDate),
                          recurrenceLabel: Value(selectedRepeat),
                        ),
                      );
                      ref.logActivity('Checklist "$t" updated', type: 'checklist');
                    }
                    if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(12)),
                    child: Text(existing == null ? 'Create Checklist' : 'Save Changes',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = KaalTheme.of(context).colors;
    final lists  = ref.watch(listsProvider).valueOrNull ?? [];

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Row(
                children: [
                  AddBackButton(onTap: () => context.pop()),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Checklist',
                            style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
                        Text('${lists.length} lists',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: lists.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('📋', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 10),
                          Text('No checklists yet', style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: colors.ink3)),
                          const SizedBox(height: 4),
                          Text('Tap + to create one', textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                      itemCount: lists.length,
                      itemBuilder: (_, i) => _ListCard(
                        key: ValueKey(lists[i].id),
                        list: lists[i],
                        colors: colors,
                        onEdit: () => _showListSheet(context, ref, existing: lists[i]),
                        onDelete: () async {
                          await ref.read(appDatabaseProvider).listsDao.deleteList(lists[i].id);
                          ref.logActivity('Checklist "${lists[i].title}" deleted', type: 'checklist');
                        },
                      ),
                    ),
            ),
          ],
        ),
        Positioned(
          bottom: 14 + MediaQuery.paddingOf(context).bottom,
          right: 16,
          child: GestureDetector(
            onTap: () => _showListSheet(context, ref),
            child: Container(
              width: 38, height: 38,
              decoration: const BoxDecoration(
                color: KaalColors.acc,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x800A84FF), blurRadius: 14, offset: Offset(0, 4))],
              ),
              alignment: Alignment.center,
              child: const Text('+', style: TextStyle(fontFamily: 'Inter', fontSize: 22, color: Colors.white, fontWeight: FontWeight.w300, height: 1)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── List card ─────────────────────────────────────────────────────────────────

class _ListCard extends ConsumerStatefulWidget {
  final CustomList list;
  final KaalColors colors;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ListCard({
    super.key,
    required this.list,
    required this.colors,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  ConsumerState<_ListCard> createState() => _ListCardState();
}

class _ListCardState extends ConsumerState<_ListCard> {
  bool _isAdding = false;
  final _addCtrl = TextEditingController();

  static const _suggestions = [
    'Milk', 'Eggs', 'Bread', 'Butter', 'Coffee',
    'Fruits', 'Vegetables', 'Rice', 'Juice', 'Cheese',
  ];

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  Future<void> _addItem(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    await ref.read(appDatabaseProvider).listsDao.addItem(
      CustomListItemsCompanion(listId: Value(widget.list.id), content: Value(t)),
    );
    ref.logActivity('Checklist item "$t" added', type: 'checklist');
    _addCtrl.clear();
  }

  Future<void> _duplicate(List<CustomListItem> items) async {
    if (!mounted) return;
    final colors = widget.colors;

    // Ask for a new date via a bottom sheet
    DateTime? newDate;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8C000000),
      isScrollControlled: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            decoration: BoxDecoration(
              color: colors.surf,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 0.5, color: colors.bdr),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Duplicate "${widget.list.title}"',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: colors.ink)),
                const SizedBox(height: 4),
                Text('All items will be reset. Pick a date for the new list.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3)),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: sheetCtx,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                    );
                    if (picked != null) setSS(() => newDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: newDate != null ? KaalColors.accBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 0.5, color: newDate != null ? const Color(0x330A84FF) : colors.bdr),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: newDate != null ? KaalColors.acc2 : colors.ink3),
                        const SizedBox(width: 8),
                        Text(
                          newDate != null ? _fmtDate(newDate!) : 'Pick a date',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: newDate != null ? KaalColors.acc2 : colors.ink3),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () async {
                    if (newDate == null) return;
                    final d = newDate!;
                    Navigator.pop(sheetCtx);
                    final newId = await ref.read(appDatabaseProvider).listsDao.createList(
                      CustomListsCompanion(
                        title: Value(widget.list.title),
                        emoji: Value(widget.list.emoji),
                        dueDate: Value(d),
                      ),
                    );
                    for (final item in items) {
                      await ref.read(appDatabaseProvider).listsDao.addItem(
                        CustomListItemsCompanion(listId: Value(newId), content: Value(item.content)),
                      );
                    }
                    ref.logActivity('Checklist "${widget.list.title}" duplicated', type: 'checklist');
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: newDate != null ? KaalColors.acc : colors.surf2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Duplicate',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700,
                            color: newDate != null ? Colors.white : colors.ink3)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors      = widget.colors;
    final list        = widget.list;
    final items       = ref.watch(listItemsProvider(list.id)).valueOrNull ?? [];
    final doneCount   = items.where((i) => i.isDone).length;
    final showDuplicate = doneCount > 0 || _datePassed(list.dueDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(list.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(list.title,
                          style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: colors.ink)),
                    ),
                    // Edit icon
                    GestureDetector(
                      onTap: widget.onEdit,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.edit_outlined, size: 14, color: colors.ink3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (items.isNotEmpty)
                      Text('$doneCount/${items.length}',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 11,
                        color: _datePassed(list.dueDate) ? KaalColors.warn : colors.ink3),
                    const SizedBox(width: 4),
                    Text(
                      list.dueDate != null ? _fmtDate(list.dueDate!) : 'No date',
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 11, height: 1,
                        color: _datePassed(list.dueDate) ? KaalColors.warn : colors.ink3,
                      ),
                    ),
                    const Spacer(),
                    if (showDuplicate)
                      GestureDetector(
                        onTap: () => _duplicate(items),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.copy_outlined, size: 11, color: colors.successFg),
                            const SizedBox(width: 3),
                            Text('Duplicate',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.successFg, height: 1)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 0.5, color: colors.bdr),

          // Item chips
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: items.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('No items yet',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3)),
                  )
                : Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: items.map((item) => _ItemChip(
                          item: item,
                          colors: colors,
                          onToggle: () async {
                            final nowDone = !item.isDone;
                            await ref.read(appDatabaseProvider).listsDao.toggleItem(item.id, nowDone);
                            ref.logActivity(
                                nowDone ? 'Checklist item "${item.content}" marked done'
                                        : 'Checklist item "${item.content}" marked undone',
                                type: 'checklist');
                          },
                          onDelete: () async {
                            await ref.read(appDatabaseProvider).listsDao.deleteItem(item.id);
                            ref.logActivity('Checklist item "${item.content}" deleted', type: 'checklist');
                          },
                        )).toList(),
                  ),
          ),

          // Inline add
          if (_isAdding) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 0.5, color: colors.bdr2),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _addCtrl,
                            autofocus: true,
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink),
                            decoration: InputDecoration(
                              hintText: AppL10n.of(context).typeItemOrTap,
                              hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 9),
                            ),
                            onSubmitted: (v) async => _addItem(v),
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async => _addItem(_addCtrl.text),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(Icons.send_rounded, size: 14, color: KaalColors.acc2),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() { _isAdding = false; _addCtrl.clear(); }),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text('×', style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: colors.ink3, height: 1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: _suggestions.map((s) => GestureDetector(
                      onTap: () => _addItem(s),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        decoration: BoxDecoration(
                          color: colors.surf2,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(width: 0.5, color: colors.bdr),
                        ),
                        child: Text(s, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1)),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isAdding = true),
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 16, color: KaalColors.acc2),
                      const SizedBox(width: 4),
                      Text('Add item', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: KaalColors.acc2)),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Text('Delete', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item chip ─────────────────────────────────────────────────────────────────

class _ItemChip extends StatelessWidget {
  final CustomListItem item;
  final KaalColors colors;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ItemChip({
    required this.item,
    required this.colors,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final done = item.isDone;
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(8, 5, 4, 5),
        decoration: BoxDecoration(
          color: done ? const Color(0x1430D158) : colors.surf2,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(width: 0.5, color: done ? const Color(0x4030D158) : colors.bdr),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 14, height: 14,
              decoration: BoxDecoration(
                color: done ? const Color(0xFF30D158) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(width: 1, color: done ? const Color(0xFF30D158) : colors.bdr2),
              ),
              child: done ? const Icon(Icons.check, size: 9, color: Colors.white) : null,
            ),
            const SizedBox(width: 6),
            Text(
              item.content,
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 12, height: 1,
                color: done ? colors.ink3 : colors.ink,
                decoration: done ? TextDecoration.lineThrough : null,
                decorationColor: colors.ink3,
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 2, 4, 2),
                child: Icon(Icons.close, size: 11, color: colors.ink3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
