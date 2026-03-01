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
  int _maxScore = 25;
  int _elapsedSeconds = 0;
  DateTime? _startDate;
  Timer? _timer;
  bool _isRunning = false;

  int _roundCount = 1;
  List<String> _history = [];

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
    _nameAController.addListener(_saveState);
    _nameBController.addListener(_saveState);
    _startTimerIfRunning();
  }

  void _startTimerIfRunning() {
    _timer?.cancel();
    if (_isRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  int get _currentSeconds {
    if (!_isRunning || _startDate == null) return _elapsedSeconds;
    return _elapsedSeconds + DateTime.now().difference(_startDate!).inSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameAController.removeListener(_saveState);
    _nameBController.removeListener(_saveState);
    _nameAController.dispose();
    _nameBController.dispose();
    super.dispose();
  }

  void _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _teamAScore = widget.initialScoreA ?? (prefs.getInt('score_a') ?? 0);
      _teamBScore = widget.initialScoreB ?? (prefs.getInt('score_b') ?? 0);
      _maxScore = prefs.getInt('max_score') ?? 25;
      _elapsedSeconds = prefs.getInt('elapsed_seconds') ?? 0;
      _isRunning = prefs.getBool('is_running') ?? false;
      _roundCount = prefs.getInt('round_count') ?? 1;
      _history = prefs.getStringList('history') ?? [];

      final startDateStr = prefs.getString('start_date');
      if (startDateStr != null) {
        _startDate = DateTime.tryParse(startDateStr);
      }

      // Initialize timer if no state exists yet (first open)
      if (prefs.getInt('score_a') == null &&
          _startDate == null &&
          !_isRunning) {
        _startDate = DateTime.now();
        _isRunning = true;
      }

      _nameAController.text =
          widget.initialNameA ?? (prefs.getString('name_a') ?? "TEAM A");
      _nameBController.text =
          widget.initialNameB ?? (prefs.getString('name_b') ?? "TEAM B");

      final colorAVal = prefs.getInt('color_a');
      if (colorAVal != null) _colorA = Color(colorAVal);
      final colorBVal = prefs.getInt('color_b');
      if (colorBVal != null) _colorB = Color(colorBVal);

      _startTimerIfRunning();
    });
  }

  void _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('score_a', _teamAScore);
    prefs.setInt('score_b', _teamBScore);
    prefs.setInt('max_score', _maxScore);
    prefs.setInt('elapsed_seconds', _currentSeconds);
    prefs.setBool('is_running', _isRunning);
    prefs.setInt('round_count', _roundCount);
    prefs.setStringList('history', _history);
    if (_startDate != null) {
      prefs.setString('start_date', _startDate!.toIso8601String());
    } else {
      prefs.remove('start_date');
    }
    prefs.setString('name_a', _nameAController.text);
    prefs.setString('name_b', _nameBController.text);
    prefs.setInt('color_a', _colorA.value);
    prefs.setInt('color_b', _colorB.value);
  }

  void _toggleTimer() {
    setState(() {
      if (_isRunning) {
        // Pausing: save accumulated elapsed time
        _elapsedSeconds = _currentSeconds;
        _startDate = null;
        _timer?.cancel();
      } else {
        // Resuming: set new start date
        _startDate = DateTime.now();
        _startTimerIfRunning();
      }
      _isRunning = !_isRunning;
      _saveState();
    });
    _startTimerIfRunning();
  }

  void _resetTimer() {
    setState(() {
      _timer?.cancel();
      _elapsedSeconds = 0;
      _startDate = DateTime.now();
      _isRunning = true;
      _saveState();
      _startTimerIfRunning();
    });
  }

  void _resetScores() {
    setState(() {
      _teamAScore = 0;
      _teamBScore = 0;
      _elapsedSeconds = 0;
      _startDate = DateTime.now();
      _isRunning = true;
      _saveState();
      _startTimerIfRunning();
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
    final totalSeconds = _currentSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  String _formatStartDate() {
    if (_startDate == null && _elapsedSeconds == 0) return "Not started";
    // We should display the start time of the game, not the last resume time.
    // If the game is paused, we don't know the exact original start time unless we save it separately, but a good approximation is current time minus elapsed time.
    final effectiveStart = _isRunning
        ? (_startDate ?? DateTime.now())
        : DateTime.now().subtract(Duration(seconds: _elapsedSeconds));
    final hours = effectiveStart.hour;
    final mins = effectiveStart.minute.toString().padLeft(2, '0');
    final ampm = hours >= 12 ? 'PM' : 'AM';
    final hour12 = hours > 12 ? hours - 12 : (hours == 0 ? 12 : hours);
    return "STARTED: $hour12:$mins $ampm";
  }

  void _incrementScore(String team) {
    setState(() {
      if (team == 'A') {
        _teamAScore++;
        if (_teamAScore >= _maxScore) {
          _handleMaxScoreReached('A');
        }
      } else {
        _teamBScore++;
        if (_teamBScore >= _maxScore) {
          _handleMaxScoreReached('B');
        }
      }
      _saveState();
    });
  }

  void _recordHistoryEntry(String winnerId) {
    String winnerName =
        winnerId == 'A' ? _nameAController.text : _nameBController.text;
    String loserName =
        winnerId == 'A' ? _nameBController.text : _nameAController.text;
    int winnerScore = winnerId == 'A' ? _teamAScore : _teamBScore;
    int loserScore = winnerId == 'A' ? _teamBScore : _teamAScore;

    final now = DateTime.now();
    final timeStr =
        "${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    final durationSeconds = _currentSeconds;
    final mins = durationSeconds ~/ 60;
    final secs = durationSeconds % 60;
    final durationStr = "${mins}m ${secs}s";

    String historyEntry =
        "Round $_roundCount • $timeStr (${durationStr})\n🏆 $winnerName ($winnerScore)\n    $loserName ($loserScore)";

    _history.add(historyEntry);
    _roundCount++;
    _saveState();
  }

  void _handleMaxScoreReached(String winnerId) {
    _recordHistoryEntry(winnerId);
    if (_isRunning) _toggleTimer();

    String winnerName =
        winnerId == 'A' ? _nameAController.text : _nameBController.text;
    String loserName =
        winnerId == 'A' ? _nameBController.text : _nameAController.text;
    int winnerScore = winnerId == 'A' ? _teamAScore : _teamBScore;
    int loserScore = winnerId == 'A' ? _teamBScore : _teamAScore;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                backgroundColor: Colors.grey[900],
                title: const Text("Round Complete",
                    style: TextStyle(color: Colors.white)),
                content: Text(
                    "🏆 $winnerName reached the max score!\n\n${winnerName}: $winnerScore\n${loserName}: $loserScore",
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 16, height: 1.5)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("KEEP PLAYING",
                          style: TextStyle(color: Colors.white38))),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _resetScores();
                      },
                      child: const Text("NEW ROUND",
                          style: TextStyle(
                              color: Colors.indigoAccent,
                              fontWeight: FontWeight.bold)))
                ]));
  }

  void _requestNextRound() {
    if (_teamAScore == 0 && _teamBScore == 0 && _elapsedSeconds == 0) {
      _resetScores();
      return;
    }

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                backgroundColor: Colors.grey[900],
                title: const Text("Start New Round?",
                    style: TextStyle(color: Colors.white)),
                content: const Text(
                    "This will record current scores to history and reset the game state.",
                    style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CANCEL",
                          style: TextStyle(color: Colors.white38))),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        String winnerId =
                            _teamAScore >= _teamBScore ? 'A' : 'B';
                        _recordHistoryEntry(winnerId);
                        _resetScores();
                      },
                      child: const Text("START NEW",
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold)))
                ]));
  }

  void _showHistoryPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Match History",
              style: TextStyle(color: Colors.white70)),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: _history.isEmpty
                ? const Center(
                    child: Text("No history yet.",
                        style: TextStyle(color: Colors.white54)))
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _history.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.white12, height: 24),
                    itemBuilder: (context, index) {
                      return Text(_history.reversed.toList()[index],
                          style: const TextStyle(
                              color: Colors.white70, height: 1.4));
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _history.clear();
                  _roundCount = 1;
                });
                _saveState();
                Navigator.pop(context);
              },
              child: const Text("CLEAR",
                  style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("CLOSE", style: TextStyle(color: Colors.white38)),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsPopup() {
    TextEditingController maxScoreCtrl =
        TextEditingController(text: _maxScore.toString());

    final countryThemes = {
      'Manual / Custom': null,
      'USA (Navy/DeepRed)': [const Color(0xFF001F3F), const Color(0xFF8B0000)],
      'Bangladesh (DarkGreen/Crimson)': [
        const Color(0xFF004030),
        const Color(0xFFB22222)
      ],
      'Mexico (ForestGreen/Maroon)': [
        const Color(0xFF004D33),
        const Color(0xFF800000)
      ],
      'India (DeepOrange/DarkGreen)': [
        const Color(0xFFD35400),
        const Color(0xFF095A04)
      ],
      'China (DarkRed/Gold)': [
        const Color(0xFF8B0000),
        const Color(0xFFB8860B)
      ],
      'Philippines (Navy/Maroon)': [
        const Color(0xFF000080),
        const Color(0xFF800000)
      ],
      'El Salvador (DarkBlue/Grey)': [
        const Color(0xFF003366),
        const Color(0xFF424242)
      ],
      'Vietnam (DarkRed/Gold)': [
        const Color(0xFF8B0000),
        const Color(0xFFB8860B)
      ],
      'Cuba (Navy/Maroon)': [const Color(0xFF000080), const Color(0xFF800000)],
      'Dominican Republic (Navy/Maroon)': [
        const Color(0xFF001A33),
        const Color(0xFF800000)
      ],
      'Guatemala (DeepSkyBlue/Slate)': [
        const Color(0xFF0074D9),
        const Color(0xFF424242)
      ],
      'South Korea (DarkGrey/Navy)': [
        const Color(0xFF212121),
        const Color(0xFF000080)
      ],
      'Colombia (Gold/Navy)': [
        const Color(0xFFB8860B),
        const Color(0xFF000080)
      ],
      'Honduras (Navy/Slate)': [
        const Color(0xFF001F3F),
        const Color(0xFF424242)
      ],
      'Canada (Maroon/DarkGrey)': [
        const Color(0xFF800000),
        const Color(0xFF424242)
      ],
      'Jamaica (DarkGreen/Gold)': [
        const Color(0xFF004D00),
        const Color(0xFFB8860B)
      ],
      'Haiti (Navy/Maroon)': [const Color(0xFF000080), const Color(0xFF800000)],
      'UK (Navy/DeepRed)': [const Color(0xFF001F3F), const Color(0xFF8B0000)],
      'Venezuela (Gold/Navy)': [
        const Color(0xFFB8860B),
        const Color(0xFF000080)
      ],
      'Brazil (Gold/DarkGreen)': [
        const Color(0xFFB8860B),
        const Color(0xFF004D00)
      ],
      'Germany (Black/DarkRed)': [
        const Color(0xFF000000),
        const Color(0xFF8B0000)
      ],
      'Russia (DarkGrey/Navy)': [
        const Color(0xFF424242),
        const Color(0xFF000080)
      ],
      'Peru (Maroon/DarkGrey)': [
        const Color(0xFF800000),
        const Color(0xFF424242)
      ],
      'Nigeria (DarkGreen/Grey)': [
        const Color(0xFF004D00),
        const Color(0xFF424242)
      ],
      'Ukraine (Navy/Gold)': [const Color(0xFF000080), const Color(0xFFB8860B)],
      'Iran (DarkGreen/Maroon)': [
        const Color(0xFF004D00),
        const Color(0xFF800000)
      ],
      'Pakistan (DarkGreen/Grey)': [
        const Color(0xFF003300),
        const Color(0xFF424242)
      ],
      'Japan (DarkGrey/Maroon)': [
        const Color(0xFF424242),
        const Color(0xFF800000)
      ],
      'France (Navy/Maroon)': [
        const Color(0xFF000080),
        const Color(0xFF800000)
      ],
      'Italy (DarkGreen/Maroon)': [
        const Color(0xFF004D00),
        const Color(0xFF800000)
      ],
      'Argentina (Navy/Slate)': [
        const Color(0xFF0074D9),
        const Color(0xFF424242)
      ],
    };

    final pickableColors = [
      const Color(0xFF0D47A1), // Darker Indigo
      const Color(0xFFB71C1C), // Deep Red
      const Color(0xFF1B5E20), // Dark Green
      const Color(0xFFE65100), // Dark Orange
      const Color(0xFF4A148C), // Deep Purple
      const Color(0xFF004D40), // Dark Teal
      const Color(0xFF212121), // Charcoal
      const Color(0xFF455A64), // Blue Grey
      const Color(0xFFF9A825), // Dark Yellow/Gold
      const Color(0xFF424242), // Slate/Dark Grey (instead of white)
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text("Game Settings",
                  style: TextStyle(color: Colors.white70)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("MAX SCORE",
                        style: TextStyle(
                            color: Colors.indigoAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: maxScoreCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Custom End Score",
                        labelStyle:
                            TextStyle(color: Colors.white54, fontSize: 13),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.indigoAccent)),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (val) {
                        int? parsed = int.tryParse(val);
                        if (parsed != null && parsed > 0) {
                          setStateDialog(() {
                            _maxScore = parsed;
                          });
                          setState(() {});
                          _saveState();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 4,
                      children: [11, 15, 21, 25, 30].map((score) {
                        final isSelected = _maxScore == score;
                        return ChoiceChip(
                          label: Text("$score",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70)),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              setStateDialog(() {
                                _maxScore = score;
                                maxScoreCtrl.text = "$score";
                              });
                              setState(() {});
                              _saveState();
                            }
                          },
                          backgroundColor: Colors.white10,
                          selectedColor:
                              Colors.indigoAccent.withValues(alpha: 0.4),
                        );
                      }).toList(),
                    ),
                    const Divider(color: Colors.white12, height: 32),
                    const Text("COUNTRY THEMES",
                        style: TextStyle(
                            color: Colors.indigoAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.grey[900],
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      value: countryThemes.keys.first,
                      items: countryThemes.keys.map((name) {
                        return DropdownMenuItem(
                          value: name,
                          child: Text(name,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null && countryThemes[val] != null) {
                          setStateDialog(() {
                            _colorA = countryThemes[val]![0];
                            _colorB = countryThemes[val]![1];
                          });
                          setState(() {});
                          _saveState();
                        }
                      },
                    ),
                    const Divider(color: Colors.white12, height: 32),
                    const Text("TEAM NAMES",
                        style: TextStyle(
                            color: Colors.indigoAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameAController,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              labelText: "TEAM A",
                              labelStyle: TextStyle(
                                  color: Colors.white54, fontSize: 12),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white24)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.indigoAccent)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _nameBController,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              labelText: "TEAM B",
                              labelStyle: TextStyle(
                                  color: Colors.white54, fontSize: 12),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white24)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.indigoAccent)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text("MANUAL COLORS",
                        style: TextStyle(
                            color: Colors.indigoAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_nameAController.text,
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 10)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: pickableColors.map((c) {
                                  return GestureDetector(
                                    onTap: () {
                                      setStateDialog(() => _colorA = c);
                                      setState(() {});
                                      _saveState();
                                    },
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: c,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: _colorA == c
                                                ? Colors.white
                                                : Colors.transparent,
                                            width: 2),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_nameBController.text,
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 10)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: pickableColors.map((c) {
                                  return GestureDetector(
                                    onTap: () {
                                      setStateDialog(() => _colorB = c);
                                      setState(() {});
                                      _saveState();
                                    },
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: c,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: _colorB == c
                                                ? Colors.white
                                                : Colors.transparent,
                                            width: 2),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("DONE",
                      style: TextStyle(
                          color: Colors.indigoAccent,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
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

          // Center Timer Area
          Positioned(
            top: 45,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatStartDate(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.3),
                      letterSpacing: 2,
                    ),
                  ),
                  GestureDetector(
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
                ],
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
                    icon: FontAwesomeIcons.forwardStep,
                    onPressed: _requestNextRound,
                    label: "Next Round",
                  ),
                  const SizedBox(width: 24),
                  _ControlCircle(
                    icon: FontAwesomeIcons.clockRotateLeft,
                    onPressed: _showHistoryPopup,
                    label: "History",
                  ),
                  const SizedBox(width: 24),
                  _ControlCircle(
                    icon: FontAwesomeIcons.gear,
                    onPressed: _showSettingsPopup,
                    label: "Settings",
                  ),
                  const SizedBox(width: 24),
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
      onTap: () => _incrementScore(team),
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
                          onPressed: () => _incrementScore(team),
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
