import 'package:flutter/material.dart';

import './home_screen.dart';

class CellRendererScreen extends StatefulWidget {
  static const routeName = 'feature/cell-renderer';

  @override
  _CellRendererScreenState createState() => _CellRendererScreenState();
}

class _CellRendererScreenState extends State<CellRendererScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Team Maker Buddy',
      topTitle: 'Squad Management',
      topContents: [
        const Text('Organize your team and balance players fairly.'),
      ],
      topButtons: [ElevatedButton(onPressed: null, child: Text("HI"))],
    );
  }
}
