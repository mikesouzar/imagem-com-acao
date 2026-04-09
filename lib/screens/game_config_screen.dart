import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/game_provider.dart';
import '../models/game_config.dart';
import '../widgets/gradient_button.dart';
import '../widgets/game_card.dart';

class GameConfigScreen extends StatelessWidget {
  const GameConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Configuração do Jogo',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, _) {
          final config = gameProvider.config;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──────────────────────────────────────
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Imagem & Ação',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Prepare sua equipe para o desafio!',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 14,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Number of Teams ─────────────────────────────
                      _SectionLabel(text: 'NÚMERO DE EQUIPES'),
                      const SizedBox(height: 12),
                      Row(
                        children: [2, 3, 4].map((n) {
                          final selected = config.numberOfTeams == n;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: n == 2 ? 0 : 6,
                                right: n == 4 ? 0 : 6,
                              ),
                              child: _SelectableChip(
                                label: '$n',
                                selected: selected,
                                onTap: () => gameProvider.setNumberOfTeams(n),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),

                      // ── Game Mode ───────────────────────────────────
                      _SectionLabel(text: 'MODO DE JOGO'),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.05,
                        children: [
                          _ModeCard(
                            icon: Icons.edit_rounded,
                            title: 'Desenho',
                            subtitle: 'Adivinhe a partir de traços',
                            selected: config.mode == GameMode.desenho,
                            onTap: () => gameProvider.setGameMode(GameMode.desenho),
                          ),
                          _ModeCard(
                            icon: Icons.back_hand_rounded,
                            title: 'Mímica',
                            subtitle: 'Interprete sem palavras',
                            selected: config.mode == GameMode.mimica,
                            onTap: () => gameProvider.setGameMode(GameMode.mimica),
                          ),
                          _ModeCard(
                            icon: Icons.chat_bubble_rounded,
                            title: 'Descrição',
                            subtitle: 'Explique a palavra',
                            selected: config.mode == GameMode.descricao,
                            onTap: () => gameProvider.setGameMode(GameMode.descricao),
                          ),
                          _ModeCard(
                            icon: Icons.shuffle_rounded,
                            title: 'Misto',
                            subtitle: 'Alternando o modo a cada rodada',
                            selected: config.mode == GameMode.misto,
                            onTap: () => gameProvider.setGameMode(GameMode.misto),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ── Difficulty ──────────────────────────────────
                      _SectionLabel(text: 'DIFICULDADE'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          (Difficulty.facil, 'Fácil'),
                          (Difficulty.medio, 'Médio'),
                          (Difficulty.dificil, 'Difícil'),
                        ].map((entry) {
                          final (difficulty, label) = entry;
                          final selected = config.difficulty == difficulty;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: difficulty == Difficulty.facil ? 0 : 6,
                                right: difficulty == Difficulty.dificil ? 0 : 6,
                              ),
                              child: _SelectableChip(
                                label: label,
                                selected: selected,
                                onTap: () => gameProvider.setDifficulty(difficulty),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),

                      // ── Time Per Round ──────────────────────────────
                      _SectionLabel(text: 'TEMPO / RODADA'),
                      const SizedBox(height: 12),
                      Row(
                        children: [30, 60, 90].map((s) {
                          final selected = config.timePerRound == s;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: s == 30 ? 0 : 6,
                                right: s == 90 ? 0 : 6,
                              ),
                              child: _SelectableChip(
                                label: '${s}s',
                                selected: selected,
                                onTap: () => gameProvider.setTimePerRound(s),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // ── Start Button ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: GradientButton(
                  text: 'Iniciar Jogo  >',
                  isLarge: true,
                  onPressed: () {
                    gameProvider.startGame();
                    final route = switch (config.mode) {
                      GameMode.desenho => '/drawing-arena',
                      GameMode.mimica => '/charades',
                      GameMode.descricao || GameMode.misto => '/game-round',
                    };
                    Navigator.of(context).pushNamed(route);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Section Label ──────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: AppColors.outline,
      ),
    );
  }
}

// ── Selectable Chip ────────────────────────────────────────────────────
class _SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(color: AppColors.outlineVariant, width: 1.5),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.onSurface.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

// ── Mode Card ──────────────────────────────────────────────────────────
class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GameCard(
      isSelected: selected,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: selected ? AppColors.primary : AppColors.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.primary : AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              subtitle,
              style: GoogleFonts.beVietnamPro(
                fontSize: 11,
                color: AppColors.outline,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
