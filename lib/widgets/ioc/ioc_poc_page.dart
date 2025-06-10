import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import 'coordinates_iframe_widget.dart';

class IocPocPage extends StatefulWidget {
  @override
  State<IocPocPage> createState() => _IocPocPageState();
}

class _IocPocPageState extends State<IocPocPage> {
  final GlobalKey _imageKey = GlobalKey();

  String _getRegionFromPosition(Offset position, Size imageSize) {
    final x = position.dx;
    final y = position.dy;

    // Top row (first half of height)
    if (y < imageSize.height / 2) {
      // Top row, first column (67.5% width) - Panorama Region
      if (x < imageSize.width * 0.675) {
        return 'Panorama';
      }
      // Top row, second column (32.5% width) - 3D
      else {
        return '3D';
      }
    }
    // Bottom row (second half of height) - 3 evenly distributed columns
    else {
      final columnWidth = imageSize.width / 3;
      if (x < columnWidth) {
        return 'Longitudinal';
      } else if (x < columnWidth * 2) {
        return 'Cross-sectional';
      } else {
        return 'Axial';
      }
    }
  }

  Offset _getRelativePosition(
      Offset globalPosition, Size imageSize, String region) {
    final x = globalPosition.dx;
    final y = globalPosition.dy;

    switch (region) {
      case 'Panorama':
        return Offset(
            x / (imageSize.width * 0.675), y / (imageSize.height * 0.5));
      case '3D':
        return Offset((x - imageSize.width * 0.675) / (imageSize.width * 0.325),
            y / (imageSize.height * 0.5));
      case 'Longitudinal':
        final columnWidth = imageSize.width / 3;
        return Offset(x / columnWidth,
            (y - imageSize.height * 0.5) / (imageSize.height * 0.5));
      case 'Cross-sectional':
        final columnWidth = imageSize.width / 3;
        return Offset((x - columnWidth) / columnWidth,
            (y - imageSize.height * 0.5) / (imageSize.height * 0.5));
      case 'Axial':
        final columnWidth = imageSize.width / 3;
        return Offset((x - columnWidth * 2) / columnWidth,
            (y - imageSize.height * 0.5) / (imageSize.height * 0.5));
      default:
        return Offset(0, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image viewer (increased height since we removed bottom bar)
              Container(
                key: _imageKey,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.95,
                  maxHeight: MediaQuery.of(context).size.height *
                      0.85, // Increased from 0.75
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MouseRegion(
                    onHover: (PointerHoverEvent event) {
                      final RenderBox? renderBox = _imageKey.currentContext
                          ?.findRenderObject() as RenderBox?;
                      if (renderBox != null) {
                        final localPosition =
                            renderBox.globalToLocal(event.position);
                        final imageSize = Size(
                          MediaQuery.of(context).size.width * 0.95,
                          MediaQuery.of(context).size.height * 0.85, // Updated
                        );
                        final region =
                            _getRegionFromPosition(localPosition, imageSize);
                        final relativePos = _getRelativePosition(
                            localPosition, imageSize, region);

                        // Send update to main.dart via ChangeNotifier
                        appState.updateMouseHover(region, relativePos);
                      }
                    },
                    onExit: (PointerExitEvent event) {
                      // Send mouse exit update to main.dart
                      appState.updateMouseExit();
                    },
                    child: GestureDetector(
                      onPanStart: (DragStartDetails details) {
                        final imageSize = Size(
                          MediaQuery.of(context).size.width * 0.95,
                          MediaQuery.of(context).size.height * 0.85, // Updated
                        );
                        final region = _getRegionFromPosition(
                            details.localPosition, imageSize);
                        final relativePos = _getRelativePosition(
                            details.localPosition, imageSize, region);

                        // Send drag start update to main.dart
                        appState.updateMouseDragStart(
                            region, details.localPosition, relativePos);
                      },
                      onPanUpdate: (DragUpdateDetails details) {
                        final imageSize = Size(
                          MediaQuery.of(context).size.width * 0.95,
                          MediaQuery.of(context).size.height * 0.85, // Updated
                        );
                        final region = _getRegionFromPosition(
                            details.localPosition, imageSize);
                        final relativePos = _getRelativePosition(
                            details.localPosition, imageSize, region);

                        // Send drag update to main.dart
                        appState.updateMouseDragUpdate(
                            region, details.localPosition, relativePos);
                      },
                      onPanEnd: (DragEndDetails details) {
                        // Send drag end update to main.dart
                        appState.updateMouseDragEnd();
                      },
                      child: Stack(
                        children: [
                          Image.asset(
                            'images/IoC_PoC_CBCT_Background.png',
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height: MediaQuery.of(context).size.height *
                                    0.85, // Updated
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    width: 2,
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: RegionGridPainter(),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 64,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Image not found',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.7),
                                            ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'IoC_PoC_CBCT_Background.png',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.5),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          // Overlay to show regions
                          Positioned.fill(
                            child: CustomPaint(
                              painter: RegionGridPainter(
                                highlightedRegion: appState.currentRegion,
                                dragStart: appState.dragStartPosition,
                                dragCurrent: appState.currentDragPosition,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom spanning iframe with coordinates
        CoordinatesIframeWidget(
          currentRegion: appState.currentRegion,
          relativePosition: appState.relativePosition,
          isDragging: appState.isDragging,
          dragStartPosition: appState.dragStartPosition,
          currentDragPosition: appState.currentDragPosition,
        ),
      ],
    );
  }
}

class RegionGridPainter extends CustomPainter {
  final String? highlightedRegion;
  final Offset? dragStart;
  final Offset? dragCurrent;

  RegionGridPainter({
    this.highlightedRegion,
    this.dragStart,
    this.dragCurrent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final highlightPaint = Paint()
      ..color = Colors.red.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final crosshairPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final crosshairCenterPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    // Draw grid lines
    // Vertical line at 67.5% (separating Panorama and 3D)
    canvas.drawLine(
      Offset(size.width * 0.675, 0),
      Offset(size.width * 0.675, size.height * 0.5),
      paint,
    );

    // Horizontal line at 50% (separating top and bottom rows)
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint,
    );

    // Vertical lines for bottom row (3 equal columns)
    final columnWidth = size.width / 3;
    canvas.drawLine(
      Offset(columnWidth, size.height * 0.5),
      Offset(columnWidth, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(columnWidth * 2, size.height * 0.5),
      Offset(columnWidth * 2, size.height),
      paint,
    );

    // Highlight regions based on hover
    if (highlightedRegion != null) {
      Rect highlightRect;

      switch (highlightedRegion) {
        case 'Panorama':
          highlightRect =
              Rect.fromLTWH(0, 0, size.width * 0.675, size.height * 0.5);
          break;
        case '3D':
          highlightRect = Rect.fromLTWH(
              size.width * 0.675, 0, size.width * 0.325, size.height * 0.5);
          break;
        case 'Longitudinal':
          highlightRect = Rect.fromLTWH(
              0, size.height * 0.5, columnWidth, size.height * 0.5);
          break;
        case 'Cross-sectional':
          highlightRect = Rect.fromLTWH(
              columnWidth, size.height * 0.5, columnWidth, size.height * 0.5);
          break;
        case 'Axial':
          highlightRect = Rect.fromLTWH(columnWidth * 2, size.height * 0.5,
              columnWidth, size.height * 0.5);
          break;
        default:
          highlightRect = Rect.zero;
      }

      if (highlightRect != Rect.zero) {
        canvas.drawRect(highlightRect, highlightPaint);
      }
    }

    // Draw crosshair at current drag position
    if (dragCurrent != null) {
      _drawCrosshair(
          canvas, dragCurrent!, size, crosshairPaint, crosshairCenterPaint);
    }
  }

  void _drawCrosshair(Canvas canvas, Offset position, Size size,
      Paint linePaint, Paint centerPaint) {
    const double centerRadius = 3.0;

    // Get the region bounds for the crosshair
    Rect regionBounds = _getRegionBounds(position, size);

    // Extend crosshair lines to the full boundaries of the region
    double left = regionBounds.left;
    double right = regionBounds.right;
    double top = regionBounds.top;
    double bottom = regionBounds.bottom;

    // Draw horizontal line of crosshair (full width of region)
    canvas.drawLine(
      Offset(left, position.dy),
      Offset(right, position.dy),
      linePaint,
    );

    // Draw vertical line of crosshair (full height of region)
    canvas.drawLine(
      Offset(position.dx, top),
      Offset(position.dx, bottom),
      linePaint,
    );

    // Draw center circle
    canvas.drawCircle(position, centerRadius, centerPaint);

    // Draw outer circle for better visibility
    canvas.drawCircle(
        position, centerRadius + 2, linePaint..style = PaintingStyle.stroke);
  }

  Rect _getRegionBounds(Offset position, Size size) {
    final x = position.dx;
    final y = position.dy;

    // Determine which region the position is in and return its bounds
    if (y < size.height / 2) {
      // Top row
      if (x < size.width * 0.675) {
        // Panorama region
        return Rect.fromLTWH(0, 0, size.width * 0.675, size.height * 0.5);
      } else {
        // 3D region
        return Rect.fromLTWH(
            size.width * 0.675, 0, size.width * 0.325, size.height * 0.5);
      }
    } else {
      // Bottom row
      final columnWidth = size.width / 3;
      if (x < columnWidth) {
        // Longitudinal region
        return Rect.fromLTWH(
            0, size.height * 0.5, columnWidth, size.height * 0.5);
      } else if (x < columnWidth * 2) {
        // Cross-sectional region
        return Rect.fromLTWH(
            columnWidth, size.height * 0.5, columnWidth, size.height * 0.5);
      } else {
        // Axial region
        return Rect.fromLTWH(
            columnWidth * 2, size.height * 0.5, columnWidth, size.height * 0.5);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
