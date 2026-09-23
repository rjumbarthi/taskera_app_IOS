import 'package:flutter_test/flutter_test.dart';
import 'package:taskera_app/data/providers/ai_access_provider.dart';

// Covers the one rule the whole payment redesign depends on: Pro access must
// track real subscription state + expiry, never "a purchase happened once".
void main() {
  final future = DateTime.now().add(const Duration(days: 3));
  final past = DateTime.now().subtract(const Duration(days: 3));

  test('active with no known expiry still grants Pro', () {
    expect(const ProEntitlement(status: ProStatus.active, currentPeriodEnd: null, willRenew: true)
        .isActive, isTrue);
  });

  test('active with a future period end grants Pro', () {
    expect(ProEntitlement(status: ProStatus.active, currentPeriodEnd: future, willRenew: true)
        .isActive, isTrue);
  });

  test('cancelled but still inside the paid period grants Pro', () {
    expect(ProEntitlement(status: ProStatus.cancelled, currentPeriodEnd: future, willRenew: false)
        .isActive, isTrue);
  });

  test('grace period / billing retry still grant Pro before expiry', () {
    expect(ProEntitlement(status: ProStatus.gracePeriod, currentPeriodEnd: future, willRenew: true)
        .isActive, isTrue);
    expect(ProEntitlement(status: ProStatus.billingRetry, currentPeriodEnd: future, willRenew: true)
        .isActive, isTrue);
  });

  test('cancelled subscription past its period end does NOT grant Pro', () {
    expect(ProEntitlement(status: ProStatus.cancelled, currentPeriodEnd: past, willRenew: false)
        .isActive, isFalse);
  });

  test('expired status never grants Pro even with a future date on the row', () {
    expect(ProEntitlement(status: ProStatus.expired, currentPeriodEnd: future, willRenew: false)
        .isActive, isFalse);
  });

  test('revoked never grants Pro', () {
    expect(ProEntitlement(status: ProStatus.revoked, currentPeriodEnd: future, willRenew: false)
        .isActive, isFalse);
  });

  test('no entitlement at all does not grant Pro', () {
    expect(const ProEntitlement.none().isActive, isFalse);
  });

  test('round-trips through JSON (the local cache format) without losing expiry', () {
    final e = ProEntitlement(status: ProStatus.cancelled, currentPeriodEnd: future, willRenew: false);
    final decoded = ProEntitlement.fromJson(e.toJson());
    expect(decoded.status, ProStatus.cancelled);
    expect(decoded.currentPeriodEnd, future);
    expect(decoded.isActive, isTrue);
  });
}
