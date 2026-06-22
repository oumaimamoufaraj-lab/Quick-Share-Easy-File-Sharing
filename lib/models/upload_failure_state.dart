import 'dart:io';

import 'transfer_endpoint.dart';

class UploadFailureState {
  const UploadFailureState({
    required this.endpoint,
    required this.files,
    required this.names,
    required this.failedAtIndex,
    required this.message,
  });

  final TransferEndpoint endpoint;
  final List<File> files;
  final List<String> names;
  final int failedAtIndex;
  final String message;

  int get remainingCount => files.length - failedAtIndex;

  String get failedFileName => names[failedAtIndex];
}
