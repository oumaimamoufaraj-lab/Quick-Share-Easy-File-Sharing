import 'dart:typed_data';

class ShareResponse {
  const ShareResponse({
    required this.statusCode,
    required this.body,
    this.contentType,
  });

  final int statusCode;
  final List<int> body;
  final String? contentType;

  Map<String, dynamic> toMap() => {
        'statusCode': statusCode,
        'contentType': contentType,
        'body': body,
      };

  factory ShareResponse.fromMap(Map<dynamic, dynamic> map) {
    final rawBody = map['body'];
    return ShareResponse(
      statusCode: map['statusCode'] as int? ?? 500,
      contentType: map['contentType'] as String?,
      body: rawBody is List
          ? rawBody.cast<int>()
          : (rawBody as Uint8List?)?.toList() ?? const [],
    );
  }
}
