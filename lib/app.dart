import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/game_mode_screen.dart';
import 'screens/rules_screen.dart';
import 'screens/game_config_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/matchmaking_screen.dart';
import 'screens/game_round_screen.dart';
import 'screens/drawing_arena_screen.dart';
import 'screens/charades_screen.dart';
import 'screens/round_results_screen.dart';
import 'screens/winner_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/store_screen.dart';
import 'screens/board_game_screen.dart';
import 'screens/board_config_screen.dart';

class ImagemComAcaoApp extends StatelessWidget {
  const ImagemComAcaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Imagem com Ação',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/game-mode': (context) => const GameModeScreen(),
        '/rules': (context) => const RulesScreen(),
        '/config': (context) => const GameConfigScreen(),
        '/lobby': (context) => const LobbyScreen(),
        '/matchmaking': (context) => const MatchmakingScreen(),
        '/game-round': (context) => const GameRoundScreen(),
        '/drawing-arena': (context) => const DrawingArenaScreen(),
        '/charades': (context) => const CharadesScreen(),
        '/round-results': (context) => const RoundResultsScreen(),
        '/winner': (context) => const WinnerScreen(),
        '/ranking': (context) => const RankingScreen(),
        '/store': (context) => const StoreScreen(),
        '/board-game': (context) => const BoardGameScreen(),
        '/config-board': (context) => const BoardConfigScreen(),
      },
    );
  }
}
