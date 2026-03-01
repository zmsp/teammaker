import 'package:flutter/material.dart';
import 'package:teammaker/match_screen.dart';
import 'package:teammaker/model/data_model.dart';
import 'package:teammaker/model/player_entry.dart';
import 'package:teammaker/theme/app_theme.dart';

class TeamList extends StatefulWidget {
  final List<ListItem> items;
  final SettingsData settingsData;
  final SportPalette? sport;

  const TeamList({
    super.key,
    required this.items,
    required this.settingsData,
    this.sport,
  });

  @override
  State<TeamList> createState() => _TeamListState();
}

class _TeamListState extends State<TeamList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team List'),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];

          if (item is MessageItem) {
            return InkWell(
              onTap: () => _editPlayer(context, item.player),
              child: item.buildTitle(context),
            );
          }

          return item.buildTitle(context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MatchScreen(widget.settingsData)));
        },
        child: Icon(
          widget.sport?.icon ?? Icons.sports,
        ),
      ),
    );
  }

  void _editPlayer(BuildContext context, PlayerEntry player) {
    final nameController = TextEditingController(text: player.name);
    final roleController = TextEditingController(text: player.role);
    int level = player.level;
    String gender = player.gender;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Player'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Skill Level'),
                child: DropdownButton<int>(
                  value: level.clamp(1, 5),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: List.generate(5, (i) => i + 1)
                      .map((l) => DropdownMenuItem(value: l, child: Text('$l')))
                      .toList(),
                  onChanged: (v) => level = v ?? level,
                ),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Gender'),
                child: DropdownButton<String>(
                  value: ['MALE', 'FEMALE', 'X'].contains(gender)
                      ? gender
                      : 'MALE',
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: ['MALE', 'FEMALE', 'X']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => gender = v ?? gender,
                ),
              ),
              const SizedBox(height: 12),
              if (widget.sport != null)
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Position'),
                  child: DropdownButton<String>(
                    value: widget.sport!.roles.contains(roleController.text)
                        ? roleController.text
                        : 'Any',
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: widget.sport!.roles
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => roleController.text = v ?? 'Any',
                  ),
                )
              else
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(labelText: 'Position'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                player.name = nameController.text;
                player.role = roleController.text;
                player.level = level;
                player.gender = gender;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

/// The base class for the different types of items the list can contain.
abstract class ListItem {
  Widget buildTitle(BuildContext context);
  Widget buildSubtitle(BuildContext context);
}

/// A ListItem that contains data to display a heading.
class HeadingItem implements ListItem {
  final String heading;
  final String subtitle;

  HeadingItem(this.heading, this.subtitle);

  @override
  Widget buildTitle(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 16.0, bottom: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer
                      .withValues(alpha: 0.8)),
            ),
          ],
        ));
  }

  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}

/// A ListItem that contains a player row.
class MessageItem implements ListItem {
  final PlayerEntry player;

  MessageItem(this.player);

  @override
  Widget buildTitle(BuildContext context) {
    final isFemale = player.gender.toUpperCase().startsWith('F');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: isFemale
              ? Colors.pink.withValues(alpha: 0.1)
              : Colors.blue.withValues(alpha: 0.1),
          child: Text(
            isFemale ? '♀' : '♂',
            style: TextStyle(
              fontSize: 16,
              color: isFemale ? Colors.pink : Colors.blue,
            ),
          ),
        ),
        title: Text(player.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: (player.role.isNotEmpty && player.role != 'Any')
            ? Text(player.role,
                style:
                    const TextStyle(fontSize: 12, fontStyle: FontStyle.italic))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            return Icon(
              i < player.level
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              size: 14,
              color: i < player.level ? Colors.amber : Colors.grey.shade300,
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}
