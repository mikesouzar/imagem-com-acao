import 'package:flutter/material.dart';
import '../models/player.dart';

class AuthProvider extends ChangeNotifier {
  Player? _currentPlayer;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;

  Player? get currentPlayer => _currentPlayer;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;

  /// Simulate login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _currentPlayer = Player(id: 'user_1', name: 'Jogador', score: 0, totalWins: 12, level: 15);
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Simulate registration
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _currentPlayer = Player(id: 'user_1', name: name, score: 0, totalWins: 0, level: 1);
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Guest mode (skip login)
  void loginAsGuest() {
    _currentPlayer = Player(id: 'guest', name: 'Convidado');
    _isLoggedIn = true;
    _errorMessage = null;
    notifyListeners();
  }

  /// Guest mode with a custom name (used for social login simulation)
  void loginAsGuestWithName(String name) {
    _currentPlayer = Player(id: 'guest_social', name: name);
    _isLoggedIn = true;
    _errorMessage = null;
    notifyListeners();
  }

  void logout() {
    _currentPlayer = null;
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
  }
}
