import 'package:flutter/material.dart';
import 'package:teammaker/cell_renderer.dart';
import 'package:teammaker/theme/app_theme.dart';

void main() {
  runApp(const TeamMakerApp());
}

class TeamMakerApp extends StatefulWidget {
  const TeamMakerApp({super.key});

  @override
  State<TeamMakerApp> createState() => _TeamMakerAppState();
}

class _TeamMakerAppState extends State<TeamMakerApp> {
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = ThemeController();
    _themeController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Maker Buddy',
      debugShowCheckedModeBanner: false,
      theme: _themeController.lightTheme,
      darkTheme: _themeController.darkTheme,
      themeMode: _themeController.mode,
      home: CellRendererScreen(themeController: _themeController),
    );
  }
}
