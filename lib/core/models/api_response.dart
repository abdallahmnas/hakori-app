/// Generic API Response Envelope matching API_DOCUMENTATION.md
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;

  const ApiResponse({
    required this.success,
    this.data,
    this.message = '',
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'] as String? ?? '',
    );
  }
}
