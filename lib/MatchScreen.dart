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

    rounds  = [];

    List <String> team = List.generate( settingsData.teamCount, (index) => "${index+1}");
    if (team.length.floor().isOdd){
      team.add("X1");
    }
    int sub_length = (team.length/2).round();
    List <String> subList2 =  List.generate( sub_length, (index) => "${2+index*2}");
    List <String> subList1 = List.generate( sub_length, (index) => "${1+ index*2}");

    List <String> games = [];
    for (var t = 0; t < sub_length; t++) {

      String team1 = subList1.elementAt(t);
      String team2 = subList2.elementAt(t);
      games.add("$team1 VS $team2");
    }
    for (var r = 1; r <= settingsData.gameRounds; r++) {
      Round c_round  = Round([], "$r");
      for (var v = 1; v <= settingsData.gameVenues; v++) {
        if (games.length ==0){
          String s_1 = subList1.removeAt(1);
          String s_2 = subList2.removeAt(0);
          subList1.insert(1, s_2);
          subList2.add(s_1);
          for (var t = 0; t < sub_length; t++) {

            String team1 = subList1.elementAt(t);
            String team2 = subList2.elementAt(t);
            games.add("$team1 VS $team2");
          }


        }
        Game g = Game(games.removeAt(0), "$v");
        c_round.matches.add(g);

      }

      rounds.add(c_round);
    }
    setState((){

    });
  }

  bool useEditor = false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Game matches'),
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
            leading: FaIcon(FontAwesomeIcons.flag),
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
                rounds  = [];

                List <String> team = List.generate( settingsData.teamCount, (index) => "${index+1}");
                if (team.length.floor().isOdd){
                  team.add("X1");
                }
                int sub_length = (team.length/2).round();
                List <String> subList2 =  List.generate( sub_length, (index) => "${2+index*2}");
                List <String> subList1 = List.generate( sub_length, (index) => "${1+ index*2}");

                List <String> games = [];
                for (var t = 0; t < sub_length; t++) {

                  String team1 = subList1.elementAt(t);
                  String team2 = subList2.elementAt(t);
                  games.add("$team1 VS $team2");
                }
                for (var r = 1; r <= settingsData.gameRounds; r++) {
                  Round c_round  = Round([], "$r");
                  for (var v = 1; v <= settingsData.gameVenues; v++) {
                    if (games.length ==0){
                      String s_1 = subList1.removeAt(1);
                      String s_2 = subList2.removeAt(0);
                      subList1.insert(1, s_2);
                      subList2.add(s_1);
                      for (var t = 0; t < sub_length; t++) {

                        String team1 = subList1.elementAt(t);
                        String team2 = subList2.elementAt(t);
                        games.add("$team1 VS $team2");
                      }


                    }
                    Game g = Game(games.removeAt(0), "$v");
                    c_round.matches.add(g);

                  }

                  rounds.add(c_round);
                }
                setState((){

                });

              },
              icon: FaIcon(FontAwesomeIcons.trophy),
              label: Text("Create matches"),
          ),


          //contains average stars and total reviews card

          SizedBox(height: 24.0),
          //the review menu label


          //contains list of reviews

          rounds.length != 0
              ? ListView(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            children: rounds.map((round) {
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
