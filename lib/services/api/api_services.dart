import 'package:chopper/chopper.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  ChopperClient? _client;

  static const String baseApiUrl =
      "https://electric-piglet-apparently.ngrok-free.app";

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal();

  Future<ChopperClient> getClient() async {
    if (_client != null) return _client!;

    _client = ChopperClient(
      baseUrl: Uri.parse(baseApiUrl),
      converter: JsonConverter(),
      interceptors: [HttpLoggingInterceptor()],
    );
    return _client!;
  }
}

// Class untuk menyimpan hasil fetching ESP data
