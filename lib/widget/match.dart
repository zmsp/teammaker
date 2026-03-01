import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/model/data_model.dart';
import 'package:teammaker/theme/app_theme.dart';
import 'package:teammaker/widgets/tapscore_widget.dart';

class MatchWidget extends StatefulWidget {
  final Round round;
  final VoidCallback? onChanged;

  const MatchWidget({super.key, required this.round, this.onChanged});

  @override
  State<MatchWidget> createState() => _MatchWidgetState();
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
                  "ROUND ${widget.round.roundName}",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 12),
              ...widget.round.matches.map((match) {
                bool isBye = match.team.contains("None");
                String scoreSummary = isBye ? "BYE" : "No score recorded";
                if (!isBye &&
                    (match.scoreTeam1 != null || match.scoreTeam2 != null)) {
                  scoreSummary =
                      "${match.scoreTeam1 ?? '?'} - ${match.scoreTeam2 ?? '?'}";
                }

                // Format Venue string
                String venueDisplay = match.venue == "Waiting"
                    ? "Waiting..."
                    : (isBye ? "REST" : "Court ${match.venue}");

                return Card(
                  key: ValueKey(
                      "match_${match.team}_${match.scoreTeam1}_${match.scoreTeam2}"),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                          color: colorScheme.outlineVariant, width: 1.5)),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isBye
                            ? Icons.coffee
                            : (Theme.of(context)
                                    .extension<SportIconExtension>()
                                    ?.icon ??
                                Icons.sports),
                        size: 24, // Bigger Icon
                        color: colorScheme.secondary,
                      ),
                    ),
                    title: Text(
                      isBye
                          ? match.team.replaceAll(" VS None", "")
                          : "${match.team} at $venueDisplay",
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        children: [
                          Icon(Icons.emoji_events,
                              size: 16, color: colorScheme.tertiary),
                          const SizedBox(width: 6),
                          Text("Score: $scoreSummary",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurfaceVariant)),
                          const SizedBox(width: 20),
                          Icon(Icons.place,
                              size: 16, color: colorScheme.outline),
                          const SizedBox(width: 6),
                          Text(venueDisplay,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    const Text("Team 1 Score",
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 60,
                                      child: TextFormField(
                                        key: ValueKey("t1_${match.scoreTeam1}"),
                                        initialValue:
                                            match.scoreTeam1?.toString() ?? '',
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 12, horizontal: 8),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            match.scoreTeam1 =
                                                int.tryParse(val);
                                          });
                                          widget.onChanged?.call();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const Text("VS",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey)),
                                Column(
                                  children: [
                                    const Text("Team 2 Score",
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 60,
                                      child: TextFormField(
                                        key: ValueKey("t2_${match.scoreTeam2}"),
                                        initialValue:
                                            match.scoreTeam2?.toString() ?? '',
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 12, horizontal: 8),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            match.scoreTeam2 =
                                                int.tryParse(val);
                                          });
                                          widget.onChanged?.call();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (!isBye)
                              ElevatedButton.icon(
                                onPressed: () async {
                                  List<String> teamNames =
                                      match.team.split(" VS ");
                                  String nameA = teamNames.isNotEmpty
                                      ? "TEAM ${teamNames[0]}"
                                      : "TEAM A";
                                  String nameB = teamNames.length > 1
                                      ? "TEAM ${teamNames[1]}"
                                      : "TEAM B";

                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TapScoreScreen(
                                              initialScoreA: match.scoreTeam1,
                                              initialScoreB: match.scoreTeam2,
                                              initialNameA: nameA,
                                              initialNameB: nameB,
                                            )),
                                  );

                                  if (result != null && result is Map) {
                                    setState(() {
                                      match.scoreTeam1 = result['scoreA'];
                                      match.scoreTeam2 = result['scoreB'];
                                    });
                                    widget.onChanged?.call();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      colorScheme.secondaryContainer,
                                  foregroundColor:
                                      colorScheme.onSecondaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const FaIcon(FontAwesomeIcons.stopwatch,
                                    size: 16),
                                label: const Text("Launch Scoreboard",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            if (isBye)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text("REST ROUND / BYE",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2)),
                              ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        Divider(color: Colors.grey.withValues(alpha: 0.5))
      ],
    );
  }
}
