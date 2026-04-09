import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../models/game_state.dart';
import '../models/team.dart';
// player.dart and word_card.dart used transitively via team.dart/game_state.dart
import '../data/word_bank.dart';

class GameProvider extends ChangeNotifier {
  GameConfig _config = GameConfig();
  GameState? _gameState;
  Timer? _timer;
  bool _isGameOver = false;
  bool _lastRoundScored = false;

  // Board game state
  BoardCategory? _currentBoardCategory;

  GameConfig get config => _config;
  GameState? get gameState => _gameState;
  bool get isGameActive => _gameState != null;
  BoardCategory? get currentBoardCategory => _currentBoardCategory;

  // Config methods
  void setNumberOfTeams(int n) { _config.numberOfTeams = n; notifyListeners(); }
  void setGameMode(GameMode mode) { _config.mode = mode; notifyListeners(); }
  void setDifficulty(Difficulty d) { _config.difficulty = d; notifyListeners(); }
  void setTimePerRound(int seconds) { _config.timePerRound = seconds; notifyListeners(); }
  void setOnline(bool v) { _config.isOnline = v; notifyListeners(); }

  // Default team colors
  static const List<Color> teamColors = [
    Color(0xFF0058BC), // Azul
    Color(0xFFB7004D), // Vermelho/Rosa
    Color(0xFF2E7D32), // Verde
    Color(0xFFFCBC05), // Amarelo
  ];

  static const List<String> teamNames = ['Time Azul', 'Time Vermelho', 'Time Verde', 'Time Amarelo'];

  // Start game
  void startGame() {
    final teams = List.generate(
      _config.numberOfTeams,
      (i) => Team(id: 'team_$i', name: teamNames[i], color: teamColors[i]),
    );

    _gameState = GameState(
      config: _config,
      teams: teams,
      timeRemaining: _config.timePerRound,
    );
    _drawNewWord();
    notifyListeners();
  }

  void _drawNewWord() {
    _gameState?.currentWord = WordBank.getRandomWord(difficulty: _config.difficulty);
    _gameState?.phase = RoundPhase.playing;
    _gameState?.timeRemaining = _config.timePerRound;
  }

  // Timer
  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState == null || _gameState!.isPaused) return;

      if (_gameState!.timeRemaining > 0) {
        _gameState!.timeRemaining--;
        notifyListeners();
      } else {
        timer.cancel();
        _gameState!.phase = RoundPhase.results;
        _gameState!.isBonusTurn = false;
        _lastRoundScored = false;
        notifyListeners();
      }
    });
  }

  void pauseGame() { _gameState?.isPaused = true; notifyListeners(); }
  void resumeGame() { _gameState?.isPaused = false; notifyListeners(); }

  // Answer correct
  void markCorrect() {
    _gameState?.correctAnswer();
    _gameState?.phase = RoundPhase.results;
    _lastRoundScored = true;
    _timer?.cancel();
    notifyListeners();
  }

  // Skip word (-50 pts conceptually, or just move on)
  void skipWord() {
    _gameState?.phase = RoundPhase.results;
    _lastRoundScored = false;
    _timer?.cancel();
    notifyListeners();
  }

  // Next turn
  void nextTurn() {
    if (_gameState == null) return;

    // Check game-over BEFORE wrapping the team index
    if (_gameState!.currentTeamIndex == _gameState!.teams.length - 1 &&
        _gameState!.isLastRound) {
      _isGameOver = true;
      notifyListeners();
      return;
    }

    _gameState!.nextTeam();
    if (_gameState!.currentTeamIndex == 0) {
      _gameState!.nextRound();
    }
    _drawNewWord();
    notifyListeners();
  }

  // Check winner
  Team? getWinner() {
    if (_gameState == null) return null;
    return _gameState!.teams.reduce((a, b) => a.score > b.score ? a : b);
  }

  bool get isGameOver => _isGameOver;
  bool get lastRoundScored => _lastRoundScored;

  // -------------------------------------------------------------------------
  // Board game (classic mode) methods
  // -------------------------------------------------------------------------

  // Start board game
  void startBoardGame() {
    final teams = List.generate(
      _config.numberOfTeams,
      (i) => Team(id: 'team_$i', name: teamNames[i], color: teamColors[i]),
    );

    _gameState = GameState(
      config: _config,
      teams: teams,
      timeRemaining: _config.timePerRound,
    );
    _gameState!.initBoard();
    notifyListeners();
  }

  // Roll dice (1-6) — legacy method kept for backwards compatibility
  int rollDice() {
    final roll = (Random().nextInt(6)) + 1;
    _gameState?.lastDiceRoll = roll;
    _gameState?.advanceTeam(roll);
    // Draw word based on board category
    _drawWordForCategory();
    _gameState?.phase = RoundPhase.playing;
    _gameState?.timeRemaining = _config.timePerRound;
    notifyListeners();
    return roll;
  }

  void _drawWordForCategory() {
    // Legacy method - just draw a random word since board spaces no longer have categories
    _gameState?.currentWord = WordBank.getRandomWord();
  }

  // ── Board game flow: both dice roll together ────────────────────────────

  /// Roll both dice together: advance on board + set category.
  /// Called after the dice animation settles in the UI.
  void rollBothDice(BoardCategory category, int numericValue) {
    // Advance on board
    _gameState?.lastDiceRoll = numericValue;
    _gameState?.advanceTeam(numericValue);

    final space = _gameState?.currentBoardSpace;

    if (space?.type == SpaceType.escolheCategoria) {
      // Don't set category yet - player will choose
      _currentBoardCategory = null;
      // Phase stays as preparing until player chooses
    } else {
      // Set category from die result
      _currentBoardCategory = category;
      // Draw word for this category
      _drawWordForBoardCategory(category);
      // Start playing
      _gameState?.phase = RoundPhase.playing;
      _gameState?.timeRemaining = _config.timePerRound;
    }

    // Check if team reached the end
    if (_gameState?.hasTeamReachedEnd ?? false) {
      _isGameOver = true;
    }

    notifyListeners();
  }

  /// Player chose a category (for "escolhe a categoria" spaces).
  void chooseCategory(BoardCategory category) {
    _currentBoardCategory = category;
    _drawWordForBoardCategory(category);
    _gameState?.phase = RoundPhase.playing;
    _gameState?.timeRemaining = _config.timePerRound;
    notifyListeners();
  }

  void _drawWordForBoardCategory(BoardCategory category) {
    final boardCat = switch (category) {
      BoardCategory.pessoa => 'P',
      BoardCategory.objeto => 'O',
      BoardCategory.acao => 'A',
      BoardCategory.dificil => 'D',
      BoardCategory.lazer => 'L',
      BoardCategory.mix => 'T',  // Mix = any category (mapped to T in word bank)
    };
    _gameState?.currentWord = WordBank.getRandomWordForBoardCategory(boardCat);
  }

  // Board: correct answer — score points, then next team
  void markCorrectBoard() {
    _gameState?.correctAnswer();
    _gameState?.isBonusTurn = false;
    _gameState?.phase = RoundPhase.results;
    _lastRoundScored = true;
    _timer?.cancel();

    if (_gameState?.hasTeamReachedEnd ?? false) {
      _isGameOver = true;
    }
    notifyListeners();
  }

  // Board: wrong answer, pass turn
  void markWrongBoard() {
    _gameState?.isBonusTurn = false;
    _gameState?.phase = RoundPhase.results;
    _lastRoundScored = false;
    _timer?.cancel();
    notifyListeners();
  }

  /// Next turn: move to next team (wrong answer / time up).
  void nextBoardTurn() {
    if (_gameState == null) return;
    _gameState!.nextTeam();
    _gameState!.phase = RoundPhase.preparing;
    _gameState!.timeRemaining = _config.timePerRound;
    _currentBoardCategory = null;
    _gameState!.isBonusTurn = false;
    notifyListeners();
  }

  // Reset
  void resetGame() {
    _timer?.cancel();
    _gameState = null;
    _config = GameConfig();
    _isGameOver = false;
    _lastRoundScored = false;
    _currentBoardCategory = null;
    notifyListeners();
  }

  void endGame() {
    _timer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
