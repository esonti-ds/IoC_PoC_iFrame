import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';

class CoordinatesIframeWidget extends StatefulWidget {
  final String currentRegion;
  final Offset? relativePosition;
  final bool isDragging;
  final Offset? dragStartPosition;
  final Offset? currentDragPosition;

  const CoordinatesIframeWidget({
    super.key,
    required this.currentRegion,
    this.relativePosition,
    required this.isDragging,
    this.dragStartPosition,
    this.currentDragPosition,
  });

  @override
  State<CoordinatesIframeWidget> createState() =>
      _CoordinatesIframeWidgetState();
}

class _CoordinatesIframeWidgetState extends State<CoordinatesIframeWidget> {
  bool _showIframe = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return Stack(
      children: [
        if (_showIframe)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              elevation: 8,
              child: Container(
                width: double.infinity,
                height: 120, // Fixed height since token is now inline
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    top: BorderSide(color: Colors.deepOrange, width: 2),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      // Mouse Coordinates section - increased flex
                      Expanded(
                        flex: 3, // Increased from 2 to 3
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Mouse Coordinates',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),
                            ),
                            SizedBox(height: 4),
                            // Changed to Column layout for better space utilization
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCompactInfoRow(
                                    'Region:',
                                    widget.currentRegion.isEmpty
                                        ? 'None'
                                        : widget.currentRegion),
                                SizedBox(height: 2),
                                if (widget.relativePosition != null)
                                  _buildCompactInfoRow('Position:',
                                      '${(widget.relativePosition!.dx * 100).toStringAsFixed(1)}%, ${(widget.relativePosition!.dy * 100).toStringAsFixed(1)}%'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16), // Added spacing
                      // Drag information section OR Token response section (mutually exclusive)
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Show drag information when dragging is active
                            if (widget.isDragging) ...[
                              Text(
                                'Dragging',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                              ),
                              SizedBox(height: 4),
                              // Changed to Column for better layout
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.dragStartPosition != null)
                                    _buildCompactInfoRow('Start:',
                                        '(${widget.dragStartPosition!.dx.toInt()}, ${widget.dragStartPosition!.dy.toInt()})'),
                                  SizedBox(height: 2),
                                  if (widget.currentDragPosition != null)
                                    _buildCompactInfoRow('Current:',
                                        '(${widget.currentDragPosition!.dx.toInt()}, ${widget.currentDragPosition!.dy.toInt()})'),
                                ],
                              ),
                            ]
                            // Show token response when not dragging and token is available
                            else if (appState.tokenResponse != null) ...[
                              Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 16),
                                  SizedBox(width: 8),
                                  Expanded(
                                    // Added Expanded to prevent overflow
                                    child: Text(
                                      'Token Response',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      appState.clearTokenResponse();
                                    },
                                    icon: Icon(Icons.close, size: 14),
                                    color: Colors.grey[400],
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(
                                        minWidth: 20, minHeight: 20),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      appState.tokenResponse!,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  if (appState.tokenResponseTime != null)
                                    Text(
                                      '${appState.tokenResponseTime!.toLocal().toString().substring(11, 19)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Colors.grey[400],
                                          ),
                                    ),
                                ],
                              ),
                            ]
                            // Show empty space when no dragging and no token
                            else ...[
                              SizedBox(), // Empty space
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 16), // Added spacing
                      // Region layout info - reduced flex
                      Expanded(
                        flex: 2, // Kept same but now proportionally smaller
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Regions Layout:',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Top: Panorama (67.5%) | 3D (32.5%)',
                                style: Theme.of(context).textTheme.labelSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Bottom: Longitudinal | Cross-sectional | Axial',
                                style: Theme.of(context).textTheme.labelSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16), // Reduced from 20 to 16
                      // Request Token button
                      ElevatedButton.icon(
                        onPressed: () {
                          appState.sendTokenRequest();
                        },
                        icon: Icon(Icons.security, size: 16),
                        label: Text('Request Token'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          minimumSize: Size(140, 40),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // Toggle button positioned at bottom right
        Positioned(
          right: 20,
          bottom: _showIframe
              ? 130
              : 20, // Fixed position since height is now constant
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            onPressed: () {
              setState(() {
                _showIframe = !_showIframe;
              });
            },
            child: Icon(_showIframe ? Icons.keyboard_arrow_down : Icons.mouse),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactInfoRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[400],
              ),
        ),
        SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
