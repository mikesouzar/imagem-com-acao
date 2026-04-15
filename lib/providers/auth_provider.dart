import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/player.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Player? _currentPlayer;
  bool _isLoading = false;
  String? _errorMessage;

  Player? get currentPlayer => _currentPlayer;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentPlayer != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _currentPlayer = Player(
          id: user.uid,
          name: user.displayName ?? user.email?.split('@').first ?? 'Jogador',
          score: 0,
          totalWins: 0,
          level: 1,
        );
      } else {
        _currentPlayer = null;
      }
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      await credential.user?.sendEmailVerification();
      _currentPlayer = Player(
        id: credential.user!.uid,
        name: name,
        score: 0,
        totalWins: 0,
        level: 1,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Erro ao entrar com Google.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    if (_currentPlayer != null) {
      _currentPlayer = Player(
        id: _currentPlayer!.id,
        name: name,
        score: _currentPlayer!.score,
        totalWins: _currentPlayer!.totalWins,
        level: _currentPlayer!.level,
      );
      notifyListeners();
    }
  }

  void loginAsGuest() {
    _currentPlayer = Player(id: 'guest', name: 'Convidado');
    _errorMessage = null;
    notifyListeners();
  }

  void loginAsGuestWithName(String name) {
    _currentPlayer = Player(id: 'guest_social', name: name);
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentPlayer = null;
    _errorMessage = null;
    notifyListeners();
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'email-already-in-use':
        return 'E-mail já cadastrado.';
      case 'weak-password':
        return 'Senha muito fraca. Use ao menos 6 caracteres.';
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      default:
        return 'Erro ao autenticar. Tente novamente.';
    }
  }
}
