import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../models/game_config.dart';
import '../models/team.dart';
import '../widgets/board_widget.dart';
import '../widgets/timer_widget.dart';
import '../widgets/gradient_button.dart';

class BoardGameScreen extends StatefulWidget {
  const BoardGameScreen({super.key});

  @override
  State<BoardGameScreen> createState() => _BoardGameScreenState();
}

class _BoardGameScreenState extends State<BoardGameScreen>
    with TickerProviderStateMixin {
  // Dice roll state
  bool _diceRolled = false;
  bool _isRollingAnimation = false;
  bool _isTransitioning = false;
  bool _showWordCard = false;
  bool _wordRevealed = false; // tela inicial antes do timer
  bool _wordVisible = false; // toggle revelar/ocultar durante o jogo
  bool _waitingForCategoryChoice = false;
  int? _numericResult;
  BoardCategory? _categoryResult;
  int? _todosJogamWinnerTeamIndex; // qual time acertou no "Todos Jogam"

  // Dice animation state
  int _animatingNumeric = 1;
  BoardCategory _animatingCategory = BoardCategory.pessoa;
  Timer? _cycleTimer;

  // Animation controllers for dice
  late final AnimationController _rollController;
  late final AnimationController _bounceController;
  late final Animation<double> _rotationAnim;
  late final Animation<double> _bounceAnim;

  final _random = Random();

  IconData _modeIcon(GameMode mode) => switch (mode) {
        GameMode.desenho => Icons.brush_rounded,
        GameMode.mimica => Icons.accessibility_new_rounded,
        GameMode.descricao => Icons.chat_bubble_rounded,
        GameMode.misto => Icons.shuffle_rounded,
      };

  String _modeLabel(GameMode mode) => switch (mode) {
        GameMode.desenho => 'DESENHO',
        GameMode.mimica => 'MIMICA',
        GameMode.descricao => 'DESCRICAO',
        GameMode.misto => 'MISTO',
      };

  static const Map<BoardCategory, Color> _categoryColors = {
    BoardCategory.pessoa: Color(0xFF1565C0),
    BoardCategory.objeto: Color(0xFF2E7D32),
    BoardCategory.acao: Color(0xFFC62828),
    BoardCategory.dificil: Color(0xFF6A1B9A),
    BoardCategory.lazer: Color(0xFFF9A825),
    BoardCategory.mix: Color(0xFFE65100),
  };

  static const Map<BoardCategory, String> _categoryNames = {
    BoardCategory.pessoa: 'Pessoa',
    BoardCategory.objeto: 'Objeto',
    BoardCategory.acao: 'Acao',
    BoardCategory.dificil: 'Dificil',
    BoardCategory.lazer: 'Lazer',
    BoardCategory.mix: 'Mix',
  };

  static const Map<BoardCategory, String> _categoryLetters = {
    BoardCategory.pessoa: 'P',
    BoardCategory.objeto: 'O',
    BoardCategory.acao: 'A',
    BoardCategory.dificil: 'D',
    BoardCategory.lazer: 'L',
    BoardCategory.mix: 'M',
  };

  @override
  void initState() {
    super.initState();

    _rollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rotationAnim = Tween<double>(begin: 0, end: 4 * pi).animate(
      CurvedAnimation(parent: _rollController, curve: Curves.easeOutCubic),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.18)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.18, end: 0.92)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.92, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _rollController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  /// Roll both dice simultaneously with animation.
  Future<void> _rollBothDice(GameProvider gp) async {
    if (_diceRolled || _isRollingAnimation) return;

    // Generate final results
    final numericResult = _random.nextInt(6) + 1;
    final categories = BoardCategory.values;
    final categoryResult = categories[_random.nextInt(categories.length)];

    setState(() {
      _isRollingAnimation = true;
      _numericResult = null;
      _categoryResult = null;
    });

    // Start rotation animation
    _rollController.forward(from: 0);

    // Cycle through random values every 60ms
    _cycleTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      if (!mounted) return;
      setState(() {
        _animatingNumeric = _random.nextInt(6) + 1;
        _animatingCategory = categories[_random.nextInt(categories.length)];
      });
    });

    // Wait for cycling phase
    await Future.delayed(const Duration(milliseconds: 800));
    _cycleTimer?.cancel();

    if (!mounted) return;

    // Set final values
    setState(() {
      _animatingNumeric = numericResult;
      _animatingCategory = categoryResult;
      _numericResult = numericResult;
      _categoryResult = categoryResult;
    });

    // Bounce / land effect
    await _bounceController.forward(from: 0);

    if (!mounted) return;

    setState(() {
      _isRollingAnimation = false;
      _diceRolled = true;
      _isTransitioning = true;
    });

    // Show transition with results for 1.5s, then proceed
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    gp.rollBothDice(categoryResult, numericResult);

    // Check if the space is "escolhe categoria" - need player to pick
    final space = gp.gameState?.currentBoardSpace;
    if (space?.type == SpaceType.escolheCategoria) {
      setState(() {
        _isTransitioning = false;
        _waitingForCategoryChoice = true;
      });
    } else {
      setState(() {
        _isTransitioning = false;
        _showWordCard = true;
        _wordRevealed = false; // mostrar botão "Revelar Palavra" primeiro
      });
      // NÃO inicia timer aqui - espera o jogador revelar a palavra
    }
  }

  void _handleCategoryChoice(GameProvider gp, BoardCategory category) {
    gp.chooseCategory(category);
    setState(() {
      _waitingForCategoryChoice = false;
      _categoryResult = category;
      _showWordCard = true;
      _wordRevealed = false; // mostrar botão "Revelar Palavra" primeiro
    });
    // NÃO inicia timer aqui
  }

  void _revealWord(GameProvider gp) {
    setState(() => _wordRevealed = true);
    gp.startTimer();
  }

  void _handleCorrect(GameProvider gp) {
    gp.markCorrectBoard();
    setState(() => _showWordCard = false);
  }

  void _handleWrong(GameProvider gp) {
    gp.markWrongBoard();
    setState(() => _showWordCard = false);
  }

  /// Correct answer: same team rolls again (bonus turn).
  /// Next team's turn (both correct and wrong go to next team).
  void _handleNextTeam(GameProvider gp) {
    gp.nextBoardTurn();
    _resetLocalState();
  }

  void _handleCorrectTodosJogam(GameProvider gp, int teamIndex) {
    _todosJogamWinnerTeamIndex = teamIndex;
    // Dar os pontos para o time que acertou
    final state = gp.gameState!;
    state.teams[teamIndex].addPoints(state.difficultyPoints);
    gp.markCorrectBoard();
    setState(() => _showWordCard = false);
  }

  void _resetLocalState() {
    setState(() {
      _diceRolled = false;
      _isRollingAnimation = false;
      _todosJogamWinnerTeamIndex = null;
      _isTransitioning = false;
      _showWordCard = false;
      _wordRevealed = false;
      _wordVisible = false;
      _waitingForCategoryChoice = false;
      _numericResult = null;
      _categoryResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gp, _) {
        final state = gp.gameState;
        if (state == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final currentPos = state.teamPositions[state.currentTeam.id] ?? 0;
        final isPlaying = state.phase == RoundPhase.playing || state.phase == RoundPhase.guessing;
        final isResults = state.phase == RoundPhase.results;
        final isPreparing = state.phase == RoundPhase.preparing;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: Text(
              'Imagem & Acao',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.primary,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () {
                gp.endGame();
                Navigator.of(context).pop();
              },
            ),
            actions: [
              if (isPlaying)
                IconButton(
                  icon: Icon(
                    state.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => state.isPaused ? gp.resumeGame() : gp.pauseGame(),
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Board map
                      Positioned.fill(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(8),
                          child: BoardWidget(
                            spaces: state.boardSpaces,
                            teamPositions: state.teamPositions,
                            teams: state.teams,
                            highlightedSpace: currentPos,
                          ),
                        ),
                      ),

                      // -- Overlay: BOTH DICE (preparing, not yet rolled) --
                      if (isPreparing && !_diceRolled)
                        _buildDiceOverlay(state, gp),

                      // -- Overlay: Transition after dice roll --
                      if (_isTransitioning && _diceRolled)
                        _buildTransitionOverlay(state),

                      // -- Overlay: Category chooser (escolhe categoria spaces) --
                      if (_waitingForCategoryChoice)
                        _buildCategoryChooserOverlay(state, gp),

                      // -- Overlay: Word card (playing) --
                      if (isPlaying && _showWordCard && !_isTransitioning)
                        _buildWordCardOverlay(state, gp),

                      // -- Overlay: Results --
                      if (isResults)
                        _buildResultsOverlay(state, gp),

                      // -- Mini badges (after dice rolled, during play) --
                      if (_categoryResult != null && !isPreparing && !isResults)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _MiniCategoryBadge(category: _categoryResult!),
                        ),
                      if (_numericResult != null && !isPreparing && !isResults)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _MiniDiceResult(value: _numericResult!),
                        ),
                    ],
                  ),
                ),

                // Score strip
                _buildScoreStrip(state),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // DICE OVERLAY: Both dice side by side + "Rolar Dados!" button
  // ---------------------------------------------------------------------------

  Widget _buildDiceOverlay(GameState state, GameProvider gp) {
    final team = state.currentTeam;

    // Face data for the category die
    final catFace = _animatingCategory;
    final catColor = _categoryColors[catFace]!;
    final catLetter = _categoryLetters[catFace]!;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Team badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: team.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(48),
                    border: Border.all(color: team.color.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group_rounded, size: 16, color: team.color),
                      const SizedBox(width: 6),
                      Text(
                        'Vez do ${team.name}!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15, fontWeight: FontWeight.w800, color: team.color,
                        ),
                      ),
                    ],
                  ),
                ),

                if (state.isBonusTurn) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.tertiary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF9A825)),
                        const SizedBox(width: 4),
                        Text('Rodada bonus!',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Instruction
                Text(
                  'Toque nos dados para jogar!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.outline,
                  ),
                ),

                const SizedBox(height: 20),

                // Both dice side by side
                AnimatedBuilder(
                  animation: Listenable.merge([_rotationAnim, _bounceAnim]),
                  builder: (_, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateX(_isRollingAnimation ? _rotationAnim.value : 0)
                        // ignore: deprecated_member_use
                        ..scale(_bounceAnim.value),
                      child: child,
                    );
                  },
                  child: GestureDetector(
                    onTap: () => _rollBothDice(gp),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Category die
                        _CategoryDieFace(letter: catLetter, color: catColor, size: 80),
                        const SizedBox(width: 16),
                        // Numeric die
                        _NumericDieFace(value: _animatingNumeric, size: 80),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Labels under dice
                if (_diceRolled && _categoryResult != null && _numericResult != null) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _categoryNames[_categoryResult!]!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: _categoryColors[_categoryResult!],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        '$_numericResult casas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Roll button
                if (!_isRollingAnimation && !_diceRolled)
                  GradientButton(
                    text: 'Rolar Dados!',
                    icon: Icons.casino_rounded,
                    onPressed: () => _rollBothDice(gp),
                  ),

                if (_isRollingAnimation)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Rolando...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.outline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TRANSITION OVERLAY: After dice roll, before word card
  // ---------------------------------------------------------------------------

  Widget _buildTransitionOverlay(GameState state) {
    final category = _categoryResult;
    final numeric = _numericResult;
    if (category == null || numeric == null) return const SizedBox.shrink();

    final catColor = _categoryColors[category]!;
    final catName = _categoryNames[category]!;
    final catLetter = _categoryLetters[category]!;
    final team = state.currentTeam;

    // Determine space type after advance
    final space = state.currentBoardSpace;
    final isTodosJogam = space?.type == SpaceType.todosJogam;
    final isEscolhe = space?.type == SpaceType.escolheCategoria;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Advance info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text('$numeric',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text('Avancou $numeric casas!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Space type indicator
                if (isTodosJogam) ...[
                  // Show "TODOS JOGAM!" banner
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE65100),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE65100).withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.groups_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF6D00), Color(0xFFFF9100)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('TODOS JOGAM!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Still show the category from the die
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(48),
                      border: Border.all(color: catColor.withValues(alpha: 0.5)),
                    ),
                    child: Text('Categoria: ${catName.toUpperCase()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w800, color: catColor, letterSpacing: 1,
                      ),
                    ),
                  ),
                ] else if (isEscolhe) ...[
                  // Show "Escolha a categoria!" prompt
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6A1B9A),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6A1B9A).withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.touch_app_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('ESCOLHA A CATEGORIA!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1,
                      ),
                    ),
                  ),
                ] else ...[
                  // Normal space: show category from die
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: catColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: catColor.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(catLetter,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Categoria: ${catName.toUpperCase()}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.w800, color: catColor, letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: team.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: team.color.withValues(alpha: 0.4)),
                    ),
                    child: Text('${team.name} joga!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w700, color: team.color,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text('Preparando...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CATEGORY CHOOSER OVERLAY (for "Escolhe a Categoria" spaces)
  // ---------------------------------------------------------------------------

  Widget _buildCategoryChooserOverlay(GameState state, GameProvider gp) {
    final team = state.currentTeam;
    final choosableCategories = [
      BoardCategory.pessoa,
      BoardCategory.objeto,
      BoardCategory.acao,
      BoardCategory.dificil,
      BoardCategory.lazer,
      BoardCategory.mix,
    ];

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Purple icon
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A1B9A).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.touch_app_rounded, color: Color(0xFF6A1B9A), size: 28),
                ),
                const SizedBox(height: 12),

                Text('Escolha a Categoria!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF6A1B9A),
                  ),
                ),
                const SizedBox(height: 4),
                Text('${team.name} escolhe',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w600, color: team.color,
                  ),
                ),
                const SizedBox(height: 20),

                // Category buttons in a grid (2 columns)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: choosableCategories.map((cat) {
                    final color = _categoryColors[cat]!;
                    final letter = _categoryLetters[cat]!;
                    final name = _categoryNames[cat]!;
                    return GestureDetector(
                      onTap: () => _handleCategoryChoice(gp, cat),
                      child: Container(
                        width: 90,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2)),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(letter,
                                style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(name,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WORD CARD OVERLAY (playing phase)
  // ---------------------------------------------------------------------------

  Widget _buildWordCardOverlay(GameState state, GameProvider gp) {
    final word = state.currentWord?.word ?? '---';
    final hint = state.currentWord?.hint;
    final isTodosJogam = state.isTodosJogam;
    final category = _categoryResult;
    final team = state.currentTeam;

    final catColor = category != null ? _categoryColors[category]! : AppColors.primary;
    final catName = category != null ? _categoryNames[category]! : '';

    // Se a palavra ainda não foi revelada, mostrar botão "Revelar Palavra"
    if (!_wordRevealed) {
      return _buildRevealWordOverlay(state, gp, catColor, catName, category, isTodosJogam, team);
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category badge
                  if (category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(48),
                        border: Border.all(color: catColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        catName.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: catColor,
                        ),
                      ),
                    ),

                  // "Todos Jogam" or team badge
                  if (isTodosJogam) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFF6D00), Color(0xFFFF9100)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('TODOS OS TIMES PODEM ADIVINHAR!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: team.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: team.color.withValues(alpha: 0.4)),
                      ),
                      child: Text('${team.name} está jogando',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.w700, color: team.color,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Mode
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_modeIcon(state.config.mode), size: 14, color: AppColors.outline),
                      const SizedBox(width: 4),
                      Text(_modeLabel(state.config.mode),
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: AppColors.outline),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Timer
                  TimerWidget(
                    totalSeconds: state.config.timePerRound,
                    remainingSeconds: state.timeRemaining,
                    size: 100,
                  ),

                  const SizedBox(height: 14),

                  // Word - com toggle revelar/ocultar
                  Text('PALAVRA SECRETA',
                    style: GoogleFonts.beVietnamPro(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2, color: AppColors.outline),
                  ),
                  const SizedBox(height: 6),

                  // Botão revelar/ocultar + palavra
                  GestureDetector(
                    onTap: () => setState(() => _wordVisible = !_wordVisible),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _wordVisible
                            ? AppColors.primary.withValues(alpha: 0.06)
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _wordVisible
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          if (_wordVisible) ...[
                            Text(word,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1.2),
                            ),
                            if (hint != null && hint.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Dica: $hint',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.onSurface.withValues(alpha: 0.5)),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.visibility_off_rounded, size: 14, color: AppColors.outline),
                                const SizedBox(width: 4),
                                Text('Toque para ocultar',
                                  style: GoogleFonts.beVietnamPro(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.outline),
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 8),
                            Icon(Icons.visibility_rounded, size: 32, color: AppColors.primary),
                            const SizedBox(height: 8),
                            Text('Toque para revelar a palavra',
                              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                            const SizedBox(height: 4),
                            Text('Apenas o desenhista deve ver!',
                              style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.onSurface.withValues(alpha: 0.4)),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Buttons - diferente para "Todos Jogam" vs "Um Time"
                  if (isTodosJogam) ...[
                    // No "Todos Jogam", mostrar qual time acertou
                    Text('Qual time acertou?',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.outline),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        for (int i = 0; i < state.teams.length; i++)
                          GestureDetector(
                            onTap: () => _handleCorrectTodosJogam(gp, i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: state.teams[i].color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: state.teams[i].color, width: 2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 16, color: state.teams[i].color),
                                  const SizedBox(width: 6),
                                  Text(state.teams[i].name,
                                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: state.teams[i].color),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GradientButton(
                      text: 'Ninguém acertou',
                      icon: Icons.close_rounded,
                      gradientColors: const [Color(0xFFC62828), Color(0xFFEF5350)],
                      onPressed: () => _handleWrong(gp),
                    ),
                  ] else ...[
                    // Modo normal: só o time da vez
                    GradientButton(
                      text: 'Acertou!',
                      icon: Icons.check_circle_rounded,
                      gradientColors: const [Color(0xFF43A047), Color(0xFF66BB6A)],
                      onPressed: () => _handleCorrect(gp),
                    ),
                    const SizedBox(height: 8),
                    GradientButton(
                      text: 'Errou / Pular',
                      icon: Icons.close_rounded,
                      gradientColors: const [Color(0xFFC62828), Color(0xFFEF5350)],
                      onPressed: () => _handleWrong(gp),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // REVEAL WORD OVERLAY - jogador vê a palavra antes de começar o timer
  // ---------------------------------------------------------------------------

  Widget _buildRevealWordOverlay(GameState state, GameProvider gp, Color catColor, String catName, BoardCategory? category, bool isTodosJogam, Team team) {
    final word = state.currentWord?.word ?? '---';
    final hint = state.currentWord?.hint;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone de esconder celular
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.visibility_rounded, size: 30, color: AppColors.primary),
                ),
                const SizedBox(height: 12),

                // Categoria
                if (category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(48),
                      border: Border.all(color: catColor.withValues(alpha: 0.5)),
                    ),
                    child: Text(catName.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: catColor),
                    ),
                  ),
                const SizedBox(height: 8),

                if (isTodosJogam)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF6D00), Color(0xFFFF9100)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('TODOS JOGAM!',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  )
                else
                  Text('${team.name} desenha/mima',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: team.color),
                  ),

                const SizedBox(height: 16),

                // Instrução
                Text('Esconda o celular dos outros jogadores!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 6),
                Text('Só o desenhista/ator pode ver a palavra.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.onSurface.withValues(alpha: 0.4)),
                ),

                const SizedBox(height: 20),

                // Palavra - toque para revelar/ocultar
                GestureDetector(
                  onTap: () => setState(() => _wordVisible = !_wordVisible),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _wordVisible
                          ? AppColors.primary.withValues(alpha: 0.06)
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _wordVisible
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text('PALAVRA SECRETA', style: GoogleFonts.beVietnamPro(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2, color: AppColors.outline)),
                        const SizedBox(height: 8),
                        if (_wordVisible) ...[
                          Text(word,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1.2),
                          ),
                          if (hint != null && hint.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('Dica: $hint',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.onSurface.withValues(alpha: 0.5)),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.visibility_off_rounded, size: 14, color: AppColors.outline),
                              const SizedBox(width: 4),
                              Text('Toque para ocultar', style: GoogleFonts.beVietnamPro(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.outline)),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          Icon(Icons.visibility_rounded, size: 32, color: AppColors.primary),
                          const SizedBox(height: 8),
                          Text('Toque para revelar a palavra',
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                          const SizedBox(height: 4),
                          Text('Apenas o desenhista deve ver!',
                            style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.onSurface.withValues(alpha: 0.4)),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botão iniciar timer
                GradientButton(
                  text: 'Estou pronto! Iniciar Timer',
                  icon: Icons.timer_rounded,
                  isLarge: true,
                  onPressed: () => _revealWord(gp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RESULTS OVERLAY
  // ---------------------------------------------------------------------------

  Widget _buildResultsOverlay(GameState state, GameProvider gp) {
    final scored = gp.lastRoundScored;
    final team = state.currentTeam;
    final points = state.difficultyPoints;
    final hasWon = state.hasTeamReachedEnd && scored;

    if (hasWon) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/winner');
      });
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Result icon
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: scored ? AppColors.success.withValues(alpha: 0.15) : AppColors.error.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    scored ? Icons.celebration_rounded : Icons.timer_off_rounded,
                    size: 32, color: scored ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(height: 12),

                if (scored) ...[
                  // CORRECT: mostra quem acertou
                  Builder(builder: (_) {
                    final winnerIdx = _todosJogamWinnerTeamIndex;
                    final winnerTeam = winnerIdx != null && winnerIdx < state.teams.length
                        ? state.teams[winnerIdx]
                        : team;
                    return Column(
                      children: [
                        Text('ACERTOU! +$points pts',
                          style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: winnerTeam.color),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(winnerTeam.name,
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: winnerTeam.color.withValues(alpha: 0.8)),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 12),

                  // Próximo time
                  Builder(builder: (_) {
                    final nextIdx = (state.currentTeamIndex + 1) % state.teams.length;
                    final next = state.teams[nextIdx];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: next.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: next.color.withValues(alpha: 0.4)),
                      ),
                      child: Text('Proximo: ${next.name}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: next.color),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  GradientButton(
                    text: 'Continuar',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => _handleNextTeam(gp),
                  ),
                ] else ...[
                  // WRONG / TIMEOUT: next team
                  Text(state.timeRemaining <= 0 ? 'Tempo Esgotado!' : 'Errou!',
                    style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Builder(builder: (_) {
                    final nextIdx = (state.currentTeamIndex + 1) % state.teams.length;
                    final next = state.teams[nextIdx];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: next.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: next.color.withValues(alpha: 0.4)),
                      ),
                      child: Text('Próximo: ${next.name}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: next.color),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  GradientButton(
                    text: 'Continuar',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => _handleNextTeam(gp),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SCORE STRIP
  // ---------------------------------------------------------------------------

  Widget _buildScoreStrip(GameState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        boxShadow: [
          BoxShadow(color: AppColors.onSurface.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: state.teams.map((team) {
          final pos = state.teamPositions[team.id] ?? 0;
          final isCurrent = team.id == state.currentTeam.id;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrent ? team.color.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isCurrent ? Border.all(color: team.color.withValues(alpha: 0.4), width: 1.5) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: team.color, shape: BoxShape.circle),
                ),
                const SizedBox(height: 2),
                Text(team.name.replaceFirst('Time ', ''),
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: team.color),
                ),
                Text('${team.score}pts - $pos/29',
                  style: GoogleFonts.beVietnamPro(fontSize: 8, fontWeight: FontWeight.w600, color: AppColors.onSurface.withValues(alpha: 0.5)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// =============================================================================
// PRIVATE HELPER WIDGETS
// =============================================================================

/// Category die face (colored square with letter)
class _CategoryDieFace extends StatelessWidget {
  final String letter;
  final Color color;
  final double size;

  const _CategoryDieFace({
    required this.letter,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: const Alignment(-0.8, -0.8),
          end: const Alignment(0.8, 0.8),
          colors: [
            color,
            Color.lerp(color, Colors.white, 0.2)!,
          ],
        ),
        border: Border.all(
          color: Color.lerp(color, Colors.black, 0.2)!.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 0,
            offset: Offset(0, size * 0.06),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: GoogleFonts.plusJakartaSans(
          fontSize: size * 0.5,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

/// Numeric die face (white square with pips)
class _NumericDieFace extends StatelessWidget {
  final int value;
  final double size;

  const _NumericDieFace({
    required this.value,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final pipSize = size * 0.17;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment(-0.8, -0.8),
          end: Alignment(0.8, 0.8),
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF4F2F8),
          ],
        ),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.12),
            blurRadius: 0,
            offset: Offset(0, size * 0.06),
          ),
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.08),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.16),
        child: _buildPips(pipSize),
      ),
    );
  }

  Widget _buildPips(double pipSize) {
    switch (value) {
      case 1:
        return _grid(pipSize, [
          [false, false, false],
          [false, true, false],
          [false, false, false],
        ]);
      case 2:
        return _grid(pipSize, [
          [false, false, true],
          [false, false, false],
          [true, false, false],
        ]);
      case 3:
        return _grid(pipSize, [
          [false, false, true],
          [false, true, false],
          [true, false, false],
        ]);
      case 4:
        return _grid(pipSize, [
          [true, false, true],
          [false, false, false],
          [true, false, true],
        ]);
      case 5:
        return _grid(pipSize, [
          [true, false, true],
          [false, true, false],
          [true, false, true],
        ]);
      case 6:
        return _grid(pipSize, [
          [true, false, true],
          [true, false, true],
          [true, false, true],
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _grid(double pipSize, List<List<bool>> rows) {
    const pipColor = Color(0xFF2B2D42);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: rows.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: row.map((show) {
            return show
                ? Container(
                    width: pipSize,
                    height: pipSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: pipColor,
                      boxShadow: [
                        BoxShadow(
                          color: pipColor.withValues(alpha: 0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  )
                : SizedBox(width: pipSize, height: pipSize);
          }).toList(),
        );
      }).toList(),
    );
  }
}

/// Mini category badge in the corner showing the rolled category
class _MiniCategoryBadge extends StatelessWidget {
  final BoardCategory category;
  const _MiniCategoryBadge({required this.category});

  static const Map<BoardCategory, Color> _colors = {
    BoardCategory.pessoa: Color(0xFF1565C0),
    BoardCategory.objeto: Color(0xFF2E7D32),
    BoardCategory.acao: Color(0xFFC62828),
    BoardCategory.dificil: Color(0xFF6A1B9A),
    BoardCategory.lazer: Color(0xFFF9A825),
    BoardCategory.mix: Color(0xFFE65100),
  };

  static const Map<BoardCategory, String> _letters = {
    BoardCategory.pessoa: 'P',
    BoardCategory.objeto: 'O',
    BoardCategory.acao: 'A',
    BoardCategory.dificil: 'D',
    BoardCategory.lazer: 'L',
    BoardCategory.mix: 'M',
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[category]!;
    final letter = _letters[category]!;
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(letter,
        style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
      ),
    );
  }
}

/// Mini numeric die result in the corner
class _MiniDiceResult extends StatelessWidget {
  final int value;
  const _MiniDiceResult({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 2)),
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Text('$value',
        style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
      ),
    );
  }
}
