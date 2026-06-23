# Kaal — Real Backend Setup Guide

Complete these steps once to turn the app from UI-only to fully functional.
Estimated time: 45-60 minutes.

---

## 1. Supabase (auth + cloud database + AI edge function)

### 1a. Create a project
1. Go to https://supabase.com → New project
2. Choose a region close to your users

### 1b. Apply the database schema
- Open **SQL Editor** in the Supabase dashboard
- Paste the contents of `supabase/migrations/001_initial_schema.sql`
- Click **Run**

### 1c. Configure Auth redirect URLs
- **Dashboard → Auth → URL Configuration**
- Add to **Redirect URLs**:
  ```
  io.supabase.kaalapp://login-callback/
  io.supabase.kaalapp://reset-callback/
  ```

### 1d. Copy your project credentials
- **Dashboard → Project Settings → API**
- Copy **Project URL** and **anon/public key**
- Paste into `lib/config/app_config.dart`:
  ```dart
  static const supabaseUrl     = 'https://YOURREF.supabase.co';
  static const supabaseAnonKey = 'eyJ...';
  ```

### 1e. Deploy the AI Edge Function
```bash
# Install Supabase CLI if needed: https://supabase.com/docs/guides/cli
npm install -g supabase

supabase login
supabase link --project-ref YOUR_PROJECT_REF

# Deploy the function
supabase functions deploy ai-proxy

# Set AI API keys as secrets (never committed to git)
supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
supabase secrets set OPENAI_API_KEY=sk-...
```

---

## 2. Google OAuth + Calendar + Gmail

### 2a. Create a Google Cloud project
1. https://console.cloud.google.com → New Project
2. Enable APIs: **Google Calendar API** + **Gmail API**
   - APIs & Services → Library → search and enable each

### 2b. Configure OAuth consent screen
- APIs & Services → OAuth consent screen
- Application type: External
- Add scopes: `calendar.readonly`, `gmail.readonly`
- Add your test email as a test user (while in "Testing" mode)

### 2c. Create OAuth credentials
Create **three** OAuth 2.0 Client IDs (one per platform):

| Platform | Application type | Notes |
|---|---|---|
| Web | Web application | Add `https://YOUR_PROJECT.supabase.co/auth/v1/callback` to Authorized redirect URIs |
| Android | Android | Package name: `com.example.kaal_app`, SHA-1 from keystore |
| iOS | iOS | Bundle ID: `com.example.kaalApp` |

### 2d. Paste client IDs
In `lib/config/app_config.dart`:
```dart
static const googleClientIdWeb     = 'YOUR_WEB_ID.apps.googleusercontent.com';
static const googleClientIdIos     = 'YOUR_IOS_ID.apps.googleusercontent.com';
static const googleClientIdAndroid = 'YOUR_ANDROID_ID.apps.googleusercontent.com';
```

### 2e. Download platform config files
- **Android**: Download `google-services.json` → place in `android/app/`
- **iOS**: Download `GoogleService-Info.plist` → add to `ios/Runner/` via Xcode

### 2f. Enable Google sign-in provider in Supabase
- Dashboard → Auth → Providers → Google
- Enable, paste your Web Client ID and Client Secret

---

## 3. Microsoft / Azure (Outlook + Calendar)

### 3a. Register an Azure app
1. https://portal.azure.com → Azure Active Directory → App registrations → New registration
2. Name: "Kaal App"
3. Account types: "Accounts in any organizational directory and personal Microsoft accounts"
4. Redirect URIs — add these:
   - Mobile/Desktop: `kaalapp://microsoft-auth`
   - Desktop (Windows/macOS): `http://localhost`

### 3b. Add API permissions
- API permissions → Add a permission → Microsoft Graph → Delegated
- Add: `Calendars.Read`, `Mail.Read`, `email`, `openid`, `profile`, `offline_access`
- Grant admin consent

### 3c. Paste credentials
In `lib/config/app_config.dart`:
```dart
static const azureClientId = 'YOUR_AZURE_APP_CLIENT_ID';
static const azureTenantId = 'common'; // or your specific tenant ID
```

### 3d. Enable Azure provider in Supabase (for sign-in)
- Dashboard → Auth → Providers → Azure
- Enable, paste Client ID and Client Secret (from Azure → Certificates & secrets)

---

## 4. iOS deep-link configuration

Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <!-- Supabase OAuth callback -->
  <dict>
    <key>CFBundleURLSchemes</key>
    <array><string>io.supabase.kaalapp</string></array>
  </dict>
  <!-- Microsoft OAuth callback -->
  <dict>
    <key>CFBundleURLSchemes</key>
    <array><string>kaalapp</string></array>
  </dict>
</array>
```

---

## 5. Android SHA-1 fingerprint (for Google Sign-In)

```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Copy the SHA-1 and add it in Google Cloud Console → Android OAuth client
```

---

## 6. Run the app

```bash
flutter run
```

On first launch after signing in, the app will:
1. Authenticate via Supabase
2. Sync all local data to the cloud
3. AI features activate (Edge Function routes calls to Claude → OpenAI fallback)
4. Integrations connect when the user taps them in Settings

---

## Security checklist

- [ ] `lib/config/app_config.dart` is in `.gitignore` (contains OAuth client IDs)
- [ ] No API keys in client code — AI keys are Supabase Edge Function secrets
- [ ] Microsoft refresh tokens stored in `flutter_secure_storage` (encrypted keychain/credential manager)
- [ ] Supabase RLS is enabled — users only see their own data

---

## Architecture summary

```
Flutter App (local-first)
├── Drift (SQLite)           ← all reads/writes happen here instantly
├── SyncService              ← pushes to Supabase in background after sign-in
│
├── AuthService (Supabase)
│   ├── email/password
│   ├── email OTP
│   ├── Google (google_sign_in → Supabase signInWithIdToken)
│   └── Microsoft (Supabase OAuth → browser redirect → deep link)
│
├── AiService (Supabase Edge Functions)
│   ├── summarize_note       → Claude haiku → OpenAI fallback
│   ├── score_task           → Claude haiku → OpenAI fallback
│   ├── brain_dump           → Claude haiku → OpenAI fallback
│   └── insights             → Claude haiku → OpenAI fallback
│
├── GoogleService (googleapis)
│   ├── Calendar events      ← synced to CalendarEvents Drift table
│   └── Gmail unread         ← shown in Inbox tab
│
└── MicrosoftService (Microsoft Graph via flutter_web_auth_2 PKCE)
    ├── Outlook calendar     ← synced to CalendarEvents Drift table
    └── Inbox mail           ← shown in Inbox tab
```
