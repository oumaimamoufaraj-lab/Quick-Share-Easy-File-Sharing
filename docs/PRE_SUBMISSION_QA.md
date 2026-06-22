# Pre-Submission QA Checklist — File Share: Easy File Sharing

Use this checklist on **real devices** before uploading to the App Store.  
Mark each item **Pass / Fail / N/A** and note the device + iOS version.

---

## Core transfer flows

- [ ] **iPhone → iPhone (same Wi‑Fi)** — Receive on A, scan QR on B, send file, file appears on A
- [ ] **iPhone → Android** — Receive on Android app or browser upload page; sender completes transfer
- [ ] **Android → iPhone** — If supported in your build, verify sender can reach iOS receiver
- [ ] **Browser upload** — Open receiver URL in Safari/Chrome on same Wi‑Fi, enter PIN, upload file

---

## QR & session security

- [ ] **QR scan on real device** — Camera permission prompt is clear; scan connects to receiver
- [ ] **Wrong PIN rejected** — Enter incorrect PIN; app shows error and does not connect
- [ ] **Expired session rejected** — Wait for session TTL (~30 min) or stop/restart receive; old QR/PIN fails safely
- [ ] **Invalid QR** — Non-app QR shows friendly error message

---

## Transfer reliability

- [ ] **Small file** (< 1 MB) — Sends and receives successfully
- [ ] **Large file** (> 50 MB) — Chunked upload works; progress updates on sender
- [ ] **Multiple files** — Batch send completes; all files listed on receiver
- [ ] **Cancel transfer** — Cancel mid-upload; sender stops cleanly; receiver state recovers
- [ ] **Retry transfer** — Force failure (e.g. toggle Wi‑Fi briefly); retry banner works (up to 3 attempts)
- [ ] **Duplicate filenames** — Two files with same name get unique names on receiver

---

## Receiver behavior

- [ ] **Foreground receiving** — Receiver stays on Receive screen; transfer completes
- [ ] **Screen awake** — Wakelock keeps screen on while receiving
- [ ] **Stop receiving** — Stopping session invalidates QR/PIN for new sends
- [ ] **Received file actions** — Open, Share (optional AirDrop), Save to Files, Delete

---

## Network edge cases

- [ ] **Same Wi‑Fi success** — Home Wi‑Fi transfer works
- [ ] **Public/corporate Wi‑Fi blocked** — Guest or office Wi‑Fi shows clear failure (not a crash)
- [ ] **No Wi‑Fi IP / offline** — iPhone shows offline Multipeer mode when applicable
- [ ] **Nearby receivers list** — mDNS/Bonjour discovery lists active receiver; PIN required

---

## Permissions & first launch

- [ ] **Camera prompt** — Appears only when scanning QR; description matches Info.plist
- [ ] **Local Network prompt** — Appears when discovery/transfer needs it; description accurate
- [ ] **Bluetooth prompt** — Appears only when Multipeer/nearby offline discovery is used
- [ ] **Photo/file picker** — No photo access until user taps Select Files
- [ ] **Language selection** — First launch language screen works
- [ ] **Onboarding (3 pages)** — Copy matches Wi‑Fi + QR + PIN flow; Get Started enters main app
- [ ] **Splash screen** — Shows on cold start; transitions to language or main flow without flash

---

## Settings & legal

- [ ] **Privacy Policy** — In-app text matches actual app behavior (local Wi‑Fi transfer, not AirDrop-only)
- [ ] **Terms of Use** — Mentions same Wi‑Fi, receiver foreground, network limitations
- [ ] **How to Connect** — iOS / Android / Web tabs show accurate steps
- [ ] **Reset onboarding** — Settings → Show Introduction Again works
- [ ] **Hosted privacy URL** — https://sites.google.com/view/quick-share-easy-file-sharing/home loads in Safari
- [ ] **Support URL** — https://sites.google.com/view/quick-share-easy-file-sharing1/home loads in Safari

---

## UI & stability

- [ ] **iPhone SE layout** — No overflow on onboarding, Send, Receive, Settings
- [ ] **iPad** — Portrait layouts usable (if supporting iPad)
- [ ] **No crashes** — Cold start, background/foreground, rotate (if allowed), tab switching
- [ ] **Localization smoke test** — At least one non-English language displays correctly

---

## App Store metadata (outside app binary)

- [ ] **Screenshots** — Show real Send/Receive/QR flow (not misleading AirDrop-only UI)
- [ ] **Description** — States local Wi‑Fi + QR + PIN; AirDrop only as optional export
- [ ] **Privacy nutrition labels** — Local network, camera, photos, Bluetooth declared accurately
- [ ] **Support URL** — Live support page or mailto link
- [ ] **Age rating** — Questionnaire completed
- [ ] **Export compliance** — ITSAppUsesNonExemptEncryption = false confirmed

---

## Ads & tracking

- [ ] **No ads** — Confirm no ad SDKs or consent dialogs (N/A if no ads)
- [ ] **No analytics/tracking SDKs** — Confirm Privacy Manifest and App Store labels say no tracking

---

## Release build

- [ ] **Release IPA** — `flutter build ipa` succeeds with distribution certificate
- [ ] **TestFlight** — Internal testers complete full two-device flow on TestFlight build
- [ ] **App Review Notes** — `docs/APP_REVIEW_NOTES.md` pasted into App Store Connect

---

## Sign-off

| Tester | Date | Devices tested | Result |
|--------|------|----------------|--------|
|        |      |                |        |
