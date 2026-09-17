import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ChatbotResponse {
  final String answer;
  final List<String> matchedFacts;

  const ChatbotResponse({
    required this.answer,
    required this.matchedFacts,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    final rawFacts = json['matched_facts'];
    List<String> facts = [];
    if (rawFacts is List) {
      facts = rawFacts.map((e) => e.toString()).toList();
    }

    return ChatbotResponse(
      answer: json['answer'] as String? ?? 'I could not find an answer for that.',
      matchedFacts: facts,
    );
  }
}

class ChatbotService {
  static const String defaultEndpoint = 'https://chatbot-xnwh.onrender.com/ask';

  /// Sends a query to the ML chatbot API and returns the structured response.
  static Future<ChatbotResponse> ask(String query, {String? customUrl}) async {
    final uri = Uri.parse(customUrl ?? defaultEndpoint);

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'query': query.trim()}),
          )
          .timeout(const Duration(seconds: 40));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ChatbotResponse.fromJson(data);
      } else {
        throw HttpException(
          'Chatbot server returned status ${response.statusCode}: ${response.body}',
        );
      }
    } on SocketException {
      throw const SocketException(
        'Unable to reach the chatbot server. Please check your internet connection.',
      );
    } on TimeoutException {
      throw TimeoutException(
        'The chatbot server took too long to respond. It may be waking up, please try again.',
      );
    } catch (e) {
      if (e is SocketException || e is TimeoutException || e is HttpException) {
        rethrow;
      }
      throw Exception('Failed to connect to chatbot: $e');
    }
  }
}
