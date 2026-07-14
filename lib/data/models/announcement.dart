/// A broadcast announcement shown to every user in Settings → Messages.
/// The developer posts rows into the Supabase `announcements` table (e.g.
/// "Fixed the crash you reported ✓", "New: Databases"); the app fetches them.
class Announcement {
  final int id;
  final String title;
  final String body;
  final String kind; // 'fix' | 'feature' | 'update' | 'notice'
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> j) => Announcement(
        id: (j['id'] as num?)?.toInt() ?? 0,
        title: (j['title'] as String?)?.trim() ?? '',
        body: (j['body'] as String?)?.trim() ?? '',
        kind: (j['kind'] as String?) ?? 'update',
        createdAt:
            DateTime.tryParse(j['created_at']?.toString() ?? '')?.toLocal() ??
                DateTime.fromMillisecondsSinceEpoch(0),
      );

  /// Emoji badge per kind (used in the Messages list).
  String get emoji => switch (kind) {
        'fix' => '🛠️',
        'feature' => '✨',
        'notice' => '📣',
        _ => '🔔',
      };

  String get kindLabel => switch (kind) {
        'fix' => 'Fixed',
        'feature' => 'New',
        'notice' => 'Notice',
        _ => 'Update',
      };
}
