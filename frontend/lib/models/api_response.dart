/// Generic API response model
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;
  final Map<String, dynamic>? metadata;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
    this.metadata,
  });

  factory ApiResponse.success(T data,
      {int? statusCode, Map<String, dynamic>? metadata}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      statusCode: statusCode,
      metadata: metadata,
    );
  }

  factory ApiResponse.error(String error,
      {int? statusCode, Map<String, dynamic>? metadata}) {
    return ApiResponse<T>(
      success: false,
      error: error,
      statusCode: statusCode,
      metadata: metadata,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'],
      statusCode: json['statusCode'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'error': error,
      'statusCode': statusCode,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, data: $data, error: $error, statusCode: $statusCode)';
  }
}
