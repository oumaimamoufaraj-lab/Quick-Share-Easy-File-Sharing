# App Store Connect — Submission Metadata

Use this file when filling out **App Store Connect** for **File Share: Easy File Sharing**.

---

## App information

| Field | Value |
|-------|-------|
| **App name** | File Share: Easy File Sharing |
| **Bundle ID** | `com.quickshare.easyfilesharing` |
| **SKU** | (your choice, e.g. `file-share-easy-001`) |
| **Primary language** | English (U.S.) |
| **Version** | 1.0.0 |
| **Build** | 3 |

---

## URLs & contact

| Field | Value |
|-------|-------|
| **Privacy Policy URL** | https://sites.google.com/view/quick-share-easy-file-sharing/home |
| **Support URL** | https://sites.google.com/view/quick-share-easy-file-sharing1/home |
| **Marketing URL** | (optional — leave blank or use support URL) |
| **Contact email** | Quick-Share235@gmail.com |

---

## Subtitle (30 characters max)

```
Wi‑Fi QR File Transfer
```

---

## Promotional text (170 characters max, optional)

```
Send files directly between nearby devices on the same Wi‑Fi. Scan a QR code, enter a PIN, and transfer with live progress. No account. No cloud upload.
```

---

## Description (suggested)

```
File Share: Easy File Sharing helps you send photos, videos, and documents directly between nearby devices on the same local Wi‑Fi network.

HOW IT WORKS
• On the receiving device, open Receive and tap Start Receiving.
• A QR code and 4-digit PIN appear for a secure transfer session.
• On the sending device, scan the QR code (or pick a nearby receiver), enter the PIN, select files, and tap Send Directly.
• Files transfer device-to-device with live progress. No cloud upload and no account required.

FEATURES
• Local Wi‑Fi file transfer with QR pairing and PIN protection
• Nearby receiver discovery on the same network
• Optional offline transfer between Apple devices when supported
• Chunked uploads for large files, retry, and cancel
• Received files can be opened, saved, shared, or deleted
• Free to use with third-party ads (Google AdMob)

REQUIREMENTS
• Both devices usually need to be on the same Wi‑Fi network
• The receiver should keep the app open while receiving
• Public or corporate Wi‑Fi may block device-to-device transfer

File Share includes third-party advertising (Google AdMob). You may see an app open ad on launch and a banner ad on the main screens. File transfer does not require an account and does not upload your files to our servers.

Support: https://sites.google.com/view/quick-share-easy-file-sharing1/home
Privacy: https://sites.google.com/view/quick-share-easy-file-sharing/home
Contact: Quick-Share235@gmail.com
```

---

## Keywords (100 characters max, comma-separated)

```
file transfer,wifi,qr,share,photos,videos,local,nearby,pin,send,receive
```

---

## App Review Information

**Contact:** Quick-Share235@gmail.com

**Notes:** Copy from `docs/APP_REVIEW_NOTES.md`

**Demo account:** Not required (no login)

---

## Age rating

Answer the questionnaire honestly. Typical answers for this app:

- No unrestricted web access
- No gambling, violence, or mature content
- File sharing utility — often **4+** depending on parental controls answers

---

## App Privacy (nutrition labels)

Answer the questionnaire based on **third-party ad SDK behavior** (Google AdMob and any enabled mediation networks). The transfer feature itself does not upload files to developer servers.

### Data collected by the app for transfer (first-party, on device)

| Data type | Collected? | Linked to user? | Used for tracking? | Purpose |
|-----------|------------|-----------------|-------------------|---------|
| Device ID (local app ID / display name) | Yes, on device only | No | No | App functionality (QR / nearby discovery) |
| Photos / files | User-selected only | No | No | App functionality (transfer) |

### Data that ad partners may collect (declare per AdMob / Apple guidance)

Typical declarations when using AdMob:

| Data type | Collected? | Purpose |
|-----------|------------|---------|
| Device ID | Yes (by ad partner) | Advertising |
| Advertising Data | Yes (by ad partner) | Advertising, analytics |
| Product Interaction | Yes (by ad partner) | Advertising, analytics |
| Coarse Location | Sometimes (derived from IP, by ad partner) | Advertising |

**Tracking:** Answer per your AdMob setup and consent flow (personalized vs non-personalized ads). If you use personalized ads, you may need to declare tracking and provide App Tracking Transparency where required.

**Data linked to you:** Usually **No** for first-party transfer data; ad partners may link data per their policies.

Also declare sensitive API usage aligned with `PrivacyInfo.xcprivacy`:

- User Defaults (CA92.1) — language and onboarding preferences

Update the hosted privacy policy and in-app Privacy Policy screen to match before submission.

---

## Export compliance

**Uses encryption:** No (or exempt) — `ITSAppUsesNonExemptEncryption` = **false** in Info.plist

---

## Screenshots (required)

Capture on real devices showing:

1. Receive screen with QR + PIN
2. Send screen with file selection
3. QR scanner / nearby receivers
4. Transfer in progress or received files list
5. Onboarding (optional)

Do **not** imply the app is Apple AirDrop or Google Quick Share.

---

## Pre-upload checklist

- [ ] Privacy Policy URL loads in Safari **and reflects advertising disclosure**
- [ ] Support URL loads in Safari
- [ ] `docs/PRE_SUBMISSION_QA.md` completed on two real devices
- [ ] Release build: `flutter build ipa`
- [ ] Upload via Xcode Organizer or Transporter
