enum GameMode { desenho, mimica, descricao, misto }

enum Difficulty { facil, medio, dificil }

enum GameStyle { classic, quick }
// classic = board game with tabuleiro, quick = current quick-play mode

class GameConfig {
  int numberOfTeams; // 2-4
  GameMode mode;
  Difficulty difficulty;
  int timePerRound; // seconds: 30, 60, 90
  int totalRounds;
  bool isOnline;
  GameStyle style;

  GameConfig({
    this.numberOfTeams = 2,
    this.mode = GameMode.desenho,
    this.difficulty = Difficulty.medio,
    this.timePerRound = 60,
    this.totalRounds = 10,
    this.isOnline = false,
    this.style = GameStyle.quick,
  });

  String get modeLabel => switch (mode) {
        GameMode.desenho => 'Desenho',
        GameMode.mimica => 'Mímica',
        GameMode.descricao => 'Descrição',
        GameMode.misto => 'Misto',
      };

  String get difficultyLabel => switch (difficulty) {
        Difficulty.facil => 'Fácil',
        Difficulty.medio => 'Médio',
        Difficulty.dificil => 'Difícil',
      };

  String get estimatedTime {
    final mins = (totalRounds * timePerRound / 60).ceil();
    return '~$mins Minutos';
  }
}
