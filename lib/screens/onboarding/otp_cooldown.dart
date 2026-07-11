import 'dart:async';
import 'package:flutter/widgets.dart';

/// Adds a countdown cooldown to a screen's OTP "send / resend" action so it
/// can't be tapped in a tight loop (email/SMS bombing + server rate-limit
/// hammering). Client-side speed bump only — Supabase still enforces the real
/// server-side limits.
mixin OtpCooldownMixin<T extends StatefulWidget> on State<T> {
  int otpCooldown = 0;
  Timer? _otpTimer;

  bool get otpOnCooldown => otpCooldown > 0;

  /// Label for the resend control (shows the remaining seconds while cooling).
  String resendLabel([String idle = 'Resend OTP']) =>
      otpOnCooldown ? 'Resend in ${otpCooldown}s' : idle;

  void startOtpCooldown([int seconds = 45]) {
    _otpTimer?.cancel();
    setState(() => otpCooldown = seconds);
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        otpCooldown--;
        if (otpCooldown <= 0) t.cancel();
      });
    });
  }

  void disposeOtpCooldown() => _otpTimer?.cancel();
}
