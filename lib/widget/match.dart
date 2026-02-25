import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/model/data_model.dart';

class MatchWidget extends StatefulWidget {
  final Round round;

  const MatchWidget({Key? key, required this.round}) : super(key: key);

  @override
  _MatchWidgetState createState() => _MatchWidgetState();
}

class _MatchWidgetState extends State<MatchWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    widget.round.roundName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  "Round " + widget.round.roundName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              ...widget.round.matches.map((match) {
                String scoreSummary = "No score recorded";
                if (match.scoreTeam1 != null || match.scoreTeam2 != null) {
                  scoreSummary =
                      "${match.scoreTeam1 ?? '?'} - ${match.scoreTeam2 ?? '?'}";
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    leading: FaIcon(FontAwesomeIcons.userGroup,
                        size: 20, color: Colors.blueAccent),
                    title: Text(
                      match.team,
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.trophy,
                              size: 12, color: Colors.amber),
                          SizedBox(width: 4),
                          Text("Score: " + scoreSummary),
                          SizedBox(width: 16),
                          FaIcon(FontAwesomeIcons.flag,
                              size: 12, color: Colors.orangeAccent),
                          SizedBox(width: 4),
                          Text(match.venue),
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
                      ),
                    ],
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
