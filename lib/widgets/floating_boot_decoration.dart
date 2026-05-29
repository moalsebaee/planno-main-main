import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FloatingBootDecoration extends StatefulWidget {
  const FloatingBootDecoration({
    super.key,
    this.assetPath = 'assets/boot.svg',
    this.leftOffset = -80,
    this.opacity = 0.35,
    this.hoverPeekAmount = 0.65,
    this.animationDuration = const Duration(milliseconds: 520),
  });

  final String assetPath;
  final double leftOffset;
  final double opacity;

  final double hoverPeekAmount;
  final Duration animationDuration;

  @override
  State<FloatingBootDecoration> createState() => _FloatingBootDecorationState();
}

class _FloatingBootDecorationState extends State<FloatingBootDecoration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatY;
  late final Animation<double> _rotate;

  bool _hovering = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatY = Tween<double>(
      begin: 0,
      end: 18,
    ).chain(CurveTween(curve: Curves.easeInOutSine)).animate(_controller);

    _rotate = Tween<double>(
      begin: -0.06,
      end: 0.06,
    ).chain(CurveTween(curve: Curves.easeInOutSine)).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final size = math.min(64.0, screenWidth * 0.095);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final slideX = _hovering
              ? (size * widget.hoverPeekAmount)
              : (-size * widget.hoverPeekAmount);

          final rawLeft = widget.leftOffset + slideX;
          final left = math.max(-size * 0.35, rawLeft);

          return Positioned(
            left: left,
            top: screenHeight * 0.45,
            child: Transform.translate(
              offset: Offset(0, _floatY.value),
              child: Transform.rotate(
                angle: _rotate.value,
                child: Opacity(opacity: widget.opacity, child: child),
              ),
            ),
          );
        },
        child: IgnorePointer(
          child: SizedBox(
            width: size,
            height: size,
            child: SvgPicture.asset(
              widget.assetPath,
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
