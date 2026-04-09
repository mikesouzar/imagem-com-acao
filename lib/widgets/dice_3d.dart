import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/game_state.dart';

// =============================================================================
// DADO 3D NUMÉRICO (1-6)
// =============================================================================

class Dice3DWidget extends StatefulWidget {
  final double size;
  final ValueChanged<int>? onRoll;
  final bool enabled;

  const Dice3DWidget({super.key, this.size = 90, this.onRoll, this.enabled = true});

  @override
  Dice3DState createState() => Dice3DState();
}

class Dice3DState extends State<Dice3DWidget> with SingleTickerProviderStateMixin {
  final _random = Random();
  late AnimationController _controller;
  int _result = 1;
  bool _isRolling = false;
  bool _settled = false;

  // Ângulos [rotX, rotY] para trazer face N para frente (viewer direction = z+)
  // Cube faces: 0=Front(z+), 1=Right(x+), 2=Top(y-), 3=Bottom(y+), 4=Left(x-), 5=Back(z-)
  // rotateX(+) roda Top→Front, rotateX(-) roda Bottom→Front
  // rotateY(+) roda Left→Front, rotateY(-) roda Right→Front
  static const Map<int, List<double>> _faceAngles = {
    1: [0.0, 0.0],         // face 0 Front  → nenhuma rotação
    2: [0.0, -pi / 2],     // face 1 Right  → rotY -90°
    3: [-pi / 2, 0.0],     // face 2 Top    → rotX -90° (top vem para frente)
    4: [pi / 2, 0.0],      // face 3 Bottom → rotX +90° (bottom vem para frente)
    5: [0.0, pi / 2],      // face 4 Left   → rotY +90°
    6: [0.0, pi],           // face 5 Back   → rotY 180°
  };

  double _rotX = 0, _rotY = 0;
  double _targetRotX = 0, _targetRotY = 0;
  double _extraSpinsX = 0, _extraSpinsY = 0;
  double _height = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..addListener(_animate);
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void rollExternally() => _roll();
  bool get isRolling => _isRolling;

  void _animate() {
    final t = _controller.value;
    final spinPhase = (t / 0.75).clamp(0.0, 1.0);
    final eased = Curves.easeOutCubic.transform(spinPhase);

    _rotX = (_extraSpinsX + _targetRotX) * eased;
    _rotY = (_extraSpinsY + _targetRotY) * eased;

    // Bounce: 3 arcos parabólicos decrescentes
    if (t < 0.45) {
      _height = sin(t / 0.45 * pi) * 35;
    } else if (t < 0.65) {
      _height = sin((t - 0.45) / 0.2 * pi) * 12;
    } else if (t < 0.78) {
      _height = sin((t - 0.65) / 0.13 * pi) * 4;
    } else {
      _height = 0;
    }

    setState(() {});

    if (t >= 1.0 && !_settled) {
      _settled = true;
      _isRolling = false;
      HapticFeedback.mediumImpact();
      // Delay para o usuário visualizar o resultado
      Future.delayed(const Duration(milliseconds: 1200), () {
        widget.onRoll?.call(_result);
      });
    }
  }

  Future<void> _roll() async {
    if (_isRolling) return;
    _isRolling = true;
    _settled = false;
    HapticFeedback.mediumImpact();

    _result = _random.nextInt(6) + 1;
    final angles = _faceAngles[_result]!;
    _targetRotX = angles[0];
    _targetRotY = angles[1];
    _extraSpinsX = (2 + _random.nextInt(2)) * 2 * pi * (_random.nextBool() ? 1 : -1);
    _extraSpinsY = (2 + _random.nextInt(2)) * 2 * pi * (_random.nextBool() ? 1 : -1);

    _controller.forward(from: 0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return GestureDetector(
      onTap: widget.enabled ? _roll : null,
      child: SizedBox(
        width: s + 10,
        height: s + 30,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sombra
            Positioned(
              bottom: 0,
              child: Container(
                width: s * 0.55,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: (0.3 - _height * 0.004).clamp(0.05, 0.35)),
                    blurRadius: 6 + _height * 0.3,
                    spreadRadius: -2,
                  )],
                ),
              ),
            ),
            // Cubo com bordas arredondadas no 3D
            Positioned(
              bottom: 12 + _height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(s * 0.18),
                child: _Cube3D(size: s, rotX: _rotX, rotY: _rotY, faceBuilder: (i) => _NumFace(value: i + 1, size: s)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// DADO 3D DE CATEGORIA (P/O/A/D/L/M)
// =============================================================================

class CategoryDice3DWidget extends StatefulWidget {
  final double size;
  final ValueChanged<BoardCategory>? onRoll;
  final bool enabled;

  const CategoryDice3DWidget({super.key, this.size = 90, this.onRoll, this.enabled = true});

  @override
  CategoryDice3DState createState() => CategoryDice3DState();
}

class CategoryDice3DState extends State<CategoryDice3DWidget> with SingleTickerProviderStateMixin {
  final _random = Random();
  late AnimationController _controller;
  int _resultIndex = 0;
  bool _isRolling = false;
  bool _settled = false;
  String _settledName = '';

  static const _cats = BoardCategory.values;
  // Mesmos ângulos corrigidos: face index → rotação para frente
  static const Map<int, List<double>> _faceAngles = {
    0: [0.0, 0.0],         // face 0 (P=pessoa) Front
    1: [0.0, -pi / 2],     // face 1 (O=objeto) Right
    2: [-pi / 2, 0.0],     // face 2 (A=ação)   Top
    3: [pi / 2, 0.0],      // face 3 (D=difícil) Bottom
    4: [0.0, pi / 2],      // face 4 (L=lazer)  Left
    5: [0.0, pi],           // face 5 (M=mix)    Back
  };

  static const Map<BoardCategory, _CatInfo> _info = {
    BoardCategory.pessoa: _CatInfo('P', 'Pessoa', Color(0xFF1565C0)),
    BoardCategory.objeto: _CatInfo('O', 'Objeto', Color(0xFF2E7D32)),
    BoardCategory.acao: _CatInfo('A', 'Ação', Color(0xFFC62828)),
    BoardCategory.dificil: _CatInfo('D', 'Difícil', Color(0xFF6A1B9A)),
    BoardCategory.lazer: _CatInfo('L', 'Lazer', Color(0xFFF9A825)),
    BoardCategory.mix: _CatInfo('M', 'Mix', Color(0xFFE65100)),
  };

  double _rotX = 0, _rotY = 0;
  double _targetRotX = 0, _targetRotY = 0;
  double _extraSpinsX = 0, _extraSpinsY = 0;
  double _height = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..addListener(_animate);
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  /// Rolar externamente
  void rollExternally() => _roll();
  bool get isRolling => _isRolling;

  void _animate() {
    final t = _controller.value;
    final spinPhase = (t / 0.75).clamp(0.0, 1.0);
    final eased = Curves.easeOutCubic.transform(spinPhase);
    _rotX = (_extraSpinsX + _targetRotX) * eased;
    _rotY = (_extraSpinsY + _targetRotY) * eased;

    if (t < 0.45) _height = sin(t / 0.45 * pi) * 35;
    else if (t < 0.65) _height = sin((t - 0.45) / 0.2 * pi) * 12;
    else if (t < 0.78) _height = sin((t - 0.65) / 0.13 * pi) * 4;
    else _height = 0;

    setState(() {});

    if (t >= 1.0 && !_settled) {
      _settled = true;
      _isRolling = false;
      HapticFeedback.mediumImpact();
      _settledName = _info[_cats[_resultIndex]]!.name;
      setState(() {}); // mostrar o nome da categoria
      // Delay para o usuário visualizar o resultado
      Future.delayed(const Duration(milliseconds: 1200), () {
        widget.onRoll?.call(_cats[_resultIndex]);
      });
    }
  }

  Future<void> _roll() async {
    if (_isRolling) return;
    _isRolling = true; _settled = false; _settledName = '';
    HapticFeedback.mediumImpact();
    _resultIndex = _random.nextInt(_cats.length);
    final angles = _faceAngles[_resultIndex]!;
    _targetRotX = angles[0]; _targetRotY = angles[1];
    _extraSpinsX = (2 + _random.nextInt(2)) * 2 * pi * (_random.nextBool() ? 1 : -1);
    _extraSpinsY = (2 + _random.nextInt(2)) * 2 * pi * (_random.nextBool() ? 1 : -1);
    _controller.forward(from: 0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final cat = _cats[_resultIndex];
    final info = _info[cat]!;

    return GestureDetector(
      onTap: widget.enabled ? _roll : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: s + 10, height: s + 30,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(bottom: 0, child: Container(
                  width: s * 0.55, height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(
                      color: info.color.withValues(alpha: (0.35 - _height * 0.004).clamp(0.05, 0.4)),
                      blurRadius: 6 + _height * 0.3, spreadRadius: -2,
                    )],
                  ),
                )),
                Positioned(
                  bottom: 12 + _height,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(s * 0.18),
                    child: _Cube3D(
                      size: s, rotX: _rotX, rotY: _rotY,
                      faceBuilder: (i) {
                        final c = _cats[i % _cats.length];
                        final d = _info[c]!;
                        return _CatFace(letter: d.letter, color: d.color, size: s);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_settled)
            Text(_settledName,
              style: GoogleFonts.plusJakartaSans(fontSize: s * 0.15, fontWeight: FontWeight.w700, color: info.color),
            ),
        ],
      ),
    );
  }
}

class _CatInfo {
  final String letter, name;
  final Color color;
  const _CatInfo(this.letter, this.name, this.color);
}

// =============================================================================
// CUBO 3D - 6 faces com z-ordering correto
// =============================================================================

class _Cube3D extends StatelessWidget {
  final double size;
  final double rotX, rotY;
  final Widget Function(int faceIndex) faceBuilder;

  const _Cube3D({required this.size, required this.rotX, required this.rotY, required this.faceBuilder});

  @override
  Widget build(BuildContext context) {
    final half = size / 2;

    // 6 faces posicionadas no espaço 3D
    final faces = <_FaceInfo>[
      _FaceInfo(0, Matrix4.identity()..translate(0.0, 0.0, half)),                              // Front (1/P)
      _FaceInfo(1, Matrix4.identity()..translate(half, 0.0, 0.0)..rotateY(pi / 2)),             // Right (2/O)
      _FaceInfo(2, Matrix4.identity()..translate(0.0, -half, 0.0)..rotateX(pi / 2)),            // Top   (3/A)
      _FaceInfo(3, Matrix4.identity()..translate(0.0, half, 0.0)..rotateX(-pi / 2)),            // Bot   (4/D)
      _FaceInfo(4, Matrix4.identity()..translate(-half, 0.0, 0.0)..rotateY(-pi / 2)),           // Left  (5/L)
      _FaceInfo(5, Matrix4.identity()..translate(0.0, 0.0, -half)..rotateY(pi)),                // Back  (6/M)
    ];

    final globalRot = Matrix4.identity()..rotateX(rotX)..rotateY(rotY);

    // Calcular profundidade e ordenar back-to-front
    final sorted = faces.map((f) {
      final combined = globalRot.clone()..multiply(f.transform);
      final z = combined.entry(2, 3);
      return (face: f, z: z);
    }).toList()
      ..sort((a, b) => a.z.compareTo(b.z));

    return SizedBox(
      width: size, height: size,
      child: Stack(
        children: sorted.map((item) {
          // Culling: esconder faces atrás da câmera
          if (item.z < -half * 0.5) return const SizedBox.shrink();

          final m = Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..multiply(globalRot)
            ..multiply(item.face.transform);

          return Positioned.fill(
            child: Transform(
              alignment: Alignment.center,
              transform: m,
              child: faceBuilder(item.face.index),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FaceInfo {
  final int index;
  final Matrix4 transform;
  _FaceInfo(this.index, this.transform);
}

// =============================================================================
// FACES
// =============================================================================

class _NumFace extends StatelessWidget {
  final int value;
  final double size;
  const _NumFace({required this.value, required this.size});

  @override
  Widget build(BuildContext context) {
    final v = ((value - 1) % 6) + 1;
    final ps = size * 0.14;
    final r = size * 0.18;
    return ClipRRect(
      borderRadius: BorderRadius.circular(r),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-1, -1), end: Alignment(1, 1),
            colors: [Color(0xFFFFFFFF), Color(0xFFF2F0F8), Color(0xFFE6E3EE)],
          ),
          boxShadow: [
            BoxShadow(color: const Color(0xFFB8B4C0).withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(0, 2)),
          ],
        ),
        // Borda interna simulada
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r - 2),
            gradient: const LinearGradient(
              begin: Alignment(-1, -1), end: Alignment(1, 1),
              colors: [Color(0xFFFFFFFF), Color(0xFFF5F3FA), Color(0xFFEAE7F0)],
            ),
          ),
          padding: EdgeInsets.all(size * 0.14),
          child: _pips(v, ps),
        ),
      ),
    );
  }

  Widget _pips(int v, double ps) {
    Widget p() => Container(width: ps, height: ps, decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const RadialGradient(center: Alignment(-0.3, -0.3), colors: [Color(0xFF44465A), Color(0xFF1A1C2E)]),
      boxShadow: [BoxShadow(color: const Color(0xFF1A1C2E).withValues(alpha: 0.4), blurRadius: 1, offset: const Offset(0.5, 1))],
    ));
    Widget e() => SizedBox(width: ps, height: ps);

    final g = switch (v) {
      1 => [[false, false, false], [false, true, false], [false, false, false]],
      2 => [[false, false, true], [false, false, false], [true, false, false]],
      3 => [[false, false, true], [false, true, false], [true, false, false]],
      4 => [[true, false, true], [false, false, false], [true, false, true]],
      5 => [[true, false, true], [false, true, false], [true, false, true]],
      6 => [[true, false, true], [true, false, true], [true, false, true]],
      _ => <List<bool>>[],
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: g.map((r) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: r.map((s) => s ? p() : e()).toList(),
      )).toList(),
    );
  }
}

class _CatFace extends StatelessWidget {
  final String letter;
  final Color color;
  final double size;
  const _CatFace({required this.letter, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    final dark = Color.lerp(color, Colors.black, 0.2)!;
    final light = Color.lerp(color, Colors.white, 0.2)!;
    final r = size * 0.18;
    return ClipRRect(
      borderRadius: BorderRadius.circular(r),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: const Alignment(-1, -1), end: const Alignment(1, 1), colors: [light, color, dark]),
          boxShadow: [
            BoxShadow(color: dark.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(0, 2)),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r - 2),
            gradient: LinearGradient(begin: const Alignment(-1, -1), end: const Alignment(1, 1), colors: [light, color, dark]),
          ),
          alignment: Alignment.center,
          child: Text(letter,
            style: GoogleFonts.plusJakartaSans(
              fontSize: size * 0.45, fontWeight: FontWeight.w900, color: Colors.white,
              shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 3, offset: const Offset(0, 2))],
            ),
          ),
        ),
      ),
    );
  }
}
