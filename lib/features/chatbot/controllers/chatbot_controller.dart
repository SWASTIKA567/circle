import 'package:get/get.dart';
import '../models/chatbot_response.dart';
import '../services/chatbot_api_service.dart';

class ChatMessage {
  final bool isUser;
  final String text;
  final List<String> matchedFacts;
  final bool isError;

  const ChatMessage({
    required this.isUser,
    required this.text,
    this.matchedFacts = const [],
    this.isError = false,
  });
}

class ChatbotController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[
    const ChatMessage(
      isUser: false,
      text: 'Hello! I am Circle AI, powered by your campus ML assistant. Ask me anything about campus locations, amphitheatre, events, or college notes!',
    ),
  ].obs;

  final RxBool isLoading = false.obs;

  final List<String> quickPrompts = [
    'Where is the amphitheatre?',
    'Where is the ATM?',
    'College fest details',
    'Upcoming events this week?',
    'Best notes for DBMS?',
  ];

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || isLoading.value) return;

    messages.add(ChatMessage(isUser: true, text: text.trim()));
    isLoading.value = true;

    try {
      final response = await ChatbotApiService.ask(text);
      messages.add(ChatMessage(
        isUser: false,
        text: response.answer,
        matchedFacts: response.matchedFacts,
      ));
    } catch (e) {
      String errorMsg = e.toString().replaceFirst('Exception: ', '');
      if (errorMsg.contains('SocketException')) {
        errorMsg = 'Could not reach server. Please check your internet connection.';
      } else if (errorMsg.contains('TimeoutException')) {
        errorMsg = 'Server took too long to respond. The Render instance may be waking up, please try again.';
      }
      messages.add(ChatMessage(isUser: false, text: errorMsg, isError: true));
    } finally {
      isLoading.value = false;
    }
  }
}
