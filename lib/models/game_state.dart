import 'package:flutter/material.dart';
import 'team.dart';
import 'game_config.dart';
import 'word_card.dart';

enum RoundPhase { preparing, playing, guessing, results }

enum BoardCategory { pessoa, objeto, acao, dificil, lazer, mix }

enum SpaceType { umTimeJoga, todosJogam, escolheCategoria }

class BoardSpace {
  final int index;
  final SpaceType type;

  const BoardSpace({required this.index, required this.type});

  String get typeLabel => switch (type) {
        SpaceType.umTimeJoga => 'Um Time',
        SpaceType.todosJogam => 'Todos Jogam!',
        SpaceType.escolheCategoria => 'Escolhe!',
      };

  IconData get typeIcon => switch (type) {
        SpaceType.umTimeJoga => Icons.person_rounded,
        SpaceType.todosJogam => Icons.groups_rounded,
        SpaceType.escolheCategoria => Icons.touch_app_rounded,
      };

  Color get typeColor => switch (type) {
        SpaceType.umTimeJoga => const Color(0xFF1565C0), // blue
        SpaceType.todosJogam => const Color(0xFFE65100), // orange
        SpaceType.escolheCategoria => const Color(0xFF6A1B9A), // purple
      };
}

class GameState {
  final GameConfig config;
  final List<Team> teams;
  int currentRound;
  int currentTeamIndex;
  WordCard? currentWord;
  RoundPhase phase;
  int timeRemaining;
  bool isPaused;
  List<String> chatMessages;

  // Board state
  List<BoardSpace> boardSpaces = [];
  Map<String, int> teamPositions = {}; // team.id -> position index
  int? lastDiceRoll;
  bool isBonusTurn = false; // true when team guessed correctly and rolls again

  GameState({
    required this.config,
    required this.teams,
    this.currentRound = 1,
    this.currentTeamIndex = 0,
    this.currentWord,
    this.phase = RoundPhase.preparing,
    this.timeRemaining = 60,
    this.isPaused = false,
  }) : chatMessages = [];

  Team get currentTeam => teams[currentTeamIndex];

  bool get isLastRound => currentRound >= config.totalRounds;

  void nextTeam() {
    currentTeamIndex = (currentTeamIndex + 1) % teams.length;
  }

  void nextRound() {
    currentRound++;
    currentTeamIndex = 0;
  }

  void correctAnswer() {
    currentTeam.addPoints(difficultyPoints);
  }

  int get difficultyPoints => switch (config.difficulty) {
        Difficulty.facil => 1,
        Difficulty.medio => 2,
        Difficulty.dificil => 3,
      };

  // Derived from board space type
  bool get isTodosJogam => currentBoardSpace?.type == SpaceType.todosJogam;
  bool get isEscolheCategoria => currentBoardSpace?.type == SpaceType.escolheCategoria;

  // Initialize board
  void initBoard() {
    // Tabuleiro real: 30 casas com tipos de rodada
    // A maioria é "Um Time Joga", com "Todos Jogam" a cada 6 casas
    // e "Escolhe a Categoria" em posições especiais
    boardSpaces = List.generate(30, (i) {
      if (i == 0) return BoardSpace(index: i, type: SpaceType.umTimeJoga);
      if (i == 29) return BoardSpace(index: i, type: SpaceType.todosJogam); // last space
      if (i % 6 == 0) return BoardSpace(index: i, type: SpaceType.todosJogam);
      if (i % 8 == 0 || i == 4 || i == 15 || i == 22) return BoardSpace(index: i, type: SpaceType.escolheCategoria);
      return BoardSpace(index: i, type: SpaceType.umTimeJoga);
    });
    // Posição inicial de todos os times
    for (final team in teams) {
      teamPositions[team.id] = 0;
    }
  }

  BoardSpace? get currentBoardSpace {
    final pos = teamPositions[currentTeam.id] ?? 0;
    if (pos >= boardSpaces.length) return boardSpaces.last;
    return boardSpaces[pos];
  }

  void advanceTeam(int spaces) {
    final teamId = currentTeam.id;
    final current = teamPositions[teamId] ?? 0;
    teamPositions[teamId] = (current + spaces).clamp(0, boardSpaces.length - 1);
  }

  bool get hasTeamReachedEnd {
    final pos = teamPositions[currentTeam.id] ?? 0;
    return pos >= boardSpaces.length - 1;
  }
}
