/// Country-tiered display pricing for Kaal Pro (USD).
///
/// Actual billing is localized by Play / App Store from the per-country price
/// you set there (and `ProductDetails.price` reflects it once products load).
/// These tiers drive the marketing copy shown in the paywall + the web/UPI flow,
/// chosen from the device's region.
class PricingTier {
  const PricingTier({
    required this.monthly,
    required this.yearlyPerMonth,
    this.introFirstMonth,
  });

  /// e.g. "$2.99"
  final String monthly;

  /// 40% off, billed yearly, shown per-month — e.g. "$1.79"
  final String yearlyPerMonth;

  /// First-month intro (tier 1 only), e.g. "$1.99"
  final String? introFirstMonth;
}

// 40% off monthly: 2.99→1.79, 1.99→1.19, 0.99→0.59.
// First-month intro: tier1 $1.99, tier2 $0.99, tier3 free ($0.00).
const _tier1 = PricingTier(monthly: r'$2.99', yearlyPerMonth: r'$1.79', introFirstMonth: r'$1.99');
const _tier2 = PricingTier(monthly: r'$1.99', yearlyPerMonth: r'$1.19', introFirstMonth: r'$0.99');
const _tier3 = PricingTier(monthly: r'$0.99', yearlyPerMonth: r'$0.59', introFirstMonth: r'$0.00');

// Tier 1 — high-income markets.
const _tier1Countries = {
  // North America
  'US', 'CA',
  // Western & Northern Europe
  'GB', 'IE', 'DE', 'FR', 'NL', 'BE', 'LU', 'AT', 'CH', 'LI', 'MC',
  'SE', 'NO', 'DK', 'FI', 'IS',
  // Southern & Central Europe (high income)
  'IT', 'ES', 'PT', 'MT', 'CY', 'GR', 'SI', 'EE', 'LT', 'LV',
  'CZ', 'SK', 'PL', 'HR',
  // Asia-Pacific
  'JP', 'KR', 'SG', 'HK', 'TW', 'AU', 'NZ', 'BN', 'MO',
  // Gulf / Middle East
  'AE', 'QA', 'KW', 'BH', 'SA', 'OM', 'IL',
};

// Tier 2 — middle-income markets.
const _tier2Countries = {
  // Latin America
  'BR', 'MX', 'AR', 'CL', 'CO', 'PE', 'UY', 'CR', 'PA', 'DO', 'EC', 'PY',
  // Europe / Caucasus / Central Asia
  'RU', 'TR', 'RO', 'BG', 'HU', 'RS', 'BA', 'MK', 'AL', 'ME',
  'BY', 'UA', 'GE', 'AM', 'AZ', 'KZ',
  // Asia
  'CN', 'TH', 'MY', 'ID', 'PH', 'VN',
  // Middle East / North Africa
  'JO', 'LB', 'EG', 'MA', 'TN', 'DZ',
  // Africa (upper-middle)
  'ZA', 'BW', 'NA', 'MU', 'GA',
};

// Everything else (incl. India and most of South Asia / Africa) → tier 3.

/// Resolve the tier from a 2-letter country code (device region).
PricingTier tierForCountry(String? countryCode) {
  final cc = (countryCode ?? '').toUpperCase();
  if (_tier1Countries.contains(cc)) return _tier1;
  if (_tier2Countries.contains(cc)) return _tier2;
  return _tier3;
}
