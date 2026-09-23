import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String? _customBaseUrl;

  static void setBaseUrl(String url) {
    _customBaseUrl = url;
  }

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api';
    }
    if (Platform.isAndroid) {
      // 10.0.2.2 points to host localhost in Android Emulator
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://127.0.0.1:5000/api';
  }

  static String get hostBaseUrl {
    final api = baseUrl;
    if (api.endsWith('/api')) {
      return api.substring(0, api.length - 4);
    }
    return api;
  }

  static String resolveFileUrl(String relativeUrl) {
    if (relativeUrl.startsWith('http://') || relativeUrl.startsWith('https://')) {
      return relativeUrl;
    }
    final cleanPath = relativeUrl.startsWith('/') ? relativeUrl : '/$relativeUrl';
    return '$hostBaseUrl$cleanPath';
  }

  static Map<String, String> _headers({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(
            uri,
            headers: _headers(token: token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        final message = data['message'] ?? 'Request failed (${response.statusCode})';
        throw Exception(message);
      }
    } on SocketException {
      throw Exception(
        'Unable to connect to backend server. Make sure the Node.js backend is running on port 5000.',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .put(
            uri,
            headers: _headers(token: token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        final message = data['message'] ?? 'Request failed (${response.statusCode})';
        throw Exception(message);
      }
    } on SocketException {
      throw Exception(
        'Unable to connect to backend server. Make sure the Node.js backend is running on port 5000.',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .get(
            uri,
            headers: _headers(token: token),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        final message = data['message'] ?? 'Request failed (${response.statusCode})';
        throw Exception(message);
      }
    } on SocketException {
      throw Exception(
        'Unable to connect to backend server. Make sure the Node.js backend is running on port 5000.',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .delete(
            uri,
            headers: _headers(token: token),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        final message = data['message'] ?? 'Request failed (${response.statusCode})';
        throw Exception(message);
      }
    } on SocketException {
      throw Exception(
        'Unable to connect to backend server. Make sure the Node.js backend is running on port 5000.',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> uploadFile(
    String endpoint, {
    required File file,
    required Map<String, String> fields,
    String fileField = 'pdf',
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll(fields);
      request.files.add(await http.MultipartFile.fromPath(fileField, file.path));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        final message = data['message'] ?? 'Upload failed (${response.statusCode})';
        throw Exception(message);
      }
    } on SocketException {
      throw Exception(
        'Unable to connect to backend server. Make sure the Node.js backend is running on port 5000.',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(e.toString());
    }
  }
}
