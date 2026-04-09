import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final player = auth.currentPlayer;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,
        title: Text(
          'Imagem & Ação',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.onSurface),
            onPressed: () => _showSettingsBottomSheet(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Banner ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryContainer],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -10,
                    bottom: -30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'IMAGEM & AÇÃO',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 3D game pieces placeholder
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.draw, color: Colors.white, size: 28),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.gesture, color: Colors.white, size: 22),
                                  SizedBox(width: 8),
                                  Icon(Icons.chat_bubble, color: Colors.white, size: 22),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Heading ──────────────────────────────────────────────────
            Text(
              'Hora do Show!',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            // ── Body text ────────────────────────────────────────────────
            Text(
              'Chame os amigos e prepare as mímicas. Quem será o mestre da Imagem e ação hoje?',
              style: GoogleFonts.beVietnamPro(
                color: AppColors.onSurface.withValues(alpha: 0.7),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // ── Jogar Agora button ───────────────────────────────────────
            GradientButton(
              text: 'Jogar Agora',
              icon: Icons.play_arrow_rounded,
              isLarge: true,
              onPressed: () => Navigator.pushNamed(context, '/game-mode'),
            ),

            const SizedBox(height: 16),

            // ── Regras & Configurações row ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _OutlinedActionButton(
                    label: 'Regras',
                    icon: Icons.grid_view_rounded,
                    onPressed: () => Navigator.pushNamed(context, '/rules'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OutlinedActionButton(
                    label: 'Configurações',
                    icon: Icons.settings_outlined,
                    onPressed: () => _showSettingsBottomSheet(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Stats row ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(
                    label: 'SEU NÍVEL',
                    value: _levelLabel(player?.level ?? 1),
                  ),
                  Container(width: 1, height: 32, color: AppColors.outlineVariant),
                  _StatItem(
                    label: 'VITÓRIAS',
                    value: '${player?.totalWins ?? 0}',
                  ),
                  Container(width: 1, height: 32, color: AppColors.outlineVariant),
                  const _StatItem(
                    label: 'AMIGOS',
                    value: '0',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            setState(() => _currentNavIndex = index);
            switch (index) {
              case 0:
                // Already on home
                break;
              case 1:
                Navigator.pushNamed(context, '/game-mode');
                break;
              case 2:
                Navigator.pushNamed(context, '/rules');
                break;
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurface.withValues(alpha: 0.5),
          selectedLabelStyle: GoogleFonts.beVietnamPro(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.beVietnamPro(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'INÍCIO',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_outline),
              activeIcon: Icon(Icons.play_circle),
              label: 'JOGAR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'REGRAS',
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.leaderboard_rounded),
                title: Text(
                  'Ranking',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/ranking');
                },
              ),
              ListTile(
                leading: const Icon(Icons.store_rounded),
                title: Text(
                  'Loja',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/store');
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(
                  'Sobre',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  showAboutDialog(
                    context: context,
                    applicationName: 'Imagem com Ação',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'Edição Digital do clássico jogo de tabuleiro.',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _levelLabel(int level) {
    if (level <= 5) return 'Iniciante';
    if (level <= 15) return 'Intermediário';
    if (level <= 30) return 'Avançado';
    return 'Mestre';
  }
}

// ── Outlined Action Button ─────────────────────────────────────────────────

class _OutlinedActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _OutlinedActionButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(48),
        onTap: onPressed,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(48),
            border: Border.all(color: AppColors.outlineVariant, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.onSurface, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat Item ──────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.beVietnamPro(
            color: AppColors.onSurface.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
