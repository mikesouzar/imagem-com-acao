import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';

class CategoryDiceWidget extends StatefulWidget {
  final double size;
  final ValueChanged<BoardCategory>? onRoll;
  final bool enabled;

  const CategoryDiceWidget({super.key, this.size = 80, this.onRoll, this.enabled = true});

  @override
  State<CategoryDiceWidget> createState() => _CategoryDiceWidgetState();
}

class _CategoryDiceWidgetState extends State<CategoryDiceWidget> with TickerProviderStateMixin {
  static const _categories = BoardCategory.values;
  static const Map<BoardCategory, _CatFace> _faces = {
    BoardCategory.pessoa: _CatFace('P', 'Pessoa', Color(0xFF1565C0)),
    BoardCategory.objeto: _CatFace('O', 'Objeto', Color(0xFF2E7D32)),
    BoardCategory.acao: _CatFace('A', 'Ação', Color(0xFFC62828)),
    BoardCategory.dificil: _CatFace('D', 'Difícil', Color(0xFF6A1B9A)),
    BoardCategory.lazer: _CatFace('L', 'Lazer', Color(0xFFF9A825)),
    BoardCategory.mix: _CatFace('M', 'Mix', Color(0xFFE65100)),
  };

  final _random = Random();
  BoardCategory _displayCategory = BoardCategory.pessoa;
  bool _isRolling = false;
  bool _hasSettled = false;

  double _height = 0;
  double _tiltX = 0;
  double _tiltY = 0;
  double _rotation = 0;
  double _shadowBlur = 8;
  double _scale = 1.0;

  Timer? _physicsTimer;

  @override
  void dispose() {
    _physicsTimer?.cancel();
    super.dispose();
  }

  Future<void> _roll() async {
    if (_isRolling || !widget.enabled) return;
    setState(() { _isRolling = true; _hasSettled = false; });
    HapticFeedback.mediumImpact();

    final result = _categories[_random.nextInt(_categories.length)];

    double velocity = 14.0;
    double angularVelX = (_random.nextDouble() - 0.5) * 28;
    double angularVelY = (_random.nextDouble() - 0.5) * 28;
    double spinVel = (_random.nextDouble() - 0.5) * 7;
    int bounceCount = 0;
    int faceChangeCounter = 0;

    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      faceChangeCounter++;
      velocity -= 0.8;
      _height += velocity * 0.5;

      angularVelX *= 0.97;
      angularVelY *= 0.97;
      spinVel *= 0.98;
      _tiltX += angularVelX * 0.016;
      _tiltY += angularVelY * 0.016;
      _rotation += spinVel * 0.016;

      final changeRate = _height > 5 ? 3 : (_height > 2 ? 5 : 8);
      if (faceChangeCounter >= changeRate && _height > 1) {
        faceChangeCounter = 0;
        _displayCategory = _categories[_random.nextInt(_categories.length)];
      }

      if (_height <= 0) {
        _height = 0;
        bounceCount++;
        HapticFeedback.lightImpact();

        if (bounceCount >= 4 || velocity.abs() < 3) {
          timer.cancel();
          _displayCategory = result;
          _settleAnimation();
          return;
        }

        velocity = velocity.abs() * 0.45;
        angularVelX *= 0.5;
        angularVelY *= 0.5;
        spinVel *= 0.6;
        _scale = 0.9;
      } else {
        _scale = 1.0;
      }

      _shadowBlur = 8 + _height * 2;
      if (mounted) setState(() {});
    });
  }

  Future<void> _settleAnimation() async {
    HapticFeedback.mediumImpact();
    _scale = 0.92; setState(() {});
    await Future.delayed(const Duration(milliseconds: 60));
    _scale = 1.05; _tiltX *= 0.3; _tiltY *= 0.3; setState(() {});
    await Future.delayed(const Duration(milliseconds: 80));
    _scale = 0.97; _tiltX *= 0.1; _tiltY *= 0.1; setState(() {});
    await Future.delayed(const Duration(milliseconds: 60));

    _height = 0; _tiltX = 0; _tiltY = 0; _rotation = 0;
    _scale = 1.0; _shadowBlur = 8;
    _isRolling = false; _hasSettled = true;
    if (mounted) setState(() {});

    await Future.delayed(const Duration(milliseconds: 100));
    widget.onRoll?.call(_displayCategory);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final face = _faces[_displayCategory]!;

    return GestureDetector(
      onTap: _roll,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size + 20,
            height: size + 30,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Sombra dinâmica
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: size * (0.7 + _height * 0.01),
                    height: size * 0.12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size),
                      boxShadow: [
                        BoxShadow(
                          color: face.color.withValues(alpha: (0.25 - _height * 0.005).clamp(0.05, 0.3)),
                          blurRadius: _shadowBlur,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                  ),
                ),
                // Dado
                Positioned(
                  bottom: 10 + _height * 3,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.004)
                      ..rotateX(_tiltX)
                      ..rotateY(_tiltY)
                      ..rotateZ(_rotation)
                      ..scale(_scale),
                    child: _CategoryCube(letter: face.letter, color: face.color, size: size),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Nome quando para
          AnimatedOpacity(
            opacity: _hasSettled ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(face.name,
              style: GoogleFonts.plusJakartaSans(fontSize: size * 0.16, fontWeight: FontWeight.w700, color: face.color),
            ),
          ),
          if (!_isRolling && !_hasSettled && widget.enabled)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Toque para jogar',
                style: GoogleFonts.plusJakartaSans(fontSize: size * 0.12, fontWeight: FontWeight.w600, color: const Color(0xFF2B2D42)),
              ),
            ),
        ],
      ),
    );
  }
}

class _CatFace {
  final String letter;
  final String name;
  final Color color;
  const _CatFace(this.letter, this.name, this.color);
}

class _CategoryCube extends StatelessWidget {
  final String letter;
  final Color color;
  final double size;

  const _CategoryCube({required this.letter, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    final dark = Color.lerp(color, Colors.black, 0.3)!;
    final light = Color.lerp(color, Colors.white, 0.3)!;
    final radius = size * 0.15;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: const Alignment(-1, -1),
          end: const Alignment(1, 1),
          colors: [light, color, dark],
          stops: const [0.0, 0.4, 1.0],
        ),
        border: Border(
          top: BorderSide(color: light.withValues(alpha: 0.8), width: 2.5),
          left: BorderSide(color: light.withValues(alpha: 0.6), width: 2.5),
          right: BorderSide(color: dark.withValues(alpha: 0.6), width: 3),
          bottom: BorderSide(color: dark.withValues(alpha: 0.8), width: 4),
        ),
        boxShadow: [
          BoxShadow(color: dark.withValues(alpha: 0.6), offset: const Offset(2, 4), blurRadius: 0),
          BoxShadow(color: dark.withValues(alpha: 0.4), offset: const Offset(1, 3), blurRadius: 0),
        ],
      ),
      child: Stack(
        children: [
          // Reflexo de luz
          Positioned(
            top: size * 0.06,
            left: size * 0.06,
            child: Container(
              width: size * 0.35,
              height: size * 0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.15),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          // Letra
          Center(
            child: Text(
              letter,
              style: GoogleFonts.plusJakartaSans(
                fontSize: size * 0.48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 3, offset: const Offset(0, 2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
