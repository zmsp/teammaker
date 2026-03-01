import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

// ---------------------------------------------------------------------------
// Top-level constants — allocated once, never recreated on dialog open
// ---------------------------------------------------------------------------

const _kCountryThemes = <String, List<Color>?>{
  'Manual / Custom': null,
  'USA (Navy/DeepRed)': [Color(0xFF001F3F), Color(0xFF8B0000)],
  'Bangladesh (DarkGreen/Crimson)': [Color(0xFF004030), Color(0xFFB22222)],
  'Mexico (ForestGreen/Maroon)': [Color(0xFF004D33), Color(0xFF800000)],
  'India (DeepOrange/DarkGreen)': [Color(0xFFD35400), Color(0xFF095A04)],
  'China (DarkRed/Gold)': [Color(0xFF8B0000), Color(0xFFB8860B)],
  'Philippines (Navy/Maroon)': [Color(0xFF000080), Color(0xFF800000)],
  'El Salvador (DarkBlue/Grey)': [Color(0xFF003366), Color(0xFF424242)],
  'Vietnam (DarkRed/Gold)': [Color(0xFF8B0000), Color(0xFFB8860B)],
  'Cuba (Navy/Maroon)': [Color(0xFF000080), Color(0xFF800000)],
  'Dominican Republic (Navy/Maroon)': [Color(0xFF001A33), Color(0xFF800000)],
  'Guatemala (DeepSkyBlue/Slate)': [Color(0xFF0074D9), Color(0xFF424242)],
  'South Korea (DarkGrey/Navy)': [Color(0xFF212121), Color(0xFF000080)],
  'Colombia (Gold/Navy)': [Color(0xFFB8860B), Color(0xFF000080)],
  'Honduras (Navy/Slate)': [Color(0xFF001F3F), Color(0xFF424242)],
  'Canada (Maroon/DarkGrey)': [Color(0xFF800000), Color(0xFF424242)],
  'Jamaica (DarkGreen/Gold)': [Color(0xFF004D00), Color(0xFFB8860B)],
  'Haiti (Navy/Maroon)': [Color(0xFF000080), Color(0xFF800000)],
  'UK (Navy/DeepRed)': [Color(0xFF001F3F), Color(0xFF8B0000)],
  'Venezuela (Gold/Navy)': [Color(0xFFB8860B), Color(0xFF000080)],
  'Brazil (Gold/DarkGreen)': [Color(0xFFB8860B), Color(0xFF004D00)],
  'Germany (Black/DarkRed)': [Color(0xFF000000), Color(0xFF8B0000)],
  'Russia (DarkGrey/Navy)': [Color(0xFF424242), Color(0xFF000080)],
  'Peru (Maroon/DarkGrey)': [Color(0xFF800000), Color(0xFF424242)],
  'Nigeria (DarkGreen/Grey)': [Color(0xFF004D00), Color(0xFF424242)],
  'Ukraine (Navy/Gold)': [Color(0xFF000080), Color(0xFFB8860B)],
  'Iran (DarkGreen/Maroon)': [Color(0xFF004D00), Color(0xFF800000)],
  'Pakistan (DarkGreen/Grey)': [Color(0xFF003300), Color(0xFF424242)],
  'Japan (DarkGrey/Maroon)': [Color(0xFF424242), Color(0xFF800000)],
  'France (Navy/Maroon)': [Color(0xFF000080), Color(0xFF800000)],
  'Italy (DarkGreen/Maroon)': [Color(0xFF004D00), Color(0xFF800000)],
  'Argentina (Navy/Slate)': [Color(0xFF0074D9), Color(0xFF424242)],
};

const _kPickableColors = <Color>[
  Color(0xFF0D47A1), // Darker Indigo
  Color(0xFFB71C1C), // Deep Red
  Color(0xFF1B5E20), // Dark Green
  Color(0xFFE65100), // Dark Orange
  Color(0xFF4A148C), // Deep Purple
  Color(0xFF004D40), // Dark Teal
  Color(0xFF212121), // Charcoal
  Color(0xFF455A64), // Blue Grey
  Color(0xFFF9A825), // Dark Yellow/Gold
  Color(0xFF424242), // Slate/Dark Grey
];

const _kMaxScorePresets = [11, 15, 21, 25, 30];

// ---------------------------------------------------------------------------
// Main screen widget
// ---------------------------------------------------------------------------

class TapScoreScreen extends StatefulWidget {
  final int? initialScoreA;
  final int? initialScoreB;
  final String? initialNameA;
  final String? initialNameB;

  final bool isTour;

  const TapScoreScreen({
    super.key,
    this.initialScoreA,
    this.initialScoreB,
    this.initialNameA,
    this.initialNameB,
    this.isTour = false,
  });

  @override
  State<TapScoreScreen> createState() => _TapScoreScreenState();
}

class _TapScoreScreenState extends State<TapScoreScreen> {
  final GlobalKey _keyScore = GlobalKey();
  final GlobalKey _keySettings = GlobalKey();

  // ── State ─────────────────────────────────────────────────────────────────
  int _teamAScore = 0;
  int _teamBScore = 0;
  int _maxScore = 25;
  int _elapsedSeconds = 0;
  DateTime? _startDate;
  bool _isRunning = false;

  int _roundCount = 1;
  List<String> _history = [];

  String _nameA = 'HOME';
  String _nameB = 'AWAY';

  Color _colorA = const Color(0xFF1A237E);
  Color _colorB = const Color(0xFFB71C1C);

  // ── Cached SharedPreferences ─────────────────────────────────────────────
  SharedPreferences? _prefs;

  // ── Timer ─────────────────────────────────────────────────────────────────
  Timer? _timer;

  // ── Name-save debounce ────────────────────────────────────────────────────
  Timer? _saveDebounce;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initPrefsAndLoad();
    if (widget.isTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowcaseView.get().startShowCase([_keyScore, _keySettings]);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _saveDebounce?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SharedPreferences helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _initPrefsAndLoad() async {
    // Cache the instance once — reused for every subsequent save
    _prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    _applyLoadedState();
  }

  void _applyLoadedState() {
    final prefs = _prefs!;
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

      // Auto-start on first open
      if (prefs.getInt('score_a') == null &&
          _startDate == null &&
          !_isRunning) {
        _startDate = DateTime.now();
        _isRunning = true;
      }

      _nameA = widget.initialNameA ?? (prefs.getString('name_a') ?? 'HOME');
      _nameB = widget.initialNameB ?? (prefs.getString('name_b') ?? 'AWAY');

      final colorAVal = prefs.getInt('color_a');
      if (colorAVal != null) _colorA = Color(colorAVal);
      final colorBVal = prefs.getInt('color_b');
      if (colorBVal != null) _colorB = Color(colorBVal);
    });

    _restartTimer();
  }

  /// Saves current state synchronously using the cached [_prefs] instance.
  void _saveState() {
    final prefs = _prefs;
    if (prefs == null) return; // Not yet initialised
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
    prefs.setString('name_a', _nameA);
    prefs.setString('name_b', _nameB);
    prefs.setInt('color_a', _colorA.toARGB32());
    prefs.setInt('color_b', _colorB.toARGB32());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Timer logic
  // ─────────────────────────────────────────────────────────────────────────

  void _restartTimer() {
    _timer?.cancel();
    if (_isRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {}); // Only _TimerDisplay rebuilds
      });
    }
  }

  int get _currentSeconds {
    if (!_isRunning || _startDate == null) return _elapsedSeconds;
    return _elapsedSeconds + DateTime.now().difference(_startDate!).inSeconds;
  }

  void _toggleTimer() {
    setState(() {
      if (_isRunning) {
        _elapsedSeconds = _currentSeconds;
        _startDate = null;
        _timer?.cancel();
      } else {
        _startDate = DateTime.now();
      }
      _isRunning = !_isRunning;
    });
    _restartTimer();
    _saveState();
  }

  void _resetTimer() {
    setState(() {
      _timer?.cancel();
      _elapsedSeconds = 0;
      _startDate = DateTime.now();
      _isRunning = true;
    });
    _restartTimer();
    _saveState();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Score operations
  // ─────────────────────────────────────────────────────────────────────────

  void _incrementScore(String team) {
    setState(() {
      if (team == 'A') {
        _teamAScore++;
        if (_teamAScore >= _maxScore) _handleMaxScoreReached('A');
      } else {
        _teamBScore++;
        if (_teamBScore >= _maxScore) _handleMaxScoreReached('B');
      }
    });
    _saveState();
  }

  void _decrementScore(String team) {
    setState(() {
      if (team == 'A') {
        if (_teamAScore > 0) _teamAScore--;
      } else {
        if (_teamBScore > 0) _teamBScore--;
      }
    });
    _saveState();
  }

  void _resetScores() {
    setState(() {
      _teamAScore = 0;
      _teamBScore = 0;
      _elapsedSeconds = 0;
      _startDate = DateTime.now();
      _isRunning = true;
    });
    _restartTimer();
    _saveState();
  }

  void _swapTeams() {
    setState(() {
      final tempScore = _teamAScore;
      _teamAScore = _teamBScore;
      _teamBScore = tempScore;

      final tempName = _nameA;
      _nameA = _nameB;
      _nameB = tempName;

      final tempColor = _colorA;
      _colorA = _colorB;
      _colorB = tempColor;
    });
    _saveState();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Round / history
  // ─────────────────────────────────────────────────────────────────────────

  void _recordHistoryEntry(String winnerId) {
    final winnerName = winnerId == 'A' ? _nameA : _nameB;
    final loserName = winnerId == 'A' ? _nameB : _nameA;
    final winnerScore = winnerId == 'A' ? _teamAScore : _teamBScore;
    final loserScore = winnerId == 'A' ? _teamBScore : _teamAScore;

    final now = DateTime.now();
    final h = now.hour;
    final timeStr =
        '${h > 12 ? h - 12 : (h == 0 ? 12 : h)}:${now.minute.toString().padLeft(2, '0')} ${h >= 12 ? 'PM' : 'AM'}';

    final durationSeconds = _currentSeconds;
    final durationStr = '${durationSeconds ~/ 60}m ${durationSeconds % 60}s';

    _history.add(
      'Round $_roundCount • $timeStr ($durationStr)\n'
      '🏆 $winnerName ($winnerScore)\n'
      '    $loserName ($loserScore)',
    );
    _roundCount++;
    _saveState();
  }

  void _handleMaxScoreReached(String winnerId) {
    _recordHistoryEntry(winnerId);
    if (_isRunning) _toggleTimer();

    final winnerName = winnerId == 'A' ? _nameA : _nameB;
    final loserName = winnerId == 'A' ? _nameB : _nameA;
    final winnerScore = winnerId == 'A' ? _teamAScore : _teamBScore;
    final loserScore = winnerId == 'A' ? _teamBScore : _teamAScore;

    showDialog(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Round Complete'),
          content: Text(
            '🏆 $winnerName reached the max score!\n\n$winnerName: $winnerScore\n$loserName: $loserScore',
            style: TextStyle(
                color: cs.onSurfaceVariant, fontSize: 16, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('KEEP PLAYING',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetScores();
              },
              child: Text(
                'NEW ROUND',
                style:
                    TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _requestNextRound() {
    if (_teamAScore == 0 && _teamBScore == 0 && _elapsedSeconds == 0) {
      _resetScores();
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Start New Round?'),
          content: Text(
            'This will record current scores to history and reset the game state.',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _recordHistoryEntry(_teamAScore >= _teamBScore ? 'A' : 'B');
                _resetScores();
              },
              child: Text(
                'START NEW',
                style: TextStyle(color: cs.error, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dialogs
  // ─────────────────────────────────────────────────────────────────────────

  void _showHistoryPopup() {
    // Reverse once here, not on every itemBuilder call
    final reversed = _history.reversed.toList(growable: false);

    showDialog(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text('Match History',
              style: TextStyle(color: cs.onSurfaceVariant)),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: reversed.isEmpty
                ? Center(
                    child: Text('No history yet.',
                        style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.5))))
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: reversed.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: cs.outlineVariant, height: 24),
                    itemBuilder: (_, i) => Text(
                      reversed[i],
                      style: TextStyle(color: cs.onSurface, height: 1.4),
                    ),
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
              child: Text('CLEAR', style: TextStyle(color: cs.error)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CLOSE',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4))),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsPopup() {
    final maxScoreCtrl = TextEditingController(text: _maxScore.toString());

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final cs = Theme.of(context).colorScheme;
          return AlertDialog(
            title: const Text('Game Settings'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Max Score ───────────────────────────────────────────
                  const _SectionLabel('MAX SCORE'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: maxScoreCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Custom End Score',
                      labelStyle: const TextStyle(fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null && parsed > 0) {
                        setStateDialog(() => _maxScore = parsed);
                        setState(() {});
                        _saveState();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _kMaxScorePresets.map((score) {
                      final isSelected = _maxScore == score;
                      return ChoiceChip(
                        label: Text('$score'),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) {
                            setStateDialog(() {
                              _maxScore = score;
                              maxScoreCtrl.text = '$score';
                            });
                            setState(() {});
                            _saveState();
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const Divider(height: 32),

                  // ── Country Themes ──────────────────────────────────────
                  const _SectionLabel('COUNTRY THEMES'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _kCountryThemes.keys.first,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: _kCountryThemes.keys
                        .map((name) => DropdownMenuItem(
                              value: name,
                              child: Text(name,
                                  style: const TextStyle(fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null && _kCountryThemes[val] != null) {
                        setStateDialog(() {
                          _colorA = _kCountryThemes[val]![0];
                          _colorB = _kCountryThemes[val]![1];
                        });
                        setState(() {});
                        _saveState();
                      }
                    },
                  ),

                  const Divider(height: 32),

                  // ── Team Names ──────────────────────────────────────────
                  const _SectionLabel('TEAM NAMES'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _NameField(
                          initialValue: _nameA,
                          label: 'HOME',
                          onChanged: (v) {
                            setStateDialog(() => _nameA = v);
                            setState(() {});
                            _debouncedSave();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NameField(
                          initialValue: _nameB,
                          label: 'AWAY',
                          onChanged: (v) {
                            setStateDialog(() => _nameB = v);
                            setState(() {});
                            _debouncedSave();
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Manual Colors ───────────────────────────────────────
                  const _SectionLabel('MANUAL COLORS'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ColorPicker(
                          label: _nameA,
                          selected: _colorA,
                          colors: _kPickableColors,
                          onPick: (c) {
                            setStateDialog(() => _colorA = c);
                            setState(() {});
                            _saveState();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ColorPicker(
                          label: _nameB,
                          selected: _colorB,
                          colors: _kPickableColors,
                          onPick: (c) {
                            setStateDialog(() => _colorB = c);
                            setState(() {});
                            _saveState();
                          },
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
                child: Text(
                  'DONE',
                  style:
                      TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Debounced save for name changes ───────────────────────────────────────
  void _debouncedSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), _saveState);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Formatting helpers
  // ─────────────────────────────────────────────────────────────────────────

  String _formatTime() {
    final t = _currentSeconds;
    return '${(t ~/ 60).toString().padLeft(2, '0')}:${(t % 60).toString().padLeft(2, '0')}';
  }

  String _formatStartDate() {
    if (_startDate == null && _elapsedSeconds == 0) return 'Not started';
    final effectiveStart = _isRunning
        ? (_startDate ?? DateTime.now())
        : DateTime.now().subtract(Duration(seconds: _elapsedSeconds));
    final h = effectiveStart.hour;
    final mins = effectiveStart.minute.toString().padLeft(2, '0');
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return 'STARTED: $h12:$mins $ampm';
  }

  void _backWithResult() {
    Navigator.pop(context, {
      'scoreA': _teamAScore,
      'scoreB': _teamBScore,
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // ── Team halves — each in a RepaintBoundary ───────────────────
          Row(
            children: [
              Expanded(
                child: Showcase(
                  key: _keyScore,
                  title: 'Score Area',
                  description:
                      'Tap anywhere on the team side to increase the score. Long press to decrease.',
                  child: RepaintBoundary(
                    child: _TeamHalf(
                      team: 'A',
                      score: _teamAScore,
                      color: _colorA,
                      name: _nameA,
                      onIncrement: () => _incrementScore('A'),
                      onDecrement: () => _decrementScore('A'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: RepaintBoundary(
                  child: _TeamHalf(
                    team: 'B',
                    score: _teamBScore,
                    color: _colorB,
                    name: _nameB,
                    onIncrement: () => _incrementScore('B'),
                    onDecrement: () => _decrementScore('B'),
                  ),
                ),
              ),
            ],
          ),

          // ── Back button ───────────────────────────────────────────────
          Positioned(
            top: 55,
            left: 15,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: cs.onSurface.withValues(alpha: 0.4),
                size: 18,
              ),
              onPressed: _backWithResult,
            ),
          ),

          // ── Timer display (isolated — rebuilds every second) ──────────
          Positioned(
            top: 45,
            left: 0,
            right: 0,
            child: Center(
              child: _TimerDisplay(
                startDateLabel: _formatStartDate(),
                timeLabel: _formatTime(),
                isRunning: _isRunning,
                onTap: _toggleTimer,
                onLongPress: _resetTimer,
              ),
            ),
          ),

          // ── Control bar ───────────────────────────────────────────────
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Showcase(
              key: _keySettings,
              title: 'Tool Controls',
              description:
                  'Manage rounds, view history, or change team colors and names here.',
              child: Opacity(
                opacity: 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ControlCircle(
                      icon: FontAwesomeIcons.forwardStep,
                      label: 'Next Round',
                      onPressed: _requestNextRound,
                    ),
                    const SizedBox(width: 24),
                    _ControlCircle(
                      icon: FontAwesomeIcons.clockRotateLeft,
                      label: 'History',
                      onPressed: _showHistoryPopup,
                    ),
                    const SizedBox(width: 24),
                    _ControlCircle(
                      icon: FontAwesomeIcons.gear,
                      label: 'Settings',
                      onPressed: _showSettingsPopup,
                    ),
                    const SizedBox(width: 24),
                    _ControlCircle(
                      icon: FontAwesomeIcons.rightLeft,
                      label: 'Swap',
                      onPressed: _swapTeams,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TeamHalf — StatelessWidget; only rebuilds when its own props change
// ---------------------------------------------------------------------------

class _TeamHalf extends StatelessWidget {
  final String team;
  final int score;
  final Color color;
  final String name;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _TeamHalf({
    required this.team,
    required this.score,
    required this.color,
    required this.name,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onIncrement,
      onLongPress: onDecrement,
      child: Container(
        color: color.withValues(alpha: 0.8),
        child: Stack(
          children: [
            // Team name — pinned top
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 52),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Score + hint + buttons — centred
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$score',
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
                    'TAP TO SCORE',
                    style: TextStyle(
                        color: Colors.white54, fontSize: 12, letterSpacing: 3),
                  ),
                  const SizedBox(height: 28),
                  Opacity(
                    opacity: 0.28,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ScoreSmallButton(
                            icon: Icons.remove, onPressed: onDecrement),
                        const SizedBox(width: 25),
                        _ScoreSmallButton(
                            icon: Icons.add, onPressed: onIncrement),
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

// ---------------------------------------------------------------------------
// _TimerDisplay — StatelessWidget; receives pre-formatted strings
// ---------------------------------------------------------------------------

class _TimerDisplay extends StatelessWidget {
  final String startDateLabel;
  final String timeLabel;
  final bool isRunning;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TimerDisplay({
    required this.startDateLabel,
    required this.timeLabel,
    required this.isRunning,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          startDateLabel,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            letterSpacing: 2,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Text(
            timeLabel,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: isRunning ? 0.9 : 0.5),
              fontFamily: 'monospace',
              letterSpacing: 3,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _NameField — uncontrolled text field that notifies parent via onChanged
// ---------------------------------------------------------------------------

class _NameField extends StatelessWidget {
  final String initialValue;
  final String label;
  final ValueChanged<String> onChanged;

  const _NameField({
    required this.initialValue,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      onChanged: onChanged,
    );
  }
}

// ---------------------------------------------------------------------------
// _ColorPicker — small circle swatch picker
// ---------------------------------------------------------------------------

class _ColorPicker extends StatelessWidget {
  final String label;
  final Color selected;
  final List<Color> colors;
  final ValueChanged<Color> onPick;

  const _ColorPicker({
    required this.label,
    required this.selected,
    required this.colors,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: colors.map((c) {
            return GestureDetector(
              onTap: () => onPick(c),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected == c ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _SectionLabel — reusable settings section header
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ScoreSmallButton
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// _ControlCircle
// ---------------------------------------------------------------------------

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
            style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
                fontSize: 10)),
      ],
    );
  }
}
