import 'package:flutter/material.dart';
import '../l10n/app_l10n.dart';
import '../theme/taskera_theme.dart';

Future<bool> taskeraConfirmDelete(BuildContext context, {String? message}) async {
  final str = AppL10n.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(str.confirmDeleteTitle,
          style: TextStyle(
              fontFamily: TaskEraTheme.of(context).fontFamily, fontWeight: FontWeight.w700, color: Colors.white)),
      content: Text(message ?? str.confirmDeleteMsg,
          style: TextStyle(
              fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, color: Color(0xFFAAAAAA))),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(str.cancel,
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily,
                  color: TaskEraTheme.of(context).colors.plainText ? Colors.white : const Color(0xFF0A84FF))),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(str.delete,
              style: TextStyle(
                  fontFamily: TaskEraTheme.of(context).fontFamily,
                  color: TaskEraTheme.of(context).colors.plainText ? Colors.white : const Color(0xFFFF453A),
                  fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return ok == true;
}
