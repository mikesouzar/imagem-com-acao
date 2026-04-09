import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';

/// An animated category die that shows letters (P, O, A, D, L, T) instead of
/// pips. Same animation style as [DiceWidget] but cycles through board
/// categories and lands on a random one.
class CategoryDiceWidget extends StatefulWidget {
  final double size;
  final ValueChanged<BoardCategory>? onRoll;
  final bool enabled;

  const CategoryDiceWidget({
    super.key,
    this.size = 80,
    this.onRoll,
    this.enabled = true,
  });

  @override
  State<CategoryDiceWidget> createState() => _CategoryDiceWidgetState();
}

class _CategoryDiceWidgetState extends State<CategoryDiceWidget>
    with TickerProviderStateMixin {
  static const _rollDuration = Duration(milliseconds: 800);
  static const _bounceDuration = Duration(milliseconds: 400);

  static const _categories = BoardCategory.values; // P, O, A, D, L, T

  static const Map<BoardCategory, _CategoryFaceData> _faceData = {
    BoardCategory.pessoa: _CategoryFaceData('P', 'Pessoa', Color(0xFF1565C0)),
    BoardCategory.objeto: _CategoryFaceData('O', 'Objeto', Color(0xFF2E7D32)),
    BoardCategory.acao: _CategoryFaceData('A', 'Acao', Color(0xFFC62828)),
    BoardCategory.dificil:
        _CategoryFaceData('D', 'Dificil', Color(0xFF6A1B9A)),
    BoardCategory.lazer: _CategoryFaceData('L', 'Lazer', Color(0xFFF9A825)),
    BoardCategory.mix:
        _CategoryFaceData('M', 'Mix', Color(0xFFE65100)),
  };

  final _random = Random();

  BoardCategory _currentCategory = BoardCategory.pessoa;
  bool _isRolling = false;
  bool _hasSettled = false;
  Timer? _cycleTimer;

  late final AnimationController _rollController;
  late final AnimationController _bounceController;
  late final Animation<double> _rotationAnim;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();

    _rollController = AnimationController(
      vsync: this,
      duration: _rollDuration,
    );
    _rotationAnim = Tween<double>(begin: 0, end: 4 * pi).animate(
      CurvedAnimation(parent: _rollController, curve: Curves.easeOutCubic),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: _bounceDuration,
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.18)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.18, end: 0.92)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.92, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _rollController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _roll() async {
    if (_isRolling || !widget.enabled) return;
    setState(() {
      _isRolling = true;
      _hasSettled = false;
    });

    _rollController.forward(from: 0);

    _cycleTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      setState(() {
        _currentCategory = _categories[_random.nextInt(_categories.length)];
      });
    });

    await Future.delayed(_rollDuration);
    _cycleTimer?.cancel();

    final result = _categories[_random.nextInt(_categories.length)];
    setState(() => _currentCategory = result);

    await _bounceController.forward(from: 0);

    setState(() {
      _isRolling = false;
      _hasSettled = true;
    });
    widget.onRoll?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final face = _faceData[_currentCategory]!;

    return GestureDetector(
      onTap: _roll,
      onLongPress: _roll,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_rotationAnim, _bounceAnim]),
            builder: (_, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateX(_isRolling ? _rotationAnim.value : 0)
                  // ignore: deprecated_member_use
                  ..scale(_bounceAnim.value),
                child: child,
              );
            },
            child: _CategoryDiceFace(
              letter: face.letter,
              color: face.color,
              size: size,
            ),
          ),
          SizedBox(height: size * 0.12),

          // Category name below when settled
          AnimatedOpacity(
            opacity: _hasSettled ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              face.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: size * 0.16,
                fontWeight: FontWeight.w700,
                color: face.color,
              ),
            ),
          ),

          SizedBox(height: size * 0.06),

          // Hint text
          AnimatedOpacity(
            opacity: _isRolling || _hasSettled ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              'Toque para jogar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: size * 0.14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2B2D42),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data class for face info ──────────────────────────────────────────────────

class _CategoryFaceData {
  final String letter;
  final String name;
  final Color color;
  const _CategoryFaceData(this.letter, this.name, this.color);
}

// ── Die face (rounded square with colored background + white letter) ──────────

class _CategoryDiceFace extends StatelessWidget {
  final String letter;
  final Color color;
  final double size;

  const _CategoryDiceFace({
    required this.letter,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: const Alignment(-0.8, -0.8),
          end: const Alignment(0.8, 0.8),
          colors: [
            color,
            Color.lerp(color, Colors.white, 0.2)!,
          ],
        ),
        border: Border.all(
          color: Color.lerp(color, Colors.black, 0.2)!.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 0,
            offset: Offset(0, size * 0.06),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: GoogleFonts.plusJakartaSans(
          fontSize: size * 0.5,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
