import 'dart:convert';
import 'dart:async';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:teammaker/theme/app_theme.dart';

import 'package:teammaker/help_screen.dart';
import 'package:teammaker/match_screen.dart';
import 'package:teammaker/settings_screen.dart';
import 'package:teammaker/add_players.dart';
import 'package:teammaker/model/data_model.dart';
import 'package:teammaker/model/player_entry.dart';
import 'package:teammaker/model/player_model.dart';
import 'package:teammaker/team_screen.dart';
import 'package:teammaker/algorithm/team_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teammaker/widgets/app_components.dart';
import 'package:teammaker/widgets/strategy_widgets.dart';
import 'package:teammaker/utils/team_utils.dart';
import 'package:teammaker/widgets/team_results_view.dart';
import 'package:teammaker/widgets/tapscore_widget.dart';
import 'package:teammaker/widgets/random_team_widget.dart';
import 'package:showcaseview/showcaseview.dart';

// ─── Available roles (built once) ─────────────────────────────────────────────
final _allRoles = SportPalette.values.expand((e) => e.roles).toSet().toList();

class PlutoExampleScreen extends StatefulWidget {
  final String? title;
  final String? topTitle;
  final List<Widget>? topContents;
  final List<Widget>? topButtons;
  final Widget? body;
  final ThemeController? themeController;

  const PlutoExampleScreen({
    super.key,
    this.title,
    this.topTitle,
    this.topContents,
    this.topButtons,
    this.body,
    this.themeController,
  });

  @override
  State<PlutoExampleScreen> createState() => _PlutoExampleScreenState();
}

enum Status { none, running, stopped, paused }

class _PlutoExampleScreenState extends State<PlutoExampleScreen> {
  final GlobalKey _key1 = GlobalKey(); // Header
  final GlobalKey _keyScore = GlobalKey(); // Score Keeper
  final GlobalKey _keyMatch = GlobalKey(); // Match Maker
  final GlobalKey _keyQueue = GlobalKey(); // Player Queue
  final GlobalKey _key2 = GlobalKey(); // Roster Section
  final GlobalKey _key3 = GlobalKey(); // Add Player
  final GlobalKey _key4 = GlobalKey(); // Edit Mode
  final GlobalKey _key5 = GlobalKey(); // Strategy
  final GlobalKey _key6 = GlobalKey(); // Generate
  final GlobalKey _key7 = GlobalKey(); // Bottom Nav

  SettingsData settingsData = SettingsData();
  bool _isEditable = false;
  Timer? _saveTimer;

  /// Cached SharedPreferences — obtained once, reused in every save call.
  SharedPreferences? _prefs;

  /// The single source of truth for all player data.
  final List<PlayerEntry> _players = [];

  // ─── Clipboard export ──────────────────────────────────────────────────────
  void exportToCsv() {
    final csv = StringBuffer('Name,Level,Gender,Team,Position\n');
    for (final p in _players) {
      csv.writeln('${p.name},${p.level},${p.gender},${p.team},${p.role}');
    }
    Clipboard.setData(ClipboardData(text: csv.toString()));
  }

  // ─── Debounced save ────────────────────────────────────────────────────────
  void _triggerSavePlayers() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), _savePlayers);
  }

  void _savePlayers() {
    if (_prefs == null) return;
    _prefs!.setString(
        'saved_players', jsonEncode(_players.map((p) => p.toJson()).toList()));
  }

  // ─── Load / save settings ──────────────────────────────────────────────────
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    await _loadSettings();
    await _loadPlayers();
    _startTour();
  }

  void _startTour() {
    if (_prefs!.getBool('tour_shown') != true) {
      _loadDemoData();
      _prefs!.setBool('tour_shown', true);
      _runHomePhase1();
    }
  }

  void _runHomePhase1() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowcaseView.get().startShowCase([
        _key1, // App Title
        _key2, // Roster Section
        _key5, // Strategy
        _key6, // Generate Button
        _keyScore, // Score Tool (Interactive)
      ]);
    });
  }

  void _loadDemoData() {
    if (_players.isNotEmpty) return;
    setState(() {
      _players.addAll([
        PlayerEntry(
            name: 'Alex R.',
            level: 5,
            gender: 'MALE',
            role: 'Setter',
            checked: true),
        PlayerEntry(
            name: 'Jordan M.',
            level: 5,
            gender: 'FEMALE',
            role: 'Outside',
            checked: true),
        PlayerEntry(
            name: 'Sam T.',
            level: 4,
            gender: 'X',
            role: 'Libero',
            checked: true),
        PlayerEntry(
            name: 'Chris P.',
            level: 3,
            gender: 'MALE',
            role: 'Middle',
            checked: true),
        PlayerEntry(
            name: 'Taylor S.',
            level: 4,
            gender: 'FEMALE',
            role: 'Opposite',
            checked: true),
        PlayerEntry(
            name: 'Pat B.',
            level: 2,
            gender: 'FEMALE',
            role: 'Any',
            checked: true),
        PlayerEntry(
            name: 'Casey K.',
            level: 3,
            gender: 'MALE',
            role: 'Setter',
            checked: true),
        PlayerEntry(
            name: 'Skyler J.',
            level: 5,
            gender: 'X',
            role: 'Outside',
            checked: true),
        PlayerEntry(
            name: 'Morgan L.',
            level: 4,
            gender: 'FEMALE',
            role: 'Middle',
            checked: true),
        PlayerEntry(
            name: 'Riley H.',
            level: 3,
            gender: 'MALE',
            role: 'Libero',
            checked: true),
        PlayerEntry(
            name: 'Quinn W.',
            level: 1,
            gender: 'FEMALE',
            role: 'Any',
            checked: true),
        PlayerEntry(
            name: 'Jamie V.',
            level: 4,
            gender: 'MALE',
            role: 'Opposite',
            checked: true),
        PlayerEntry(
            name: 'Reese F.',
            level: 2,
            gender: 'X',
            role: 'Any',
            checked: true),
        PlayerEntry(
            name: 'Dakota G.',
            level: 5,
            gender: 'FEMALE',
            role: 'Outside',
            checked: true),
        PlayerEntry(
            name: 'Emery N.',
            level: 3,
            gender: 'MALE',
            role: 'Middle',
            checked: true),
        PlayerEntry(
            name: 'Blake D.',
            level: 4,
            gender: 'FEMALE',
            role: 'Setter',
            checked: false),
        PlayerEntry(
            name: 'Avery Z.',
            level: 2,
            gender: 'X',
            role: 'Any',
            checked: false),
        PlayerEntry(
            name: 'Parker Y.',
            level: 5,
            gender: 'MALE',
            role: 'Outside',
            checked: true),
        PlayerEntry(
            name: 'Finley Q.',
            level: 3,
            gender: 'FEMALE',
            role: 'Middle',
            checked: true),
        PlayerEntry(
            name: 'Sage C.',
            level: 4,
            gender: 'MALE',
            role: 'Opposite',
            checked: true),
      ]);
    });
    _savePlayers();
  }

  Future<void> _loadSettings() async {
    final prefs = _prefs!;
    if (!mounted) return;
    setState(() {
      settingsData.teamCount = prefs.getInt('teamCount') ?? 2;
      settingsData.division = prefs.getInt('division') ?? 2;
      settingsData.proportion = prefs.getInt('proportion') ?? 6;
      settingsData.gameVenues = prefs.getInt('gameVenues') ?? 1;
      settingsData.gameRounds = prefs.getInt('gameRounds') ?? 2;
      settingsData.preferExtraTeam = prefs.getBool('preferExtraTeam') ?? false;
      final savedOption =
          prefs.getString('genOption') ?? GenOption.evenGender.toString();
      settingsData.o = GenOption.values.firstWhere(
          (e) => e.toString() == savedOption,
          orElse: () => GenOption.evenGender);
    });
  }

  Future<void> _loadPlayers() async {
    final prefs = _prefs!;
    final saved = prefs.getString('saved_players');
    if (saved == null) return;
    final jsonList = jsonDecode(saved) as List<dynamic>;
    final loaded = jsonList
        .map((e) => PlayerEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    if (loaded.isEmpty) return;
    if (!mounted) return;
    setState(() {
      _players.clear();
      _players.addAll(loaded);
    });
  }

  void _saveSettings() {
    if (_prefs == null) return;
    _prefs!.setInt('teamCount', settingsData.teamCount);
    _prefs!.setInt('division', settingsData.division);
    _prefs!.setInt('proportion', settingsData.proportion);
    _prefs!.setInt('gameVenues', settingsData.gameVenues);
    _prefs!.setInt('gameRounds', settingsData.gameRounds);
    _prefs!.setBool('preferExtraTeam', settingsData.preferExtraTeam);
    _prefs!.setString('genOption', settingsData.o.toString());
  }

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  // ─── Add players ───────────────────────────────────────────────────────────
  void addPlayers(List<PlayerModel> players) {
    setState(() {
      for (final p in players) {
        _players.add(PlayerEntry(
          name: p.name,
          level: p.level,
          gender: p.gender,
          team: p.team.isEmpty ? 'No team' : p.team,
          role: p.role,
          checked: true,
        ));
      }
    });
    _triggerSavePlayers();
  }

  // ─── Navigate to team view ─────────────────────────────────────────────────
  void _navigateToTeam() {
    final checkedPlayers = _players.where((p) => p.checked).toList();
    checkedPlayers.sort((a, b) => a.team.compareTo(b.team));

    final Map<String, List<PlayerEntry>> teamsRows = {};
    final Map<String, double> teamsTotalScore = {};

    for (final p in checkedPlayers) {
      final team = p.team;
      teamsTotalScore.update(
        team,
        (v) => v + p.level.toDouble(),
        ifAbsent: () => p.level.toDouble(),
      );
      teamsRows.putIfAbsent(team, () => []).add(p);
    }

    final teamsListData = <ListItem>[];
    for (final teamName in teamsRows.keys) {
      if (teamName == 'No team') continue;
      final count = teamsRows[teamName]!.length;
      final total = teamsTotalScore[teamName]!;
      final avg = (total / count).toStringAsFixed(2);
      teamsListData.add(HeadingItem('TEAM#: $teamName',
          '$count players · avg level $avg · combined $total'));
      for (final row in teamsRows[teamName]!) {
        teamsListData.add(MessageItem(row));
      }
    }

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TeamList(
                  items: teamsListData,
                  settingsData: settingsData,
                  sport: widget.themeController?.palette,
                  onEditPlayer: (player) => _editPlayer(context, player),
                )));
  }

  // ─── Generate teams ────────────────────────────────────────────────────────
  void generateTeams() {
    // Reset all player team assignments first
    for (final p in _players) {
      p.team = 'No team';
    }

    final checkedPlayers = _players.where((p) => p.checked).toList();

    if (settingsData.o == GenOption.evenGender) {
      final playerNum = checkedPlayers.length;
      if (settingsData.preferExtraTeam) {
        settingsData.teamCount = (playerNum / settingsData.proportion).ceil();
      } else {
        settingsData.teamCount = (playerNum / settingsData.proportion).floor();
      }
      if (settingsData.teamCount == 0) settingsData.teamCount = 1;
    }

    final teamsList = TeamGenerator.generateTeams(
      checkedPlayers,
      settingsData,
      sport: widget.themeController?.palette,
    );

    // Apply team assignments back to the player list
    setState(() {
      teamsList.forEach((teamName, teamPlayers) {
        for (final p in teamPlayers) {
          p.team = teamName;
        }
      });
    });

    _triggerSavePlayers();
    _navigateToTeam();
  }

  // ─── Premium Player Editing BottomSheet ───────────────────────────────────
  void _editPlayer(BuildContext context, PlayerEntry player) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String editName = player.name;
    int editLevel = player.level;
    String editGender = player.gender;
    String editRole = player.role;
    String editTeam = player.team;

    // Determine sport for roles (try to match existing role to a sport palette)
    SportPalette editSport =
        widget.themeController?.palette ?? SportPalette.volleyball;
    for (var s in SportPalette.values) {
      if (s.roles.contains(player.role) && player.role != 'Any') {
        editSport = s;
        break;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text("Edit Player",
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                controller: TextEditingController(text: editName),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Player Name",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) => editName = v.trim(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Skill Level", style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        SegmentedButton<int>(
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                          ),
                          segments: List.generate(5, (i) => i + 1)
                              .map((l) =>
                                  ButtonSegment(value: l, label: Text("$l")))
                              .toList(),
                          selected: {editLevel},
                          onSelectionChanged: (val) =>
                              setLocal(() => editLevel = val.first),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text("Gender", style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: "MALE",
                      label: Text("M"),
                      icon: Icon(Icons.male, size: 16)),
                  ButtonSegment(
                      value: "FEMALE",
                      label: Text("F"),
                      icon: Icon(Icons.female, size: 16)),
                  ButtonSegment(
                      value: "X",
                      label: Text("X"),
                      icon: Icon(Icons.horizontal_rule, size: 16)),
                ],
                selected: {editGender},
                onSelectionChanged: (val) =>
                    setLocal(() => editGender = val.first),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Sport / Roles",
                            style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<SportPalette>(
                          initialValue: editSport,
                          isDense: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(editSport.icon, size: 18),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: SportPalette.values.map((s) {
                            return DropdownMenuItem(
                                value: s,
                                child: Text(s.label,
                                    style: const TextStyle(fontSize: 13)));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setLocal(() {
                                editSport = val;
                                editRole = "Any";
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Team Assignment",
                            style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        TextField(
                          controller: TextEditingController(
                              text: editTeam == 'No team' ? '' : editTeam),
                          decoration: InputDecoration(
                            labelText: "Team (e.g. 1, 2)",
                            prefixIcon: const Icon(Icons.group, size: 18),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onChanged: (v) => editTeam =
                              v.trim().isEmpty ? 'No team' : v.trim(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 0,
                children: editSport.roles.map((r) {
                  final isSelected = editRole == r;
                  return ChoiceChip(
                    label: Text(r, style: const TextStyle(fontSize: 12)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setLocal(() => editRole = r);
                    },
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text("Save Player Details"),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() {
                    player.name = editName;
                    player.level = editLevel;
                    player.gender = editGender;
                    player.role = editRole;
                    player.team = editTeam;
                  });
                  _triggerSavePlayers();
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Add row dialog (quick-add via text) ───────────────────────────────────
  void _showBulkAddDialog(BuildContext context) {
    final ctrl = TextEditingController(text: 'John,3,M\nJane,4,F');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bulk Add Players'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('One per line: Name,Level,Gender  (e.g. Alice,4,F)'),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Alice,4,F\nBob,3,M',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final lines = ctrl.text.split('\n');
              setState(() {
                for (final line in lines) {
                  final parts = line.trim().split(',');
                  if (parts.isEmpty || parts[0].trim().isEmpty) continue;
                  final name = parts[0].trim();
                  final level = parts.length > 1
                      ? (int.tryParse(parts[1].trim()) ?? 3)
                      : 3;
                  String gender = 'MALE';
                  if (parts.length > 2) {
                    final g = parts[2].trim().toUpperCase();
                    if (g.startsWith('F')) {
                      gender = 'FEMALE';
                    } else if (g == 'X') {
                      gender = 'X';
                    }
                  }
                  final team = parts.length > 3 ? parts[3].trim() : 'No team';
                  final role = parts.length > 4 ? parts[4].trim() : 'Any';
                  _players.add(PlayerEntry(
                    name: name,
                    level: level,
                    gender: gender,
                    team: team.isEmpty ? 'No team' : team,
                    role: role.isEmpty ? 'Any' : role,
                    checked: true,
                  ));
                }
              });
              _triggerSavePlayers();
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final checkedCount = _players.where((p) => p.checked).length;
    final hasResults =
        _players.any((p) => TeamUtils.normalizeTeamName(p.team) != 'No team');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Maker Buddy',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Team Picker',
            icon: const FaIcon(FontAwesomeIcons.dice, size: 20),
            onPressed: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          RandomTeamScreen(initialTotal: 6)));
            },
          ),
          IconButton(
            tooltip: 'Export to CSV',
            icon: const FaIcon(FontAwesomeIcons.fileExport, size: 20),
            onPressed: () {
              exportToCsv();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Data Copied to Clipboard!'),
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
          IconButton(
            tooltip: 'Appearance',
            icon: const FaIcon(FontAwesomeIcons.palette, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    settingsData,
                    themeController: widget.themeController,
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Get help',
            icon: const FaIcon(FontAwesomeIcons.circleQuestion, size: 20),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HelpExample(onRestartTour: _startTour)));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RepaintBoundary(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          children: [
            // ── Quick Tools ────────────────────────────────────────────────
            FadeSlideIn(
              delay: Duration.zero,
              child: Showcase(
                key: _key1,
                title: 'Quick Tools',
                description:
                    'Access the Score Keeper, Match Maker, and Player Queue instantly.',
                child: SectionHeader(
                    title: 'QUICK TOOLS',
                    icon: FontAwesomeIcons.bolt,
                    color: colorScheme.primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Showcase(
                      key: _keyScore,
                      title: 'Score Keeper',
                      description:
                          'Tap to see the Pro Scoreboard in action! (Click to enter)',
                      onTargetClick: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const TapScoreScreen(isTour: true)));
                        // When returning, highlight the next tool
                        ShowcaseView.get().startShowCase([_keyMatch]);
                      },
                      disposeOnTap: true,
                      child: QuickToolCard(
                        title: 'SCORE KEEPER',
                        icon: Theme.of(context)
                                .extension<SportIconExtension>()
                                ?.icon ??
                            Icons.sports,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const TapScoreScreen()));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Showcase(
                      key: _keyMatch,
                      title: 'Match Maker',
                      description:
                          'Tap to see rotation and round scheduling! (Click to enter)',
                      onTargetClick: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MatchScreen(settingsData, isTour: true)));
                        ShowcaseView.get().startShowCase([_keyQueue]);
                      },
                      disposeOnTap: true,
                      child: QuickToolCard(
                        title: 'MATCH MAKER',
                        icon: FontAwesomeIcons.trophy,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MatchScreen(settingsData)));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Showcase(
                      key: _keyQueue,
                      title: 'Player Queue',
                      description:
                          'Tap to see the digital sequence revealing system! (Click to enter)',
                      onTargetClick: () async {
                        await Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (context, anim, sec) =>
                                    const RandomTeamScreen(
                                        initialTotal: 6, isTour: true)));
                        ShowcaseView.get().startShowCase([_key7]);
                      },
                      disposeOnTap: true,
                      child: QuickToolCard(
                        title: 'PLAYER QUEUE',
                        icon: FontAwesomeIcons.dice,
                        onTap: () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                  pageBuilder: (context, anim, sec) =>
                                      const RandomTeamScreen(initialTotal: 6)));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── 1. Player Roster ───────────────────────────────────────────
            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: Showcase(
                key: _key2,
                title: 'Player Roster',
                description:
                    'Manage your players here. Check the boxes for those present today.',
                child: SectionHeader(
                    title: '1. PLAYER ROSTER',
                    icon: FontAwesomeIcons.users,
                    color: colorScheme.primary),
              ),
            ),
            Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ExpansionTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                childrenPadding: EdgeInsets.zero,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
                initiallyExpanded: false,
                backgroundColor: colorScheme.surface,
                collapsedBackgroundColor: colorScheme.surface,
                leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child:
                        Icon(Icons.people_outline, color: colorScheme.primary)),
                title: const Text('Manage Players',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${_players.length} Players listed',
                    style: const TextStyle(color: Color(0xFF8A99A8))),
                children: [
                  // ── Toolbar ──────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      border: Border(
                          bottom:
                              BorderSide(color: colorScheme.outlineVariant)),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Showcase(
                            key: _key3,
                            title: 'Add Players',
                            description:
                                'Add players one by one or import them in bulk.',
                            child: GridHeaderButton(
                              onPressed: () async {
                                final List<PlayerModel>? players =
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddPlayersScreen()));
                                if (players != null) addPlayers(players);
                              },
                              icon: Icons.group_add,
                              label: 'Quick Add',
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GridHeaderButton(
                            onPressed: () {
                              setState(() {
                                _players.removeWhere((p) => p.checked);
                              });
                              _triggerSavePlayers();
                            },
                            icon: Icons.delete_sweep,
                            label: 'Clear Selected',
                            color: colorScheme.error,
                          ),
                          const SizedBox(width: 6),
                          GridHeaderButton(
                            onPressed: () => _showBulkAddDialog(context),
                            icon: Icons.format_list_bulleted_add,
                            label: 'Bulk Add',
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 6),
                          GridHeaderButton(
                            onPressed: () {
                              setState(() {
                                _players.add(PlayerEntry(checked: true));
                              });
                              _triggerSavePlayers();
                            },
                            icon: Icons.person_add,
                            label: 'Add Row',
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 6),
                          Showcase(
                            key: _key4,
                            title: 'Edit Mode',
                            description:
                                'Toggle this to quickly edit names and levels directly in the table.',
                            child: GridHeaderButton(
                              onPressed: () {
                                setState(() => _isEditable = !_isEditable);
                              },
                              icon: _isEditable ? Icons.edit_off : Icons.edit,
                              label: _isEditable ? 'Lock' : 'Edit',
                              color: _isEditable
                                  ? colorScheme.tertiary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 6),

                        ],
                      ),
                    ),
                  ),
                  // ── DataTable2 ────────────────────────────────────────────
                  RepaintBoundary(
                    child: _PlayerDataTable(
                      players: _players,
                      allRoles: _allRoles,
                      isEditable: _isEditable,
                      colorScheme: colorScheme,
                      onEdit: (p) => _editPlayer(context, p),
                      onChanged: () {
                        setState(() {});
                        _triggerSavePlayers();
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── 2. Balance Strategy ────────────────────────────────────────
            FadeSlideIn(
              delay: const Duration(milliseconds: 160),
              child: Showcase(
                key: _key5,
                title: 'Balance Strategy',
                description:
                    'Select how you want to split teams: by Skill, Gender, or Randomly.',
                child: SectionHeader(
                    title: '2. BALANCE STRATEGY',
                    icon: FontAwesomeIcons.gears,
                    color: colorScheme.primary),
              ),
            ),
            Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ExpansionTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                childrenPadding: EdgeInsets.zero,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
                initiallyExpanded: false,
                backgroundColor: colorScheme.surface,
                collapsedBackgroundColor: colorScheme.surface,
                leading: CircleAvatar(
                    backgroundColor: colorScheme.secondaryContainer,
                    child:
                        Icon(Icons.auto_awesome, color: colorScheme.secondary)),
                title: const Text('Team Splitting Rules',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Mode: ${settingsData.o.toString().split('.').last.replaceAll('_', ' ').toUpperCase()} • $checkedCount Players Selected',
                  style: TextStyle(
                      fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
                children: [
                  _StrategySection(
                    settingsData: settingsData,
                    onStrategyChanged: (v) {
                      setState(() {
                        settingsData.o = v ?? settingsData.o;
                        _saveSettings();
                      });
                    },
                    onSettingsChanged: () {
                      setState(() => _saveSettings());
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Showcase(
                      key: _key6,
                      title: 'Generate Teams',
                      description:
                          'Hit this to create fair matches! Results will appear below.',
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: generateTeams,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Theme.of(context)
                                        .extension<SportIconExtension>()
                                        ?.icon ??
                                    Icons.sports,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'GENERATE TEAMS',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.flash_on, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 3. Results (conditional) ───────────────────────────────────
            if (hasResults) ...[
              FadeSlideIn(
                delay: Duration.zero,
                child: SectionHeader(
                    title: '3. RESULTS',
                    icon: FontAwesomeIcons.trophy,
                    color: colorScheme.primary),
              ),
              Card(
                elevation: 4,
                shadowColor: colorScheme.tertiary.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                      color: colorScheme.tertiary.withValues(alpha: 0.3)),
                ),
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ExpansionTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  childrenPadding: EdgeInsets.zero,
                  tilePadding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 0.0),
                  initiallyExpanded: true,
                  leading: CircleAvatar(
                      backgroundColor: colorScheme.tertiaryContainer,
                      child: Icon(Icons.groups, color: colorScheme.tertiary)),
                  title: const Text('Active Teams',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    TeamResultsView(
                      players: _players,
                      onEditPlayer: (p) => _editPlayer(context, p),
                      onChanged: () {
                        setState(() {});
                        _triggerSavePlayers();
                      },
                    )
                  ],
                ),
              ),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  childrenPadding: EdgeInsets.zero,
                  tilePadding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 0.0),
                  initiallyExpanded: false,
                  leading: CircleAvatar(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      child:
                          Icon(Icons.map, color: colorScheme.onSurfaceVariant)),
                  title: const Text('Player/Team Directory',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  children: [PlayerTeamDirectoryView(players: _players)],
                ),
              ),
            ],

            // ── Unassigned list ────────────────────────────────────────────
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ExpansionTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                childrenPadding: EdgeInsets.zero,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
                initiallyExpanded: false,
                leading: CircleAvatar(
                    backgroundColor:
                        colorScheme.secondaryContainer.withValues(alpha: 0.5),
                    child:
                        Icon(Icons.person_off, color: colorScheme.secondary)),
                title: const Text('Unassigned List',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  UnassignedPlayersView(
                    players: _players,
                    onChanged: () {
                      setState(() {});
                      _triggerSavePlayers();
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Showcase(
        key: _key7,
        title: 'Quick Access',
        description:
            'Navigate to Teams history, Match Maker, or Scoreboard any time.',
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BottomNavButton(
                    onPressed: () async {
                      final List<PlayerModel>? players = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddPlayersScreen()));
                      if (players != null) addPlayers(players);
                    },
                    icon: FontAwesomeIcons.userPlus,
                    label: 'Add',
                  ),
                  BottomNavButton(
                    onPressed: _navigateToTeam,
                    icon: FontAwesomeIcons.usersViewfinder,
                    label: 'Teams',
                  ),
                  BottomNavButton(
                    onPressed: () {
                      final activeTeams = _players
                          .where((p) => p.checked)
                          .map((p) => p.team)
                          .where((t) => t != 'No team' && t != 'None')
                          .toSet()
                          .length;

                      if (activeTeams >= 2) {
                        settingsData.teamCount = activeTeams;
                      }

                      settingsData.gameVenues = 1;
                      settingsData.gameRounds = settingsData.teamCount.isOdd
                          ? settingsData.teamCount
                          : (settingsData.teamCount - 1).clamp(1, 99);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MatchScreen(settingsData)));
                    },
                    icon: FontAwesomeIcons.trophy,
                    label: 'Match',
                  ),
                  BottomNavButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TapScoreScreen()));
                    },
                    icon: FontAwesomeIcons.stopwatch20,
                    label: 'Score',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Strategy section — extracted to avoid rebuilding the whole tree when
// the strategy radio changes.
// ─────────────────────────────────────────────────────────────────────────────
class _StrategySection extends StatelessWidget {
  final SettingsData settingsData;
  final ValueChanged<GenOption?> onStrategyChanged;
  final VoidCallback onSettingsChanged;

  const _StrategySection({
    required this.settingsData,
    required this.onStrategyChanged,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioGroup<GenOption>(
      groupValue: settingsData.o,
      onChanged: onStrategyChanged,
      child: Column(
        children: [
          StrategyOption(
            option: GenOption.evenGender,
            title: 'Fair Mix (Best)',
            subtitle:
                'Mix players by gender and skill correctly. Grows teams naturally (${settingsData.proportion}/team).',
            icon: Icons.wc,
            isSelected: settingsData.o == GenOption.evenGender,
            configWidget: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Players per team',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                  ),
                  initialValue: settingsData.proportion.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    settingsData.proportion = int.tryParse(v) ?? 6;
                    onSettingsChanged();
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Add extra team for leftovers',
                      style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                      settingsData.preferExtraTeam
                          ? 'Ex: 13 players -> 3 smaller teams'
                          : 'Ex: 13 players -> 2 larger teams',
                      style: const TextStyle(fontSize: 11)),
                  value: settingsData.preferExtraTeam,
                  onChanged: (bool value) {
                    settingsData.preferExtraTeam = value;
                    onSettingsChanged();
                  },
                ),
              ],
            ),
          ),
          StrategyOption(
            option: GenOption.distribute,
            title: 'Skill Balance',
            subtitle: 'Spread top players across teams fairly.',
            icon: Icons.balance,
            isSelected: settingsData.o == GenOption.distribute,
            configWidget: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Total Teams',
                prefixIcon: Icon(Icons.grid_view),
                border: OutlineInputBorder(),
              ),
              initialValue: settingsData.teamCount.toString(),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                settingsData.teamCount = int.tryParse(v) ?? 2;
                onSettingsChanged();
              },
            ),
          ),
          StrategyOption(
            option: GenOption.division,
            title: 'Ranked Groups',
            subtitle: 'Put strong players together and new players together.',
            icon: Icons.military_tech,
            isSelected: settingsData.o == GenOption.division,
            configWidget: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Number of Groups',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: settingsData.division.toString(),
                  onChanged: (v) {
                    settingsData.division = int.tryParse(v) ?? 2;
                    onSettingsChanged();
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Total Teams',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: settingsData.teamCount.toString(),
                  onChanged: (v) {
                    settingsData.teamCount = int.tryParse(v) ?? 2;
                    onSettingsChanged();
                  },
                ),
              ],
            ),
          ),
          StrategyOption(
            option: GenOption.random,
            title: 'Random',
            subtitle: 'Mix players with no rules.',
            icon: Icons.shuffle,
            isSelected: settingsData.o == GenOption.random,
            configWidget: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Total Teams',
                prefixIcon: Icon(Icons.grid_view),
                border: OutlineInputBorder(),
              ),
              initialValue: settingsData.teamCount.toString(),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                settingsData.teamCount = int.tryParse(v) ?? 2;
                onSettingsChanged();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Player DataTable2 — lightweight replacement for PlutoGrid
// ─────────────────────────────────────────────────────────────────────────────
class _PlayerDataTable extends StatelessWidget {
  final List<PlayerEntry> players;
  final List<String> allRoles;
  final bool isEditable;
  final ColorScheme colorScheme;
  final void Function(PlayerEntry) onEdit;
  final VoidCallback onChanged;

  const _PlayerDataTable({
    required this.players,
    required this.allRoles,
    required this.isEditable,
    required this.colorScheme,
    required this.onEdit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Use SizedBox with a sensible max-height so the list can scroll
    return SizedBox(
      height:
          (players.isEmpty ? 120 : (players.length * 52.0 + 56).clamp(120, 420))
              .toDouble(),
      child: DataTable2(
        columnSpacing: 8,
        horizontalMargin: 10,
        minWidth: 500,
        headingRowHeight: 36,
        dataRowHeight: 48,
        showCheckboxColumn: true,
        onSelectAll: (val) {
          if (val != null) {
            for (var p in players) {
              p.checked = val;
            }
            onChanged();
          }
        },
        headingRowColor: WidgetStateProperty.all(
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
        border: TableBorder(
          horizontalInside:
              BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
        columns: const [
          DataColumn2(label: Text('Name'), size: ColumnSize.L),
          DataColumn2(label: Text('Lvl'), fixedWidth: 52),
          DataColumn2(label: Text('Gender'), fixedWidth: 72),
          DataColumn2(label: Text('Position'), size: ColumnSize.M),
          DataColumn2(label: Text('Team'), fixedWidth: 70),
          DataColumn2(label: Text(''), fixedWidth: 44),
        ],
        rows: [
          for (int i = 0; i < players.length; i++)
            _buildRow(context, players[i], i),
        ],
      ),
    );
  }

  DataRow2 _buildRow(BuildContext context, PlayerEntry p, int index) {
    final isFemale = p.gender.toUpperCase().startsWith('F');
    final isChecked = p.checked;

    return DataRow2(
      selected: p.checked,
      onSelectChanged: (val) {
        if (val != null) {
          p.checked = val;
          onChanged();
        }
      },
      color: WidgetStateProperty.resolveWith((states) {
        if (!isChecked) {
          return colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
        }
        return index % 2 == 0
            ? Colors.transparent
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04);
      }),
      cells: [
        // ── Name ──────────────────────────────────────────────────────────
        DataCell(
          isEditable
              ? _InlineTextField(
                  value: p.name,
                  hint: 'Player name',
                  onChanged: (v) {
                    p.name = v;
                    onChanged();
                  },
                )
              : Text(p.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  overflow: TextOverflow.ellipsis),
          onTap: isEditable ? null : () => onEdit(p),
        ),
        // ── Level ─────────────────────────────────────────────────────────
        DataCell(
          isEditable
              ? _LevelBadge(level: p.level, color: colorScheme.primary)
              : _LevelBadge(level: p.level, color: colorScheme.primary),
        ),
        // ── Gender ────────────────────────────────────────────────────────
        DataCell(
          isEditable
              ? _GenderDropdown(
                  value: p.gender,
                  onChanged: (v) {
                    p.gender = v ?? p.gender;
                    onChanged();
                  },
                )
              : Text(
                  isFemale ? '♀' : '♂',
                  style: TextStyle(
                    fontSize: 16,
                    color: isFemale ? Colors.pink : Colors.blue,
                  ),
                ),
        ),
        // ── Position ──────────────────────────────────────────────────────
        DataCell(
          isEditable
              ? _RoleDropdown(
                  value: p.role,
                  allRoles: allRoles,
                  onChanged: (v) {
                    p.role = v ?? p.role;
                    onChanged();
                  },
                )
              : Text(p.role,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF8A99A8)),
                  overflow: TextOverflow.ellipsis),
        ),
        // ── Team ──────────────────────────────────────────────────────────
        DataCell(
          Text(
            TeamUtils.normalizeTeamName(p.team) == 'No team' ? '-' : p.team,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: TeamUtils.normalizeTeamName(p.team) == 'No team'
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.primary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // ── Edit button ───────────────────────────────────────────────────
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit_note, size: 18),
            color: colorScheme.onSurfaceVariant,
            onPressed: () => onEdit(p),
            tooltip: 'Edit',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }
}

// ─── Inline widgets for edit mode ────────────────────────────────────────────

class _InlineTextField extends StatefulWidget {
  final String value;
  final String hint;
  final ValueChanged<String> onChanged;

  const _InlineTextField(
      {required this.value, required this.hint, required this.onChanged});

  @override
  State<_InlineTextField> createState() => _InlineTextFieldState();
}

class _InlineTextFieldState extends State<_InlineTextField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        border: InputBorder.none,
        hintText: widget.hint,
      ),
      onChanged: widget.onChanged,
    );
  }
}

class _LevelDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int?> onChanged;
  const _LevelDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => DropdownButton<int>(
        value: value.clamp(1, 5),
        isDense: true,
        underline: const SizedBox(),
        items: List.generate(5, (i) => i + 1)
            .map((l) => DropdownMenuItem(value: l, child: Text('$l')))
            .toList(),
        onChanged: onChanged,
      );
}

class _GenderDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _GenderDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => DropdownButton<String>(
        value: ['MALE', 'FEMALE', 'X'].contains(value) ? value : 'MALE',
        isDense: true,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'MALE', child: Text('M')),
          DropdownMenuItem(value: 'FEMALE', child: Text('F')),
          DropdownMenuItem(value: 'X', child: Text('X')),
        ],
        onChanged: onChanged,
      );
}

class _RoleDropdown extends StatelessWidget {
  final String value;
  final List<String> allRoles;
  final ValueChanged<String?> onChanged;
  const _RoleDropdown(
      {required this.value, required this.allRoles, required this.onChanged});

  @override
  Widget build(BuildContext context) => DropdownButton<String>(
        value: allRoles.contains(value) ? value : 'Any',
        isDense: true,
        underline: const SizedBox(),
        items: allRoles
            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
            .toList(),
        onChanged: onChanged,
      );
}

class _LevelBadge extends StatelessWidget {
  final int level;
  final Color color;
  const _LevelBadge({required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            level.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
