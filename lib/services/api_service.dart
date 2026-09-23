import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/history_item.dart';

class ApiService {
  static String _baseUrl = 'http://127.0.0.1:8000';
  static String get baseUrl => _baseUrl;
  static void setBaseUrl(String url) => _baseUrl = url;

  /// Helper to get full audio stream URL
  static String getAudioUrl(String relativePath) {
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      return relativePath;
    }
    final clean = relativePath.startsWith('/') ? relativePath : '/$relativePath';
    return '$baseUrl$clean';
  }

  /// Check backend health status
  static Future<bool> checkHealth() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Fetch history items from SQLite
  static Future<List<HistoryItem>> fetchHistory() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/history'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((json) {
          final dt =
              DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now();
          final formattedDate =
              "${_monthName(dt.month)} ${dt.day}, ${dt.year} · ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
          return HistoryItem(
            id: json['id'] ?? '',
            dateTime: formattedDate,
            riskCategory: json['risk_category'] ?? 'Low Risk',
            confidence: (json['confidence'] as num?)?.toDouble() ?? 90.0,
            modelUsed: json['model_used'] ?? 'Classical PyTorch',
            jitter: (json['jitter'] as num?)?.toDouble() ?? 0.0,
            shimmer: (json['shimmer'] as num?)?.toDouble() ?? 0.0,
            hnr: (json['hnr'] as num?)?.toDouble(),
            vocalStability:
                "${((json['vocal_stability'] as num?)?.toDouble() ?? 92.0).toStringAsFixed(1)}%",
            tremorIncidence:
                (json['tremor_incidence'] as num?)?.toDouble() != null &&
                    ((json['tremor_incidence'] as num).toDouble() > 50.0)
                ? "Detected"
                : "None Detected",
            articulationRate:
                "${((json['articulation_rate'] as num?)?.toDouble() ?? 4.2).toStringAsFixed(1)} syl/s",
            duration:
                "${((json['duration_sec'] as num?)?.toDouble() ?? 10.0).toStringAsFixed(1)}s",
            rationale:
                json['rationale'] ?? "Analysis complete with high confidence.",
            audioUrl: json['audio_url'] != null ? getAudioUrl(json['audio_url']) : null,
            audioFilename: json['audio_filename'] ?? json['audio_url']?.toString().split('/').last,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint("ApiService fetchHistory error: $e");
    }
    return [];
  }

  /// Submit audio recording for screening
  static Future<HistoryItem?> submitAudioScreening({
    required List<int> audioBytes,
    required String filename,
    String mode = 'classical',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/screen?mode=$mode');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes('file', audioBytes, filename: filename),
      );

      final streamedRes = await request.send().timeout(
        const Duration(seconds: 45),
      );
      final res = await http.Response.fromStream(streamedRes);

      if (res.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(res.body);
        final dt = DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now();
        final formattedDate =
            "${_monthName(dt.month)} ${dt.day}, ${dt.year} · ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
        return HistoryItem(
          id: json['id'] ?? '',
          dateTime: formattedDate,
          riskCategory: json['risk_category'] ?? 'Low Risk',
          confidence: (json['confidence'] as num?)?.toDouble() ?? 90.0,
          modelUsed: json['model_used'] ?? 'Classical PyTorch',
          jitter: (json['jitter'] as num?)?.toDouble() ?? 0.0,
          shimmer: (json['shimmer'] as num?)?.toDouble() ?? 0.0,
          hnr: (json['hnr'] as num?)?.toDouble(),
          vocalStability:
              "${((json['vocal_stability'] as num?)?.toDouble() ?? 92.0).toStringAsFixed(1)}%",
          tremorIncidence:
              (json['tremor_incidence'] as num?)?.toDouble() != null &&
                  ((json['tremor_incidence'] as num).toDouble() > 50.0)
              ? "Detected"
              : "None Detected",
          articulationRate:
              "${((json['articulation_rate'] as num?)?.toDouble() ?? 4.2).toStringAsFixed(1)} syl/s",
          duration:
              "${((json['duration_sec'] as num?)?.toDouble() ?? 10.0).toStringAsFixed(1)}s",
          rationale:
              json['rationale'] ?? "Analysis complete with high confidence.",
          audioUrl: json['audio_filename'] != null ? getAudioUrl('/api/audio/${json['audio_filename']}') : null,
          audioFilename: json['audio_filename'],
        );
      }
    } catch (e) {
      debugPrint("ApiService submitAudioScreening error: $e");
    }
    return null;
  }

  /// Batch delete screening records
  static Future<bool> deleteBatchHistory(List<String> ids) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/history/delete-batch'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ids': ids}),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("ApiService deleteBatchHistory error: $e");
      return false;
    }
  }

  /// Delete single screening record
  static Future<bool> deleteSingle(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/api/history/$id'));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("ApiService deleteSingle error: $e");
      return false;
    }
  }

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
