import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/model/player_model.dart';

class PlayerWidget extends StatelessWidget {
  final PlayerModel player;

  const PlayerWidget({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Hide the placeholder empty player
    if (player.name == "None" && player.level == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        leading: CircleAvatar(
          backgroundColor: player.getGenderString().toUpperCase() == "FEMALE" ||
                  player.getGenderString().toUpperCase() == "F"
              ? colorScheme.secondaryContainer
              : colorScheme.primaryContainer,
          child: FaIcon(
            player.getGenderString().toUpperCase() == "FEMALE" ||
                    player.getGenderString().toUpperCase() == "F"
                ? FontAwesomeIcons.personDress
                : FontAwesomeIcons.person,
            color: player.getGenderString().toUpperCase() == "FEMALE" ||
                    player.getGenderString().toUpperCase() == "F"
                ? colorScheme.onSecondaryContainer
                : colorScheme.onPrimaryContainer,
            size: 18,
          ),
        ),
        title: Text(
          player.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(player.getGenderString(),
            style:
                TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              index < player.level ? Icons.star : Icons.star_border,
              color: index < player.level
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              size: 16,
            );
          }),
        ),
      ),
    );
  }
}
