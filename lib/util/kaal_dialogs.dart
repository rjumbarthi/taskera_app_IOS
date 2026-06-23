import 'package:flutter/material.dart';
import '../l10n/app_l10n.dart';

Future<bool> kaalConfirmDelete(BuildContext context, {String? message}) async {
  final str = AppL10n.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(str.confirmDeleteTitle,
          style: const TextStyle(
              fontFamily: 'Inter', fontWeight: FontWeight.w700, color: Colors.white)),
      content: Text(message ?? str.confirmDeleteMsg,
          style: const TextStyle(
              fontFamily: 'Inter', fontSize: 14, color: Color(0xFFAAAAAA))),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(str.cancel,
              style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF0A84FF))),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(str.delete,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFFFF453A),
                  fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return ok == true;
}
