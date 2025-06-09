import 'package:flutter/material.dart';
import 'favorites_page.dart';

class IframeFavoritesWidget extends StatefulWidget {
  const IframeFavoritesWidget({super.key});

  @override
  State<IframeFavoritesWidget> createState() => _IframeFavoritesWidgetState();
}

class _IframeFavoritesWidgetState extends State<IframeFavoritesWidget> {
  bool _showIframe = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_showIframe)
          Positioned(
            right: 20,
            bottom: 20,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 320,
                height: 400,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepOrange, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FavoritesPage(),
                ),
              ),
            ),
          ),
        Positioned(
          right: 30,
          bottom: _showIframe ? 430 : 20,
          child: FloatingActionButton(
            mini: true,
            onPressed: () {
              setState(() {
                _showIframe = !_showIframe;
              });
            },
            child: Icon(_showIframe ? Icons.close : Icons.favorite),
          ),
        ),
      ],
    );
  }
}
