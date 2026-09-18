import 'package:flutter_test/flutter_test.dart';
import 'package:college_notes/features/chatbot/models/chatbot_response.dart';

void main() {
  group('ChatbotResponse Model Tests', () {
    test('correctly parses JSON from ML API', () {
      final json = {
        'answer': 'The amphitheatre is near me canteen.',
        'matched_facts': ['amphitheatre', 'ATM', 'Fest'],
      };

      final response = ChatbotResponse.fromJson(json);

      expect(response.answer, 'The amphitheatre is near me canteen.');
      expect(response.matchedFacts, ['amphitheatre', 'ATM', 'Fest']);
    });

    test('handles missing or empty matched_facts', () {
      final json = {
        'answer': 'General reply',
      };

      final response = ChatbotResponse.fromJson(json);

      expect(response.answer, 'General reply');
      expect(response.matchedFacts, isEmpty);
    });
  });
}
