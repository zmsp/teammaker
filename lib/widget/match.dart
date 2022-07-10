import 'package:flutter/material.dart';
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  'Round 1' )
                ),

            ],
          ),
        ),
        Divider(
          color: Colors.grey,
        )
      ],
    );
  }
}
