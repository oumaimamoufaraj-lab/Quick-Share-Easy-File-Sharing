import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../app/app_scope.dart';
import '../l10n/app_strings.dart';
import '../models/device_profile.dart';
import '../models/transfer_endpoint.dart';
import '../services/file_export_service.dart';
import '../services/transfer/transfer_service.dart';
import '../theme/app_colors.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final _nameController = TextEditingController();
  final _fileExport = const FileExportService();
  bool _editingName = false;

  TransferService get _transfer => AppScope.of(context).transfer;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _toggleReceiving(AppScopeController scope) async {
    if (_transfer.isReceiving) {
      await _transfer.stopReceiving();
    } else {
      await _transfer.startReceiving(
        deviceName: scope.deviceName,
        deviceId: scope.deviceId,
      );
    }
  }

  Future<void> _saveName(AppScopeController scope) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await scope.updateDeviceName(name);
    if (!mounted) return;
    setState(() => _editingName = false);
    if (_transfer.isReceiving) {
      await _transfer.stopReceiving();
      await _transfer.startReceiving(
        deviceName: scope.deviceName,
        deviceId: scope.deviceId,
      );
    }
  }

  Future<void> _shareFile(ReceivedFileItem item) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(item.path, name: item.name)]),
    );
  }

  Future<void> _saveToFiles(ReceivedFileItem item) async {
    final strings = S.of(context);
    final saved = await _fileExport.saveToFiles(
      sourcePath: item.path,
      fileName: item.name,
    );
    if (!mounted) return;
    _showSnack(
      saved ? strings.savedToFiles : strings.saveToFilesFailed,
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final scope = AppScope.of(context);

    if (!_editingName && _nameController.text != scope.deviceName) {
      _nameController.text = scope.deviceName;
    }

    return ListenableBuilder(
      listenable: _transfer,
      builder: (context, _) {
        final endpoint = _transfer.activeEndpoint;
        final state = _transfer.state;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text(
                  strings.tabReceive,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.receiveHint,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textGrey,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                _SessionCard(
                  deviceName: scope.deviceName,
                  nameController: _nameController,
                  editingName: _editingName,
                  isReceiving: _transfer.isReceiving,
                  isStarting: state == ReceiveServerState.starting,
                  isOfflineReceiving: _transfer.isOfflineReceiving,
                  errorMessage: _transfer.errorMessage,
                  endpoint: endpoint,
                  onToggleNameEdit: () {
                    if (_editingName) {
                      _saveName(scope);
                    } else {
                      setState(() => _editingName = true);
                    }
                  },
                  onToggleReceiving: () => _toggleReceiving(scope),
                  strings: strings,
                ),
                if (_transfer.isReceiving) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _transfer.isOfflineReceiving
                              ? CupertinoIcons.bluetooth
                              : CupertinoIcons.wifi,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            strings.waitingForFiles,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  strings.receivedFiles,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (_transfer.receivedFiles.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      strings.noReceivedFiles,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textGrey),
                    ),
                  )
                else
                  ..._transfer.receivedFiles.map(
                    (file) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ReceivedTile(
                        file: file,
                        onShare: () => _shareFile(file),
                        onSave: () => _saveToFiles(file),
                        onDelete: () => _transfer.deleteReceived(file),
                        strings: strings,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.deviceName,
    required this.nameController,
    required this.editingName,
    required this.isReceiving,
    required this.isStarting,
    required this.isOfflineReceiving,
    required this.errorMessage,
    required this.endpoint,
    required this.onToggleNameEdit,
    required this.onToggleReceiving,
    required this.strings,
  });

  final String deviceName;
  final TextEditingController nameController;
  final bool editingName;
  final bool isReceiving;
  final bool isStarting;
  final bool isOfflineReceiving;
  final String? errorMessage;
  final TransferEndpoint? endpoint;
  final VoidCallback onToggleNameEdit;
  final VoidCallback onToggleReceiving;
  final S strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            strings.receiveTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          if (isReceiving && endpoint != null) ...[
            QrImageView(
              data: endpoint!.toQrPayload(),
              size: 220,
              backgroundColor: AppColors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.textDark,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            if (isOfflineReceiving)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.antenna_radiowaves_left_right,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      strings.offlineReceiving,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              )
            else
              SelectableText(
                endpoint!.baseUrl,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textGrey,
                ),
              ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    strings.sessionPin,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    endpoint!.pin,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 8,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.sessionPinHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ] else
            Container(
              height: 220,
              alignment: Alignment.center,
              child: Icon(
                CupertinoIcons.antenna_radiowaves_left_right,
                size: 64,
                color: AppColors.primaryBlue.withValues(alpha: 0.35),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: editingName
                    ? CupertinoTextField(
                        controller: nameController,
                        placeholder: strings.deviceName,
                        padding: const EdgeInsets.all(12),
                      )
                    : Text(
                        deviceName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              IconButton(
                onPressed: onToggleNameEdit,
                icon: Icon(
                  editingName
                      ? CupertinoIcons.checkmark_circle_fill
                      : CupertinoIcons.pencil_circle,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isStarting ? null : onToggleReceiving,
              style: FilledButton.styleFrom(
                backgroundColor:
                    isReceiving ? Colors.red.shade600 : AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isStarting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      isReceiving
                          ? strings.stopReceiving
                          : strings.startReceiving,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceivedTile extends StatelessWidget {
  const _ReceivedTile({
    required this.file,
    required this.onShare,
    required this.onSave,
    required this.onDelete,
    required this.strings,
  });

  final ReceivedFileItem file;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onDelete;
  final S strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
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
                CupertinoIcons.doc_fill,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      formatFileSize(file.size),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: onSave,
                icon: const Icon(CupertinoIcons.folder, size: 18),
                label: Text(strings.saveToFiles),
              ),
              TextButton.icon(
                onPressed: onShare,
                icon: const Icon(CupertinoIcons.share, size: 18),
                label: Text(strings.shareReceived),
              ),
              const Spacer(),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(CupertinoIcons.delete),
                color: Colors.red.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
