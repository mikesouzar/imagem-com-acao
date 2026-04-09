import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/game_provider.dart';
import '../widgets/gradient_button.dart';

class BoardConfigScreen extends StatelessWidget {
  const BoardConfigScreen({super.key});

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
          'Tabuleiro Clássico',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
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
                      // ── Header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFCBC05), Color(0xFFFF9800)],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFCBC05).withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.casino_rounded, size: 40, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
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
                              'Configure o tabuleiro e chame os amigos!',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 14,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Number of Teams
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

                      // ── Time Per Round
                      _SectionLabel(text: 'TEMPO POR RODADA'),
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
                      const SizedBox(height: 28),

                      // ── Board Preview Info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.onSurface.withValues(alpha: 0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Como funciona',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _RuleItem(
                              icon: Icons.casino_rounded,
                              color: const Color(0xFFFCBC05),
                              text: 'Jogue o dado para avançar no tabuleiro',
                            ),
                            const SizedBox(height: 8),
                            _RuleItem(
                              icon: Icons.category_rounded,
                              color: AppColors.primary,
                              text: 'Cada casa tem uma categoria diferente',
                            ),
                            const SizedBox(height: 8),
                            _RuleItem(
                              icon: Icons.check_circle_rounded,
                              color: const Color(0xFF2E7D32),
                              text: 'Acertou? Jogue o dado novamente!',
                            ),
                            const SizedBox(height: 8),
                            _RuleItem(
                              icon: Icons.emoji_events_rounded,
                              color: const Color(0xFFFF6D00),
                              text: 'Primeiro time a chegar ao fim vence!',
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _CategoryChip('P', 'Pessoa', const Color(0xFF0058BC)),
                                _CategoryChip('O', 'Objeto', const Color(0xFF2E7D32)),
                                _CategoryChip('A', 'Ação', const Color(0xFFB7004D)),
                                _CategoryChip('D', 'Difícil', const Color(0xFF6A1B9A)),
                                _CategoryChip('L', 'Lazer', const Color(0xFFFCBC05)),
                                _CategoryChip('T', 'Todos!', const Color(0xFFFF6D00)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // ── Start Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: GradientButton(
                  text: 'Iniciar Tabuleiro  >',
                  isLarge: true,
                  gradientColors: const [Color(0xFFFCBC05), Color(0xFFFF9800)],
                  onPressed: () {
                    gameProvider.startBoardGame();
                    Navigator.of(context).pushNamed('/board-game');
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

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableChip({required this.label, required this.selected, required this.onTap});

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
          border: selected ? null : Border.all(color: AppColors.outlineVariant, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : AppColors.onSurface.withValues(alpha: 0.06),
              blurRadius: selected ? 16 : 12,
              offset: Offset(0, selected ? 4 : 3),
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

class _RuleItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _RuleItem({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.beVietnamPro(
              fontSize: 13,
              color: AppColors.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String letter;
  final String label;
  final Color color;

  const _CategoryChip(this.letter, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.center,
            child: Text(letter, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.beVietnamPro(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
