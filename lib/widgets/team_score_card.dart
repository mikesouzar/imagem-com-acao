import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class TeamScoreCard extends StatelessWidget {
  final String teamName;
  final Color teamColor;
  final int score;
  final bool isPlayingNow;

  const TeamScoreCard({
    super.key,
    required this.teamName,
    required this.teamColor,
    required this.score,
    this.isPlayingNow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            // Team color accent strip
            Container(
              width: 6,
              height: 72,
              color: teamColor,
            ),
            const SizedBox(width: 16),
            // Team info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            teamName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPlayingNow) ...[
                          const SizedBox(width: 8),
                          _PlayingNowBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$score pontos',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: teamColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Score display
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                '$score',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: teamColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayingNowBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        'JOGANDO',
        style: GoogleFonts.beVietnamPro(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
