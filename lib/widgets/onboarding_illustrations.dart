import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.illustration,
    this.compactTitle,
  });

  final String title;
  final String? compactTitle;
  final String subtitle;
  final Widget illustration;
}

class ScanConnectIllustration extends StatelessWidget {
  const ScanConnectIllustration({super.key});

  static const _sessionUrl = 'http://192.168.1.23:10001/s/ABCD1234';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = (width / 390).clamp(0.72, 1.0);
    final leftWidth = 148 * scale;
    final rightWidth = 172 * scale;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                left: width * 0.04,
                top: 8 * scale,
                child: Transform.rotate(
                  angle: -0.06,
                  child: _PhoneFrame(
                    width: leftWidth,
                    child: _ScannerPhoneContent(sessionUrl: _sessionUrl),
                  ),
                ),
              ),
              Positioned(
                right: width * 0.02,
                bottom: 4 * scale,
                child: _PhoneFrame(
                  width: rightWidth,
                  elevation: 18,
                  child: const _ReceiverPhoneContent(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScannerPhoneContent extends StatelessWidget {
  const _ScannerPhoneContent({required this.sessionUrl});

  final String sessionUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QR Code Scanner',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: CustomPaint(painter: _MiniQrPainter()),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  sessionUrl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 6.5,
                    height: 1.25,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _ActionChip(icon: Icons.copy_rounded, label: 'Copy'),
            _ActionChip(icon: Icons.share_rounded, label: 'Share'),
          ],
        ),
      ],
    );
  }
}

class _ReceiverPhoneContent extends StatelessWidget {
  const _ReceiverPhoneContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Scan QR Code to Receive',
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CustomPaint(painter: _MiniQrPainter(dense: true)),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 28,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withValues(alpha: 0.0),
                        Colors.green.withValues(alpha: 0.95),
                        Colors.green.withValues(alpha: 0.0),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.65),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'SCANNING ...',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Cancel',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class NearbyDevicesIllustration extends StatelessWidget {
  const NearbyDevicesIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = (width / 390).clamp(0.72, 1.0);
    final phoneWidth = 136 * scale;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                left: width * 0.06,
                top: 10 * scale,
                child: _PlatformPhone(
                  width: phoneWidth,
                  label: 'Receive',
                  icon: Icons.apple,
                  iconColor: AppColors.iosBlue,
                  ringColor: AppColors.iosBlue,
                ),
              ),
              Positioned(
                right: width * 0.04,
                bottom: 6 * scale,
                child: _PlatformPhone(
                  width: phoneWidth,
                  label: 'Send',
                  icon: Icons.apple,
                  iconColor: AppColors.iosBlue,
                  ringColor: AppColors.iosBlue,
                  elevation: 18,
                ),
              ),
              Positioned(
                left: width * 0.43,
                top: constraints.maxHeight * 0.38,
                child: _TransferBadge(size: 42 * scale),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TransferBadge extends StatelessWidget {
  const _TransferBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.swap_horiz_rounded,
        color: AppColors.white,
        size: size * 0.55,
      ),
    );
  }
}

class ShareFilesIllustration extends StatelessWidget {
  const ShareFilesIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = (width / 390).clamp(0.72, 1.0);
    final phoneWidth = 228 * scale;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Center(
            child: _PhoneFrame(
              width: phoneWidth,
              elevation: 16,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: phoneWidth - 20,
                  child: _ShareFilesPhoneContent(scale: scale),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShareFilesPhoneContent extends StatelessWidget {
  const _ShareFilesPhoneContent({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share Files',
          style: TextStyle(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 8 * scale),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 8 * scale,
            vertical: 7 * scale,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Selected Files : 3 items (24.5MB)',
                  style: TextStyle(
                    fontSize: 8.5 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * scale,
                  vertical: 4 * scale,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Send Files',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 8 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10 * scale),
        _DateSectionHeader(label: 'Today (06)', scale: scale),
        SizedBox(height: 6 * scale),
        Stack(
          clipBehavior: Clip.none,
          children: [
            _PhotoGrid(
              itemCount: 9,
              selectedIndices: const {0, 2, 4},
              scale: scale,
            ),
            Positioned(
              right: 18 * scale,
              bottom: -6 * scale,
              child: Transform.rotate(
                angle: -0.25,
                child: Icon(
                  Icons.touch_app_rounded,
                  size: 34 * scale,
                  color: AppColors.primaryBlue.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10 * scale),
        _DateSectionHeader(label: 'March 23, 2026 (06)', scale: scale),
        if (scale >= 0.78) ...[
          SizedBox(height: 6 * scale),
          _PhotoGrid(
            itemCount: 3,
            selectedIndices: const {1},
            scale: scale,
          ),
        ],
      ],
    );
  }
}

class _DateSectionHeader extends StatelessWidget {
  const _DateSectionHeader({required this.label, required this.scale});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10 * scale,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(width: 4 * scale),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 14 * scale,
          color: AppColors.textDark,
        ),
      ],
    );
  }
}

class _PlatformPhone extends StatelessWidget {
  const _PlatformPhone({
    required this.width,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.ringColor,
    this.elevation = 12,
  });

  final double width;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color ringColor;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return _PhoneFrame(
      width: width,
      elevation: elevation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: width * 0.72,
            height: width * 0.72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (int i = 4; i >= 1; i--)
                  Container(
                    width: width * 0.28 + i * (width * 0.09),
                    height: width * 0.28 + i * (width * 0.09),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ringColor.withValues(alpha: 0.12 + i * 0.04),
                        width: 1.5,
                      ),
                    ),
                  ),
                Container(
                  width: width * 0.34,
                  height: width * 0.34,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.white, size: width * 0.2),
                ),
              ],
            ),
          ),
          SizedBox(height: width * 0.08),
          Text(
            label,
            style: TextStyle(
              fontSize: width * 0.1,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({
    required this.width,
    required this.child,
    this.elevation = 12,
  });

  final double width;
  final Widget child;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 1.72,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textDark, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: elevation,
            offset: Offset(0, elevation / 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: AppColors.textDark),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

const _photoColors = <Color>[
  Color(0xFF90A4AE),
  Color(0xFF81C784),
  Color(0xFF64B5F6),
  Color(0xFFFFB74D),
  Color(0xFFBA68C8),
  Color(0xFF4DB6AC),
];

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({
    required this.selectedIndices,
    this.itemCount = 6,
    this.scale = 1,
  });

  final Set<int> selectedIndices;
  final int itemCount;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4 * scale,
        mainAxisSpacing: 4 * scale,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final isSelected = selectedIndices.contains(index);
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _photoColors[index % _photoColors.length],
                    _photoColors[(index + 2) % _photoColors.length],
                  ],
                ),
                borderRadius: BorderRadius.circular(4 * scale),
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(3 * scale),
                  child: Icon(
                    Icons.image_outlined,
                    size: 10 * scale,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 2 * scale,
                right: 2 * scale,
                child: Container(
                  width: 14 * scale,
                  height: 14 * scale,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(3 * scale),
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 10 * scale,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MiniQrPainter extends CustomPainter {
  const _MiniQrPainter({this.dense = false});

  final bool dense;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.textDark;
    final cell = dense ? 5.0 : 6.0;
    final cols = (size.width / cell).floor();
    final rows = (size.height / cell).floor();

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final hash = (row * 17 + col * 31) % 5;
        if (hash == 0) continue;
        canvas.drawRect(
          Rect.fromLTWH(col * cell, row * cell, cell - 0.8, cell - 0.8),
          paint,
        );
      }
    }

    _drawFinder(canvas, paint, cell, 0, 0);
    _drawFinder(canvas, paint, cell, cols - 7, 0);
    _drawFinder(canvas, paint, cell, 0, rows - 7);
  }

  void _drawFinder(Canvas canvas, Paint paint, double cell, int col, int row) {
    final origin = Offset(col * cell, row * cell);
    canvas.drawRect(
      Rect.fromLTWH(origin.dx, origin.dy, cell * 7, cell * 7),
      paint,
    );
    final inner = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(origin.dx + cell, origin.dy + cell, cell * 5, cell * 5),
      inner,
    );
    canvas.drawRect(
      Rect.fromLTWH(origin.dx + cell * 2, origin.dy + cell * 2, cell * 3, cell * 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
