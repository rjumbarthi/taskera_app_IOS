import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Sub-screen push (slide from right + fade-in) ──────────────────────────────
// Used for all tab sub-routes (tasks/taskdetail, focus/goals, etc.)
Page<void> slideRightPage({
  required Widget child,
  required GoRouterState state,
}) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 240),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.55, curve: Curves.easeIn),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );

// ── Standalone overlay (slight upward drift + fade) ───────────────────────────
// Used for standalone routes pushed onto the root navigator: settings, profile,
// paywall, legal, etc.
Page<void> slideUpPage({
  required Widget child,
  required GoRouterState state,
}) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.05),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );

// ── Full-screen fade (onboarding flow replacements) ───────────────────────────
// Used for context.go() transitions: quote → signin → onboard → focus
Page<void> fadePage({
  required Widget child,
  required GoRouterState state,
}) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: child,
        );
      },
    );
