# 🔥 Firebase Setup Guide for Clan Unite

Complete step-by-step guide to configure Firebase for the Clan Unite Flutter app.

---

## 📋 Table of Contents
1. [Create Firebase Project](#1-create-firebase-project)
2. [Configure Android](#2-configure-android)
3. [Configure iOS](#3-configure-ios)
4. [Update Firebase Options](#4-update-firebase-options)
5. [Enable Firestore](#5-enable-firestore)
6. [Enable Firebase Auth](#6-enable-firebase-auth)
7. [Enable Cloud Storage](#7-enable-cloud-storage)
8. [Test the Setup](#8-test-the-setup)
9. [Troubleshooting](#troubleshooting)

---

## 1. Create Firebase Project

### Step 1.1: Go to Firebase Console
1. Visit [Firebase Console](https://console.firebase.google.com)
2. Sign in with your Google account
3. Click **"Create a project"**

### Step 1.2: Project Details
1. **Project Name**: `Clan-Unite` (or your preferred name)
2. Click **"Continue"**
3. **Analytics**: Toggle ON/OFF (optional, recommended ON)
4. Click **"Create project"**
5. Wait for the project to initialize (~1 minute)

### Step 1.3: Get Project ID
Once created, note these details:
- **Project ID**: Found in project settings (you'll need this)
- **Web API Key**: Found in project settings

---

## 2. Configure Android

### Step 2.1: Register Android App

1. In Firebase Console, click the **"+"** icon next to "Project Overview"
2. Select **"Android"**
3. Fill in the following:
   ```
   Android Package Name: com.example.clan_unite
   App Nickname: Clan Unite Android (optional)
   Debug SHA-1 (optional): Get it in Step 2.3
   ```

### Step 2.2: Get SHA-1 Fingerprint (Important)

**Option A: Using Flutter (Recommended)**
```bash
cd Clan-Unite
flutter pub get
flutter doctor -v
```

**Option B: Using Gradle**
```bash
cd Clan-Unite/android
./gradlew signingReport
```

Look for the **SHA-1** value and copy it.

### Step 2.3: Add SHA-1 to Firebase
1. Go back to Firebase Console → Android App Settings
2. Click **"Add fingerprint"**
3. Paste your SHA-1
4. Click **"Save"**

### Step 2.4: Download Configuration File

1. Click **"Download google-services.json"**
2. Save the file to your project:
   ```
   Clan-Unite/android/app/google-services.json
   ```

### Step 2.5: Verify Android Setup
Your project structure should now look like:
```
android/
├── app/
│   ├── google-services.json  ✅ (newly added)
│   ├── build.gradle
│   └── ...
├── build.gradle
└── ...
```

---

## 3. Configure iOS

### Step 3.1: Register iOS App

1. In Firebase Console, click **"+"** icon next to Android app
2. Select **"iOS"**
3. Fill in:
   ```
   iOS Bundle ID: com.example.clanUnite
   App Nickname: Clan Unite iOS (optional)
   App Store ID: (leave empty for now)
   ```

### Step 3.2: Download Configuration File

1. Click **"Download GoogleService-Info.plist"**
2. Save to your project:
   ```
   Clan-Unite/ios/Runner/GoogleService-Info.plist
   ```

### Step 3.3: Add File to Xcode

1. Open Xcode:
   ```bash
   cd Clan-Unite/ios
   open Runner.xcworkspace
   ```

2. In Xcode:
   - Right-click on "Runner" folder
   - Select **"Add Files to Runner"**
   - Choose `GoogleService-Info.plist`
   - Check **"Copy items if needed"**
   - Check **"Runner"** target
   - Click **"Add"**

3. Verify the file appears in Xcode project navigator

### Step 3.4: Update iOS Deployment Target (if needed)

In `ios/Podfile`, ensure minimum deployment target is set:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_LOCATION=1',
        'PERMISSION_CAMERA=1',
      ]
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
```

---

## 4. Update Firebase Options

### Step 4.1: Get Firebase Project Details

In Firebase Console → Project Settings, get these values:
- **Project ID**
- **Web API Key**
- **Auth Domain** (usually `{projectId}.firebaseapp.com`)
- **Storage Bucket** (usually `{projectId}.appspot.com`)
- **Messaging Sender ID**
- **App ID** (Android App ID from Firebase)

### Step 4.2: Update firebase_options.dart

Edit `lib/config/firebase_options.dart`:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    } else if (defaultTargetPlatform == TargetPlatform.web) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY', // Get from google-services.json
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'your-project-id',
    databaseURL: 'https://your-project-id.firebaseio.com',
    storageBucket: 'your-project-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'your-project-id',
    databaseURL: 'https://your-project-id.firebaseio.com',
    storageBucket: 'your-project-id.appspot.com',
    iosBundleId: 'com.example.clanUnite',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'your-project-id',
    authDomain: 'your-project-id.firebaseapp.com',
    storageBucket: 'your-project-id.appspot.com',
  );
}
```

### Step 4.3: Get Values from Google Services Files

**For Android values**, open `android/app/google-services.json`:
```json
{
  "project_info": {
    "project_number": "YOUR_MESSAGING_SENDER_ID",
    "project_id": "your-project-id",
    ...
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789:android:abcdef123456...",
        ...
      },
      "api_key": [
        {
          "current_key": "YOUR_ANDROID_API_KEY"
        }
      ]
    }
  ]
}
```

**For iOS values**, open `ios/Runner/GoogleService-Info.plist` (right-click → Open As → Source Code):
```xml
<dict>
    <key>PROJECT_ID</key>
    <string>your-project-id</string>
    <key>BUNDLE_ID</key>
    <string>com.example.clanUnite</string>
    <key>API_KEY</key>
    <string>YOUR_IOS_API_KEY</string>
    ...
</dict>
```

---

## 5. Enable Firestore

### Step 5.1: Create Firestore Database

1. Go to Firebase Console → **"Firestore Database"**
2. Click **"Create database"**
3. Choose location (closest to your users)
4. Start in **"Test mode"** (for development)
   - ⚠️ Warning: Test mode is NOT secure for production
5. Click **"Enable"**

### Step 5.2: Set Security Rules (Test Mode)
For development, test rules allow all reads/writes:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

To update:
1. Go to Firestore → **"Rules"** tab
2. Replace default rules with above
3. Click **"Publish"**

### Step 5.3: Create Collections (Optional - Auto-created on first write)
The app will auto-create these collections when users sign up:
- `users` - User profiles
- `clans` - Clan/organization data
- `messages` - Chat messages
- `transactions` - Financial transactions

---

## 6. Enable Firebase Auth

### Step 6.1: Enable Email/Password Auth

1. Go to Firebase Console → **"Authentication"**
2. Click **"Get Started"**
3. Click **"Email/Password"** provider
4. Toggle **"Enable"**
5. Click **"Save"**

### Step 6.2: (Optional) Enable Other Providers

For future enhancement:
- Google Sign-In
- Apple Sign-In
- Phone Authentication

---

## 7. Enable Cloud Storage

### Step 7.1: Create Storage Bucket

1. Go to Firebase Console → **"Storage"**
2. Click **"Get Started"**
3. Start in **"Test mode"** (development)
4. Choose location (same as Firestore)
5. Click **"Done"**

### Step 7.2: Set Storage Rules

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

To update:
1. Go to Storage → **"Rules"** tab
2. Replace default rules
3. Click **"Publish"**

---

## 8. Test the Setup

### Step 8.1: Clean & Rebuild

```bash
cd Clan-Unite

# Clean previous builds
flutter clean
rm -rf build/

# Get dependencies
flutter pub get
```

### Step 8.2: Run on Emulator/Device

**Android:**
```bash
flutter emulators --launch Pixel_5_API_33  # or your emulator
flutter run
```

**iOS:**
```bash
flutter run -d "iPhone 15"  # or your simulator
```

**Web (Quick Test):**
```bash
flutter run -d chrome
```

### Step 8.3: Test Authentication Flow

1. **Sign Up**:
   - Enter email: `test@example.com`
   - Enter password: `Test123!`
   - Fill other fields
   - Click "Create Account"

2. **Check Firebase Console**:
   - Go to Authentication → Users
   - You should see your test user

3. **Check Firestore**:
   - Go to Firestore → Collections → `users`
   - You should see your user profile document

4. **Login**:
   - Use same email/password to log in
   - Should see Home screen

---

## 🐛 Troubleshooting

### Issue: "Google Services file not found"
**Solution**: Ensure files are in correct locations:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

### Issue: Build fails with "Firebase Core initialization failed"
**Solution**: 
```bash
flutter clean
flutter pub get
flutter pub upgrade firebase_core
flutter run
```

### Issue: "Permission denied" when writing to Firestore
**Solution**: Check security rules. For test mode, use:
```
allow read, write: if request.auth != null;
```

### Issue: iOS build fails with Pod errors
**Solution**:
```bash
cd ios
rm -rf Pods Pod.lock
cd ..
flutter pub get
flutter run
```

### Issue: App crashes on login with "Authentication not configured"
**Solution**: 
1. Verify `firebase_options.dart` has correct project ID
2. Verify `google-services.json` is in `android/app/`
3. Verify `GoogleService-Info.plist` is added to Xcode project
4. Run: `flutter clean && flutter pub get && flutter run`

### Issue: Firestore rules showing "Permission denied"
**Solution**: Go to Firestore → Rules, ensure this is set:
```
match /{document=**} {
  allow read, write: if request.auth != null;
}
```

---

## ✅ Verification Checklist

- [ ] Firebase project created
- [ ] Android app registered in Firebase
- [ ] `google-services.json` downloaded to `android/app/`
- [ ] iOS app registered in Firebase
- [ ] `GoogleService-Info.plist` downloaded to `ios/Runner/`
- [ ] `GoogleService-Info.plist` added to Xcode project
- [ ] `lib/config/firebase_options.dart` updated with credentials
- [ ] Firestore Database enabled
- [ ] Firestore Security Rules configured
- [ ] Firebase Authentication (Email/Password) enabled
- [ ] Cloud Storage enabled
- [ ] Cloud Storage Rules configured
- [ ] `flutter clean && flutter pub get` executed
- [ ] App runs without Firebase errors
- [ ] Can sign up a test user
- [ ] Can log in with test user
- [ ] Can see user in Firestore

---

## 📞 Next Steps

Once Firebase is configured:
1. Test the authentication flow
2. Create additional screens (financial, social, location)
3. Implement Firestore operations
4. Add image upload functionality
5. Set up push notifications

For issues, check the [Flutter Firebase Documentation](https://firebase.flutter.dev/)

Happy coding! 🚀
