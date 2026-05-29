import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FloatingChatbotLeftButton extends StatefulWidget {
  const FloatingChatbotLeftButton({
    super.key,
    this.onPressed,
    this.duration = const Duration(milliseconds: 420),
  });

  final VoidCallback? onPressed;
  final Duration duration;

  @override
  State<FloatingChatbotLeftButton> createState() =>
      _FloatingChatbotLeftButtonState();
}

class _FloatingChatbotLeftButtonState extends State<FloatingChatbotLeftButton> {
  bool _hovering = false;

  Future<void> _openChatbotPanel(BuildContext context) async {
    widget.onPressed?.call();

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
                child: _ChatbotPanelGlass(
                  onClose: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final size = screenWidth < 420 ? 38.0 : 42.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final top = constraints.maxHeight * 0.52;

        return Positioned(
          left: -28,
          top: top,
          width: size,
          height: size,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => _openChatbotPanel(context),
              child: AnimatedContainer(
                duration: widget.duration,
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(
                  _hovering ? 12 : (-size * 0.45),
                  0,
                  0,
                ),
                child: SizedBox(
                  width: size,
                  height: size,
                  child: SvgPicture.asset(
                    'assets/boot.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChatbotPanelGlass extends StatelessWidget {
  const _ChatbotPanelGlass({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final width = math.min(340.0, MediaQuery.of(context).size.width * 0.88);

    final height = math.min(500.0, MediaQuery.of(context).size.height * 0.72);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(left: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).withOpacity(0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.28)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22D3EE).withOpacity(0.18),
              blurRadius: 24,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 12, 12),
              child: Row(
                children: [
                  SvgPicture.asset('assets/boot.svg', width: 22, height: 22),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Text(
                      'Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Colors.white12),

            const Expanded(
              child: Center(
                child: Text(
                  'Chatbot panel prototype',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onClose,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: const Color(0xFF22D3EE).withOpacity(0.35),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
