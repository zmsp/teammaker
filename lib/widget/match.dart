import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/model/data_model.dart';
import 'package:teammaker/widgets/tapscore_widget.dart';

class MatchWidget extends StatefulWidget {
  final Round round;

  const MatchWidget({Key? key, required this.round}) : super(key: key);

  @override
  _MatchWidgetState createState() => _MatchWidgetState();
}

class _MatchWidgetState extends State<MatchWidget> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    widget.round.roundName,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  "Round ${widget.round.roundName}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              ...widget.round.matches.map((match) {
                String scoreSummary = "No score recorded";
                if (match.scoreTeam1 != null || match.scoreTeam2 != null) {
                  scoreSummary =
                      "${match.scoreTeam1 ?? '?'} - ${match.scoreTeam2 ?? '?'}";
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outlineVariant)),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    leading: FaIcon(FontAwesomeIcons.userGroup,
                        size: 20, color: colorScheme.secondary),
                    title: Text(
                      match.team,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.trophy,
                              size: 12, color: colorScheme.tertiary),
                          const SizedBox(width: 4),
                          Text("Score: $scoreSummary",
                              style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 16),
                          FaIcon(FontAwesomeIcons.mapLocationDot,
                              size: 12, color: colorScheme.outline),
                          const SizedBox(width: 4),
                          Text(match.venue, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text("Team 1 Score",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                SizedBox(height: 8),
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    initialValue:
                                        match.scoreTeam1?.toString() ?? '',
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        match.scoreTeam1 = int.tryParse(val);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Text("VS",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            Column(
                              children: [
                                Text("Team 2 Score",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                SizedBox(height: 8),
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    initialValue:
                                        match.scoreTeam2?.toString() ?? '',
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        match.scoreTeam2 = int.tryParse(val);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const TapScoreScreen()),
                              );

                              if (result != null && result is Map) {
                                setState(() {
                                  match.scoreTeam1 = result['scoreA'];
                                  match.scoreTeam2 = result['scoreB'];
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondaryContainer,
                              foregroundColor: colorScheme.onSecondaryContainer,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const FaIcon(FontAwesomeIcons.stopwatch, size: 16),
                            label: const Text("Launch Scoreboard",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        Divider(color: Colors.grey.withValues(alpha: 0.5))
      ],
    );
  }
}
