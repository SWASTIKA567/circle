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
