import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_metadata.dart';
import '../../theme/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  Future<void> _openSupport() async {
    final uri = Uri.parse(AppMetadata.supportUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Use'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              _body,
              style: TextStyle(
                fontSize: 15,
                height: 1.55,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _openSupport,
              icon: const Icon(Icons.support_agent),
              label: const Text('Visit support page'),
            ),
          ],
        ),
      ),
    );
  }
}

const _body = '''
Last updated: June 18, 2026

By using File Share: Easy File Sharing ("File Share"), you agree to these Terms of Use.

Service Description
File Share transfers files directly between nearby devices. Transfers typically require both devices to be on the same Wi‑Fi network. The receiving device must keep File Share open with receiving active while files are sent. File Share does not operate a cloud storage service and does not guarantee transfer speed, availability, or success on every network.

Network and Session Requirements
• Both devices may need to be connected to the same local Wi‑Fi network for standard Wi‑Fi transfer.
• Public, guest, or corporate Wi‑Fi networks may block device-to-device communication. Transfers may fail on those networks.
• Each receive session uses a QR code, session token, and 4-digit PIN that expire after a limited time.
• On supported Apple devices, nearby offline discovery may use Bluetooth/Multipeer when Wi‑Fi IP transfer is unavailable.

Your Responsibilities
You are responsible for the files you send and receive and for complying with applicable laws. Do not use File Share to send unlawful, harmful, or infringing content. You are responsible for confirming you trust the device you connect to before entering a PIN or sending files.

Optional Export Through Other Apps
After receiving files, you may optionally share or export them using the iOS share sheet (for example AirDrop or other apps). That step is optional. Sharing through AirDrop, Mail, Messages, or other apps is subject to those services' own terms and policies.

No Warranty
File Share is provided "as is" without warranties of any kind. We do not guarantee uninterrupted, secure, or error-free operation on every device or network.

Limitation of Liability
To the maximum extent permitted by law, the developer is not liable for any indirect, incidental, or consequential damages arising from your use of File Share, failed transfers, network restrictions, or optional exports through third-party apps.

Changes
We may update these terms. Continued use after changes constitutes acceptance of the revised terms.

Contact
Support: https://sites.google.com/view/quick-share-easy-file-sharing1/home
Email: Quick-Share235@gmail.com
''';
