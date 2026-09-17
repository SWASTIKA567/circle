import 'package:flutter/material.dart';
import '../../services/chatbot_service.dart';

class ChatbotTab extends StatefulWidget {
  const ChatbotTab({super.key});

  @override
  State<ChatbotTab> createState() => _ChatbotTabState();
}

class _ChatbotTabState extends State<ChatbotTab> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
          'Hello! I am Circle AI, powered by your campus ML assistant. Ask me anything about campus locations, amphitheatre, events, or college notes!',
      'time': 'Just now',
      'matchedFacts': <String>[],
    },
  ];

  final List<String> _quickPrompts = [
    'Where is the amphitheatre?',
    'Where is the ATM?',
    'College fest details',
    'Upcoming events this week?',
    'Best notes for DBMS?',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? promptText]) async {
    final text = promptText ?? _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _messageController.clear();

    setState(() {
      _messages.add({
        'isUser': true,
        'text': text,
        'time': 'Just now',
      });
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await ChatbotService.ask(text);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _messages.add({
          'isUser': false,
          'text': response.answer,
          'matchedFacts': response.matchedFacts,
          'time': 'Just now',
        });
      });
    } catch (e) {
      if (!mounted) return;

      String errorMsg = e.toString().replaceFirst('Exception: ', '');
      if (errorMsg.contains('SocketException')) {
        errorMsg = 'Could not reach server. Please check your internet connection.';
      } else if (errorMsg.contains('TimeoutException')) {
        errorMsg = 'Server took too long to respond. The free Render instance may be waking up, please try again in a moment.';
      }

      setState(() {
        _isLoading = false;
        _messages.add({
          'isUser': false,
          'text': errorMsg,
          'matchedFacts': <String>[],
          'isError': true,
          'time': 'Just now',
        });
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryIndigo = Colors.indigo;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Quick Prompts Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50.withValues(alpha: 0.4),
              border: Border(bottom: BorderSide(color: Colors.indigo.shade100)),
            ),
            child: SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _quickPrompts.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final prompt = _quickPrompts[index];
                  return ActionChip(
                    label: Text(
                      prompt,
                      style: const TextStyle(
                        fontSize: 12,
                        color: primaryIndigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.indigo.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onPressed: _isLoading ? null : () => _sendMessage(prompt),
                  );
                },
              ),
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Render typing bubble when loading
                if (index == _messages.length) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: primaryIndigo,
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50.withValues(alpha: 0.6),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                              bottomLeft: Radius.circular(4),
                              bottomRight: Radius.circular(18),
                            ),
                            border: Border.all(color: Colors.indigo.shade100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primaryIndigo,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Circle AI is thinking...',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.indigo.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final msg = _messages[index];
                final isUser = msg['isUser'] as bool;
                final isError = msg['isError'] as bool? ?? false;
                final matchedFacts = msg['matchedFacts'] as List<String>? ?? [];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    mainAxisAlignment:
                        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              isError ? Colors.red.shade400 : primaryIndigo,
                          child: Icon(
                            isError ? Icons.error_outline : Icons.auto_awesome,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? primaryIndigo
                                    : isError
                                        ? Colors.red.shade50
                                        : Colors.indigo.shade50
                                            .withValues(alpha: 0.6),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: isUser
                                      ? const Radius.circular(18)
                                      : const Radius.circular(4),
                                  bottomRight: isUser
                                      ? const Radius.circular(4)
                                      : const Radius.circular(18),
                                ),
                                border: isUser
                                    ? null
                                    : Border.all(
                                        color: isError
                                            ? Colors.red.shade200
                                            : Colors.indigo.shade100,
                                      ),
                              ),
                              child: Text(
                                msg['text'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isUser
                                      ? Colors.white
                                      : isError
                                          ? Colors.red.shade900
                                          : Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            if (!isUser && matchedFacts.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: matchedFacts.map((fact) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.indigo.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.tag,
                                          size: 11,
                                          color: Colors.indigo.shade600,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          fact,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.indigo.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.indigo.shade100,
                          child: const Icon(
                            Icons.person,
                            color: primaryIndigo,
                            size: 18,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Message Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.indigo.shade100)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isLoading,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: _isLoading
                            ? 'Waiting for response...'
                            : 'Ask Circle AI anything...',
                        hintStyle: TextStyle(
                          color: Colors.indigo.shade200,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.indigo.shade50.withValues(alpha: 0.4),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.indigo.shade100),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.indigo.shade100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: primaryIndigo,
                            width: 1.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isLoading ? Colors.indigo.shade200 : primaryIndigo,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _isLoading ? null : () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
