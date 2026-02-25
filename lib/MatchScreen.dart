import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/model/data_model.dart';
import 'package:teammaker/model/player_model.dart';
import 'package:teammaker/widget/match.dart';

class MatchScreen extends StatefulWidget {
  final SettingsData settingsData;

  const MatchScreen(this.settingsData, {super.key});

  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  SettingsData get settingsData => widget.settingsData;
  List<Round> rounds = [];
  List<PlayerModel> players = [];

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
  }

  @override
  void initState() {
    super.initState();
    _generateMatches();
  }

  bool useEditor = false;

  bool _anyScoreEntered() {
    for (var round in rounds) {
      for (var match in round.matches) {
        if (match.scoreTeam1 != null || match.scoreTeam2 != null) return true;
      }
    }
    return false;
  }

  Future<bool> _onWillPop({bool isDestructive = false}) async {
    // Show warning if scores exist OR if a match list exists
    if (!_anyScoreEntered() && rounds.isEmpty) return true;

    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Scores?'),
            content: Text(isDestructive
                ? 'Regenerating matches will overwrite all currently entered scores. Proceed?'
                : 'Do you want to leave? Any unsaved scores will be lost.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Match Maker'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          tooltip: "Finish and Return",
          onPressed: () async {
            if (await _onWillPop()) {
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
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.userGroup),
                  title: TextFormField(
                      decoration: const InputDecoration(
                        label: Text("How many teams are playing?"),
                        hintText: 'Number of teams',
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      initialValue: settingsData.teamCount.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          settingsData.teamCount =
                              int.tryParse(value) ?? settingsData.teamCount;
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      initialValue: settingsData.gameVenues.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          settingsData.gameVenues =
                              int.tryParse(value) ?? settingsData.gameVenues;
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      initialValue: settingsData.gameRounds.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          settingsData.gameRounds =
                              int.tryParse(value) ?? settingsData.gameRounds;
                        });
                      },
                      textAlign: TextAlign.left),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (await _onWillPop(isDestructive: true)) {
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
            const SizedBox(height: 24.0),
            rounds.isNotEmpty
                ? ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: rounds.map((round) {
                      return MatchWidget(
                        round: round,
                      );
                    }).toList(),
                  )
                : const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Center(child: Text('Press generate matches')),
                  ),
          ],
        ),
      ),
    );
  }
}
