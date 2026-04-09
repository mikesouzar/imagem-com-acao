import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/lobby_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _dotsController;
  Timer? _timerCountdown;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _timerCountdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsedSeconds++);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<LobbyProvider>().searchMatch();
      if (mounted) {
        context.read<GameProvider>().setOnline(true);
        Navigator.of(context).pushReplacementNamed('/config');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotsController.dispose();
    _timerCountdown?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // ── Header ──────────────────────────────────────
                    Text(
                      'PlayPulse Digital',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.outline,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Matchmaking',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── Title ───────────────────────────────────────
                    Text(
                      'Buscando Oponentes',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        'Preparando a arena para o duelo digital...',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 14,
                          color: AppColors.outline,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ── Player Cards ────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        children: [
                          Expanded(
                            child: _PlayerCard(
                              name: context.watch<AuthProvider>().currentPlayer?.name ?? 'Jogador',
                              color: AppColors.primary,
                              icon: Icons.person_rounded,
                              isReady: true,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 0.9 + (_pulseController.value * 0.2),
                                  child: Text(
                                    'VS',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: _PlayerCard(
                              name: 'Luna_Strike',
                              color: AppColors.tertiary,
                              icon: Icons.person_search_rounded,
                              isReady: false,
                              pulseController: _pulseController,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 44),

                    // ── Stats Row ───────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        children: [
                          // Estimated time
                          Expanded(
                            child: _StatCard(
                              label: 'TEMPO ESTIMADO',
                              value: _formattedTime,
                              icon: Icons.timer_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Online count
                          Expanded(
                            child: _StatCard(
                              label: 'EM LINHA AGORA',
                              value: '1,248',
                              icon: Icons.wifi_rounded,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Animated Loading Dots ───────────────────────
                    AnimatedBuilder(
                      animation: _dotsController,
                      builder: (context, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final delay = i * 0.3;
                            final t = (_dotsController.value - delay).clamp(0.0, 1.0);
                            final opacity = (t < 0.5)
                                ? (t * 2).clamp(0.3, 1.0)
                                : ((1.0 - t) * 2).clamp(0.3, 1.0);
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Opacity(
                                opacity: opacity,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Cancel Button (fixed at bottom) ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 0, 48, 40),
              child: GestureDetector(
                onTap: () {
                  context.read<LobbyProvider>().cancelSearch();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(48),
                    border: Border.all(color: AppColors.secondary, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Player Card ────────────────────────────────────────────────────────
class _PlayerCard extends StatelessWidget {
  final String name;
  final Color color;
  final IconData icon;
  final bool isReady;
  final AnimationController? pulseController;

  const _PlayerCard({
    required this.name,
    required this.color,
    required this.icon,
    required this.isReady,
    this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: isReady ? Border.all(color: color, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar placeholder
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: isReady
                ? Icon(icon, color: color, size: 28)
                : (pulseController != null
                    ? AnimatedBuilder(
                        animation: pulseController!,
                        builder: (context, _) {
                          return Opacity(
                            opacity: 0.4 + (pulseController!.value * 0.6),
                            child: Icon(icon, color: color, size: 28),
                          );
                        },
                      )
                    : Icon(icon, color: color, size: 28)),
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Status
          if (isReady)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Pronto',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            )
          else
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Stat Card ──────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.outline,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
