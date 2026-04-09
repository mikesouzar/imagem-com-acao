import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// An animated 3D-looking dice widget.
///
/// **Tap** to roll. **Long-press** as a "shake" alternative (no extra
/// dependencies required).  Cycles through random faces for ~800 ms then
/// settles with a satisfying bounce.
class DiceWidget extends StatefulWidget {
  final double size;
  final ValueChanged<int>? onRoll;
  final bool enabled;

  const DiceWidget({
    super.key,
    this.size = 100,
    this.onRoll,
    this.enabled = true,
  });

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget>
    with TickerProviderStateMixin {
  static const _pipColor = Color(0xFF2B2D42);
  static const _rollDuration = Duration(milliseconds: 800);
  static const _bounceDuration = Duration(milliseconds: 400);

  final _random = Random();

  int _currentValue = 1;
  bool _isRolling = false;
  Timer? _cycleTimer;

  late final AnimationController _rollController;
  late final AnimationController _bounceController;
  late final Animation<double> _rotationAnim;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();

    // Rotation during the fast-cycling phase.
    _rollController = AnimationController(
      vsync: this,
      duration: _rollDuration,
    );
    _rotationAnim = Tween<double>(begin: 0, end: 4 * pi).animate(
      CurvedAnimation(parent: _rollController, curve: Curves.easeOutCubic),
    );

    // Bounce / scale when the die "lands".
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

  // ── Roll logic ────────────────────────────────────────────────────────────

  Future<void> _roll() async {
    if (_isRolling || !widget.enabled) return;
    setState(() => _isRolling = true);

    // Start rotation animation.
    _rollController.forward(from: 0);

    // Cycle through random faces ~every 60 ms.
    _cycleTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      setState(() => _currentValue = _random.nextInt(6) + 1);
    });

    // Wait for the cycling phase.
    await Future.delayed(_rollDuration);
    _cycleTimer?.cancel();

    // Pick the final result.
    final result = _random.nextInt(6) + 1;
    setState(() => _currentValue = result);

    // Bounce / land effect.
    await _bounceController.forward(from: 0);

    setState(() => _isRolling = false);
    widget.onRoll?.call(result);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final pipSize = size * 0.17;

    return GestureDetector(
      onTap: _roll,
      onLongPress: _roll, // "shake" alternative
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Die with roll + bounce animations.
          AnimatedBuilder(
            animation: Listenable.merge([_rotationAnim, _bounceAnim]),
            builder: (_, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002) // subtle perspective
                  ..rotateX(_isRolling ? _rotationAnim.value : 0)
                  // ignore: deprecated_member_use
              ..scale(_bounceAnim.value),
                child: child,
              );
            },
            child: _DiceFace(
              value: _currentValue,
              size: size,
              pipSize: pipSize,
              pipColor: _pipColor,
            ),
          ),
          SizedBox(height: size * 0.18),

          // Hint text.
          AnimatedOpacity(
            opacity: _isRolling ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Column(
              children: [
                Text(
                  'Toque para jogar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: size * 0.14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sacuda o celular!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: size * 0.11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Die face ──────────────────────────────────────────────────────────────────

class _DiceFace extends StatelessWidget {
  final int value;
  final double size;
  final double pipSize;
  final Color pipColor;

  const _DiceFace({
    required this.value,
    required this.size,
    required this.pipSize,
    required this.pipColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment(-0.8, -0.8),
          end: Alignment(0.8, 0.8),
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF4F2F8),
          ],
        ),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          // Chunky bottom shadow for 3D depth.
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.12),
            blurRadius: 0,
            offset: Offset(0, size * 0.06),
          ),
          // Soft ambient shadow.
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.08),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.16),
        child: _buildPips(),
      ),
    );
  }

  /// Standard pip layout for the given [value] using a 3×3 grid.
  Widget _buildPips() {
    switch (value) {
      case 1:
        return _grid([
          [false, false, false],
          [false, true, false],
          [false, false, false],
        ]);
      case 2:
        return _grid([
          [false, false, true],
          [false, false, false],
          [true, false, false],
        ]);
      case 3:
        return _grid([
          [false, false, true],
          [false, true, false],
          [true, false, false],
        ]);
      case 4:
        return _grid([
          [true, false, true],
          [false, false, false],
          [true, false, true],
        ]);
      case 5:
        return _grid([
          [true, false, true],
          [false, true, false],
          [true, false, true],
        ]);
      case 6:
        return _grid([
          [true, false, true],
          [true, false, true],
          [true, false, true],
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _grid(List<List<bool>> rows) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: rows.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: row.map((show) {
            return show ? _pip() : SizedBox(width: pipSize, height: pipSize);
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _pip() {
    return Container(
      width: pipSize,
      height: pipSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: pipColor,
        boxShadow: [
          BoxShadow(
            color: pipColor.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
