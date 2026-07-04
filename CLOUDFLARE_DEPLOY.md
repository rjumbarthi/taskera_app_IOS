# Deploying the Kaal web app to Cloudflare Pages

The `kaal_app_Web_App` repo auto-deploys to Cloudflare Pages. Cloudflare builds
the Flutter web bundle on every push to `main` and serves it globally.

## One-time setup (Cloudflare dashboard)

1. <https://dash.cloudflare.com> → **Workers & Pages** → **Create** →
   **Pages** → **Connect to Git** → authorize GitHub → pick **`kaal_app_Web_App`**.
2. **Build settings:**
   - **Framework preset:** `None`
   - **Build command:**
     ```
     git clone https://github.com/flutter/flutter.git --depth 1 -b 3.44.1 "$HOME/flutter" && export PATH="$HOME/flutter/bin:$PATH" && flutter pub get && flutter build web --release
     ```
   - **Build output directory:** `build/web`
   - **Root directory:** `/` (leave default)
3. **Save and Deploy.** First build is slow (~5–8 min: it clones Flutter). Later
   builds are faster with Cloudflare's cache.
4. Your site goes live at `https://kaal-app-web-app.pages.dev` (Cloudflare shows
   the exact URL). Every push to `main` redeploys automatically.

> The Flutter version is pinned to **3.44.1** (matches local dev). Bump the
> `-b 3.44.1` tag in the build command when you upgrade Flutter.

## Post-deploy: point Supabase + Google at the live URL

Once you know your `*.pages.dev` URL (and any custom domain):

- **Supabase** → Authentication → **URL Configuration**:
  - Set **Site URL** to your Pages URL.
  - Add it to **Redirect URLs** (e.g. `https://kaal-app-web-app.pages.dev/*`).
- **Google Cloud** (only if using Google sign-in on web) → your OAuth client →
  add the Pages URL to **Authorized JavaScript origins**. (The Google→Supabase
  redirect URI stays `https://dutlcoxtxmnqektttffg.supabase.co/auth/v1/callback`.)

## Notes
- **Database persistence:** by default the local Drift/SQLite DB uses **IndexedDB**
  (works and persists across reloads). To switch it to **OPFS**, uncomment the
  cross-origin-isolation block in `web/_headers` — but first confirm Supabase
  auth/sync still works under `COEP: require-corp` (it can block some
  cross-origin responses).
- **Custom domain:** add it under the Pages project → **Custom domains**, then
  update the Supabase/Google URLs above to match.
- **Local build check:** `flutter build web --release` → output in `build/web`.
