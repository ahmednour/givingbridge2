import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class CsrfService {
  static String? _csrfToken;

  static Future<String?> getToken() async {
    if (_csrfToken != null) {
      return _csrfToken;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/csrf-token'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _csrfToken = data['csrf_token'];
        return _csrfToken;
      }
    } catch (e) {
      print('Error getting CSRF token: $e');
    }

    return null;
  }

  static void clearToken() {
    _csrfToken = null;
  }

  static Map<String, String> getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['X-CSRF-Token'] = token;
    }

    return headers;
  }
}