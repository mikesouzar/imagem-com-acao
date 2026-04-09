import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// A single stroke on the canvas.
class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool isEraser;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.isEraser = false,
  });
}

class DrawingCanvas extends StatefulWidget {
  final Color backgroundColor;
  final ValueChanged<List<DrawingStroke>>? onStrokesChanged;

  const DrawingCanvas({
    super.key,
    this.backgroundColor = Colors.white,
    this.onStrokesChanged,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final List<DrawingStroke> _strokes = [];
  DrawingStroke? _currentStroke;

  Color _selectedColor = Colors.black;
  double _brushSize = 4.0;
  bool _isEraser = false;
  _ToolbarTab _activeTab = _ToolbarTab.draw;

  static const List<Color> _palette = [
    Colors.black,
    Color(0xFFE53935), // red
    Color(0xFF1E88E5), // blue
    Color(0xFF43A047), // green
    Color(0xFFFDD835), // yellow
    Color(0xFFFB8C00), // orange
    Color(0xFF8E24AA), // purple
    Color(0xFFEC407A), // pink
    Color(0xFF00ACC1), // cyan
    Color(0xFF6D4C41), // brown
  ];

  void _onPanStart(DragStartDetails details) {
    final point = details.localPosition;
    _currentStroke = DrawingStroke(
      points: [point],
      color: _isEraser ? widget.backgroundColor : _selectedColor,
      strokeWidth: _isEraser ? _brushSize * 3 : _brushSize,
      isEraser: _isEraser,
    );
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentStroke == null) return;
    _currentStroke!.points.add(details.localPosition);
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke != null) {
      _strokes.add(_currentStroke!);
      _currentStroke = null;
      widget.onStrokesChanged?.call(List.unmodifiable(_strokes));
      setState(() {});
    }
  }

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() => _strokes.removeLast());
      widget.onStrokesChanged?.call(List.unmodifiable(_strokes));
    }
  }

  void _clear() {
    if (_strokes.isNotEmpty) {
      setState(() => _strokes.clear());
      widget.onStrokesChanged?.call(List.unmodifiable(_strokes));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Canvas area
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: CustomPaint(
                  painter: _CanvasPainter(
                    strokes: _strokes,
                    currentStroke: _currentStroke,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Toolbar
        _buildToolbar(),
        // Active panel
        _buildActivePanel(),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ToolbarButton(
            icon: Icons.edit,
            label: 'Desenhar',
            isActive: _activeTab == _ToolbarTab.draw && !_isEraser,
            onTap: () => setState(() {
              _activeTab = _ToolbarTab.draw;
              _isEraser = false;
            }),
          ),
          _ToolbarButton(
            icon: Icons.palette_outlined,
            label: 'Cores',
            isActive: _activeTab == _ToolbarTab.colors,
            onTap: () => setState(() {
              _activeTab = _ToolbarTab.colors;
              _isEraser = false;
            }),
          ),
          _ToolbarButton(
            icon: Icons.brush,
            label: 'Pincel',
            isActive: _activeTab == _ToolbarTab.brush,
            onTap: () => setState(() {
              _activeTab = _ToolbarTab.brush;
            }),
          ),
          _ToolbarButton(
            icon: Icons.auto_fix_normal,
            label: 'Apagar',
            isActive: _isEraser,
            onTap: () => setState(() {
              _isEraser = !_isEraser;
              _activeTab = _ToolbarTab.draw;
            }),
          ),
          _ToolbarButton(
            icon: Icons.undo,
            label: 'Desfazer',
            isActive: false,
            onTap: _undo,
          ),
          _ToolbarButton(
            icon: Icons.delete_outline,
            label: 'Limpar',
            isActive: false,
            onTap: _clear,
          ),
        ],
      ),
    );
  }

  Widget _buildActivePanel() {
    switch (_activeTab) {
      case _ToolbarTab.colors:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: _buildColorPalette(),
        );
      case _ToolbarTab.brush:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: _buildBrushSlider(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildColorPalette() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: _palette.map((color) {
          final isSelected = _selectedColor == color && !_isEraser;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedColor = color;
              _isEraser = false;
              _activeTab = _ToolbarTab.draw;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 3)
                    : Border.all(
                        color: AppColors.outlineVariant,
                        width: 1.5,
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBrushSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Preview dot
          Container(
            width: _brushSize.clamp(4, 24),
            height: _brushSize.clamp(4, 24),
            decoration: BoxDecoration(
              color: _isEraser ? AppColors.outline : _selectedColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.surfaceContainerHigh,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.1),
                trackHeight: 4,
              ),
              child: Slider(
                value: _brushSize,
                min: 1,
                max: 24,
                onChanged: (v) => setState(() => _brushSize = v),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_brushSize.round()}',
            style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Toolbar tab enum ────────────────────────────────────────────────────────

enum _ToolbarTab { draw, colors, brush }

// ─── Toolbar button ──────────────────────────────────────────────────────────

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.primary : AppColors.outline,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.beVietnamPro(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Canvas painter ──────────────────────────────────────────────────────────

class _CanvasPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;

  _CanvasPainter({required this.strokes, this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    final allStrokes = [...strokes];
    if (currentStroke != null) allStrokes.add(currentStroke!);
    for (final stroke in allStrokes) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;

      if (stroke.isEraser) {
        paint.blendMode = BlendMode.clear;
      }

      if (stroke.points.length == 1) {
        // Single dot
        final dotPaint = Paint()
          ..color = stroke.color
          ..style = PaintingStyle.fill;
        if (stroke.isEraser) {
          dotPaint.blendMode = BlendMode.clear;
        }
        canvas.drawCircle(
          stroke.points.first,
          stroke.strokeWidth / 2,
          dotPaint,
        );
      } else {
        final path = Path();
        path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (var i = 1; i < stroke.points.length; i++) {
          // Smooth with quadratic bezier using midpoints
          if (i < stroke.points.length - 1) {
            final mid = Offset(
              (stroke.points[i].dx + stroke.points[i + 1].dx) / 2,
              (stroke.points[i].dy + stroke.points[i + 1].dy) / 2,
            );
            path.quadraticBezierTo(
              stroke.points[i].dx,
              stroke.points[i].dy,
              mid.dx,
              mid.dy,
            );
          } else {
            path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
          }
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) => true;
}
