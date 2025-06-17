import 'package:chopper/chopper.dart';
import 'package:smart_farming/services/api/api_services.dart';

part 'esp_service.chopper.dart';

@ChopperApi(baseUrl: '/api')
abstract class EspService extends ChopperService {
  // Pastikan path endpoint benar
  @Get(path: '/mqtt/messages')
  Future<Response<dynamic>> getWaterDistance();

  static Future<EspService> create() async {
    final client = await ApiClient().getClient();
    return _$EspService(client);
  }
}
