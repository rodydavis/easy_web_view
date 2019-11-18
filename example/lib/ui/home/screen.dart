import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String url = 'https://flutter.dev';
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Live View'),
      ),
      body: LiveView(
        src: url,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (val) {
          if (mounted)
            setState(() {
              url = _getUrl(val);
              _currentIndex = val;
            });
        },
        items: [
          BottomNavigationBarItem(
            title: Text('Flutter'),
            icon: Icon(Icons.info),
          ),
          BottomNavigationBarItem(
            title: Text('Dart'),
            icon: Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }

  String _getUrl(int val) {
    switch (val) {
      case 0:
        return 'https://flutter.dev';
      case 1:
        return 'https://dart.dev';
      default:
        return 'https://google.com';
    }
  }
}
