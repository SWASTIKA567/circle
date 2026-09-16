import 'package:flutter/material.dart';

class ChatbotTab extends StatefulWidget {
  const ChatbotTab({super.key});

  @override
  State<ChatbotTab> createState() => _ChatbotTabState();
}

class _ChatbotTabState extends State<ChatbotTab> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
          'Hello! I am Circle AI, your campus assistant. How can I help you today with college notes, upcoming events, or campus societies?',
      'time': 'Just now',
    },
  ];

  final List<String> _quickPrompts = [
    'Upcoming events this week?',
    'Best notes for DBMS?',
    'How do I join Coding Club?',
    'Exam schedule guidelines',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? promptText]) {
    final text = promptText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'isUser': true,
        'text': text,
        'time': 'Just now',
      });
    });

    _messageController.clear();
    _scrollToBottom();

    // Generate intelligent response after brief delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      String reply;
      final lower = text.toLowerCase();

      if (lower.contains('note') || lower.contains('dbms') || lower.contains('os')) {
        reply =
            'You can find top-rated semester notes in the Notes tab! We have handnotes for DBMS, OS, Data Structures, and Mathematics with download access.';
      } else if (lower.contains('event') || lower.contains('hackathon')) {
        reply =
            'Check out the Events tab! Upcoming events include the Annual Hackathon 2026 and Tech Fest. You can RSVP directly in the app.';
      } else if (lower.contains('society') || lower.contains('club')) {
        reply =
            'Explore the Societies tab to discover Technical, Cultural, and Sports clubs. If you are an active member, your profile displays a verified badge!';
      } else {
        reply =
            'Got it! As your Circle campus assistant, I can help you find notes, navigate societies, or track event registrations. Feel free to ask anytime!';
      }

      setState(() {
        _messages.add({
          'isUser': false,
          'text': reply,
          'time': 'Just now',
        });
      });
      _scrollToBottom();
    });
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
                separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                    onPressed: () => _sendMessage(prompt),
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] as bool;

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
                          backgroundColor: primaryIndigo,
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? primaryIndigo
                                : Colors.indigo.shade50.withValues(alpha: 0.6),
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
                                : Border.all(color: Colors.indigo.shade100),
                          ),
                          child: Text(
                            msg['text'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: isUser ? Colors.white : Colors.black87,
                              height: 1.4,
                            ),
                          ),
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
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask Circle AI anything...',
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
                    decoration: const BoxDecoration(
                      color: primaryIndigo,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(),
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
