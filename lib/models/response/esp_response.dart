import 'package:json_annotation/json_annotation.dart';

part 'esp_response.g.dart';

@JsonSerializable()
class ESPResponse {
  final String topic;
  final String payload;
  final String timestamp;

  ESPResponse({
    required this.topic,
    required this.payload,
    required this.timestamp,
  });

  // Helper method to get numeric payload
  double? get numericPayload {
    try {
      return double.parse(payload);
    } catch (_) {
      return null;
    }
  }

  // Helper to get DateTime from timestamp string
  DateTime get timestampDateTime {
    return DateTime.parse(timestamp);
  }

  // JSON conversions
  factory ESPResponse.fromJson(Map<String, dynamic> json) =>
      _$ESPResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ESPResponseToJson(this);
}

// For lists of ESP responses
@JsonSerializable()
class ESPResponseList {
  final List<ESPResponse> items;

  ESPResponseList({required this.items});

  factory ESPResponseList.fromJson(List<dynamic> json) {
    return ESPResponseList(
      items: json
          .map((e) => ESPResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// Auth response classes
@JsonSerializable()
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class LoginResponse {
  final String token;
  final User user;
  final bool success;
  final String? message;

  LoginResponse({
    required this.token,
    required this.user,
    required this.success,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
