import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewTaskChatbotSuffixButton extends StatefulWidget {
  const NewTaskChatbotSuffixButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<NewTaskChatbotSuffixButton> createState() =>
      _NewTaskChatbotSuffixButtonState();
}

class _NewTaskChatbotSuffixButtonState
    extends State<NewTaskChatbotSuffixButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0EA5E9).withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF0EA5E9).withOpacity(0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset('assets/boot.svg', fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
