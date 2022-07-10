import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/model/data_model.dart';
import 'package:teammaker/model/player_model.dart';
import 'package:teammaker/widget/match.dart';
import 'package:teammaker/widget/player.dart';

class MatchScreen extends StatefulWidget {

  SettingsData settingsData;

  MatchScreen(this.settingsData);
  @override
  MatchScreenState createState() {
    return new MatchScreenState(settingsData);
  }
}

class MatchScreenState extends State<MatchScreen> {

  SettingsData settingsData;

  MatchScreenState(this.settingsData);

  final List<int> _levels = [1, 2, 3, 4, 5];
  final List<String> _genders = ["MALE", "FEMALE", "x"];
  final TextEditingController _batch_text = TextEditingController();
  final TextEditingController _player_text = TextEditingController();
  final FocusNode myFocusNode = FocusNode();

  int _selectedLevel = 3;
  String _selectedGender = "MALE";
  TextEditingController textarea = TextEditingController();

  List<PlayerModel> players = [];
  List<Round> rounds = [];

  showTextDialog(BuildContext context, String title, String message) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("$title"),
      content: SingleChildScrollView(
        child: Text("$message"),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  bool useEditor = false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Players'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: "Add listed players",
        onPressed: () {
          Navigator.pop(context, players);
          // print(rows.length);
          // showDialog<void>(
          //   context: context,
          //   builder: HelpDialog,
          // );
        },
        child: const FaIcon(
          FontAwesomeIcons.check,
        ),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 12.0),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.userGroup),
            subtitle: TextFormField(
                decoration: const InputDecoration(
                  label: Text("How many teams are playing?"),
                  hintText:
                  'Number of teams',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                initialValue: settingsData.teamCount.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  settingsData.teamCount =
                      int.tryParse(value) ??
                          settingsData.teamCount;
                },
                textAlign: TextAlign.left),
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.volleyball),
            subtitle:  TextFormField(
                decoration: const InputDecoration(
                  label: Text("How many sites are available?"),
                  hintText:
                  'Number of available nets/sites/venues?',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                initialValue: settingsData.gameVenues.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  settingsData.gameVenues =
                      int.tryParse(value) ??
                          settingsData.gameVenues;
                },
                textAlign: TextAlign.left),
          ),
          ListTile(

            leading: FaIcon(FontAwesomeIcons.rotate),
            subtitle:  TextFormField(
                decoration: const InputDecoration(
                  label: Text("How many rounds of game?"),
                  hintText:
                  'Number of rounds or rotations',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                initialValue: settingsData.gameRounds.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  settingsData.gameRounds =
                      int.tryParse(value) ??
                          settingsData.gameRounds;
                },
                textAlign: TextAlign.left),

          ),
          ElevatedButton.icon(
              onPressed: () {

              },
              icon: FaIcon(FontAwesomeIcons.trophy),
              label: Text("Create matches"),
          ),


          //contains average stars and total reviews card

          SizedBox(height: 24.0),
          //the review menu label


          //contains list of reviews

          players.length != 0
              ? ListView(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            children: rounds.reversed.map((round) {
              return MatchWidget(
                round: round,
              );
            }).toList(),



          )
              :      Padding(
            padding: EdgeInsets.all(10.0),
            child:
            Expanded(
                child: Text(
                    'Press generate matches' )
            ),




          ),

        ],
      ),
    );
  }
}
