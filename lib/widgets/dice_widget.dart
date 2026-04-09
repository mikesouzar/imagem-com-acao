import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class DiceWidget extends StatefulWidget {
  final double size;
  final ValueChanged<int>? onRoll;
  final bool enabled;

  const DiceWidget({super.key, this.size = 100, this.onRoll, this.enabled = true});

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget> with TickerProviderStateMixin {
  final _random = Random();
  int _displayValue = 1;
  bool _isRolling = false;

  // Simulação de física
  double _height = 0; // altura do dado (0 = mesa)
  double _tiltX = 0; // inclinação X
  double _tiltY = 0; // inclinação Y
  double _rotation = 0; // rotação Z (giro na mesa)
  double _shadowBlur = 8;
  double _shadowOffset = 4;
  double _scale = 1.0;

  Timer? _physicsTimer;

  @override
  void dispose() {
    _physicsTimer?.cancel();
    super.dispose();
  }

  Future<void> _roll() async {
    if (_isRolling || !widget.enabled) return;
    setState(() => _isRolling = true);
    HapticFeedback.mediumImpact();

    final result = _random.nextInt(6) + 1;

    // Fase 1: Lançamento - dado sobe girando (500ms)
    double velocity = 15.0; // velocidade vertical
    double angularVelX = (_random.nextDouble() - 0.5) * 30;
    double angularVelY = (_random.nextDouble() - 0.5) * 30;
    double spinVel = (_random.nextDouble() - 0.5) * 8;
    int bounceCount = 0;
    int frameCount = 0;
    int faceChangeCounter = 0;

    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      frameCount++;
      faceChangeCounter++;

      // Gravidade
      velocity -= 0.8;
      _height += velocity * 0.5;

      // Rotações diminuem com atrito
      angularVelX *= 0.97;
      angularVelY *= 0.97;
      spinVel *= 0.98;
      _tiltX += angularVelX * 0.016;
      _tiltY += angularVelY * 0.016;
      _rotation += spinVel * 0.016;

      // Trocar face enquanto gira (mais rápido quando está alto)
      final changeRate = _height > 5 ? 3 : (_height > 2 ? 5 : 8);
      if (faceChangeCounter >= changeRate && _height > 1) {
        faceChangeCounter = 0;
        _displayValue = _random.nextInt(6) + 1;
      }

      // Quique no chão
      if (_height <= 0) {
        _height = 0;
        bounceCount++;
        HapticFeedback.lightImpact();

        if (bounceCount >= 4 || velocity.abs() < 3) {
          // Parou
          timer.cancel();
          _displayValue = result;
          _settleAnimation();
          return;
        }

        // Rebate com perda de energia
        velocity = velocity.abs() * 0.45;
        angularVelX *= 0.5;
        angularVelY *= 0.5;
        spinVel *= 0.6;

        // Squash no impacto
        _scale = 0.9;
      } else {
        _scale = 1.0;
      }

      // Sombra proporcional à altura
      _shadowBlur = 8 + _height * 2;
      _shadowOffset = 4 + _height * 1.5;

      if (mounted) setState(() {});
    });
  }

  Future<void> _settleAnimation() async {
    // Wobble final suave
    HapticFeedback.mediumImpact();
    _scale = 0.92;
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 60));

    _scale = 1.05;
    _tiltX *= 0.3;
    _tiltY *= 0.3;
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 80));

    _scale = 0.97;
    _tiltX *= 0.1;
    _tiltY *= 0.1;
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 60));

    // Posição final
    _height = 0;
    _tiltX = 0;
    _tiltY = 0;
    _rotation = 0;
    _scale = 1.0;
    _shadowBlur = 8;
    _shadowOffset = 4;
    _isRolling = false;
    if (mounted) setState(() {});

    await Future.delayed(const Duration(milliseconds: 100));
    widget.onRoll?.call(_displayValue);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

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
                // Sombra no chão (muda com altura)
                Positioned(
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 16),
                    width: size * (0.7 + _height * 0.01),
                    height: size * 0.12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: (0.2 - _height * 0.005).clamp(0.05, 0.25)),
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
                    child: _DiceCube(value: _displayValue, size: size),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          if (!_isRolling && widget.enabled)
            Text('Toque para jogar',
              style: GoogleFonts.plusJakartaSans(fontSize: size * 0.12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
        ],
      ),
    );
  }
}

/// Dado 3D com visual de cubo usando gradiente e bordas
class _DiceCube extends StatelessWidget {
  final int value;
  final double size;

  const _DiceCube({required this.value, required this.size});

  @override
  Widget build(BuildContext context) {
    final pipSize = size * 0.16;
    final radius = size * 0.15;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        // Face principal com gradiente 3D
        gradient: const LinearGradient(
          begin: Alignment(-1, -1),
          end: Alignment(1, 1),
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF8F6FC),
            Color(0xFFEDEAF2),
          ],
          stops: [0.0, 0.4, 1.0],
        ),
        // Borda simulando aresta do cubo
        border: Border(
          top: BorderSide(color: const Color(0xFFE0DCE8), width: 2.5),
          left: BorderSide(color: const Color(0xFFE0DCE8), width: 2.5),
          right: BorderSide(color: const Color(0xFFC8C4D0), width: 3),
          bottom: BorderSide(color: const Color(0xFFB8B4C0), width: 4),
        ),
        boxShadow: const [
          // Sombra inferior grossa (profundidade do cubo)
          BoxShadow(color: Color(0xFF9E9AAA), offset: Offset(2, 4), blurRadius: 0),
          BoxShadow(color: Color(0xFFB0ACBA), offset: Offset(1, 3), blurRadius: 0),
        ],
      ),
      child: Stack(
        children: [
          // Brilho no topo (reflexo da luz)
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
                  colors: [
                    Colors.white.withValues(alpha: 0.7),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          // Pips
          Padding(
            padding: EdgeInsets.all(size * 0.17),
            child: _buildPips(pipSize),
          ),
        ],
      ),
    );
  }

  Widget _buildPips(double pipSize) {
    return switch (value) {
      1 => _grid([[false, false, false], [false, true, false], [false, false, false]], pipSize),
      2 => _grid([[false, false, true], [false, false, false], [true, false, false]], pipSize),
      3 => _grid([[false, false, true], [false, true, false], [true, false, false]], pipSize),
      4 => _grid([[true, false, true], [false, false, false], [true, false, true]], pipSize),
      5 => _grid([[true, false, true], [false, true, false], [true, false, true]], pipSize),
      6 => _grid([[true, false, true], [true, false, true], [true, false, true]], pipSize),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _grid(List<List<bool>> rows, double pipSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: rows.map((row) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: row.map((show) => show ? _pip(pipSize) : SizedBox(width: pipSize, height: pipSize)).toList(),
      )).toList(),
    );
  }

  Widget _pip(double pipSize) {
    return Container(
      width: pipSize,
      height: pipSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.25, -0.25),
          colors: [Color(0xFF3D3F54), Color(0xFF1A1C2E)],
        ),
        boxShadow: [
          // Sombra do pip (profundidade no dado)
          BoxShadow(color: const Color(0xFF1A1C2E).withValues(alpha: 0.5), blurRadius: 1.5, offset: const Offset(0.5, 1)),
          // Indent interno
          BoxShadow(color: Colors.white.withValues(alpha: 0.15), blurRadius: 0.5, offset: const Offset(-0.5, -0.5)),
        ],
      ),
    );
  }
}
