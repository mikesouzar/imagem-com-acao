import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/game_provider.dart';
import '../models/game_config.dart';
import '../widgets/gradient_button.dart';
class RoundResultsScreen extends StatelessWidget {
  const RoundResultsScreen({super.key});

  String _modeActionText(GameMode mode) {
    switch (mode) {
      case GameMode.desenho:
        return 'desenho';
      case GameMode.mimica:
        return 'mímica';
      case GameMode.descricao:
        return 'descrição';
      case GameMode.misto:
        return 'rodada';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final gameState = gameProvider.gameState;

    if (gameState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final teams = gameState.teams;
    final currentTeam = gameState.currentTeam;
    final sortedTeams = List.of(teams)..sort((a, b) => b.score.compareTo(a.score));
    final leadingTeam = sortedTeams.first;
    final goalPoints = gameState.config.totalRounds * 2;
    final pointsEarned = gameState.difficultyPoints;
    final word = gameState.currentWord?.word ?? 'Palavra';
    final scored = gameProvider.lastRoundScored;
    final modeText = _modeActionText(gameState.config.mode);

    // Next team (for "Próxima Rodada" section)
    final nextTeamIndex = (gameState.currentTeamIndex + 1) % teams.length;
    final nextTeam = teams[nextTeamIndex];

    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.home_rounded,
              label: 'INICIO',
              isSelected: false,
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/home'),
            ),
            _BottomNavItem(
              icon: Icons.play_circle_filled_rounded,
              label: 'JOGAR',
              isSelected: true,
              onTap: () {
                if (!gameProvider.isGameOver) {
                  gameProvider.nextTurn();
                  final route = switch (gameState.config.mode) {
                    GameMode.desenho => '/drawing-arena',
                    GameMode.mimica => '/charades',
                    GameMode.descricao || GameMode.misto => '/game-round',
                  };
                  Navigator.pushReplacementNamed(context, route);
                }
              },
            ),
            _BottomNavItem(
              icon: Icons.history_rounded,
              label: 'RODADAS',
              isSelected: false,
              isDisabled: true,
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
                    const SizedBox(height: 24),

                    // ── "RODADA FINALIZADA" badge ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: scored ? AppColors.secondary : AppColors.outline,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (scored ? AppColors.secondary : AppColors.outline).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        scored ? 'RODADA FINALIZADA' : 'TEMPO ESGOTADO!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Heading ──
                    Text(
                      scored ? 'Fim da Rodada' : 'Tempo Esgotado!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      scored
                          ? 'Os pincéis descansam, os pontos sobem!'
                          : 'Não foi dessa vez, mas a próxima vem!',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // ── Points earned card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: scored
                              ? [AppColors.primary, AppColors.primaryContainer]
                              : [AppColors.outline, AppColors.outline.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: (scored ? AppColors.primary : AppColors.outline).withValues(alpha: 0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Trophy / timeout icon
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              scored ? Icons.emoji_events_rounded : Icons.timer_off_rounded,
                              color: scored ? AppColors.tertiary : Colors.white70,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentTeam.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            scored ? '+$pointsEarned PONTOS' : '0 PONTOS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            scored
                                ? 'Mandaram bem na $modeText do \'$word\'!'
                                : 'A palavra era \'$word\'. Na próxima será melhor!',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── "Placar Geral" section header ──
                    Row(
                      children: [
                        Text(
                          'Placar Geral',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.tertiary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'META: $goalPoints PONTOS',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Team scores list ──
                    ...sortedTeams.map((team) {
                      final isLeading = team.id == leadingTeam.id;
                      final progress =
                          (team.score / goalPoints).clamp(0.0, 1.0);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isLeading
                                ? AppColors.surfaceContainerLow
                                : AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(24),
                            border: isLeading
                                ? Border.all(
                                    color: team.color
                                        .withValues(alpha: 0.4),
                                    width: 2)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.onSurface
                                    .withValues(alpha: isLeading ? 0.1 : 0.04),
                                blurRadius: isLeading ? 20 : 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Team color icon
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: team.color
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.palette_rounded,
                                  color: team.color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Name + progress bar
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            team.name,
                                            style:
                                                GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onSurface,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isLeading)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 6),
                                            child: Icon(
                                              Icons.star_rounded,
                                              color: AppColors.tertiary,
                                              size: 18,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Progress bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 8,
                                        backgroundColor: AppColors
                                            .surfaceContainerHigh,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                team.color),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Score
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${team.score}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: team.color,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '/$goalPoints',
                                      style: GoogleFonts.beVietnamPro(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.onSurface
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // ── Next round / Game over section ──
                    if (!gameProvider.isGameOver) ...[
                      // "Próxima Rodada" section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.onSurface.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Próxima Rodada',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: nextTeam.color,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  nextTeam.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: nextTeam.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'PREPARE-SE, ${nextTeam.name.toUpperCase()}!',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color:
                                    AppColors.onSurface.withValues(alpha: 0.5),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      GradientButton(
                        text: 'Próxima Rodada',
                        icon: Icons.play_arrow_rounded,
                        isLarge: true,
                        onPressed: () {
                          gameProvider.nextTurn();
                          final route = switch (gameState.config.mode) {
                            GameMode.desenho => '/drawing-arena',
                            GameMode.mimica => '/charades',
                            GameMode.descricao || GameMode.misto => '/game-round',
                          };
                          Navigator.pushReplacementNamed(context, route);
                        },
                      ),
                    ] else ...[
                      GradientButton(
                        text: 'Ver Vencedor',
                        icon: Icons.emoji_events_rounded,
                        isLarge: true,
                        gradientColors: [
                          AppColors.tertiary,
                          AppColors.tertiary.withValues(alpha: 0.8),
                        ],
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/winner');
                        },
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
        );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isDisabled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDisabled
        ? AppColors.outline.withValues(alpha: 0.4)
        : isSelected
            ? AppColors.primary
            : AppColors.outline;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.beVietnamPro(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
