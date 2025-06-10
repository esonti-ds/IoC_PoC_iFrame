// ignore_for_file: invalid_runtime_check_with_js_interop_types

import 'dart:js';
import 'dart:js_interop';

import 'package:web/web.dart' as web;
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import the separated widgets
import 'widgets/ioc/ioc_poc_page.dart';
import 'widgets/favorites/generator_page.dart';

// Define JavaScript interop function
@JS('sendMessageToParent')
external bool sendMessageToParentJS(JSAny message);

// Global reference to the app state for message handling
MyAppState? _globalAppState;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    _setupMessageListener();

    return ChangeNotifierProvider(
      create: (context) {
        final appState = MyAppState();
        _globalAppState = appState; // Store global reference
        return appState;
      },
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.dark,
          ).copyWith(
            // Custom dark theme colors with gray shades
            surface: Colors.grey[900]!,
            background: Colors.grey[850]!,
            primaryContainer: Colors.grey[800]!,
            secondaryContainer: Colors.grey[700]!,
            onSurface: Colors.grey[100]!,
            onBackground: Colors.grey[100]!,
            onPrimaryContainer: Colors.grey[100]!,
            onSecondaryContainer: Colors.grey[100]!,
          ),
          scaffoldBackgroundColor: Colors.grey[900],
          cardColor: Colors.grey[800],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[850],
            foregroundColor: Colors.grey[100],
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }

  void _setupMessageListener() {
    web.window.onMessage.listen((event) {
      web.console.log(
          'iframe.flutterapp.dart: Received Message. Origin -  ${event.origin}'
              as JSAny?);

      _parseAndHandleMessage(event);
    });
  }

  void _parseAndHandleMessage(web.MessageEvent event) {
    try {
      final jsEvent = JsObject.fromBrowserObject(event);
      final message = jsEvent['data']; // LegacyJavaScriptObject

      if (message is JsObject) {
        final type = message['type'];
        final details = message['details'];

        switch (type) {
          case 'status':
            print(
                'iframe.flutterapp.dart: Received Message. Status - $details');
            _handleStatusMessage(details);
          case 'data':
            print('iframe.flutterapp.dart: Received Message. Data - $details');
            _handleDataMessage(details);
          default:
            print(
                'iframe.flutterapp.dart: Received Message. Unknown type - $type');
        }
      } else {
        web.console.log(
            'iframe.flutterapp.dart: Message data is not a JsObject' as JSAny?);
      }
    } catch (e) {
      web.console.error(
          'iframe.flutterapp.dart: Error parsing message - $e' as JSAny?);
    }
  }

  void _handleStatusMessage(dynamic details) {
    // Handle status message logic here
    web.console.log('Processing status message: $details' as JSAny?);
  }

  void _handleDataMessage(dynamic details) {
    // Handle data message logic here
    web.console.log('Processing data message: $details' as JSAny?);

    // Check if the message contains "Token" and update the app state
    if (details != null && details.toString().contains('Token')) {
      web.console.log('Token message detected: $details' as JSAny?);

      // Update the global app state with the token response
      if (_globalAppState != null) {
        _globalAppState!.updateTokenResponse(details.toString());
      }
    }
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];

  // Mouse interaction data
  String _currentRegion = '';
  Offset? _relativePosition;
  bool _isDragging = false;
  Offset? _dragStartPosition;
  Offset? _currentDragPosition;

  // Token response data
  String? _tokenResponse;
  DateTime? _tokenResponseTime;

  // Getters for mouse interaction data
  String get currentRegion => _currentRegion;
  Offset? get relativePosition => _relativePosition;
  bool get isDragging => _isDragging;
  Offset? get dragStartPosition => _dragStartPosition;
  Offset? get currentDragPosition => _currentDragPosition;

  // Getters for token data
  String? get tokenResponse => _tokenResponse;
  DateTime? get tokenResponseTime => _tokenResponseTime;

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
      // Safe postMessage implementation
      _sendMessageToParent({
        'type': 'data',
        'origin': web.window.location.origin,
        'details': 'Message - ${current.asLowerCase}',
        'timestamp': DateTime.now().millisecondsSinceEpoch
      });
    }
    notifyListeners();
  }

  // New methods for mouse interaction updates
  void updateMouseHover(String region, Offset? relativePos) {
    _currentRegion = region;
    _relativePosition = relativePos;
    // final percentX =
    //     relativePos != null ? (relativePos.dx * 100).toStringAsFixed(1) : '0.0';
    // final percentY =
    //     relativePos != null ? (relativePos.dy * 100).toStringAsFixed(1) : '0.0';
    // final hoverMessage = '$region at ($percentX%, $percentY%)';
    // // Send message to parent with hover data
    // if (region.isNotEmpty && relativePos != null) {
    //   _sendMessageToParent({
    //     'type': 'data',
    //     'origin': web.window.location.origin,
    //     'details': 'Message: $hoverMessage',
    //     'timestamp': DateTime.now().millisecondsSinceEpoch,
    //   });
    // }

    notifyListeners();
  }

  void updateMouseDragStart(
      String region, Offset position, Offset? relativePos) {
    _currentRegion = region;
    _dragStartPosition = position;
    _relativePosition = relativePos;
    _isDragging = true;
    final percentX = relativePos != null ? (relativePos.dx * 100).round() : 0;
    final percentY = relativePos != null ? (relativePos.dy * 100).round() : 0;
    final dragMessage = '$region at ($percentX%, $percentY%)';
    // Send message to parent with drag start data
    _sendMessageToParent({
      'type': 'data',
      'origin': web.window.location.origin,
      'details': 'Message: $dragMessage',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    notifyListeners();
  }

  void updateMouseDragUpdate(
      String region, Offset position, Offset? relativePos) {
    _currentRegion = region;
    _currentDragPosition = position;
    _relativePosition = relativePos;
    final percentX = relativePos != null ? (relativePos.dx * 100).round() : 0;
    final percentY = relativePos != null ? (relativePos.dy * 100).round() : 0;
    final dragMessage = '$region at ($percentX%, $percentY%)';
    // Send message to parent with drag update data
    _sendMessageToParent({
      'type': 'data',
      'origin': web.window.location.origin,
      'details': 'Message: $dragMessage',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    notifyListeners();
  }

  void updateMouseDragEnd() {
    _isDragging = false;

    // Send message to parent with drag end data
    // _sendMessageToParent({
    //   'type': 'data',
    //   'origin': web.window.location.origin,
    //   'details': 'Message: $_currentRegion',
    //   'timestamp': DateTime.now().millisecondsSinceEpoch,
    // });

    _dragStartPosition = null;
    _currentDragPosition = null;
    notifyListeners();
  }

  void updateMouseExit() {
    _currentRegion = '';
    _relativePosition = null;

    // Send message to parent with mouse exit data
    // _sendMessageToParent({
    //   'type': 'data',
    //   'origin': web.window.location.origin,
    //   'details': 'Mouse exited image region',
    //   'timestamp': DateTime.now().millisecondsSinceEpoch,
    // });

    notifyListeners();
  }

  void sendTokenRequest() {
    // Send special token request message to parent
    _sendMessageToParent({
      'type': 'data',
      'origin': web.window.location.origin,
      'details':
          'Token - Special authentication token request from Flutter app',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    notifyListeners();
  }

  void updateTokenResponse(String tokenMessage) {
    _tokenResponse = tokenMessage;
    _tokenResponseTime = DateTime.now();
    web.console
        .log('Token response updated in app state: $tokenMessage' as JSAny?);
    notifyListeners();
  }

  void clearTokenResponse() {
    _tokenResponse = null;
    _tokenResponseTime = null;
    notifyListeners();
  }

  void _sendMessageToParent(Map<String, dynamic> message) {
    try {
      web.console.log(
          'iframe.flutterapp.dart: Send Message - ${message.toString()}'
              as JSAny?);
      // Convert message to JSAny and call JavaScript function
      final jsMessage = message.jsify() as JSAny;
      sendMessageToParentJS(jsMessage);
    } catch (e) {
      web.console.error(
          'iframe.flutterapp.dart: Send Message- Failed. Reason - $e'
              as JSAny?);

      // Fallback to direct web API call
      try {
        if (web.window.parent != null && web.window.parent != web.window) {
          final jsMessage = message.jsify() as JSAny;
          web.window.parent!.postMessage(jsMessage, '*' as JSAny);
          web.console
              .log('iframe.flutterapp.dart: Send Message - Success' as JSAny?);
        }
      } catch (fallbackError) {
        web.console.error(
            'iframe.flutterapp.dart: Send Message - Failed. Reason - $fallbackError'
                as JSAny?);
      }
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = IocPocPage(); // Changed from GeneratorPage to IocPocPage
      case 1:
        page = GeneratorPage(); // Changed from GeneratorPage to FavoritesPage
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: Colors.grey[900], // Dark background
        body: Row(
          children: [
            SafeArea(
              child: Container(
                color: Colors.grey[850], // Dark navigation rail background
                child: NavigationRail(
                  backgroundColor: Colors.grey[850],
                  selectedIconTheme: IconThemeData(
                    color: Colors.deepOrange,
                  ),
                  unselectedIconTheme: IconThemeData(
                    color: Colors.grey[400],
                  ),
                  selectedLabelTextStyle: TextStyle(
                    color: Colors.deepOrange,
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    color: Colors.grey[400],
                  ),
                  extended: false, // Always show only icons
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.medical_information),
                      label: Text('IoC_PoC_Widget'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites_PoC_Widget'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.grey[800], // Dark main content background
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}
