import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Como Jogar',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Heading ──────────────────────────────────────────────────
            Text(
              'Prepare-se para rir!',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Divirta-se com mímicas e desenhos para transformar qualquer encontro em risadas e imaginação dentro.',
              style: GoogleFonts.beVietnamPro(
                color: AppColors.onSurface.withValues(alpha: 0.7),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            // ── Rule 1: Desenho ──────────────────────────────────────────
            _RuleSection(
              iconColor: AppColors.primary,
              icon: Icons.edit_rounded,
              title: 'Desenho',
              description:
                  'Desenhe sem usar palavras, letras, sinais ou símbolos. Use apenas traços e formas para representar a palavra.',
            ),

            const SizedBox(height: 20),

            // ── Rule 2: Mímica ───────────────────────────────────────────
            _RuleSection(
              iconColor: AppColors.tertiary,
              icon: Icons.back_hand_rounded,
              title: 'Mímica',
              description:
                  'Use seu corpo para representar a palavra. Sem falar, sem apontar e sem usar objetos. Seus gestos são tudo!',
            ),

            const SizedBox(height: 20),

            // ── Rule 3: Descrição ────────────────────────────────────────
            _RuleSection(
              iconColor: const Color(0xFF7C4DFF),
              icon: Icons.chat_bubble_rounded,
              title: 'Descrição',
              description:
                  'Explique a palavra usando dicas, sinônimos e associações. Proibido dizer a palavra, traduzir ou soletrar!',
            ),

            const SizedBox(height: 20),

            // ── Rule 4: Misto ────────────────────────────────────────────
            _RuleSection(
              iconColor: AppColors.secondary,
              icon: Icons.shuffle_rounded,
              title: 'Misto',
              description:
                  'A cada rodada, o modo muda! Prepare-se para alternar entre Desenho, Mímica e Descrição.',
            ),

            const SizedBox(height: 28),

            // ── Dica de Ouro ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.tertiaryContainer,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.tertiary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.tertiary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dica de Ouro',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'O segredo é a criatividade! Quanto mais inesperadas forem suas representações, mais divertido fica o jogo. Não tenha medo de errar — a diversão está na tentativa!',
                          style: GoogleFonts.beVietnamPro(
                            color: AppColors.onSurface.withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Footer text ──────────────────────────────────────────────
            Center(
              child: Text(
                'Divirta-se tanto!',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.onSurface.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Rule Section ───────────────────────────────────────────────────────────

class _RuleSection extends StatelessWidget {
  final Color iconColor;
  final IconData icon;
  final String title;
  final String description;

  const _RuleSection({
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.beVietnamPro(
                    color: AppColors.onSurface.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
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
