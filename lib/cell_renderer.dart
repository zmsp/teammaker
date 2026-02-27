import 'package:flutter/material.dart';
import 'package:teammaker/theme/app_theme.dart';
import './home_screen.dart';

class CellRendererScreen extends StatelessWidget {
  static const routeName = 'feature/cell-renderer';

  final ThemeController themeController;

  const CellRendererScreen({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Team Maker Buddy',
      topTitle: 'Squad Management',
      themeController: themeController,
    );
  }
}
