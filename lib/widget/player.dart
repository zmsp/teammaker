import 'package:flutter/material.dart';
import 'package:teammaker/model/player_model.dart';
import 'package:teammaker/widgets/player_widgets.dart';

class PlayerWidget extends StatelessWidget {
  final PlayerModel player;
  final VoidCallback? onTap;

  const PlayerWidget({super.key, required this.player, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Hide the placeholder empty player
    if (player.name == "None" && player.level == 0) {
      return const SizedBox.shrink();
    }

    return PlayerCard.fromModel(
      player,
      onTap: onTap,
    );
  }
}
