class Player {
  final String id;
  final String name;
  final String? avatarUrl;
  int score;
  int totalWins;
  int level;
  int coins;

  Player({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.score = 0,
    this.totalWins = 0,
    this.level = 1,
    this.coins = 1250,
  });
}
