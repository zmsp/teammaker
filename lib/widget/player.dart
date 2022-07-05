import 'package:flutter/material.dart';
import 'package:teammaker/model/player_model.dart';

class PlayerWidget extends StatelessWidget {
  final PlayerModel player;

  const PlayerWidget({Key? key, required this.player}) : super(key: key);

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
                  '${player.name} - ( ${player.getGenderString()} )' )
                ),

              Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < player.level ? Icons.star : Icons.star_border,
                    );
                  })),
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
