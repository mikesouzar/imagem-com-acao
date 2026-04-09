import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../widgets/drawing_canvas.dart';

/// Digital Drawing Arena screen – "Arena de Desenho Digital".
///
/// Provides a full-screen drawing canvas with colour palette, brush size
/// slider and a tool bar, plus a live countdown timer and the secret word.
class DrawingArenaScreen extends StatefulWidget {
  const DrawingArenaScreen({super.key});

  @override
  State<DrawingArenaScreen> createState() => _DrawingArenaScreenState();
}

class _DrawingArenaScreenState extends State<DrawingArenaScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().startTimer();
    });
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

        // Auto-navigate to results when timer expires
        if (state.phase == RoundPhase.results && !_navigated) {
          _navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/round-results');
            }
          });
        }

        final word = state.currentWord?.word ?? '---';
        final timeRemaining = state.timeRemaining;
        final minutes = (timeRemaining ~/ 60).toString().padLeft(2, '0');
        final seconds = (timeRemaining % 60).toString().padLeft(2, '0');

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────
                _buildTopBar(word, '$minutes:$seconds', timeRemaining <= 10),
                const SizedBox(height: 8),

                // ── Canvas + overlay button ──────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      children: [
                        // Drawing canvas (takes full space)
                        const DrawingCanvas(
                          backgroundColor: Colors.white,
                        ),

                        // "ENVIAR >" button overlaid bottom-right
                        Positioned(
                          bottom: 110, // above the toolbar
                          right: 12,
                          child: _buildSendButton(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── widgets ──────────────────────────────────────────────────────────────

  Widget _buildTopBar(String word, String timeLabel, bool isUrgent) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo / brand
          Text(
            'PLAYPULSE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),

          // Timer with red dot
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppColors.secondary.withValues(alpha: 0.12)
                  : AppColors.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(48),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isUrgent ? AppColors.secondary : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timeLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isUrgent ? AppColors.secondary : AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Word badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(48),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              word.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: () {
        context.read<GameProvider>().markCorrect();
        _navigated = true;
        Navigator.of(context).pushReplacementNamed('/round-results');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(48),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ENVIAR',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
