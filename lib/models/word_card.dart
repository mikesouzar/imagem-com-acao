import 'game_config.dart';

class WordCard {
  final String word;
  final String category; // Objeto, Animal, Profissão, Ação, Lugar, etc.
  final Difficulty difficulty;
  final String? hint;

  const WordCard({
    required this.word,
    required this.category,
    required this.difficulty,
    this.hint,
  });
}
