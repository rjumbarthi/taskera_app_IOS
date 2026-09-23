import 'package:flutter/material.dart';

class TaskEraMotion {
  // Duration constants — directly from tokens.json transitions
  static const Duration fastPress           = Duration(milliseconds: 120);
  static const Duration defaultDuration     = Duration(milliseconds: 200);
  static const Duration screenSlideIn       = Duration(milliseconds: 220);
  static const Duration longPress           = Duration(milliseconds: 480);
  static const Duration pulse               = Duration(milliseconds: 110);
  static const Duration outsideDismissDelay = Duration(milliseconds: 450);
  static const Duration lpBlockWindow       = Duration(milliseconds: 700);
  static const Duration switchThumb         = Duration(milliseconds: 200);
  static const Duration colorSwatch        = Duration(milliseconds: 140);
  static const Duration screenCleanup      = Duration(milliseconds: 280);

  // Scale values
  static const double scalePressed = 0.97;

  // Curves
  static const Curve defaultCurve = Curves.ease;
  // cubic-bezier(.34,1.56,.64,1) — spring bounce
  static const Curve spring = Cubic(0.34, 1.56, 0.64, 1);

  const TaskEraMotion();
}
