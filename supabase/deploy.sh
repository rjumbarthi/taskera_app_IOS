#!/usr/bin/env bash
# One-shot deploy for Kaal's Supabase backend.
# Prereqs: `supabase` CLI installed, `supabase login` done.
# Fill the REPLACE_ME secrets below, then run:  bash supabase/deploy.sh
set -euo pipefail

PROJECT_REF="dutlcoxtxmnqektttffg"
supabase link --project-ref "$PROJECT_REF"

# ── Edge functions ───────────────────────────────────────────────────────────
supabase functions deploy ai-proxy
supabase functions deploy razorpay-webhook --no-verify-jwt   # Razorpay sends no JWT
supabase functions deploy validate-purchase

# ── Secrets (replace placeholders) ───────────────────────────────────────────
supabase secrets set \
  ANTHROPIC_API_KEY="sk-ant-REPLACE_ME" \
  OPENAI_API_KEY="sk-REPLACE_ME" \
  RAZORPAY_WEBHOOK_SECRET="whsec_REPLACE_ME" \
  APPLE_SHARED_SECRET="REPLACE_ME" \
  ANDROID_PACKAGE="com.port443.kaal"

# Google Play service-account JSON — single-quote to preserve the JSON literal:
# supabase secrets set GOOGLE_PLAY_SERVICE_ACCOUNT='{"type":"service_account", ...}'

echo
echo "✅ Functions + secrets deployed."
echo "➡  Now run the SQL migrations in order (Supabase SQL editor):"
echo "   001_initial_schema.sql, 002_sync_labels_realtime.sql,"
echo "   003_notes_columns.sql, 004_pro_entitlements.sql"
echo "➡  And paste supabase/templates/*.html into Auth → Emails → Templates."
