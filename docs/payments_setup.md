# Payments setup (Kaal Pro)

The app code is wired; these are the **external** steps you must do for real payments.
None of this can be tested on Windows (`in_app_purchase` is Android/iOS only).

## Pricing (region-tiered — `lib/config/pricing.dart`, chosen by device country)
| Tier | Markets | Monthly | Yearly (40% off) | Intro |
|---|---|---|---|---|
| 1 | High-income (US/UK/EU/JP/AU/Gulf…) | $2.99/mo | $1.79/mo | $1.99 first month |
| 2 | Middle-income (CN/BR/TR/SEA/ZA…) | $1.99/mo | $1.19/mo | $0.99 first month |
| 3 | Everyone else incl. **India** | $0.99/mo | $0.59/mo | Free first month |

Set the **matching per-country prices in Play Console + App Store Connect** (both stores
let you price each product per country/region). `ProductDetails.price` then reflects the
real localized charge; the tiers above drive the in-app display + the web/UPI flow. The
first-month intro (tier 1) and the 40% yearly discount are configured as store
**intro/offer** prices.

## 1. Play Store + App Store subscriptions (the in-app path)
`in_app_purchase` handles both. **UPI, cards, wallets & net-banking appear inside
Google Play's own checkout in India automatically** — there is no separate in-app
UPI SDK (that would breach Play/Apple policy for digital goods).

Create two subscription products with these **exact IDs** (same on both stores) —
they're referenced in `lib/config/app_config.dart`:

| Plan | Product ID | Price |
|---|---|---|
| Monthly | `kaal_pro_monthly` | ₹199 / month |
| Annual | `kaal_pro_annual` | ₹1,188 / year (≈ ₹99/mo) |

- **Google Play Console** → Monetize → Subscriptions → create both, add a 7-day free trial offer.
- **App Store Connect** → your app → Subscriptions → create both in one subscription group.
- Until these exist, the paywall buttons show "Plan not available yet" (expected).

## 2. UPI via Razorpay (external / web checkout)
A standalone UPI gateway charging for an **in-app** subscription is **against Play/Apple
policy**, so the "Pay with UPI" button opens an **external** Razorpay link in the browser.

- Create a Razorpay **Payment Link** (or `razorpay.me/@handle`) for the plan.
- Paste it into `AppConfig.razorpayUpiLink` (empty by default → button shows "coming soon").
- Because it's external, the app can't auto-detect success. Pass the Supabase
  **user id in `notes.user_id`** when you create the Payment Link / Checkout, and the
  **`razorpay-webhook`** edge function (§4) grants Pro on `payment.captured`.

## 3. Granting Pro (entitlement)
On a successful store purchase, `PurchaseService` sets `kaal.isPro = true`, which unlocks
AI and other Pro features via `isProProvider` / `aiUnlockedProvider`.

⚠️ **For production, validate the purchase server-side** (e.g. a Supabase edge function
checking `verificationData` with Google/Apple) before granting — the current client-side
grant is a scaffold and is spoofable.

## 4. Razorpay webhook — `supabase/functions/razorpay-webhook`
1. `supabase functions deploy razorpay-webhook --no-verify-jwt`
2. `supabase secrets set RAZORPAY_WEBHOOK_SECRET=whsec_...`
3. Run `supabase/migrations/004_pro_entitlements.sql` (creates `public.pro_entitlements`,
   RLS: users read their own row, only the service role writes).
4. Razorpay Dashboard → Settings → Webhooks → add the function URL, the **same secret**,
   and subscribe to `payment.captured` + the `subscription.*` events.
5. When opening the payment link/checkout from the app, include **`notes.user_id`** = the
   Supabase auth uid so the webhook knows whom to grant.

The function verifies the HMAC signature, then upserts `pro_entitlements.is_pro`
(grant on `payment.captured`/`subscription.activated`/`charged`, revoke on
`cancelled`/`halted`/`completed`).

### Remaining app-side wire-up (NOT done yet)
The app still reads Pro from the local `kaal.isPro` pref. To honor this server entitlement
(needed for Razorpay + cross-device), read the user's `pro_entitlements` row on
launch/sign-in and set `kaal.isPro` from it — then `isProProvider` / `aiUnlockedProvider`
pick it up automatically. Ask and I'll wire it.
