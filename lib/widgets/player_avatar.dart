import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum PlayerAvatarSize { small, medium, large }

class PlayerAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final Color borderColor;
  final PlayerAvatarSize size;
  final bool isOnline;

  const PlayerAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.borderColor = AppColors.primary,
    this.size = PlayerAvatarSize.medium,
    this.isOnline = false,
  });

  double get _diameter {
    switch (size) {
      case PlayerAvatarSize.small:
        return 32;
      case PlayerAvatarSize.medium:
        return 48;
      case PlayerAvatarSize.large:
        return 64;
    }
  }

  double get _borderWidth {
    switch (size) {
      case PlayerAvatarSize.small:
        return 2;
      case PlayerAvatarSize.medium:
        return 2.5;
      case PlayerAvatarSize.large:
        return 3;
    }
  }

  double get _fontSize {
    switch (size) {
      case PlayerAvatarSize.small:
        return 12;
      case PlayerAvatarSize.medium:
        return 18;
      case PlayerAvatarSize.large:
        return 24;
    }
  }

  double get _indicatorSize {
    switch (size) {
      case PlayerAvatarSize.small:
        return 8;
      case PlayerAvatarSize.medium:
        return 12;
      case PlayerAvatarSize.large:
        return 14;
    }
  }

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _diameter + _borderWidth * 2,
      height: _diameter + _borderWidth * 2,
      child: Stack(
        children: [
          // Avatar circle with border
          Container(
            width: _diameter + _borderWidth * 2,
            height: _diameter + _borderWidth * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: _borderWidth),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _InitialsView(
                        initials: _initials,
                        fontSize: _fontSize,
                      ),
                    )
                  : _InitialsView(
                      initials: _initials,
                      fontSize: _fontSize,
                    ),
            ),
          ),
          // Online indicator
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: _indicatorSize,
                height: _indicatorSize,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InitialsView extends StatelessWidget {
  final String initials;
  final double fontSize;

  const _InitialsView({required this.initials, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}
