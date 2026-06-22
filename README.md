# File Share: Easy File Sharing

Local Wi‑Fi file transfer for iOS and Android. Pair devices with a **QR code** and **4-digit PIN**, then send files **directly device-to-device** — no account and no cloud upload.

## Overview

File Share lets a **receiver** start a local session and show a QR code. A **sender** scans the code (or picks a nearby receiver), enters the PIN, selects files, and uploads over the local network. Received files stay on the device and can optionally be exported via the iOS share sheet (AirDrop, Mail, etc.).

| Item | Value |
|------|-------|
| **App name** | File Share: Easy File Sharing |
| **Bundle ID** | `com.quickshare.easyfilesharing` |
| **Privacy policy** | https://sites.google.com/view/quick-share-easy-file-sharing/home |
| **Support** | https://sites.google.com/view/quick-share-easy-file-sharing1/home |
| **Contact** | Quick-Share235@gmail.com |

## Main features

- **Send / Receive / Settings** tabbed shell
- **QR pairing** with session token + **4-digit PIN** (30-minute session TTL)
- **Local HTTP server** on the receiver for direct uploads
- **Bonjour/mDNS** discovery (`_quickshare._tcp`) for nearby receivers on the same Wi‑Fi
- **iOS Multipeer Connectivity** for offline/nearby Apple-to-Apple transfer when Wi‑Fi IP is unavailable
- **Chunked uploads** for files over 50 MB (5 MB HTTP chunks; smaller chunks over Multipeer)
- **Retry** (up to 3 attempts), **cancel upload**, duplicate filename handling
- **Browser upload page** for sending from a phone/computer browser via the QR URL
- **Splash**, **3-page onboarding**, **9 languages**
- **Ads** via Google AdMob (app open on launch, banner on main tabs; remote-configurable)
- **No account required**

## Architecture

```
Sender                         Receiver (same Wi‑Fi)
  │                                │
  ├─ Scan QR / pick nearby ───────►│ Start Receiving
  ├─ Enter PIN                     │ QR + PIN + HTTP server
  ├─ POST /upload (or /upload/chunk)►│ LocalShareServer
  └─ Progress / retry              └─ Received files list
```

**Key Dart modules**

| Area | Path |
|------|------|
| HTTP server & sessions | `lib/services/transfer/local_share_server.dart` |
| Client uploads | `lib/services/transfer/transfer_client.dart` |
| Orchestration | `lib/services/transfer/transfer_service.dart` |
| mDNS | `lib/services/transfer/mdns_discovery_service.dart` |
| Multipeer bridge | `lib/services/transfer/multipeer_service.dart` |
| iOS native Multipeer | `ios/Runner/QuickShareMultipeer.swift` |
| App metadata | `lib/app/app_metadata.dart` |
| Ads (multiads / AdMob) | `lib/main.dart`, `lib/services/ads_actions.dart`, `lib/widgets/ad_banner.dart` |

## Advertising

Ads are loaded through the local `multiads` package and remote JSON configuration:

| Format | When shown |
|--------|------------|
| **App open** | Once per session after splash (`AdsActions.showAppOpenIfAvailable`) |
| **Banner** | Above tab bar on Send / Receive / Settings (`BottomAdBanner`) |

Ad formats can be disabled remotely (for example `"banners": ["false"]`, `"openads": "false"`). See `packages/multiads` for supported networks.

## iOS permissions

Declared in `ios/Runner/Info.plist`:

| Key | Purpose |
|-----|---------|
| `NSCameraUsageDescription` | Scan receiver QR codes |
| `NSPhotoLibraryUsageDescription` | User-selected photos/videos to send |
| `NSLocalNetworkUsageDescription` | Direct Wi‑Fi transfer + Bonjour discovery |
| `NSBluetoothAlwaysUsageDescription` | Nearby/offline Apple discovery (Multipeer) |
| `NSBonjourServices` | `_quickshare._tcp` |
| `ITSAppUsesNonExemptEncryption` | `false` |

## How to test locally

### Prerequisites

- Flutter SDK 3.11+
- Xcode (iOS) and/or Android Studio
- **Two real devices** on the **same Wi‑Fi** for full transfer testing

### Run

```bash
flutter pub get
flutter run
```

After adding or updating native plugins, do a **full restart** (`flutter run`), not hot restart.

### Two-device test

1. **Device A** → **Receive** → **Start Receiving** (note QR + PIN).
2. **Device B** → **Send** → **Scan Receiver QR** → scan → enter PIN.
3. Select files → **Send Directly**.
4. Confirm files appear under **Received Files** on Device A.

## App Store submission docs

| Document | Purpose |
|----------|---------|
| `docs/APP_STORE_CONNECT.md` | Copy-paste metadata for App Store Connect |
| `docs/APP_REVIEW_NOTES.md` | Paste into App Review Information |
| `docs/PRE_SUBMISSION_QA.md` | Pre-upload QA checklist |
| `docs/PRIVACY_POLICY.md` | Mirror of hosted privacy policy |

## Known iOS limitations

- **Same Wi‑Fi required** for standard HTTP/mDNS transfer in most cases.
- **Guest/corporate Wi‑Fi** may block peer-to-peer traffic.
- **Receiver must stay in the app** with receiving active during transfer.
- **Multipeer** needs **two real iPhones**; simulator support is limited.
- **AirDrop / share sheet** is optional export only — not the primary transfer path.

## Build notes

```bash
# iOS release / App Store
flutter build ipa

# Android debug APK
flutter build apk --debug
```

## License

Proprietary — all rights reserved unless otherwise specified by the project owner.
