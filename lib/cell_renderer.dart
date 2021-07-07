import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../dummy_data/development.dart';
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
      title: 'Cell renderer',
      topTitle: 'Cell renderer',
      topContents: [
        const Text(
            'You can change the widget of the cell through the renderer.'),
      ],
      topButtons: [
        ElevatedButton(onPressed: null, child: Text("HI"))

      ],

    );
  }
}