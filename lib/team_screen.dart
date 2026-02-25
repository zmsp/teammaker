import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/MatchScreen.dart';
import 'package:teammaker/model/data_model.dart';

class TeamList extends StatelessWidget {
  final List<ListItem> items;
  final SettingsData settingsData;
  //
  TeamList({Key? key, required this.items, required this.settingsData})
      : super(key: key);

  List<String> findAllPermutations(String source) {
    List allPermutations = [];

    void permutate(List list, int cursor) {
      // when the cursor gets this far, we've found one permutation, so save it
      if (cursor == list.length) {
        allPermutations.add(list);
        return;
      }

      for (int i = cursor; i < list.length; i++) {
        List permutation = new List.from(list);
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
        color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
        child: Text(
          heading,
          style: Theme.of(context).textTheme.titleLarge,
        ));
  }

  @override
  Widget buildSubtitle(BuildContext context) => Text(subtitle);
}

/// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  final String sender;
  final String body;

  MessageItem(this.sender, this.body);

  @override
  Widget buildTitle(BuildContext context) => Text(sender);

  @override
  Widget buildSubtitle(BuildContext context) => SizedBox();
}
