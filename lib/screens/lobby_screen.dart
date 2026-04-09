import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/lobby_provider.dart';
import '../providers/game_provider.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Accent colors for room avatars
  static const List<Color> _roomAccentColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.tertiary,
    Color(0xFF2E7D32),
    Color(0xFF7C4DFF),
    Color(0xFFFF6D00),
  ];

  static const List<IconData> _roomIcons = [
    Icons.theater_comedy_rounded,
    Icons.brush_rounded,
    Icons.create_rounded,
    Icons.star_rounded,
    Icons.auto_awesome_rounded,
    Icons.lightbulb_rounded,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LobbyProvider>().loadRooms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Imagem & Ação',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Text(
              'Encontre sua diversão',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // ── Search Bar ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: GoogleFonts.beVietnamPro(
                  fontSize: 15,
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar salas...',
                  hintStyle: GoogleFonts.beVietnamPro(
                    fontSize: 15,
                    color: AppColors.outline,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.outline,
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Create Private Room Button ──────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  final roomNameController = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        'Criar Sala Privada',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      ),
                      content: TextField(
                        controller: roomNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da sala',
                          hintText: 'Ex: Minha Sala',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            final name = roomNameController.text.trim();
                            if (name.isNotEmpty) {
                              context.read<LobbyProvider>().createRoom(name, 'Misto');
                            }
                            Navigator.pop(ctx);
                          },
                          child: const Text('Criar'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Criar Sala Privada',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // ── Room List ───────────────────────────────────────
          Expanded(
            child: Consumer<LobbyProvider>(
              builder: (context, lobbyProvider, _) {
                final rooms = lobbyProvider.rooms.where((room) {
                  if (_searchQuery.isEmpty) return true;
                  return room.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      room.mode
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                }).toList();

                if (rooms.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhuma sala encontrada',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 16,
                        color: AppColors.outline,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  itemCount: rooms.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    final accentColor =
                        _roomAccentColors[index % _roomAccentColors.length];
                    final roomIcon =
                        _roomIcons[index % _roomIcons.length];

                    return _RoomCard(
                      room: room,
                      accentColor: accentColor,
                      icon: roomIcon,
                      onTap: () {
                        lobbyProvider.joinRoom(room);
                        context.read<GameProvider>().setOnline(true);
                        Navigator.of(context).pushNamed('/config');
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Room Card ──────────────────────────────────────────────────────────
class _RoomCard extends StatelessWidget {
  final OnlineRoom room;
  final Color accentColor;
  final IconData icon;
  final VoidCallback onTap;

  const _RoomCard({
    required this.room,
    required this.accentColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accentColor, size: 26),
            ),
            const SizedBox(width: 14),

            // Name & mode
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    room.mode,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 13,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),

            // Player count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${room.currentPlayers}/${room.maxPlayers}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
