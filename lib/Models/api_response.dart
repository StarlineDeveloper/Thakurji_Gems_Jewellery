import 'dart:convert';

ApiResponse<T> apiResponseFromJson<T>(String str) =>

    ApiResponse<T>.fromJson(json.decode(str));

String apiResponseToJson<T>(ApiResponse<T> data) => json.encode(data.toJson());

class ApiResponse<T> {
  ApiResponse({required this.code, this.message, this.data});

  final int code;
  final dynamic message;
  final T? data;

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse<T>(
    code: json["code"] as int,
    message: json["message"],
    data: json["data"] != null ? json["data"] as T : null,
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data,
  };
}