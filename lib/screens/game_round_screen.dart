import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../models/game_config.dart';
import '../widgets/timer_widget.dart';
import '../widgets/gradient_button.dart';

/// Main game round screen – "Tela de Jogo Rodada".
///
/// Shows the current word, a circular countdown timer, mode badge,
/// team indicator, score and action buttons (Acertou! / Pular Rodada).
class GameRoundScreen extends StatefulWidget {
  const GameRoundScreen({super.key});

  @override
  State<GameRoundScreen> createState() => _GameRoundScreenState();
}

class _GameRoundScreenState extends State<GameRoundScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Start the round timer as soon as the screen is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().startTimer();
    });
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  IconData _modeIcon(GameMode mode) => switch (mode) {
        GameMode.desenho => Icons.brush_rounded,
        GameMode.mimica => Icons.accessibility_new_rounded,
        GameMode.descricao => Icons.chat_bubble_rounded,
        GameMode.misto => Icons.shuffle_rounded,
      };

  String _modeLabel(GameMode mode) => switch (mode) {
        GameMode.desenho => 'MODO DESENHO',
        GameMode.mimica => 'MODO MÍMICA',
        GameMode.descricao => 'MODO DESCRIÇÃO',
        GameMode.misto => 'MODO MISTO',
      };

  String _hintText(GameState state) {
    final hint = state.currentWord?.hint;
    if (hint != null && hint.isNotEmpty) return 'Dica: $hint';
    final cat = state.currentWord?.category ?? '';
    return 'Dica: $cat. Use formas geométricas para ajudar o time!';
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gp, _) {
        final state = gp.gameState;
        if (state == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Navigate to results when time is up or phase changes to results.
        if (state.phase == RoundPhase.results && !_navigated) {
          _navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/round-results');
            }
          });
        }

        final team = state.currentTeam;
        final word = state.currentWord?.word ?? '---';

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        // ── Top bar ──────────────────────────────────────────
                        _buildTopBar(team),
                        const SizedBox(height: 16),

                        // ── Mode badge ───────────────────────────────────────
                        _buildModeBadge(state.config.mode),
                        const SizedBox(height: 24),

                        // ── Timer ────────────────────────────────────────────
                        TimerWidget(
                          totalSeconds: state.config.timePerRound,
                          remainingSeconds: state.timeRemaining,
                          size: 140,
                        ),
                        const SizedBox(height: 28),

                        // ── Secret word area ─────────────────────────────────
                        _buildSecretWordCard(word, state),
                        const SizedBox(height: 24),

                        // ── Score ────────────────────────────────────────────
                        _buildScoreBar(state),
                      ],
                    ),
                  ),
                ),

                // ── Action buttons (fixed at bottom) ───────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      GradientButton(
                        text: 'Acertou!',
                        icon: Icons.check_circle_rounded,
                        isLarge: true,
                        gradientColors: const [
                          Color(0xFF43A047),
                          Color(0xFF66BB6A),
                        ],
                        onPressed: () {
                          gp.markCorrect();
                        },
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () {
                          gp.skipWord();
                        },
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          color: AppColors.outline,
                        ),
                        label: Text(
                          'Pular Rodada',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.outline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── widgets ──────────────────────────────────────────────────────────────

  Widget _buildTopBar(dynamic team) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Text(
          'Imagem & Acao',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        // Team badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Color(team.color.value).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(48),
            border: Border.all(
              color: Color(team.color.value).withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(team.color.value).withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.group_rounded,
                  size: 16, color: Color(team.color.value)),
              const SizedBox(width: 6),
              Text(
                team.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(team.color.value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeBadge(GameMode mode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(48),
        border: Border.all(
          color: AppColors.tertiary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_modeIcon(mode), size: 18, color: AppColors.onSurface),
          const SizedBox(width: 8),
          Text(
            _modeLabel(mode),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecretWordCard(String word, GameState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'SUA PALAVRA SECRETA',
            style: GoogleFonts.beVietnamPro(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.outline,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            word,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _hintText(state),
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(GameState state) {
    final scores = state.teams
        .map((t) => t.score.toString().padLeft(2, '0'))
        .join(' vs ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Text(
        'PLACAR: $scores',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}
