import 'package:flutter/material.dart';

import 'examples/basic.dart';
import 'examples/html_to_pdf.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Web View',
      theme: ThemeData.light(),
      home: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              labelType: NavigationRailLabelType.all,
              selectedIndex: currentIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.details),
                  label: Text('Basic'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text('PDF'),
                ),
              ],
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  switch (currentIndex) {
                    case 0:
                      return const BasicExample();
                    case 1:
                      return const HtmlToPdfTest();
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
