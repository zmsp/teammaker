import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teammaker/model/data_model.dart';
import 'package:teammaker/model/player_model.dart';
import 'package:teammaker/widget/match.dart';
import 'package:showcaseview/showcaseview.dart';

class MatchScreen extends StatefulWidget {
  final SettingsData settingsData;
  final bool isTour;

  const MatchScreen(this.settingsData, {super.key, this.isTour = false});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  SettingsData get settingsData => widget.settingsData;
  List<Round> rounds = [];
  List<PlayerModel> players = [];

  final GlobalKey _keySettings = GlobalKey();
  final GlobalKey _keyGenerate = GlobalKey();

  Future<void> _saveRounds() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(rounds.map((r) => r.toJson()).toList());
    await prefs.setString('saved_rounds', encoded);
  }

  Future<void> _loadRounds() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString('saved_rounds');
    if (encoded != null && encoded.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(encoded);
        setState(() {
          rounds = decoded.map((r) => Round.fromJson(r)).toList();
        });
      } catch (e) {
        debugPrint("Error loading rounds: $e");
      }
    }
  }

  void _copyResults() {
    if (rounds.isEmpty) return;
    String buffer = "🏆 MATCH RESULTS 🏆\n\n";
    for (var round in rounds) {
      buffer += "ROUND ${round.roundName}\n";
      for (var match in round.matches) {
        bool isBye = match.team.contains("None");
        if (isBye) {
          buffer += "• ${match.team.replaceAll(" VS None", "")} (BYE)\n";
        } else {
          String score = (match.scoreTeam1 != null || match.scoreTeam2 != null)
              ? "${match.scoreTeam1 ?? '?'} - ${match.scoreTeam2 ?? '?'}"
              : "No score";
          buffer += "• ${match.team}: $score\n";
        }
      }
      buffer += "\n";
    }
    Clipboard.setData(ClipboardData(text: buffer));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Results copied to clipboard!")),
    );
  }

  Future<void> _resetMatches() async {
    if (rounds.isEmpty) return;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset All Matches?"),
        content:
            const Text("This will clear all rounds and scores permanently."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        rounds = [];
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_rounds');
    }
  }

  void reportingDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Help"),
      content: const Text("Help message goes here"),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _generateMatches() {
    rounds = [];
    int n = settingsData.teamCount;
    bool isOdd = n.isOdd;
    int numTeams = isOdd ? n + 1 : n;

    // Tracker for how many times each team has actually played
    Map<String, int> playCounts = {};
    for (int i = 1; i <= n; i++) {
      playCounts[i.toString()] = 0;
    }

    // Create team list [1, 2, ..., numTeams]
    List<String> teams = List.generate(numTeams, (i) => (i + 1).toString());
    if (isOdd) {
      teams[numTeams - 1] = "None";
    }

    int numCycles = numTeams - 1;
    int requestedRounds =
        settingsData.gameRounds > 0 ? settingsData.gameRounds : numCycles;

    for (int r = 0; r < requestedRounds; r++) {
      Round round = Round([], "${r + 1}");
      List<Game> pairingPool = [];
      List<Game> byeGames = [];

      // Split teams into two rows for the circle method
      int half = numTeams ~/ 2;
      for (int i = 0; i < half; i++) {
        String t1 = teams[i];
        String t2 = teams[numTeams - 1 - i];

        if (t1 == "None" || t2 == "None") {
          String activeTeam = t1 == "None" ? t2 : t1;
          byeGames.add(Game("$activeTeam VS None", "BYE"));
        } else {
          pairingPool.add(Game("$t1 VS $t2", "0"));
        }
      }

      // SORT pairing pool based on the combined participation of the teams
      // We want to prioritize teams that have played the LEAST so far
      pairingPool.sort((a, b) {
        List<String> teamsA = a.team.split(" VS ");
        List<String> teamsB = b.team.split(" VS ");

        int sumA = (playCounts[teamsA[0]] ?? 0) + (playCounts[teamsA[1]] ?? 0);
        int sumB = (playCounts[teamsB[0]] ?? 0) + (playCounts[teamsB[1]] ?? 0);

        return sumA.compareTo(sumB);
      });

      // Assign games to venues
      int venueCount = settingsData.gameVenues;
      for (int i = 0; i < pairingPool.length; i++) {
        Game game = pairingPool[i];
        if (i < venueCount) {
          game.venue = (i + 1).toString();
          // Log participation for these teams
          List<String> tNames = game.team.split(" VS ");
          playCounts[tNames[0]] = (playCounts[tNames[0]] ?? 0) + 1;
          playCounts[tNames[1]] = (playCounts[tNames[1]] ?? 0) + 1;
          round.matches.add(game);
        } else {
          game.venue = "Waiting";
          round.matches.add(game);
        }
      }

      // Add BYEs
      for (var bye in byeGames) {
        round.matches.add(bye);
      }

      rounds.add(round);

      // Rotate (Circle Method)
      String last = teams.removeLast();
      teams.insert(1, last);
    }
    _saveRounds();
  }

  @override
  void initState() {
    super.initState();
    _loadRounds();
    if (widget.isTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowcaseView.get().startShowCase([_keySettings, _keyGenerate]);
      });
    }
  }

  bool _anyScoreEntered() {
    for (var round in rounds) {
      for (var match in round.matches) {
        if (match.scoreTeam1 != null || match.scoreTeam2 != null) return true;
      }
    }
    return false;
  }

  bool useEditor = false;

  Future<bool> _showResetWarning() async {
    if (!_anyScoreEntered()) return true;

    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset Scores?'),
            content: const Text(
                'Regenerating matches will overwrite all currently entered scores. This cannot be undone.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Reset & Regenerate',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<bool> _onWillPop() async {
    if (!_anyScoreEntered() && rounds.isEmpty) return true;

    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Leave Match Maker?'),
            content: const Text(
                'Your current match schedule and any entered scores will be lost.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Leave', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Match Maker'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          tooltip: "Finish and Return",
          onPressed: () async {
            final shouldPop = await _onWillPop();
            if (shouldPop && context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
          child: const FaIcon(
            FontAwesomeIcons.check,
          ),
        ),
        body: ListView(
          children: <Widget>[
            const SizedBox(height: 12.0),
            ExpansionTile(
              leading: const FaIcon(FontAwesomeIcons.gear),
              title: const Text("Match Settings",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Configure teams, venues, and rounds"),
              children: [
                Showcase(
                  key: _keySettings,
                  title: 'Match Configuration',
                  description:
                      'Adjust how many teams, courts, and rounds you want to schedule.',
                  child: Column(
                    children: [
                      ListTile(
                        leading: const FaIcon(FontAwesomeIcons.userGroup),
                        title: TextFormField(
                            decoration: const InputDecoration(
                              label: Text("How many teams are playing?"),
                              hintText: 'Number of teams',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue: settingsData.teamCount.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                settingsData.teamCount = int.tryParse(value) ??
                                    settingsData.teamCount;
                              });
                            },
                            textAlign: TextAlign.left),
                      ),
                      ListTile(
                        leading: const FaIcon(FontAwesomeIcons.landmark),
                        title: TextFormField(
                            decoration: const InputDecoration(
                              label: Text("How many courts are available?"),
                              hintText: 'Number of available courts/venues?',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue: settingsData.gameVenues.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                settingsData.gameVenues = int.tryParse(value) ??
                                    settingsData.gameVenues;
                              });
                            },
                            textAlign: TextAlign.left),
                      ),
                      ListTile(
                        leading: const FaIcon(FontAwesomeIcons.rotate),
                        title: TextFormField(
                            decoration: const InputDecoration(
                              label: Text("How many rounds of game?"),
                              hintText: 'Number of rounds or rotations',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue: settingsData.gameRounds.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                settingsData.gameRounds = int.tryParse(value) ??
                                    settingsData.gameRounds;
                              });
                            },
                            textAlign: TextAlign.left),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Showcase(
                key: _keyGenerate,
                title: 'Generate Brackets',
                description:
                    'Once configured, click here to create the match schedule. Each round will track scores!',
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (await _showResetWarning()) {
                      setState(() {
                        _generateMatches();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const FaIcon(FontAwesomeIcons.trophy),
                  label: const Text("Create matches",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            rounds.isNotEmpty
                ? ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: rounds.map((round) {
                      return MatchWidget(
                        round: round,
                        onChanged: _saveRounds,
                      );
                    }).toList(),
                  )
                : const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Center(child: Text('Press generate matches')),
                  ),
            if (rounds.isNotEmpty) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _copyResults,
                        icon: const Icon(Icons.copy),
                        label: const Text("Copy Result"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetMatches,
                        icon: const Icon(Icons.refresh, color: Colors.red),
                        label: const Text("Reset matches",
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }
}
