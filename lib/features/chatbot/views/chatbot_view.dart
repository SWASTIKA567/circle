import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/chatbot_controller.dart';

class ChatbotView extends GetView<ChatbotController> {
  const ChatbotView({super.key});

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();
    final scrollController = ScrollController();

    void scrollToBottom() {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Quick Prompts Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(bottom: BorderSide(color: AppColors.grayFade(0.12))),
            ),
            child: SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.quickPrompts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final prompt = controller.quickPrompts[index];
                  return ActionChip(
                    label: Text(
                      prompt,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.card,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: AppColors.purpleLight,
                    side: BorderSide(color: AppColors.purple.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            controller.sendMessage(prompt);
                            scrollToBottom();
                          },
                  );
                },
              ),
            ),
          ),

          // Messages List
          Expanded(
            child: Obx(() {
              final messages = controller.messages;
              final isLoading = controller.isLoading.value;

              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: messages.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.card,
                            child: Icon(Icons.auto_awesome, color: AppColors.purple, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(18),
                              ),
                              border: Border.all(color: AppColors.grayFade(0.12)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.purple,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Circle AI is thinking...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.gray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final msg = messages[index];
                  final isUser = msg.isUser;
                  final isError = msg.isError;
                  final matchedFacts = msg.matchedFacts;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: isError ? AppColors.pink : AppColors.card,
                            child: Icon(
                              isError ? Icons.error_outline : Icons.auto_awesome,
                              color: isError ? AppColors.white : AppColors.purple,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Column(
                            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? AppColors.card
                                      : isError
                                          ? AppColors.pinkLight
                                          : AppColors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                                    bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                                  ),
                                  border: isUser
                                      ? null
                                      : Border.all(
                                          color: isError ? AppColors.pink : AppColors.grayFade(0.12),
                                        ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.black.withValues(alpha: 0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  msg.text,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isUser
                                        ? AppColors.white
                                        : isError
                                            ? AppColors.magenta
                                            : AppColors.text,
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
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.blueLight,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.tag, size: 11, color: AppColors.card),
                                          const SizedBox(width: 2),
                                          Text(
                                            fact,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.card,
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
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.purpleLight,
                            child: Icon(Icons.person, color: AppColors.card, size: 18),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          // Message Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.grayFade(0.12))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => TextField(
                      controller: messageController,
                      enabled: !controller.isLoading.value,
                      style: const TextStyle(fontSize: 14, color: AppColors.text),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          controller.sendMessage(val.trim());
                          messageController.clear();
                          scrollToBottom();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: controller.isLoading.value ? 'Waiting for response...' : 'Ask Circle AI anything...',
                        hintStyle: const TextStyle(color: AppColors.gray, fontSize: 14),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: AppColors.grayFade(0.15)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: AppColors.grayFade(0.15)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide: BorderSide(color: AppColors.purple, width: 1.8),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => Container(
                    decoration: BoxDecoration(
                      color: controller.isLoading.value ? AppColors.grayFade(0.3) : AppColors.card,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.purple, size: 20),
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              if (messageController.text.trim().isNotEmpty) {
                                controller.sendMessage(messageController.text.trim());
                                messageController.clear();
                                scrollToBottom();
                              }
                            },
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
