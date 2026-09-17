import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/chatbot_response.dart';

class ChatbotApiService {
  static const String endpoint = 'https://chatbot-xnwh.onrender.com/ask';

  static Future<ChatbotResponse> ask(String query) async {
    final uri = Uri.parse(endpoint);
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: jsonEncode({'query': query.trim()}),
          )
          .timeout(const Duration(seconds: 40));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ChatbotResponse.fromJson(data);
      } else {
        throw HttpException('Chatbot returned status ${response.statusCode}');
      }
    } on SocketException {
      throw const SocketException('Unable to reach the chatbot server. Check your internet connection.');
    } on TimeoutException {
      throw TimeoutException('Chatbot server is waking up. Please try again in a moment.');
    } catch (e) {
      if (e is SocketException || e is TimeoutException || e is HttpException) rethrow;
      throw Exception('Failed to connect to chatbot: $e');
    }
  }
}
