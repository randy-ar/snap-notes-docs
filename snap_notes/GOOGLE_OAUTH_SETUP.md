# Google OAuth Setup Instructions

This guide walks you through setting up Google OAuth with Supabase for your Android app.

## Prerequisites
- Google account with access to Google Cloud Console
- Supabase project (already configured: `https://hdqmpftvkvwdjpnjbmlg.supabase.co`)

## Step 1: Google Cloud Console Setup

### 1.1 Create/Select Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/home/dashboard)
2. Create a new project or select an existing one
3. Note the project ID for reference

### 1.2 Configure OAuth Consent Screen
1. Navigate to [APIs & Services > OAuth consent screen](https://console.cloud.google.com/auth/consent)
2. Choose **External** (for testing) or **Internal** (if within organization)
3. Fill in required fields:
   - **App name**: Snap Notes
   - **User support email**: Your email
   - **Developer contact**: Your email
4. Click **Save and Continue**
5. Add **Scopes** (required by Supabase):
   - `openid` (add manually)
   - `.../auth/userinfo.email` (added by default)
   - `.../auth/userinfo.profile` (added by default)
6. Click **Save and Continue**
7. Skip "Test users" for now (or add your email for testing)
8. Click **Save and Continue** to finish

### 1.3 Create OAuth Credentials
1. Navigate to [APIs & Services > Credentials](https://console.cloud.google.com/auth/clients)
2. Click **+ Create Credentials** > **OAuth client ID**
3. Select **Web application** as the application type
4. Configure:
   - **Name**: Snap Notes Android OAuth
   - **Authorized JavaScript origins**: 
     - Add your production domain (if applicable)
     - For local testing: `http://localhost`
   - **Authorized redirect URIs**:
     - **IMPORTANT**: Add your Supabase callback URL from Supabase Dashboard
     - Format: `https://hdqmpftvkvwdjpnjbmlg.supabase.co/auth/v1/callback`
     - **DO NOT** add `http://localhost:3000` or other localhost URLs
     - For local development with Supabase CLI: `http://127.0.0.1:54321/auth/v1/callback`
5. Click **Create**
6. **Save the Client ID and Client Secret** - you'll need these for Supabase

## Step 2: Configure Supabase Google Provider

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project: `hdqmpftvkvwdjpnjbmlg`
3. Navigate to **Authentication** > **Providers** > **Google**
4. Enable the Google provider
5. Enter the credentials from Google Cloud Console:
   - **Client ID**: Paste the Client ID from Step 1.3
   - **Client Secret**: Paste the Client Secret from Step 1.3
6. Configure **Redirect URLs**:
   - Add: `snapnotes://auth` (this matches your Android deep link)
   - **IMPORTANT**: Remove `http://localhost:3000` if it exists - this is causing the redirect issue
7. Click **Save**

### Step 2.1: Configure Site URL
1. Navigate to **Authentication** > **URL Configuration**
2. Set **Site URL** to your app's domain (or leave empty for mobile apps)
3. In **Redirect URLs**, ensure only `snapnotes://auth` is listed for mobile
4. Remove any localhost URLs that are not needed for testing
5. Click **Save**

## Step 3: Update Your .env File

Replace the placeholder in your `.env` file with your actual Google Client ID:

```env
GOOGLE_CLIENT_ID=your-actual-google-client-id-here
```

## Step 4: Verify Android Configuration

The following have already been configured in your project:

### AndroidManifest.xml
- Deep link scheme: `snapnotes://auth`
- Intent filter for OAuth callback

### Auth Datasource
- Redirect URL set to `snapnotes://auth`
- OAuth flow configured with external browser

## Step 5: Test the Implementation

### 5.1 Build and Run
```bash
flutter clean
flutter pub get
flutter run
```

### 5.2 Test Sign-In Flow
1. Tap the Google Sign-In button in your app
2. Browser should open with Google's consent screen
3. Sign in with your Google account
4. After consent, browser should redirect back to your app
5. Verify that the user session is created successfully

### 5.3 Troubleshooting
- **Redirect to localhost:3000 instead of deep link**:
  - Go to Supabase Dashboard > Authentication > URL Configuration
  - Remove `http://localhost:3000` from Redirect URLs
  - Ensure only `snapnotes://auth` is listed for mobile
  - Also check Authentication > Providers > Google > Redirect URLs and remove localhost:3000

- **Redirect not working**: Ensure deep link scheme matches in both AndroidManifest.xml and auth datasource
- **Invalid redirect URI**: Check Supabase Dashboard > Auth > Redirect URLs includes `snapnotes://auth`
- **OAuth error**: Verify Client ID and Secret are correctly entered in Supabase Dashboard
- **Browser doesn't open**: Check that `LaunchMode.externalApplication` is working on your device

## Step 6: Production Deployment

Before deploying to production:

1. **Update Google Cloud Console**:
   - Add your production domain to Authorized JavaScript origins
   - Remove `http://localhost` from origins
   - Update redirect URIs if needed

2. **Update Supabase Dashboard**:
   - Verify all redirect URLs are correct
   - Ensure Client ID and Secret are for production

3. **Update .env**:
   - Use production Client ID
   - Never commit real secrets to version control

## Additional Resources

- [Supabase Auth Documentation - Google](https://supabase.com/docs/guides/auth/social-login/auth-google)
- [Google Cloud OAuth Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Flutter Deep Linking Guide](https://docs.flutter.dev/ui/navigation/deep-linking)
