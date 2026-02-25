import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/model/data_model.dart';

class MatchWidget extends StatelessWidget {
  final Round round;

  const MatchWidget({Key? key, required this.round}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(
                round.roundName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
            title: Text("Round " + round.roundName),

            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: round.matches.map((match) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.userGroup, size: 12),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  match.team,
                                  style: TextStyle(fontSize: 14),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 35,
                                child: TextFormField(
                                  initialValue:
                                      match.scoreTeam1?.toString() ?? '',
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(8),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (val) {
                                    match.scoreTeam1 = int.tryParse(val);
                                  },
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text('-'),
                              ),
                              SizedBox(
                                width: 35,
                                child: TextFormField(
                                  initialValue:
                                      match.scoreTeam2?.toString() ?? '',
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(8),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (val) {
                                    match.scoreTeam2 = int.tryParse(val);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FaIcon(FontAwesomeIcons.flag, size: 12),
                              SizedBox(width: 8),
                              Text(match.venue),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            //
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // children: <Widget>[
            //   Expanded(
            //     child: Text(
            //       round.roundName )
            //     ),
            //   Column(
            //
            //     children: round.matches.map((match) {
            //       return Text(match.team);
            //     }).toList(),
            //
            //   )
            //
            // ],
          ),
        ),
        Divider(
          color: Colors.grey,
        )
      ],
    );
  }
}
