import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TapScoreScreen extends StatefulWidget {
  final int? initialScoreA;
  final int? initialScoreB;
  final String? initialNameA;
  final String? initialNameB;

  const TapScoreScreen({
    super.key,
    this.initialScoreA,
    this.initialScoreB,
    this.initialNameA,
    this.initialNameB,
  });

  @override
  State<TapScoreScreen> createState() => _TapScoreScreenState();
}

class _TapScoreScreenState extends State<TapScoreScreen> {
  int _teamAScore = 0;
  int _teamBScore = 0;
  int _seconds = 0;
  Timer? _timer;
  bool _isRunning = true;

  final TextEditingController _nameAController =
      TextEditingController(text: "TEAM A");
  final TextEditingController _nameBController =
      TextEditingController(text: "TEAM B");

  Color _colorA = const Color(0xFF1A237E); // Indigo
  Color _colorB = const Color(0xFFB71C1C); // Red

  @override
  void initState() {
    super.initState();
    _loadState();
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameAController.dispose();
    _nameBController.dispose();
    super.dispose();
  }

  void _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _teamAScore = widget.initialScoreA ?? (prefs.getInt('score_a') ?? 0);
      _teamBScore = widget.initialScoreB ?? (prefs.getInt('score_b') ?? 0);
      _nameAController.text =
          widget.initialNameA ?? (prefs.getString('name_a') ?? "TEAM A");
      _nameBController.text =
          widget.initialNameB ?? (prefs.getString('name_b') ?? "TEAM B");
    });
  }

  void _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('score_a', _teamAScore);
    prefs.setInt('score_b', _teamBScore);
    prefs.setString('name_a', _nameAController.text);
    prefs.setString('name_b', _nameBController.text);
  }

  void _toggleTimer() {
    setState(() {
      if (_isRunning) {
        _timer?.cancel();
      } else {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _seconds++;
          });
        });
      }
      _isRunning = !_isRunning;
    });
  }

  void _resetTimer() {
    setState(() {
      _timer?.cancel();
      _seconds = 0;
      _isRunning = false;
    });
  }

  void _resetScores() {
    setState(() {
      _teamAScore = 0;
      _teamBScore = 0;
      _saveState();
    });
  }

  void _swapTeams() {
    setState(() {
      final tempScore = _teamAScore;
      _teamAScore = _teamBScore;
      _teamBScore = tempScore;

      final tempName = _nameAController.text;
      _nameAController.text = _nameBController.text;
      _nameBController.text = tempName;

      final tempColor = _colorA;
      _colorA = _colorB;
      _colorB = tempColor;

      _saveState();
    });
  }

  void _backWithResult() {
    Navigator.pop(context, {
      'scoreA': _teamAScore,
      'scoreB': _teamBScore,
    });
  }

  String _formatTime() {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(child: _buildTeamHalf('A')),
              Expanded(child: _buildTeamHalf('B')),
            ],
          ),

          // Top Header with Back button — very dim
          Positioned(
            top: 55,
            left: 15,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new,
                  color: Colors.white.withValues(alpha: 0.18), size: 18),
              onPressed: _backWithResult,
            ),
          ),

          // Center Timer — clearly visible, no border box
          Positioned(
            top: 56,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _toggleTimer,
                onLongPress: _resetTimer,
                child: Text(
                  _formatTime(),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: _isRunning
                        ? Colors.white.withValues(alpha: 0.72)
                        : Colors.white.withValues(alpha: 0.30),
                    fontFamily: 'monospace',
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),
          ),

          // Control Bar — dim
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.25,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ControlCircle(
                    icon: FontAwesomeIcons.rotate,
                    onPressed: _resetScores,
                    label: "Reset",
                  ),
                  const SizedBox(width: 40),
                  _ControlCircle(
                    icon: FontAwesomeIcons.rightLeft,
                    onPressed: _swapTeams,
                    label: "Swap",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamHalf(String team) {
    final score = team == 'A' ? _teamAScore : _teamBScore;
    final color = team == 'A' ? _colorA : _colorB;
    final controller = team == 'A' ? _nameAController : _nameBController;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (team == 'A') {
            _teamAScore++;
          } else {
            _teamBScore++;
          }
          _saveState();
        });
      },
      onLongPress: () {
        setState(() {
          if (team == 'A') {
            if (_teamAScore > 0) _teamAScore--;
          } else {
            if (_teamBScore > 0) _teamBScore--;
          }
          _saveState();
        });
      },
      child: Container(
        color: color.withValues(alpha: 0.8),
        child: Stack(
          children: [
            // ── Team name pinned to top, read-only, no background ──────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 52),
                  child: Text(
                    controller.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.22),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 5,
                    ),
                  ),
                ),
              ),
            ),

            // ── Score + hint + buttons centred ─────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Score scales to fill the half-screen width
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "$score",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 220,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "TAP TO SCORE",
                    style: TextStyle(
                        color: Colors.white30, fontSize: 12, letterSpacing: 3),
                  ),
                  const SizedBox(height: 28),
                  // +/- buttons dimmed
                  Opacity(
                    opacity: 0.28,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ScoreSmallButton(
                          icon: Icons.remove,
                          onPressed: () {
                            setState(() {
                              if (team == 'A') {
                                if (_teamAScore > 0) _teamAScore--;
                              } else {
                                if (_teamBScore > 0) _teamBScore--;
                              }
                              _saveState();
                            });
                          },
                        ),
                        const SizedBox(width: 25),
                        _ScoreSmallButton(
                          icon: Icons.add,
                          onPressed: () {
                            setState(() {
                              if (team == 'A') {
                                _teamAScore++;
                              } else {
                                _teamBScore++;
                              }
                              _saveState();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreSmallButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ScoreSmallButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white70, size: 24),
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}

class _ControlCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String label;

  const _ControlCircle({
    required this.icon,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: onPressed,
          icon: FaIcon(icon, size: 18),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white10,
            foregroundColor: Colors.white70,
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}
