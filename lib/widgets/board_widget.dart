import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import '../models/team.dart';

/// Tabuleiro estilo MAPA com caminho sinuoso e pins de localização dos times.
/// Visual inspirado em jogos de tabuleiro reais com trilha serpenteante.
class BoardWidget extends StatelessWidget {
  final List<BoardSpace> spaces;
  final Map<String, int> teamPositions;
  final List<Team> teams;
  final int? highlightedSpace;

  const BoardWidget({
    super.key,
    required this.spaces,
    required this.teamPositions,
    required this.teams,
    this.highlightedSpace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Fundo estilo mapa antigo / tabuleiro de mesa
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5E6C8),
            Color(0xFFEDD9AD),
            Color(0xFFF0DEB5),
            Color(0xFFE8D1A0),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B6914), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          const BoxShadow(
            color: Color(0xFF6B4E0A),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: CustomPaint(
          painter: _MapBackgroundPainter(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                _buildTitle(),
                const SizedBox(height: 8),
                // Mapa do tabuleiro
                LayoutBuilder(
                  builder: (context, constraints) {
                    return _BoardMapLayout(
                      spaces: spaces,
                      teamPositions: teamPositions,
                      teams: teams,
                      highlightedSpace: highlightedSpace,
                      width: constraints.maxWidth,
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Legenda
                _buildLegend(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'IMAGEM & AÇÃO',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final items = [
      (Icons.person_rounded, 'Um Time', const Color(0xFF1565C0)),
      (Icons.groups_rounded, 'Todos Jogam!', const Color(0xFFE65100)),
      (Icons.touch_app_rounded, 'Escolhe!', const Color(0xFF6A1B9A)),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: item.$3,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.white, width: 1),
                  boxShadow: [BoxShadow(color: item.$3.withValues(alpha: 0.4), blurRadius: 2)],
                ),
                alignment: Alignment.center,
                child: Icon(item.$1, color: Colors.white, size: 11),
              ),
              const SizedBox(width: 3),
              Text(item.$2, style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w700, color: item.$3)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Fundo com textura de mapa
class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final dotPaint = Paint()..color = const Color(0xFFD4B876).withValues(alpha: 0.3);

    // Pontilhado sutil de mapa antigo
    for (int i = 0; i < 60; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        rng.nextDouble() * 1.5 + 0.5,
        dotPaint,
      );
    }
    // Linhas decorativas leves
    final linePaint = Paint()
      ..color = const Color(0xFFD4B876).withValues(alpha: 0.15)
      ..strokeWidth = 0.5;
    for (int i = 0; i < 5; i++) {
      final y = size.height * (0.1 + i * 0.2);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Layout que posiciona as casas em um caminho sinuoso de mapa
class _BoardMapLayout extends StatelessWidget {
  final List<BoardSpace> spaces;
  final Map<String, int> teamPositions;
  final List<Team> teams;
  final int? highlightedSpace;
  final double width;

  const _BoardMapLayout({
    required this.spaces,
    required this.teamPositions,
    required this.teams,
    required this.highlightedSpace,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular posições em caminho sinuoso
    final positions = _calculatePositions();
    final spaceSize = 38.0;
    final height = _calculateHeight();

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _PathPainter(positions: positions, spaceSize: spaceSize),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Casas do tabuleiro
            for (int i = 0; i < spaces.length && i < positions.length; i++)
              Builder(builder: (_) {
                final isSpecial = spaces[i].type != SpaceType.umTimeJoga;
                final s = isSpecial ? spaceSize + 4 : spaceSize;
                return Positioned(
                  left: positions[i].dx - s / 2,
                  top: positions[i].dy - s / 2,
                  child: _MapSpaceWidget(
                    space: spaces[i],
                    size: s,
                    isStart: i == 0,
                    isEnd: i == spaces.length - 1,
                    isHighlighted: i == highlightedSpace,
                  ),
                );
              }),
            // Pins dos times
            for (final team in teams)
              _buildTeamPin(team, positions, spaceSize),
          ],
        ),
      ),
    );
  }

  double _calculateHeight() {
    final rows = (spaces.length / 6).ceil();
    return rows * 52.0 + 20;
  }

  List<Offset> _calculatePositions() {
    final cols = 6;
    final hSpacing = (width - 38) / (cols - 1);
    final vSpacing = 52.0;
    final positions = <Offset>[];

    for (int i = 0; i < spaces.length; i++) {
      final row = i ~/ cols;
      final colInRow = i % cols;

      // Serpentina: linhas pares da esquerda pra direita, ímpares ao contrário
      final col = row.isEven ? colInRow : (cols - 1 - colInRow);

      // Offset sinuoso - cada casa tem leve variação vertical
      final waveOffset = sin(i * 0.5) * 4;

      final x = 19.0 + col * hSpacing;
      final y = 19.0 + row * vSpacing + waveOffset;
      positions.add(Offset(x, y));
    }
    return positions;
  }

  Widget _buildTeamPin(Team team, List<Offset> positions, double spaceSize) {
    final pos = teamPositions[team.id] ?? 0;
    if (pos >= positions.length) return const SizedBox.shrink();

    final offset = positions[pos];
    // Calcular deslocamento para múltiplos times na mesma casa
    final teamsAtSamePos = teams.where((t) => (teamPositions[t.id] ?? 0) == pos).toList();
    final indexInGroup = teamsAtSamePos.indexOf(team);
    final xShift = (indexInGroup - (teamsAtSamePos.length - 1) / 2) * 14.0;

    final pinHeight = 36.0;

    return Positioned(
      left: offset.dx - 10 + xShift,
      top: offset.dy - pinHeight - spaceSize / 2 + 8,
      child: _TeamPinWidget(team: team, size: 20, pinHeight: pinHeight),
    );
  }
}

/// Pinta o caminho pontilhado entre as casas
class _PathPainter extends CustomPainter {
  final List<Offset> positions;
  final double spaceSize;

  _PathPainter({required this.positions, required this.spaceSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    // Caminho sólido como trilha
    final trailPaint = Paint()
      ..color = const Color(0xFFD4B876).withValues(alpha: 0.6)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final trailBorderPaint = Paint()
      ..color = const Color(0xFFBDA06A).withValues(alpha: 0.4)
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(positions[0].dx, positions[0].dy);
    for (int i = 1; i < positions.length; i++) {
      // Usar curvas suaves entre os pontos
      if (i < positions.length - 1) {
        final mid = Offset(
          (positions[i].dx + positions[i + 1].dx) / 2,
          (positions[i].dy + positions[i + 1].dy) / 2,
        );
        path.quadraticBezierTo(positions[i].dx, positions[i].dy, mid.dx, mid.dy);
      } else {
        path.lineTo(positions[i].dx, positions[i].dy);
      }
    }

    canvas.drawPath(path, trailBorderPaint);
    canvas.drawPath(path, trailPaint);

    // Pontilhado sobre o caminho
    final dotPaint = Paint()
      ..color = const Color(0xFFC4A45A).withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final dashPath = Path();
    dashPath.moveTo(positions[0].dx, positions[0].dy);
    for (int i = 1; i < positions.length; i++) {
      dashPath.lineTo(positions[i].dx, positions[i].dy);
    }
    canvas.drawPath(dashPath, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) => true;
}

/// Casa individual no mapa
class _MapSpaceWidget extends StatefulWidget {
  final BoardSpace space;
  final double size;
  final bool isStart;
  final bool isEnd;
  final bool isHighlighted;

  const _MapSpaceWidget({
    required this.space,
    required this.size,
    required this.isStart,
    required this.isEnd,
    required this.isHighlighted,
  });

  @override
  State<_MapSpaceWidget> createState() => _MapSpaceWidgetState();
}

class _MapSpaceWidgetState extends State<_MapSpaceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    if (widget.isHighlighted) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _MapSpaceWidget old) {
    super.didUpdateWidget(old);
    if (widget.isHighlighted && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isHighlighted && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.reset();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.space.typeColor;
    final dark = Color.lerp(color, Colors.black, 0.3)!;
    final light = Color.lerp(color, Colors.white, 0.35)!;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final scale = widget.isHighlighted ? 1.0 + _pulse.value * 0.15 : 1.0;
        final glowAlpha = widget.isHighlighted ? 0.3 + _pulse.value * 0.5 : 0.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.4),
                colors: [light, color, dark],
                stops: const [0.0, 0.5, 1.0],
              ),
              border: Border.all(
                color: widget.isHighlighted ? Colors.white : dark.withValues(alpha: 0.6),
                width: widget.isHighlighted ? 2.5 : 1.5,
              ),
              boxShadow: [
                // Sombra 3D
                BoxShadow(color: dark.withValues(alpha: 0.7), offset: const Offset(0, 2.5), blurRadius: 0.5),
                BoxShadow(color: dark.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2)),
                // Glow pulsante
                if (widget.isHighlighted)
                  BoxShadow(color: Colors.white.withValues(alpha: glowAlpha), blurRadius: 10, spreadRadius: 3),
              ],
            ),
            alignment: Alignment.center,
            child: _buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (widget.isStart) {
      return Icon(Icons.flag_rounded, color: Colors.white, size: widget.size * 0.5);
    }
    if (widget.isEnd) {
      return Icon(Icons.emoji_events_rounded, color: const Color(0xFFFFD700), size: widget.size * 0.5);
    }
    return Icon(
      widget.space.typeIcon,
      color: Colors.white,
      size: widget.size * 0.48,
      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 2)],
    );
  }
}

/// Pin de localização do time (estilo Google Maps pin)
class _TeamPinWidget extends StatelessWidget {
  final Team team;
  final double size;
  final double pinHeight;

  const _TeamPinWidget({required this.team, required this.size, required this.pinHeight});

  @override
  Widget build(BuildContext context) {
    final color = team.color;
    final dark = Color.lerp(color, Colors.black, 0.3)!;
    final light = Color.lerp(color, Colors.white, 0.3)!;

    return SizedBox(
      width: size,
      height: pinHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Sombra do pin
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.5,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Haste do pin
          Positioned(
            bottom: 2,
            child: CustomPaint(
              size: Size(size * 0.3, pinHeight * 0.35),
              painter: _PinNeedlePainter(color: dark),
            ),
          ),
          // Cabeça do pin (círculo colorido)
          Positioned(
            top: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  colors: [light, color, dark],
                ),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(color: dark.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                team.name.substring(5, 6), // Primeira letra do nome (ex: "A" de "Time Azul")
                style: GoogleFonts.plusJakartaSans(
                  fontSize: size * 0.45,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pinta a haste pontuda do pin
class _PinNeedlePainter extends CustomPainter {
  final Color color;
  _PinNeedlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinNeedlePainter old) => old.color != color;
}
