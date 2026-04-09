import 'dart:ui';

import 'player.dart';

class Team {
  final String id;
  final String name;
  final Color color;
  final List<Player> players;
  int score;
  int roundsWon;

  Team({
    required this.id,
    required this.name,
    required this.color,
    List<Player>? players,
    this.score = 0,
    this.roundsWon = 0,
  }) : players = players ?? [];

  void addPoints(int points) {
    score += points;
  }

  void addPlayer(Player p) {
    players.add(p);
  }
}
