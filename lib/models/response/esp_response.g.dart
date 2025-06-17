// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'esp_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ESPResponse _$ESPResponseFromJson(Map<String, dynamic> json) => ESPResponse(
      topic: json['topic'] as String,
      payload: json['payload'] as String,
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$ESPResponseToJson(ESPResponse instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'payload': instance.payload,
      'timestamp': instance.timestamp,
    };

ESPResponseList _$ESPResponseListFromJson(Map<String, dynamic> json) =>
    ESPResponseList(
      items: (json['items'] as List<dynamic>)
          .map((e) => ESPResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ESPResponseListToJson(ESPResponseList instance) =>
    <String, dynamic>{
      'items': instance.items,
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      success: json['success'] as bool,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'user': instance.user,
      'success': instance.success,
      'message': instance.message,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
    };
