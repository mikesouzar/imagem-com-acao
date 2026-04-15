import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<_RankEntry> _buildGlobalRankings(String userName, int userScore) {
    // Dados de exemplo (simulados) + jogador atual
    return [
      _RankEntry(id: 'user_1', name: 'ArtMaster99', score: 15200, badge: 'LEGEND', avatarColor: const Color(0xFFB7004D)),
      _RankEntry(id: 'user_2', name: 'DrawKing', score: 14800, badge: 'LEGEND', avatarColor: const Color(0xFF0058BC)),
      _RankEntry(id: 'user_3', name: 'PicassoJr', score: 13500, badge: 'MASTER', avatarColor: const Color(0xFF2E7D32)),
      _RankEntry(id: 'user_4', name: 'SketchQueen', score: 12900, badge: 'MASTER', avatarColor: const Color(0xFFFCBC05)),
      _RankEntry(id: 'user_5', name: 'BrushStroke', score: 12100, badge: 'ELITE', avatarColor: const Color(0xFF9C27B0)),
      _RankEntry(id: 'user_6', name: 'DoodlePro', score: 11800, badge: 'ELITE', avatarColor: const Color(0xFFFF5722)),
      _RankEntry(id: 'current_user', name: userName, score: userScore, badge: 'GOLD III', avatarColor: const Color(0xFF0058BC), isCurrentUser: true),
      _RankEntry(id: 'user_8', name: 'InkWizard', score: 9200, badge: 'GOLD III', avatarColor: const Color(0xFF00BCD4)),
      _RankEntry(id: 'user_9', name: 'ColorBurst', score: 8700, badge: 'GOLD II', avatarColor: const Color(0xFFE91E63)),
      _RankEntry(id: 'user_10', name: 'LineArtist', score: 8100, badge: 'GOLD I', avatarColor: const Color(0xFF4CAF50)),
    ];
  }

  List<_RankEntry> _buildFriendsRankings(String userName, int userScore) {
    // Dados de exemplo (simulados) + jogador atual
    return [
      _RankEntry(id: 'f_1', name: 'Maria Silva', score: 11200, badge: 'ELITE', avatarColor: const Color(0xFFB7004D)),
      _RankEntry(id: 'f_2', name: 'João Pedro', score: 10500, badge: 'ELITE', avatarColor: const Color(0xFF0058BC)),
      _RankEntry(id: 'current_user', name: userName, score: userScore, badge: 'GOLD III', avatarColor: const Color(0xFF0058BC), isCurrentUser: true),
      _RankEntry(id: 'f_3', name: 'Ana Costa', score: 7800, badge: 'GOLD II', avatarColor: const Color(0xFF2E7D32)),
      _RankEntry(id: 'f_4', name: 'Lucas Souza', score: 6200, badge: 'SILVER', avatarColor: const Color(0xFFFCBC05)),
    ];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final player = authProvider.currentPlayer;
    final userName = player?.name ?? 'Você';
    final userScore = player?.score ?? 9450;
    final globalRankings = _buildGlobalRankings(userName, userScore);
    final friendsRankings = _buildFriendsRankings(userName, userScore);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rankings PlayPulse Digital',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Tab bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.onSurface.withValues(alpha: 0.6),
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Global'),
                  Tab(text: 'Amigos'),
                ],
              ),
            ),
          ),

          // ── Tab content ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRankingTab(globalRankings, userScore),
                _buildRankingTab(friendsRankings, userScore),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingTab(List<_RankEntry> rankings, int userScore) {
    final top3 = rankings.take(3).toList();
    final rest = rankings.skip(3).toList();

    // Progress bar data (for current user toward top 5)
    const topTargetScore = 11200;

    return Column(
      children: [
        const SizedBox(height: 12),

        // ── Podium ──
        if (top3.length >= 3)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              height: 220,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // #2 - Silver (left)
                  Expanded(child: _buildPodiumItem(top3[1], 2, 140)),
                  const SizedBox(width: 8),
                  // #1 - Gold (center, elevated)
                  Expanded(child: _buildPodiumItem(top3[0], 1, 190)),
                  const SizedBox(width: 8),
                  // #3 - Bronze (right)
                  Expanded(child: _buildPodiumItem(top3[2], 3, 120)),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // ── Scrollable list for rank 4+ ──
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: rest.length,
            itemBuilder: (context, index) {
              final entry = rest[index];
              final rank = index + 4;
              return _buildRankRow(entry, rank);
            },
          ),
        ),

        // ── Progress bar ──
        Container(
          margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
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
              Row(
                children: [
                  Text(
                    'SEU PROGRESSO PARA O TOP 5',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface.withValues(alpha: 0.5),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$userScore / $topTargetScore',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (userScore / topTargetScore).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumItem(_RankEntry entry, int rank, double height) {
    final Color podiumColor;
    final IconData? crownIcon;

    switch (rank) {
      case 1:
        podiumColor = const Color(0xFFFCBC05);
        crownIcon = Icons.workspace_premium_rounded;
        break;
      case 2:
        podiumColor = const Color(0xFFC0C0C0);
        crownIcon = null;
        break;
      default:
        podiumColor = const Color(0xFFCD7F32);
        crownIcon = null;
    }

    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Crown for #1
          if (crownIcon != null)
            Icon(crownIcon, color: podiumColor, size: 28)
          else
            const SizedBox(height: 28),

          const SizedBox(height: 4),

          // Avatar
          Container(
            width: rank == 1 ? 64 : 52,
            height: rank == 1 ? 64 : 52,
            decoration: BoxDecoration(
              color: entry.avatarColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: podiumColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: podiumColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                entry.name[0].toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: rank == 1 ? 24 : 20,
                  fontWeight: FontWeight.w800,
                  color: entry.avatarColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            entry.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 2),

          Text(
            '${entry.score}',
            style: GoogleFonts.beVietnamPro(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),

          const SizedBox(height: 8),

          // Podium base
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
            width: double.infinity,
            height: rank == 1 ? 44 : (rank == 2 ? 32 : 24),
            decoration: BoxDecoration(
              color: podiumColor.withValues(alpha: 0.2),
              border: Border(
                top: BorderSide(color: podiumColor, width: 3),
                left: BorderSide(color: podiumColor.withValues(alpha: 0.3), width: 1),
                right: BorderSide(color: podiumColor.withValues(alpha: 0.3), width: 1),
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: podiumColor.withValues(alpha: 0.8),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRankRow(_RankEntry entry, int rank) {
    final isCurrentUser = entry.isCurrentUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: isCurrentUser
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isCurrentUser
                    ? AppColors.primary
                    : AppColors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: entry.avatarColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCurrentUser
                  ? const Icon(Icons.star_rounded,
                      color: AppColors.tertiary, size: 20)
                  : Text(
                      entry.name[0].toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: entry.avatarColor,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentUser ? 'Você (${entry.badge})' : entry.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isCurrentUser
                        ? AppColors.primary
                        : AppColors.onSurface,
                  ),
                ),
                Text(
                  '${entry.score} pts',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _badgeColor(entry.badge).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              entry.badge,
              style: GoogleFonts.beVietnamPro(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _badgeColor(entry.badge),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _badgeColor(String badge) {
    if (badge.contains('LEGEND')) return AppColors.secondary;
    if (badge.contains('MASTER')) return const Color(0xFF9C27B0);
    if (badge.contains('ELITE')) return AppColors.primary;
    if (badge.contains('GOLD')) return const Color(0xFFE69500);
    if (badge.contains('SILVER')) return const Color(0xFF78909C);
    return AppColors.outline;
  }
}

class _RankEntry {
  final String id;
  final String name;
  final int score;
  final String badge;
  final Color avatarColor;
  final bool isCurrentUser;

  const _RankEntry({
    required this.id,
    required this.name,
    required this.score,
    required this.badge,
    required this.avatarColor,
    this.isCurrentUser = false,
  });
}
