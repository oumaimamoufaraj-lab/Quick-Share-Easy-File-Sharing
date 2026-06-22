import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../app/app_scope.dart';
import '../l10n/app_strings.dart';
import '../models/discovered_receiver.dart';
import '../models/device_profile.dart';
import '../models/transfer_endpoint.dart';
import '../models/upload_failure_state.dart';
import '../services/transfer/transfer_client.dart';
import '../services/transfer/transfer_service.dart';
import '../theme/app_colors.dart';
import '../util/global.dart';
import 'qr_scanner_screen.dart';

class SelectedFile {
  SelectedFile({required this.path, required this.name, required this.size});

  final String path;
  final String name;
  final int size;
}

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final List<SelectedFile> _files = [];
  TransferEndpoint? _receiver;
  TransferService? _transfer;
  bool _startedBrowsing = false;
  bool _isBusy = false;
  double _uploadProgress = 0;
  String? _uploadingFileName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _transfer = AppScope.of(context).transfer;
    if (!_startedBrowsing) {
      _startedBrowsing = true;
      _transfer?.startBrowsingReceivers();
    }
  }

  @override
  void dispose() {
    _transfer?.stopBrowsingReceivers();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withReadStream: false,
      );
      if (result == null) return;

      final picked = <SelectedFile>[];
      for (final file in result.files) {
        final path = file.path;
        if (path == null) continue;
        final size = file.size > 0 ? file.size : await File(path).length();
        picked.add(SelectedFile(path: path, name: file.name, size: size));
      }

      if (!mounted || picked.isEmpty) return;
      setState(() => _files.addAll(picked));
    } on PlatformException {
      if (!mounted) return;
      _showMessage(S.of(context).pickError);
    }
  }

  Future<void> _scanReceiver() async {
    hideBottomBanner.value = true;
    final scanned = await Navigator.of(context).push<TransferEndpoint>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    hideBottomBanner.value = false;
    if (!mounted || scanned == null) return;

    final transfer = AppScope.of(context).transfer;
    final strings = S.of(context);
    setState(() => _isBusy = true);
    try {
      final endpoint = await transfer.resolveEndpoint(scanned);
      final ready = await transfer.pingReceiver(endpoint);
      if (!mounted) return;
      if (!ready) {
        _showMessage(strings.receiverNotReady);
        return;
      }
      setState(() => _receiver = endpoint);
      _showMessage('${strings.connectedTo} ${endpoint.deviceName}');
    } on TransferException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _connectToNearby(DiscoveredReceiver receiver) async {
    if (_isBusy) return;

    final pin = await _promptPin(receiver.deviceName);
    if (!mounted || pin == null) return;

    setState(() => _isBusy = true);
    try {
      final endpoint = await AppScope.of(context).transfer.pairWithDiscoveredReceiver(
            receiver: receiver,
            pin: pin,
          );
      if (!mounted) return;
      setState(() => _receiver = endpoint);
      _showMessage('${S.of(context).connectedTo} ${endpoint.deviceName}');
    } on TransferException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<String?> _promptPin(String deviceName) async {
    final controller = TextEditingController();
    final strings = S.of(context);

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.enterPinTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.enterPinBody(deviceName)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                autofocus: true,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: strings.enterPinHint,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.dismiss),
            ),
            FilledButton(
              onPressed: () {
                final pin = controller.text.trim();
                if (pin.length != 4) return;
                Navigator.of(context).pop(pin);
              },
              child: Text(strings.connect),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendDirectly() async {
    final receiver = _receiver;
    if (receiver == null) {
      await _scanReceiver();
      return;
    }
    if (_files.isEmpty || _isBusy) return;

    setState(() {
      _isBusy = true;
      _uploadProgress = 0;
    });

    try {
      final transfer = AppScope.of(context).transfer;
      final resolved = await transfer.resolveEndpoint(receiver);
      await transfer.uploadFiles(
        endpoint: resolved,
        files: _files.map((f) => File(f.path)).toList(),
        names: _files.map((f) => f.name).toList(),
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            _uploadProgress = progress.fraction;
            _uploadingFileName = progress.fileName;
          });
        },
      );
      if (!mounted) return;
      _showMessage(S.of(context).uploadComplete);
      setState(() {
        _files.clear();
        _uploadProgress = 0;
        _uploadingFileName = null;
      });
    } on TransferCancelledException {
      if (!mounted) return;
      _showMessage(S.of(context).uploadCancelled);
    } on TransferException catch (error) {
      if (!mounted) return;
      _showMessage('${S.of(context).uploadFailed}: ${error.message}');
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
          _uploadingFileName = null;
        });
      }
    }
  }

  void _cancelUpload() {
    AppScope.of(context).transfer.cancelUpload();
  }

  Future<void> _retryUpload() async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
      _uploadProgress = 0;
    });

    try {
      final transfer = AppScope.of(context).transfer;
      await transfer.retryLastUpload(
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            _uploadProgress = progress.fraction;
            _uploadingFileName = progress.fileName;
          });
        },
      );
      if (!mounted) return;
      _showMessage(S.of(context).uploadComplete);
      setState(() {
        _files.clear();
        _uploadProgress = 0;
        _uploadingFileName = null;
      });
    } on TransferCancelledException {
      if (!mounted) return;
      _showMessage(S.of(context).uploadCancelled);
    } on TransferException catch (error) {
      if (!mounted) return;
      _showMessage('${S.of(context).uploadFailed}: ${error.message}');
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
          _uploadingFileName = null;
        });
      }
    }
  }

  void _dismissRetry() {
    AppScope.of(context).transfer.clearLastFailure();
  }

  Future<void> _shareViaOtherApps() async {
    if (_files.isEmpty || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      final box = context.findRenderObject() as RenderBox?;
      final origin = box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size;

      await SharePlus.instance.share(
        ShareParams(
          files: _files.map((f) => XFile(f.path, name: f.name)).toList(),
          subject: 'File Share',
          sharePositionOrigin: origin,
        ),
      );
      if (!mounted) return;
      _showMessage(S.of(context).shareSuccess);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  int get _totalSize => _files.fold(0, (sum, file) => sum + file.size);

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final transfer = AppScope.of(context).transfer;
    final isCompact = MediaQuery.sizeOf(context).height < 700;

    return ListenableBuilder(
      listenable: transfer,
      builder: (context, _) {
        final failure = transfer.lastFailure;
        final canRetry = transfer.canRetryUpload && !_isBusy;
        final nearby = transfer.discoveredReceivers;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                20,
                                isCompact ? 8 : 16,
                                20,
                                isCompact ? 4 : 8,
                              ),
                              child: Text(
                                strings.tabSend,
                                style: TextStyle(
                                  fontSize: isCompact ? 28 : 34,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Text(
                                strings.sendHint,
                                style: TextStyle(
                                  fontSize: isCompact ? 14 : 15,
                                  color: AppColors.textGrey,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            SizedBox(height: isCompact ? 10 : 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: _ReceiverCard(
                                receiver: _receiver,
                                onScan: _scanReceiver,
                                onDisconnect: () =>
                                    setState(() => _receiver = null),
                                strings: strings,
                                compact: isCompact,
                              ),
                            ),
                            SizedBox(height: isCompact ? 8 : 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: _NearbyReceiversCard(
                                receivers: nearby,
                                isBrowsing: transfer.isBrowsingReceivers,
                                isBusy: _isBusy,
                                onSelect: _connectToNearby,
                                strings: strings,
                                compact: isCompact,
                              ),
                            ),
                            if (canRetry && failure != null) ...[
                              SizedBox(height: isCompact ? 8 : 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: _RetryBanner(
                                  failure: failure,
                                  strings: strings,
                                  onRetry: _retryUpload,
                                  onDismiss: _dismissRetry,
                                ),
                              ),
                            ],
                            if (_isBusy && _uploadingFileName != null) ...[
                              SizedBox(height: isCompact ? 8 : 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _uploadingFileName!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: _cancelUpload,
                                          child: Text(strings.cancelUpload),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    LinearProgressIndicator(
                                      value: _uploadProgress,
                                      backgroundColor: AppColors.divider,
                                      color: AppColors.primaryBlue,
                                      minHeight: 6,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            SizedBox(height: isCompact ? 8 : 16),
                          ],
                        ),
                      ),
                      if (_files.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyState(
                            onPick: _pickFiles,
                            compact: isCompact,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          sliver: SliverList.separated(
                            itemCount: _files.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final file = _files[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    CupertinoIcons.doc_fill,
                                    color: AppColors.primaryBlue,
                                  ),
                                  title: Text(
                                    file.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(formatFileSize(file.size)),
                                  trailing: IconButton(
                                    onPressed: () =>
                                        setState(() => _files.removeAt(index)),
                                    icon: const Icon(
                                      CupertinoIcons.clear_circled_solid,
                                    ),
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                _BottomBar(
                  fileCount: _files.length,
                  totalSize: _totalSize,
                  isBusy: _isBusy,
                  hasReceiver: _receiver != null,
                  onPick: _pickFiles,
                  onSendDirectly: _sendDirectly,
                  onShareOther: _shareViaOtherApps,
                  strings: strings,
                  compact: isCompact,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NearbyReceiversCard extends StatelessWidget {
  const _NearbyReceiversCard({
    required this.receivers,
    required this.isBrowsing,
    required this.isBusy,
    required this.onSelect,
    required this.strings,
    this.compact = false,
  });

  final List<DiscoveredReceiver> receivers;
  final bool isBrowsing;
  final bool isBusy;
  final void Function(DiscoveredReceiver receiver) onSelect;
  final S strings;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final listMaxHeight = compact ? 96.0 : 160.0;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.wifi,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.nearbyReceivers,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isBrowsing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            strings.nearbyReceiversHint,
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              color: AppColors.textGrey,
              height: 1.35,
            ),
          ),
          SizedBox(height: compact ? 8 : 12),
          if (receivers.isEmpty)
            Text(
              strings.noNearbyReceivers,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: listMaxHeight),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: receivers.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: compact ? 6 : 8),
                itemBuilder: (context, index) {
                  final receiver = receivers[index];
                  return Material(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: isBusy ? null : () => onSelect(receiver),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: compact ? 8 : 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              receiver.isMultipeer
                                  ? CupertinoIcons
                                      .antenna_radiowaves_left_right
                                  : CupertinoIcons.device_phone_portrait,
                              color: AppColors.primaryBlue,
                              size: compact ? 20 : 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    receiver.deviceName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (receiver.isMultipeer)
                                    Text(
                                      strings.offlinePeer,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(
                              CupertinoIcons.chevron_right,
                              size: 16,
                              color: AppColors.textGrey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _RetryBanner extends StatelessWidget {
  const _RetryBanner({
    required this.failure,
    required this.strings,
    required this.onRetry,
    required this.onDismiss,
  });

  final UploadFailureState failure;
  final S strings;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final hint = strings.retryUploadHint
        .replaceFirst('%s', failure.failedFileName)
        .replaceFirst('%d', '${failure.remainingCount}');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            failure.message,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                child: Text(strings.retryUpload),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: onDismiss, child: Text(strings.dismiss)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReceiverCard extends StatelessWidget {
  const _ReceiverCard({
    required this.receiver,
    required this.onScan,
    required this.onDisconnect,
    required this.strings,
    this.compact = false,
  });

  final TransferEndpoint? receiver;
  final VoidCallback onScan;
  final VoidCallback onDisconnect;
  final S strings;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: receiver == null
          ? Row(
              children: [
                const Icon(CupertinoIcons.qrcode_viewfinder,
                    color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.scanToConnect,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                FilledButton(
                  onPressed: onScan,
                  style: compact
                      ? FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        )
                      : null,
                  child: Text(strings.scanQr),
                ),
              ],
            )
          : Row(
              children: [
                const Icon(CupertinoIcons.checkmark_seal_fill,
                    color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.connectedTo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                      Text(
                        receiver!.deviceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: onDisconnect, child: Text(strings.disconnect)),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onPick, this.compact = false});

  final VoidCallback onPick;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 72 : 88,
              height: compact ? 72 : 88,
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(compact ? 18 : 24),
              ),
              child: Icon(
                CupertinoIcons.folder,
                size: compact ? 32 : 40,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: compact ? 12 : 20),
            Text(
              strings.noFilesSelected,
              style: TextStyle(
                fontSize: compact ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: compact ? 16 : 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPick,
                icon: const Icon(CupertinoIcons.add),
                label: Text(strings.selectFiles),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: compact ? 12 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.fileCount,
    required this.totalSize,
    required this.isBusy,
    required this.hasReceiver,
    required this.onPick,
    required this.onSendDirectly,
    required this.onShareOther,
    required this.strings,
    this.compact = false,
  });

  final int fileCount;
  final int totalSize;
  final bool isBusy;
  final bool hasReceiver;
  final VoidCallback onPick;
  final VoidCallback onSendDirectly;
  final VoidCallback onShareOther;
  final S strings;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final buttonPadding = EdgeInsets.symmetric(vertical: compact ? 12 : 16);

    return Container(
      padding: EdgeInsets.fromLTRB(20, compact ? 8 : 12, 20, compact ? 12 : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fileCount > 0)
            Padding(
              padding: EdgeInsets.only(bottom: compact ? 8 : 12),
              child: Row(
                children: [
                  Text(
                    '$fileCount ${strings.filesSelected}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    formatFileSize(totalSize),
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onPick,
                  style: OutlinedButton.styleFrom(
                    padding: buttonPadding,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: AppColors.primaryBlue),
                  ),
                  child: Text(strings.selectFiles),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: isBusy ? null : onSendDirectly,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: buttonPadding,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    hasReceiver
                        ? strings.sendDirectly
                        : strings.scanToConnect,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: fileCount == 0 || isBusy ? null : onShareOther,
                  style: OutlinedButton.styleFrom(
                    padding: buttonPadding,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(strings.sendViaOtherApps),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
