import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_metadata.dart';
import '../../theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static String get body => _privacyPolicyBody;

  Future<void> _openHostedPolicy() async {
    final uri = Uri.parse(AppMetadata.privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        actions: [
          IconButton(
            tooltip: 'Open online',
            onPressed: _openHostedPolicy,
            icon: const Icon(Icons.open_in_browser),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              _privacyPolicyBody,
              style: TextStyle(
                fontSize: 15,
                height: 1.55,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _openHostedPolicy,
              icon: const Icon(Icons.link),
              label: const Text('View hosted privacy policy'),
            ),
          ],
        ),
      ),
    );
  }
}

const _privacyPolicyBody = '''
Last updated: June 18, 2026

File Share: Easy File Sharing ("File Share") is a local file-transfer app. It helps you send files directly between nearby devices over the same Wi‑Fi network using QR code pairing, a session token, and a 4-digit PIN. On supported Apple devices, File Share can also discover nearby receivers using Bonjour/mDNS and optional offline Multipeer Connectivity.

File Share does not require an account, does not upload your files to our servers, and does not sell your personal information.

How File Share Works
• The receiving device starts a local transfer session and displays a QR code and PIN.
• The sending device scans the QR code (or selects a nearby receiver) and enters the PIN when prompted.
• Files are transferred directly between devices on the local network or, when available, through Apple Multipeer Connectivity.
• Received files are stored locally on the receiving device.

Information We Collect
File Share does not collect personal information on developer-operated servers. The app stores the following data locally on your device only:
• Your selected language preference
• Whether you completed the introduction screens
• A randomly generated device identifier and optional device name shown on QR codes and in nearby discovery

Advertising
File Share is free to use and may display ads from third-party partners, including Google AdMob and, when enabled, other ad networks used for mediation (such as AppLovin or Meta Audience Network).

Ad formats that may appear:
• App open ads — a full-screen ad may appear once when you open the app (after the splash screen).
• Banner ads — a small ad may appear above the bottom tab bar on the main screens. The banner is hidden while the QR scanner is open.

We do not send your selected files, transfer content, PIN, or QR session data to advertising partners.

Third-party ad providers may collect device and ad interaction information to deliver and measure ads, such as advertising identifiers (where permitted), IP address, and ad impressions or clicks. Their use of data is governed by their own privacy policies. For Google ads, see: https://policies.google.com/privacy

Where required, the app may show a consent message before personalized ads are used. We do not operate our own ad server.

Information We Do Not Collect
We do not upload your files to a cloud service operated by us. We do not operate a separate first-party analytics product in this app. Your transfer files, PIN, and QR session content are not collected on developer-operated servers.

Permissions
File Share requests permissions only when needed for features you use:
• Camera — to scan a receiver QR code when you choose Scan QR Code
• Photo Library / Files — only when you choose photos, videos, or other files to send through the system picker
• Local Network — to discover nearby receivers and transfer files directly over Wi‑Fi
• Bluetooth — only for nearby/offline Apple device discovery when Multipeer transfer is active

These permissions are not requested for advertising.

Optional Share Sheet / AirDrop
After you receive files, you may optionally export them using the iOS share sheet (for example AirDrop, Mail, or Messages). That export is your choice and is handled by iOS and the app you select. File Share does not require AirDrop or any third-party app to complete a direct transfer.

Children's Privacy
File Share is not directed to children under 13, and we do not knowingly collect information from children.

Changes
We may update this policy from time to time. Continued use of the app after changes means you accept the updated policy.

Contact
Privacy policy (web): https://sites.google.com/view/quick-share-easy-file-sharing/home
Support: https://sites.google.com/view/quick-share-easy-file-sharing1/home
Email: Quick-Share235@gmail.com
''';
