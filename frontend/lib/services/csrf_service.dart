import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';

/// CSRF Token Service
/// Manages CSRF tokens for secure API requests
class CsrfService {
  static String? _csrfToken;
  static DateTime? _tokenExpiry;
  
  /// Get CSRF token (cached for 1 hour)
  static Future<String> getToken() async {
    // Return cached token if still valid
    if (_csrfToken != null && 
        _tokenExpiry != null && 
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _csrfToken!;
    }
    
    // Fetch new token
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/csrf-token'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _csrfToken = data['csrfToken'];
        
        // Set expiry based on server response or default to 1 hour
        final expiresIn = data['expiresIn'] ?? 3600; // seconds
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
        
        print('✅ CSRF token fetched successfully');
        return _csrfToken!;
      } else {
        print('❌ Failed to fetch CSRF token: ${response.statusCode}');
        throw Exception('Failed to get CSRF token: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching CSRF token: $e');
      throw Exception('Failed to get CSRF token: $e');
    }
  }
  
  /// Clear cached token (call on logout or token error)
  static void clearToken() {
    _csrfToken = null;
    _tokenExpiry = null;
    print('🔄 CSRF token cleared');
  }
  
  /// Check if token is expired
  static bool isTokenExpired() {
    if (_tokenExpiry == null) return true;
    return DateTime.now().isAfter(_tokenExpiry!);
  }
  
  /// Get cached token without fetching (returns null if not cached)
  static String? getCachedToken() {
    if (_csrfToken != null && !isTokenExpired()) {
      return _csrfToken;
    }
    return null;
  }
}
