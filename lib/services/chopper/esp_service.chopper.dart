// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'esp_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$EspService extends EspService {
  _$EspService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = EspService;

  @override
  Future<Response<dynamic>> getWaterDistance() {
    final Uri $url = Uri.parse('api/mqtt/messages');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}
