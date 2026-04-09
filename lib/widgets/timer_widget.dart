import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class TimerWidget extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final double size;

  const TimerWidget({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final progress = remainingSeconds / totalSeconds;
    final isUrgent = remainingSeconds <= 10;
    final color = isUrgent ? AppColors.secondary : AppColors.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              color: AppColors.surfaceContainerHigh,
              strokeCap: StrokeCap.round,
            ),
          ),
          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: progress, end: progress),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                color: color,
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          // Seconds text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$remainingSeconds',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                'SEGUNDOS',
                style: GoogleFonts.beVietnamPro(
                  fontSize: size * 0.08,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface.withValues(alpha: 0.5),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
