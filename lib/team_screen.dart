import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/MatchScreen.dart';
import 'package:teammaker/model/data_model.dart';

class TeamList extends StatelessWidget {
  final List<ListItem> items;
  final SettingsData settingsData;
  //
  const TeamList({super.key, required this.items, required this.settingsData});

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
        // Let the ListView know how many items it needs to build.
        itemCount: items.length,
        // Provide a builder function. This is where the magic happens.
        // Convert each item into a widget based on the type of item it is.
        itemBuilder: (context, index) {
          final item = items[index];

          return ListTile(
            title: item.buildTitle(context),
            subtitle: item.buildSubtitle(context),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MatchScreen(settingsData)));
        },
        child: const FaIcon(
          FontAwesomeIcons.volleyball,
        ),
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
  final String sender;
  final String body;

  MessageItem(this.sender, this.body);

  @override
  Widget buildTitle(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: FaIcon(FontAwesomeIcons.userAstronaut,
              size: 16,
              color: Theme.of(context).colorScheme.onSecondaryContainer),
        ),
        title:
            Text(sender, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}
