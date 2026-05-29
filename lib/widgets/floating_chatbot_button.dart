import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:planno/services/gemini_service.dart';

// import '../services/ai_service.dart'; // 👈 IMPORTANT CHANGE

class ChatbotPanel {
  static Future<void> open(
    BuildContext context, {
    VoidCallback? onPressed,
  }) async {
    onPressed?.call();

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.18),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final t = Curves.easeOutCubic.transform(animation.value);

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.transparent),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: Offset(-180 * (1 - t), 0),
                child: const ChatbotPanelGlass(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class FloatingChatbotLeftButton extends StatelessWidget {
  const FloatingChatbotLeftButton({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Positioned(
      left: -60,
      top: h * 0.45,
      child: GestureDetector(
        onTap: () => ChatbotPanel.open(context),
        child: SizedBox(
          width: 52,
          height: 52,
          child: SvgPicture.asset('assets/boot.svg'),
        ),
      ),
    );
  }
}

class ChatbotPanelGlass extends StatefulWidget {
  const ChatbotPanelGlass({super.key});

  @override
  State<ChatbotPanelGlass> createState() => _ChatbotPanelGlassState();
}

class _ChatbotPanelGlassState extends State<ChatbotPanelGlass> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [];
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(_ChatMessage.user(text));
      _controller.clear();
      _sending = true;
    });

    _scrollToBottom();

    String reply;

    try {
      // ✅ NEW SERVICE CALL (OpenRouter)
      reply = await AIService.ask(text);
    } catch (e) {
      reply = "Server error: $e";
    }

    if (!mounted) return;

    setState(() {
      _messages.add(_ChatMessage.assistant(reply));
      _sending = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
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
    return Material(
      color: Colors.transparent,
      child: Container(
        width: math.min(340, MediaQuery.of(context).size.width * 0.88),
        height: math.min(500, MediaQuery.of(context).size.height * 0.72),
        margin: const EdgeInsets.only(left: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).withOpacity(0.92),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg.role == _ChatRole.user;

                  return ListTile(
                    title: Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg.text,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Ask anything...",
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ChatRole { user, assistant }

class _ChatMessage {
  final _ChatRole role;
  final String text;

  _ChatMessage.user(this.text) : role = _ChatRole.user;
  _ChatMessage.assistant(this.text) : role = _ChatRole.assistant;
}
