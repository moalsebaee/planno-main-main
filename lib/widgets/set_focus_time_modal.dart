import 'dart:ui';

import 'package:flutter/material.dart';

class SetFocusTimeModal extends StatefulWidget {
  final int initialMinutes;
  final ValueChanged<int> onConfirm;

  const SetFocusTimeModal({
    super.key,
    required this.initialMinutes,
    required this.onConfirm,
  });

  @override
  State<SetFocusTimeModal> createState() => _SetFocusTimeModalState();
}

class _SetFocusTimeModalState extends State<SetFocusTimeModal> {
  static const int _minMinutes = 1;
  static const int _maxMinutes = 500;

  final List<int> _presetMinutes = const [15, 25, 45, 60, 90];

  late int _selectedMinutes;
  late final TextEditingController _minutesController;
  late final FocusNode _focusNode;
  bool _isTextEditing = false;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.initialMinutes;
    _minutesController = TextEditingController(text: '$_selectedMinutes');
    _focusNode = FocusNode();

    // Ensure cursor is visible (TextField is always present).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Blue-based palette (primary/secondary/accent)
  Color get _primary => const Color(0xFF0B1B3A); // deep navy blue
  Color get _secondary => const Color(0xFF1D4ED8); // medium blue
  Color get _accent => const Color(0xFFE0F2FE); // light sky blue

  // Backwards-compatible aliases to keep the UI code simple.
  // (We can rename usages in a follow-up pass once everything compiles.)
  Color get _brand => _primary; // primary in this palette
  Color get _brandTint => _secondary.withOpacity(0.22);
  Color get _brandTint2 => _accent.withOpacity(0.75);

  Color get _primaryTint => _primary.withOpacity(0.14);
  Color get _accentTint => _accent.withOpacity(0.75);

  void _setMinutes(int minutes, {bool fromText = false}) {
    if (_isTextEditing && !fromText) {
      // If user is typing, don't fight their input.
      return;
    }

    setState(() {
      _selectedMinutes = minutes;
      _minutesController.text = '$_selectedMinutes';

      _minutesController.selection = TextSelection.fromPosition(
        TextPosition(offset: _minutesController.text.length),
      );
    });
  }

  int _parseMinutesFromText(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final value = int.tryParse(digits);

    if (value == null || value <= 0) {
      return 1;
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final cardWidth = media.size.width * 0.92;

    return SafeArea(
      child: Stack(
        children: [
          // Background blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.white.withOpacity(0.08)),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: SizedBox(
                width: cardWidth,
                child: Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 22,
                                color: _brand.withOpacity(0.55),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Set Focus Time',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: _brand.withOpacity(0.85),
                                ),
                              ),
                              const Spacer(),
                              // Close is subtle and optional; Cancel handles it too.
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => Navigator.of(context).pop(),
                                icon: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Time selection pills
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _presetMinutes.map((m) {
                              final selected = m == _selectedMinutes;
                              return ChoiceChip(
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                selectedColor: _brand,
                                selected: selected,
                                showCheckmark: false,
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                  side: BorderSide(
                                    color: selected
                                        ? _brand
                                        : Colors.grey.shade300,
                                    width: 1.2,
                                  ),
                                ),
                                label: Text('${m} min'),
                                onSelected: (_) => _setMinutes(m),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Manual input
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color: _brand.withOpacity(0.45),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Manual input',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _brand.withOpacity(0.55),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 16,
                                    color: _brand.withOpacity(0.45),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                focusNode: _focusNode,
                                controller: _minutesController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: _brand,
                                  letterSpacing: -0.3,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  filled: true,
                                  fillColor: _brandTint2,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(color: _brandTint),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(color: _brandTint),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(
                                      color: _brand,
                                      width: 1.5,
                                    ),
                                  ),
                                  suffixText: 'min',
                                ),
                                onTap: () {
                                  _isTextEditing = true;
                                },
                                onChanged: (val) {
                                  _isTextEditing = true;

                                  final parsed = _parseMinutesFromText(val);

                                  setState(() {
                                    _selectedMinutes = parsed;
                                  });
                                },
                                onEditingComplete: () {
                                  _isTextEditing = false;
                                  FocusScope.of(context).unfocus();
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Slider
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Focus duration',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${_selectedMinutes}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: _brand,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: _brand,
                                  inactiveTrackColor: Colors.grey.shade200,
                                  trackHeight: 6,
                                  thumbColor: _brand,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 12,
                                  ),
                                  overlayColor: _brand.withOpacity(0.14),
                                  valueIndicatorColor: _brand,
                                  valueIndicatorTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                child: Slider(
                                  min: _minMinutes.toDouble(),
                                  max: _maxMinutes.toDouble(),
                                  value: _selectedMinutes
                                      .clamp(_minMinutes, _maxMinutes)
                                      .toDouble(),
                                  divisions: (_maxMinutes - _minMinutes),
                                  label: '$_selectedMinutes min',
                                  onChanged: (v) {
                                    _setMinutes(v.round());
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Illustration section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Minimal rocket/focus illustration
                              SizedBox(
                                width: 96,
                                height: 64,
                                child: CustomPaint(
                                  painter: _RocketPainter(color: _brand),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_selectedMinutes} minutes of focus',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          size: 16,
                                          color: _brand,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Build momentum gently',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _brand,
                                    side: BorderSide(color: _brand, width: 1.6),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    widget.onConfirm(_selectedMinutes);
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _brand,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Start Focus',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RocketPainter extends CustomPainter {
  final Color color;

  _RocketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    final main = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final cx = size.width / 2;
    final topY = size.height * 0.18;
    final baseY = size.height * 0.78;

    // Body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 10, topY, 20, baseY - topY),
      const Radius.circular(10),
    );
    canvas.drawRRect(bodyRect, paint);
    canvas.drawRRect(bodyRect, stroke);

    canvas.drawCircle(
      Offset(cx, topY + 6),
      4,
      Paint()..color = color.withOpacity(0.25),
    );

    // Window
    canvas.drawCircle(Offset(cx + 2, topY + 22), 5, Paint()..color = color);
    canvas.drawCircle(
      Offset(cx + 2, topY + 22),
      2,
      Paint()..color = Colors.white.withOpacity(0.9),
    );

    // Fin
    final path = Path();
    path.moveTo(cx - 10, baseY - 10);
    path.lineTo(cx - 4, baseY);
    path.lineTo(cx - 9, baseY - 4);
    path.close();
    canvas.drawPath(path, paint);

    // Flame
    final flamePaint = Paint()..color = color.withOpacity(0.28);
    final flame = Path();
    flame.moveTo(cx - 6, baseY - 2);
    flame.quadraticBezierTo(cx, baseY + 8, cx + 6, baseY - 2);
    flame.lineTo(cx + 3, baseY + 1);
    flame.quadraticBezierTo(cx, baseY + 4, cx - 3, baseY + 1);
    flame.close();
    canvas.drawPath(flame, flamePaint);
  }

  @override
  bool shouldRepaint(covariant _RocketPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}