// ignore_for_file: unused_field, unused_import, constant_identifier_names

import 'package:chopper/chopper.dart';
import 'package:smart_farming/models/esp_water_data.dart';
import 'package:smart_farming/services/chopper/esp_service.dart';
import '../../models/response/esp_response.dart';
import '../../utils/logger.dart';
import '../api/api_services.dart';

class ESPRepository {
  static const String TAG = 'ESPRepository';
  final ApiClient _apiClient = ApiClient();
  EspService? _espService;

  // Get the ESP service (create if not exists)
  Future<EspService> _getEspService() async {
    Logger.d('Getting ESP service', tag: TAG);
    _espService ??= await EspService.create();
    return _espService!;
  }

  // Fetch the latest water level data from the ESP device
  Future<ESPWaterData> getLatestWaterDistance() async {
    try {
      Logger.d('Fetching latest water distance', tag: TAG);
      final service = await _getEspService();
      final response = await service.getWaterDistance();

      Logger.d('Response status code: ${response.statusCode}', tag: TAG);

      if (!response.isSuccessful) {
        Logger.e('Error fetching data: ${response.error}', tag: TAG);
        return ESPWaterData.error(
          "Error fetching data: ${response.error ?? 'Unknown error'}",
        );
      }

      // Parse response body and log it
      final dynamic responseBody = response.body;
      Logger.logJson(responseBody, tag: 'ESP-Response');

      if (responseBody is List && responseBody.isNotEmpty) {
        Logger.i('Got ${responseBody.length} data entries', tag: TAG);

        // Sort data by timestamp (newest first) to ensure we get the latest
        final List<dynamic> sortedData = List.from(responseBody);
        sortedData.sort((a, b) {
          final DateTime timeA = DateTime.parse(a['timestamp'] as String);
          final DateTime timeB = DateTime.parse(b['timestamp'] as String);
          return timeB.compareTo(timeA); // Descending order (newest first)
        });

        // Log sorted timestamps for debugging
        Logger.d(
          'Sorted timestamps: ${sortedData.map((e) => e['timestamp']).toList()}',
          tag: TAG,
        );

        // Get the latest entry (first after sorting)
        final latestData = ESPResponse.fromJson(sortedData[0]);

        Logger.i(
          'Latest data - Topic: ${latestData.topic}, Payload: ${latestData.payload}, Time: ${latestData.timestamp}',
          tag: TAG,
        );

        // Parse payload menjadi nilai jarak (dalam cm)
        final distanceInCm = latestData.numericPayload ?? 0;
        Logger.d('Parsed distance: $distanceInCm cm', tag: TAG);

        return ESPWaterData(
          distanceToWater: distanceInCm,
          timestamp: latestData.timestampDateTime,
        );
      } else {
        Logger.w('No data received from device', tag: TAG);
        return ESPWaterData.error("No data received from device");
      }
    } catch (e, stackTrace) {
      Logger.e(
        "Error in getLatestWaterDistance: $e",
        tag: TAG,
        error: e,
        stackTrace: stackTrace,
      );
      return ESPWaterData.error("Error: $e");
    }
  }

  // Get historical water level data for charts
  Future<List<ESPResponse>> getHistoricalWaterData({int limit = 10}) async {
    try {
      Logger.d('Fetching historical water data (limit: $limit)', tag: TAG);
      final service = await _getEspService();
      final response = await service.getWaterDistance();

      if (!response.isSuccessful) {
        Logger.e('Error fetching historical data: ${response.error}', tag: TAG);
        return [];
      }

      // Parse response body
      final dynamic responseBody = response.body;
      Logger.d(
        'Got ${responseBody is List ? responseBody.length : 0} historical entries',
        tag: TAG,
      );

      if (responseBody is List) {
        // Sort data by timestamp (newest first)
        final List<dynamic> sortedData = List.from(responseBody);
        sortedData.sort((a, b) {
          final DateTime timeA = DateTime.parse(a['timestamp'] as String);
          final DateTime timeB = DateTime.parse(b['timestamp'] as String);
          return timeB.compareTo(timeA); // Descending order (newest first)
        });

        // Convert to ESP responses
        final data = sortedData
            .map((e) => ESPResponse.fromJson(e))
            .toList()
            .cast<ESPResponse>();

        // Log some data for verification
        if (data.isNotEmpty) {
          Logger.i(
            'Historical data range: ${data.first.timestamp} to ${data.last.timestamp}',
            tag: TAG,
          );
          Logger.d(
            'First 3 values: ${data.take(3).map((e) => e.payload).toList()}',
            tag: TAG,
          );
        }

        // Limit number of entries if needed
        if (data.length > limit) {
          return data.sublist(0, limit);
        }
        return data;
      }
      return [];
    } catch (e, stackTrace) {
      Logger.e(
        "Error in getHistoricalWaterData: $e",
        tag: TAG,
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }
}
