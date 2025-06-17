import '../models/response/esp_response.dart';
import 'package:intl/intl.dart';

class ESPDataHelper {
  // Format timestamp dari ESP response
  static String formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }

  // Konversi payload ke level air (dalam cm)
  static double? convertToWaterLevel(String payload) {
    try {
      // Kalkulasi level air berdasarkan payload
      // Ini contoh sederhana, sesuaikan dengan cara kerja sensor
      return double.parse(payload);
    } catch (_) {
      return null;
    }
  }

  // Konversi respon ESP ke array data untuk chart
  static List<List<double>> convertToChartData(List<ESPResponse> responses) {
    final result = <List<double>>[];

    for (final response in responses) {
      final dateTime = response.timestampDateTime;
      final timestamp = dateTime.millisecondsSinceEpoch.toDouble();
      final value = response.numericPayload ?? 0.0;

      result.add([timestamp, value]);
    }

    return result;
  }

  // Hitung rata-rata dari kumpulan data
  static double calculateAverage(List<ESPResponse> responses) {
    if (responses.isEmpty) return 0;

    double sum = 0;
    int count = 0;

    for (final response in responses) {
      final value = response.numericPayload;
      if (value != null) {
        sum += value;
        count++;
      }
    }

    return count > 0 ? sum / count : 0;
  }

  // Dapatkan nilai minimum dan maksimum
  static Map<String, double> getMinMax(List<ESPResponse> responses) {
    if (responses.isEmpty) {
      return {'min': 0, 'max': 0};
    }

    double? min, max;

    for (final response in responses) {
      final value = response.numericPayload;
      if (value != null) {
        min = min == null || value < min ? value : min;
        max = max == null || value > max ? value : max;
      }
    }

    return {'min': min ?? 0, 'max': max ?? 0};
  }
}
