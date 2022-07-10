import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/model/data_model.dart';
import 'package:teammaker/model/player_model.dart';

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
            leading:CircleAvatar(
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

            subtitle: Column(
              children: round.matches.map((match) {
                return Row(
                  //   mainAxisAlignment:MainAxisAlignment.end,
                  // mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,

                     mainAxisAlignment:MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  // MainAxisSize mainAxisSize = MainAxisSize.max,
                  // CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,

                  children: [
                    FaIcon(FontAwesomeIcons.userGroup, size: 12,),
                    SizedBox(width: 10),
                    Text(match.team ),
                    SizedBox(width: 50),
                    FaIcon(FontAwesomeIcons.flag, size: 12,),
                    SizedBox(width: 10),
                    Text(match.venue),


                  ],
                );
              }).toList(),
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
