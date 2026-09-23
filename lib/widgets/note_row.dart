import 'package:flutter/material.dart';
import '../theme/taskera_theme.dart';
import 'glass_card.dart';

class NoteRow extends StatelessWidget {
  final String title;
  final String preview;
  final String? tag;
  final String timestamp;
  final VoidCallback? onTap;

  const NoteRow({
    super.key,
    required this.title,
    required this.preview,
    required this.timestamp,
    this.tag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: colors.ink3,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (tag != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: colors.surf2,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        color: colors.ink3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  timestamp,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    color: colors.ink4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
