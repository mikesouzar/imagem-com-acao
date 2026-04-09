import 'package:flutter/material.dart';

class OnlineRoom {
  final String id;
  final String name;
  final String mode;
  final int currentPlayers;
  final int maxPlayers;
  final String hostAvatar;

  const OnlineRoom({required this.id, required this.name, required this.mode, required this.currentPlayers, required this.maxPlayers, this.hostAvatar = ''});
}

class LobbyProvider extends ChangeNotifier {
  bool _isSearching = false;
  List<OnlineRoom> _rooms = [];
  OnlineRoom? _currentRoom;

  bool get isSearching => _isSearching;
  List<OnlineRoom> get rooms => _rooms;
  OnlineRoom? get currentRoom => _currentRoom;

  void loadRooms() {
    _rooms = [
      OnlineRoom(id: '1', name: 'Mestres do Silêncio', mode: 'Mímica & Desenho', currentPlayers: 4, maxPlayers: 8),
      OnlineRoom(id: '2', name: 'Festa dos Desenhos', mode: 'Desenho Rápido', currentPlayers: 6, maxPlayers: 8),
      OnlineRoom(id: '3', name: 'Clã da Caneta', mode: 'Desenho', currentPlayers: 3, maxPlayers: 6),
      OnlineRoom(id: '4', name: 'Show de Talentos', mode: 'Mímica Aleatório', currentPlayers: 2, maxPlayers: 4),
      OnlineRoom(id: '5', name: 'Traço Mágico', mode: 'Misto', currentPlayers: 5, maxPlayers: 8),
      OnlineRoom(id: '6', name: 'Gênios do Lápis', mode: 'Dicas Alternativas', currentPlayers: 4, maxPlayers: 6),
    ];
    notifyListeners();
  }

  void createRoom(String name, String mode) {
    final newId = (_rooms.length + 1).toString();
    _rooms.add(OnlineRoom(
      id: newId,
      name: name,
      mode: mode,
      currentPlayers: 1,
      maxPlayers: 8,
    ));
    notifyListeners();
  }

  Future<void> searchMatch() async {
    _isSearching = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 3));
    _isSearching = false;
    notifyListeners();
  }

  void cancelSearch() {
    _isSearching = false;
    notifyListeners();
  }

  void joinRoom(OnlineRoom room) {
    _currentRoom = room;
    notifyListeners();
  }

  void leaveRoom() {
    _currentRoom = null;
    notifyListeners();
  }
}
