import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../widgets/gradient_button.dart';

/// Online Charades screen – "Arena de Mímica Online".
///
/// Features a video placeholder, live timer overlay, chat-style guess
/// bubbles, quick-guess chips, secret word overlay and action buttons.
class CharadesScreen extends StatefulWidget {
  const CharadesScreen({super.key});

  @override
  State<CharadesScreen> createState() => _CharadesScreenState();
}

class _CharadesScreenState extends State<CharadesScreen> {
  final TextEditingController _guessController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isMuted = true;
  bool _navigated = false;
  int _bottomNavIndex = 1; // "JOGAR ONLINE" selected

  // Chat messages – start empty
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().startTimer();
    });
  }

  @override
  void dispose() {
    _guessController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendGuess() {
    final text = _guessController.text.trim();
    if (text.isEmpty) return;

    final gp = context.read<GameProvider>();
    final secretWord = gp.gameState?.currentWord?.word ?? '';

    // Check if the guess matches the secret word (case-insensitive)
    final isCorrect = secretWord.isNotEmpty &&
        text.toLowerCase() == secretWord.trim().toLowerCase();

    setState(() {
      _messages.add(
        _ChatMessage(sender: 'Voce', text: text, isCorrect: isCorrect),
      );
      if (isCorrect) {
        _messages.add(
          _ChatMessage(
            sender: 'Sistema',
            text: 'Acertou! A palavra era "$secretWord"!',
            isCorrect: true,
          ),
        );
      }
      _guessController.clear();
    });

    _scrollToBottom();

    if (isCorrect) {
      gp.markCorrect();
      if (!_navigated && mounted) {
        _navigated = true;
        Navigator.of(context).pushReplacementNamed('/round-results');
      }
    }
  }

  void _addQuickChip(String text) {
    setState(() {
      _messages.add(
        _ChatMessage(sender: 'Voce', text: text, isCorrect: false),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isMuted ? 'Microfone desativado' : 'Microfone ativado',
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da partida?'),
        content: const Text(
          'Tem certeza que deseja voltar ao início? O progresso da partida será perdido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (shouldExit == true && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
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

        // Navigate to results when round ends.
        if (state.phase == RoundPhase.results && !_navigated) {
          _navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/round-results');
            }
          });
        }

        final word = state.currentWord?.word ?? '---';
        final team = state.currentTeam;
        final timeRemaining = state.timeRemaining;
        final minutes = (timeRemaining ~/ 60).toString().padLeft(2, '0');
        final seconds = (timeRemaining % 60).toString().padLeft(2, '0');

        return Scaffold(
          backgroundColor: AppColors.surface,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                // ── Scrollable upper section ─────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // ── Header ───────────────────────────────────────────
                        _buildHeader(team),
                        const SizedBox(height: 8),

                        // ── Mode badge + player count ────────────────────────
                        _buildModeBadgeRow(state),
                        const SizedBox(height: 8),

                        // ── Score line ────────────────────────────────────────
                        _buildScoreLine(team),
                        const SizedBox(height: 12),

                        // ── Video area with overlays ─────────────────────────
                        _buildVideoArea(word, '$minutes:$seconds', timeRemaining <= 10),
                        const SizedBox(height: 8),

                        // ── Mute toggle ──────────────────────────────────────
                        _buildMuteButton(),
                        const SizedBox(height: 8),

                        // ── Chat guesses ─────────────────────────────────────
                        SizedBox(
                          height: 120,
                          child: _buildChat(),
                        ),

                        // ── Quick-guess chips ────────────────────────────────
                        _buildQuickChips(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // ── Fixed bottom section ─────────────────────────────
                // ── Text input ───────────────────────────────────────
                _buildGuessInput(),
                const SizedBox(height: 10),

                // ── Action buttons ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GradientButton(
                    text: 'Acertou!',
                    icon: Icons.check_circle_rounded,
                    isLarge: true,
                    gradientColors: const [
                      Color(0xFF43A047),
                      Color(0xFF66BB6A),
                    ],
                    onPressed: () => gp.markCorrect(),
                  ),
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: () => gp.skipWord(),
                  icon: const Icon(Icons.skip_next_rounded,
                      color: AppColors.outline),
                  label: Text(
                    'Pular Rodada',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.outline,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),

          // ── Bottom navigation ────────────────────────────────────────
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  // ── widgets ──────────────────────────────────────────────────────────────

  Widget _buildHeader(dynamic team) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          // Logo + avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.gamepad_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'Imagem & Acao',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(48),
            ),
            child: Text(
              '${team.score} pts',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBadgeRow(GameState state) {
    final config = state.config;
    final modeText = config.isOnline
        ? '${config.modeLabel.toUpperCase()} ONLINE'
        : config.modeLabel.toUpperCase();
    final teamCount = state.teams.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Mode badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(48),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.accessibility_new_rounded,
                    size: 16, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  modeText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Player count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(48),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_alt_rounded,
                    size: 14, color: AppColors.outline),
                const SizedBox(width: 4),
                Text(
                  '$teamCount',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreLine(dynamic team) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '${team.name}: ${team.score} pts',
          style: GoogleFonts.beVietnamPro(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoArea(String word, String timeLabel, bool isUrgent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Person placeholder
              Center(
                child: Icon(
                  Icons.person_rounded,
                  size: 72,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),

              // Timer overlay – top left
              Positioned(
                top: 12,
                left: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(48),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isUrgent
                              ? AppColors.secondary
                              : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Secret word card – bottom center
              Positioned(
                bottom: 14,
                left: 24,
                right: 24,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PALAVRA SECRETA',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: AppColors.outline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        word.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMuteButton() {
    return GestureDetector(
      onTap: _toggleMute,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _isMuted
              ? AppColors.secondary.withValues(alpha: 0.12)
              : AppColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(48),
          border: Border.all(
            color: _isMuted
                ? AppColors.secondary.withValues(alpha: 0.3)
                : AppColors.success.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              size: 18,
              color: _isMuted ? AppColors.secondary : AppColors.success,
            ),
            const SizedBox(width: 8),
            Text(
              _isMuted ? 'MICROFONE MUDO' : 'MICROFONE ATIVO',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: _isMuted ? AppColors.secondary : AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChat() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMe = msg.sender == 'Voce';
        final isSystem = msg.sender == 'Sistema';

        // Correct-answer system messages get a centered green style
        if (msg.isCorrect && isSystem) {
          return Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF43A047).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF43A047).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
          );
        }

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: msg.isCorrect
                  ? const Color(0xFF43A047).withValues(alpha: 0.15)
                  : isMe
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: msg.isCorrect
                  ? Border.all(
                      color: const Color(0xFF43A047).withValues(alpha: 0.4),
                      width: 1.5,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${msg.sender}: ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: msg.isCorrect
                          ? const Color(0xFF2E7D32)
                          : AppColors.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: msg.text,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: msg.isCorrect
                          ? const Color(0xFF2E7D32)
                          : AppColors.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickChips() {
    const chips = [
      'E um objeto?',
      'E uma profissao?',
      'Nao entendi!',
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _addQuickChip(chips[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(48),
                border: Border.all(
                  color: AppColors.outlineVariant,
                  width: 1,
                ),
              ),
              child: Text(
                chips[index],
                style: GoogleFonts.beVietnamPro(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuessInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _guessController,
                onSubmitted: (_) => _sendGuess(),
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Digite seu palpite...',
                  hintStyle: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    color: AppColors.outline,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
            GestureDetector(
              onTap: _sendGuess,
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, 'INICIO', 0),
              _navItem(Icons.sports_esports_rounded, 'JOGAR ONLINE', 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          _confirmExit();
          return;
        }
        setState(() => _bottomNavIndex = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.outline,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.5,
              color: isSelected ? AppColors.primary : AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat message model (local) ────────────────────────────────────────────────

class _ChatMessage {
  final String sender;
  final String text;
  final bool isCorrect;

  _ChatMessage({
    required this.sender,
    required this.text,
    required this.isCorrect,
  });
}
