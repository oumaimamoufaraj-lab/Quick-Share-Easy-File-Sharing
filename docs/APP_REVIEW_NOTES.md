# App Review Notes — File Share: Easy File Sharing

Paste this into **App Store Connect → App Review Information → Notes** when submitting.

---

## Overview

**File Share: Easy File Sharing** is a **local, device-to-device file transfer app**. It does **not** require login and does **not** upload transfer files to developer servers.

The app **displays third-party ads** (Google AdMob, with optional mediation partners when enabled):

- **App open ad** — may appear once after the splash screen on cold start.
- **Banner ad** — appears above the bottom tab bar on the main Send, Receive, and Settings screens. It is hidden while the QR scanner is open.

File transfer, QR pairing, and PIN entry are **not blocked** by ads. Ads do not receive the user’s selected files or transfer payload.

Primary flow: **same Wi‑Fi → QR pairing → 4-digit PIN → direct transfer**.

---

## Contact

- **Email:** Quick-Share235@gmail.com
- **Support URL:** https://sites.google.com/view/quick-share-easy-file-sharing1/home
- **Privacy Policy:** https://sites.google.com/view/quick-share-easy-file-sharing/home

---

## How to Test (recommended)

Use **two real devices** on the **same Wi‑Fi network**.

1. Install the app on **Device A** and **Device B**.
2. Connect both devices to the **same Wi‑Fi network** (avoid guest/corporate Wi‑Fi if possible).
3. On **Device A**, open **Receive** and tap **Start Receiving**.
4. A **QR code** and **4-digit PIN** should appear on Device A.
5. On **Device B**, open **Send** and tap **Scan Receiver QR** (grant **Camera** if prompted).
6. Scan Device A’s QR code.
7. Enter the **PIN** if prompted (also required for nearby-receiver pairing).
8. On Device B, tap **Select Files**, choose one or more files, then tap **Send Directly**.
9. On Device A, incoming transfer progress should appear; received files should show in the **Received Files** list.
10. On Device A, open a received file action: **Share** (optional iOS share sheet export) or **Delete**.

### Optional: Nearby receivers (same Wi‑Fi)

1. Start receiving on Device A.
2. On Device B, open **Send** and check **Nearby Receivers**.
3. Tap the receiver, enter the PIN shown on Device A, then send files.

### Optional: Browser upload (cross-platform)

1. Start receiving on Device A.
2. On a computer or phone browser on the same Wi‑Fi, open the **HTTP URL** embedded in the QR payload (or scan and open in browser).
3. Enter the **PIN** on the upload page and send a test file.

### Optional: Offline Multipeer (two iPhones, no Wi‑Fi IP)

1. On two iPhones without usable Wi‑Fi IP, start receiving on Device A.
2. Device A may show **Offline mode**.
3. On Device B, use **Nearby Receivers** over Bluetooth/Multipeer, enter PIN, and send a small test file.

---

## Permissions (why we request them)

| Permission | Purpose |
|------------|---------|
| **Camera** | Scan receiver QR codes on the Send screen |
| **Local Network** | Discover nearby receivers and transfer files directly over Wi‑Fi (Bonjour/mDNS) |
| **Photo Library / Files** | Only when the user picks photos, videos, or other files to send |
| **Bluetooth** | Nearby/offline Apple device discovery when Multipeer transfer is active |

**Internet** is used for ad loading and remote ad configuration. Camera, Local Network, Photos/Files, and Bluetooth are used only for transfer features as described above—not for serving ads.

---

## Advertising (for review)

1. Launch the app — after the splash screen, an **app open ad** may appear (if loaded from remote config).
2. Dismiss the ad (or wait if none loads) to reach the main tabs.
3. A **banner ad** may appear above the bottom navigation bar.
4. Open **Send → Scan Receiver QR** — the bottom banner should **hide** during scanning.
5. Complete the normal two-device transfer test below — transfer must work with ads enabled or disabled.

Ad behavior is controlled by a remote configuration file fetched at startup. If ads fail to load, the app continues normally.

---

## Login / accounts

**No login required.** Reviewers can test immediately after install.

---

## Encryption export

App uses standard iOS networking only. **ITSAppUsesNonExemptEncryption** is set to **false**.

---

## Known limitations (not bugs)

- Both devices usually need the **same Wi‑Fi** for standard transfer.
- **Public/corporate/guest Wi‑Fi** may block device-to-device traffic; transfer may fail with a network error.
- The **receiver must keep the app open** with receiving active during transfer.
- **Multipeer** requires **two real iPhones**; the iOS Simulator has limited Multipeer support.
- **Share sheet** is an **optional export** for already-received files, not the primary transfer method.

---

## Privacy Policy URL

https://sites.google.com/view/quick-share-easy-file-sharing/home

Full metadata: see `docs/APP_STORE_CONNECT.md`.
