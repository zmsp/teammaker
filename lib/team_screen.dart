import 'package:flutter/material.dart';
import 'package:teammaker/MatchScreen.dart';
import 'package:teammaker/model/data_model.dart';
import 'package:teammaker/theme/app_theme.dart';
import 'package:pluto_grid/pluto_grid.dart';

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
  List<String> findAllPermutations(String source) {
    List allPermutations = [];

    void permutate(List list, int cursor) {
      // when the cursor gets this far, we've found one permutation, so save it
      if (cursor == list.length) {
        allPermutations.add(list);
        return;
      }

      for (int i = cursor; i < list.length; i++) {
        List permutation = List.from(list);
        permutation[cursor] = list[i];
        permutation[i] = list[cursor];
        permutate(permutation, cursor + 1);
      }
    }

    permutate(source.split(''), 0);

    List<String> strPermutations = [];
    for (List permutation in allPermutations) {
      strPermutations.add(permutation.join());
    }

    return strPermutations;
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Team List';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];

          if (item is MessageItem) {
            return InkWell(
              onTap: () => _editPlayer(context, item.row),
              child: item.buildTitle(context),
            );
          }

          return item.buildTitle(context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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

  void _editPlayer(BuildContext context, PlutoRow row) {
    final nameController =
        TextEditingController(text: row.cells['name_field']?.value.toString());
    final roleController =
        TextEditingController(text: row.cells['role_field']?.value.toString());
    int level = (row.cells['skill_level_field']?.value ?? 3) as int;
    String gender = row.cells['gender_field']?.value.toString() ?? "MALE";

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
              DropdownButtonFormField<int>(
                value: level,
                decoration: const InputDecoration(labelText: 'Skill Level'),
                items: List.generate(5, (i) => i + 1)
                    .map((l) => DropdownMenuItem(value: l, child: Text('$l')))
                    .toList(),
                onChanged: (v) => level = v ?? level,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['MALE', 'FEMALE', 'X']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => gender = v ?? gender,
              ),
              const SizedBox(height: 12),
              if (widget.sport != null)
                DropdownButtonFormField<String>(
                  value: widget.sport!.roles.contains(roleController.text)
                      ? roleController.text
                      : 'Any',
                  decoration: const InputDecoration(labelText: 'Position'),
                  items: widget.sport!.roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => roleController.text = v ?? 'Any',
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
                row.cells['name_field']?.value = nameController.text;
                row.cells['role_field']?.value = roleController.text;
                row.cells['skill_level_field']?.value = level;
                row.cells['gender_field']?.value = gender;
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
  /// The title line to show in a list item.
  Widget buildTitle(BuildContext context);

  /// The subtitle line, if any, to show in a list item.
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

/// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  final PlutoRow row;

  MessageItem(this.row);

  @override
  Widget buildTitle(BuildContext context) {
    final name = row.cells['name_field']?.value.toString() ?? '';
    final role = row.cells['role_field']?.value.toString() ?? '';
    final level = (row.cells['skill_level_field']?.value ?? 0) as int;
    final gender = row.cells['gender_field']?.value.toString() ?? '';
    final isFemale = gender.toUpperCase().startsWith('F');

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
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: (role.isNotEmpty && role != 'Any')
            ? Text(role,
                style:
                    const TextStyle(fontSize: 12, fontStyle: FontStyle.italic))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            return Icon(
              i < level ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 14,
              color: i < level ? Colors.amber : Colors.grey.shade300,
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}
