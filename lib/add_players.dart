import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/model/player_model.dart';
import 'package:teammaker/widget/player.dart';

class AddPlayersScreen extends StatefulWidget {
  @override
  AddPlayersScreenState createState() {
    return new AddPlayersScreenState();
  }
}

class AddPlayersScreenState extends State<AddPlayersScreen> {
  final List<int> _levels = [1, 2, 3, 4, 5];
  final List<String> _genders = ["MALE", "FEMALE", "x"];
  final TextEditingController _batch_text = TextEditingController();
  final TextEditingController _player_text = TextEditingController();
  final FocusNode myFocusNode = FocusNode();

  int _selectedLevel = 3;
  String _selectedGender = "MALE";
  TextEditingController textarea = TextEditingController();

  List<PlayerModel> players = [];

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
            title: const Text('Add from text'),
            leading: Switch(
              value: useEditor,
              onChanged: (value) {
                setState(() {
                  useEditor = value;
                  print(useEditor);
                });
              },
              // activeTrackColor: Colors.lightGreenAccent,
              // activeColor: Colors.green,
            ),
          ),

          !useEditor
              ? Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: screenWidth * 0.4,
                          child: TextField(
                            textInputAction: TextInputAction.done,
                            focusNode: myFocusNode,
                            onSubmitted: (value) {
                              setState(() {
                                players.add(PlayerModel(_selectedLevel,
                                    _player_text.text, "team", _selectedGender));
                              });
                              _player_text.text = "";
                              myFocusNode.requestFocus();
                            },
                            controller: _player_text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: "Player name",
                              labelText: "Name",
                            ),
                          ),
                        ),
                        Container(
                          child: DropdownButton(
                            hint: Text("Levels"),
                            elevation: 0,
                            value: _selectedLevel,
                            items: _levels.map((star) {
                              return DropdownMenuItem<int>(
                                child: Text(star.toString()),
                                value: star,
                              );
                            }).toList(),
                            onChanged: (int? item) {
                              setState(() {
                                _selectedLevel = item ?? 3;
                              });
                            },
                          ),
                        ),
                        Container(
                          child: DropdownButton(
                            hint: Text("Genders"),
                            elevation: 0,
                            value: _selectedGender,
                            items: _genders.map((gender) {
                              return DropdownMenuItem<String>(
                                child: Text(gender.toString()),
                                value: gender,
                              );
                            }).toList(),
                            onChanged: (String? item) {
                              setState(() {
                                _selectedGender = item ?? "MALE";
                              });
                            },
                          ),
                        ),
                        Container(
                          child: Builder(
                            builder: (BuildContext context) {
                              return IconButton(
                                icon: FaIcon(FontAwesomeIcons.personCirclePlus),
                                onPressed: () {
                                  setState(() {
                                    players.add(PlayerModel(_selectedLevel,
                                        _player_text.text, "0", _selectedGender));
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),


                ],
              )
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ElevatedButton.icon(
                            icon: Icon(
                              FontAwesomeIcons.clipboard,
                              size: 25.0,
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                  new ClipboardData(text: _batch_text.text));
                              print(_batch_text.text);
                            },
                            label: Text("Copy")),

                        ElevatedButton.icon(
                            icon: Icon(
                              FontAwesomeIcons.meetup,
                              size: 25.0,
                            ),
                            onPressed: () {
                              String text = _batch_text.text;
                              print(text);
                              var lines = text.split("\n");
                              var player_line = [];
                              var date_field_regex =
                                  RegExp(r'^(J|F|M|A|M|J|A|S|O|N|D).*(AM|PM)$');
                              var record_flag = true;
                              for (var i = 0; i <= lines.length - 1; i++) {
                                if ((record_flag == true) &&
                                    (lines[i].trim() != "")) {
                                  print(lines[i]);
                                  player_line.add(lines[i] + ",3" + ",M");
                                  record_flag = false;
                                  continue;
                                }
                                // Here if we find a pattern for date field, we record the next line.
                                print(lines[i]);
                                print(date_field_regex.hasMatch(lines[i]));
                                if (date_field_regex.hasMatch(lines[i]) ==
                                    true) {
                                  // print()
                                  record_flag = true;
                                }
                              }

                              setState(() {
                                _batch_text.text = player_line.join("\n");
                              });
                            },
                            label: Text("Meetup")),

                        ElevatedButton.icon(
                            icon: Icon(
                              FontAwesomeIcons.alignRight,
                              size: 25.0,
                            ),
                            onPressed: () {
                              var lines = _batch_text.text.split("\n");
                              var string_data = [];

                              for (var i = 0; i <= lines.length - 1; i++) {
                                var map_data = {
                                  "name": "x",
                                  "level": 3,
                                  "gender": "MALE",
                                  "team": "None"
                                };

                                var data = lines[i].split(",");
                                for (var j = 0; j < data.length; j++) {
                                  switch (j) {
                                    case 0:
                                      {
                                        map_data["name"] = data[0];
                                      }
                                      break;
                                    case 1:
                                      {
                                        map_data["level"] =
                                            double.tryParse(data[1]) ?? 3;
                                      }
                                      break;
                                    case 2:
                                      {
                                        if (data[2]
                                            .trim()
                                            .toUpperCase()
                                            .startsWith("M")) {
                                          map_data["gender"] = "MALE";
                                        } else if (data[2]
                                            .trim()
                                            .toUpperCase()
                                            .startsWith("F")) {
                                          map_data["gender"] = "FEMALE";
                                        } else {
                                          map_data["gender"] = "X";
                                        }
                                      }
                                      break;
                                    case 3:
                                      {
                                        map_data["team"] = data[3];
                                      }
                                      break;
                                    default:
                                      {
                                        break;
                                      }
                                  }
                                }
                                string_data.add(map_data.toString() + "\n");
                              }
                              showTextDialog(
                                  context,
                                  "Following players will be added",
                                  string_data.join("\n"));
                            },
                            label: Text("Defaults")),
                        ElevatedButton.icon(
                            icon: Icon(
                              FontAwesomeIcons.eraser,
                              size: 25.0,
                            ),
                            onPressed: () {
                              _batch_text.text = "";
                            },
                            label: Text("Clear")),
                        // ElevatedButton(
                        //     onPressed: (){
                        //       print(textarea.text);
                        //     },
                        //     child: Text("Paste Meetup")
                        // ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    TextField(
                      controller: _batch_text,
                      keyboardType: TextInputType.multiline,
                      maxLines: 7,
                      decoration: InputDecoration(
                          hintText:
                              "Enter players levels and gender. See help menu for details on adding from text or meetup. One player per line.\nFormat: <Name>,<Level>,<Gender>"
                              "\n---Example--- \nZobair,3,M, \nMary,2,Female \nZach,5,male",
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1, color: Colors.redAccent))),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ElevatedButton.icon(
                            icon: Icon(
                              FontAwesomeIcons.circleXmark,
                              size: 25.0,
                            ),
                            onPressed: () {
                              // Navigator.pop(context);

                              setState(() {
                                players = [];
                              });
                            },
                            label: Text("Cancel")),
                        ElevatedButton.icon(
                            icon: Icon(
                              FontAwesomeIcons.circleCheck,
                              size: 25.0,
                            ),
                            onPressed: () {
                              var lines = _batch_text.text.split("\n");
                              var string_data = [];

                              for (var i = 0; i <= lines.length - 1; i++) {
                                var map_data = {
                                  "name": "x",
                                  "level": 3,
                                  "gender": "MALE",
                                  "team": "None"
                                };

                                var data = lines[i].split(",");
                                for (var j = 0; j < data.length; j++) {
                                  switch (j) {
                                    case 0:
                                      {
                                        map_data["name"] = data[0];
                                      }
                                      break;
                                    case 1:
                                      {
                                        map_data["level"] =
                                            double.tryParse(data[1]) ?? 3;
                                      }
                                      break;
                                    case 2:
                                      {
                                        if (data[2]
                                            .trim()
                                            .toUpperCase()
                                            .startsWith("M")) {
                                          map_data["gender"] = "MALE";
                                        } else if (data[2]
                                            .trim()
                                            .toUpperCase()
                                            .startsWith("F")) {
                                          map_data["gender"] = "FEMALE";
                                        } else {
                                          map_data["gender"] = "X";
                                        }
                                      }
                                      break;
                                    case 3:
                                      {
                                        map_data["team"] = data[3];
                                      }
                                      break;
                                    default:
                                      {
                                        break;
                                      }
                                  }
                                }
                                string_data.add(map_data.toString() + "\n");
                              }
                              showTextDialog(
                                  context,
                                  "Following players will be added",
                                  string_data.join("\n"));
                            },
                            label: Text("Check")),
                        ElevatedButton.icon(
                            icon: Icon(
                              FontAwesomeIcons.circlePlus,
                              size: 25.0,
                            ),
                            onPressed: () {
                              var lines = _batch_text.text.split("\n");
                              var string_data = [];

                              for (var i = 0; i <= lines.length - 1; i++) {
                                PlayerModel player =
                                    PlayerModel(3, "X", "X", "X");

                                var data = lines[i].split(",");
                                for (var j = 0; j < data.length; j++) {
                                  switch (j) {
                                    case 0:
                                      {
                                        player.name = data[0];
                                      }
                                      break;
                                    case 1:
                                      {
                                        player.level =
                                            int.tryParse(data[1]) ?? 3;
                                      }
                                      break;
                                    case 2:
                                      {
                                        if (data[2]
                                            .trim()
                                            .toUpperCase()
                                            .startsWith("M")) {
                                          player.gender = "MALE";
                                        } else if (data[2]
                                            .trim()
                                            .toUpperCase()
                                            .startsWith("F")) {
                                          player.gender = "FEMALE";
                                        } else {
                                          player.gender = "X";
                                        }
                                      }
                                      break;
                                    case 3:
                                      {
                                        player.team = data[3];
                                      }
                                      break;
                                    default:
                                      {
                                        break;
                                      }
                                  }
                                }
                                players.add(player);
                              }

                              setState(() {});
                            },
                            label: Text("Add")),
                      ],
                    ),
                  ],
                ),

          //contains average stars and total reviews card

          SizedBox(height: 24.0),
          //the review menu label
          Container(
            color: Theme.of(context).secondaryHeaderColor,
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.person),
                SizedBox(width: 10.0),
                Text(
                  "We will add ${players.length} players",
                  style: TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  color: Colors.red,
                  onPressed: () {
                    setState(() {
                      players = [];
                    });
                  },
                ),
              ],
            ),
          ),
          //contains list of reviews

          players.length != 0
              ? ListView(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: players.reversed.map((player) {
                    return PlayerWidget(
                      player: player,
                    );
                  }).toList(),
                )
              :      Padding(
            padding: EdgeInsets.all(10.0),
            child:
                Expanded(
                    child: Text(
                        'No Players to be added' )
                ),




          ),

          ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, players);
              },
              icon: FaIcon(FontAwesomeIcons.peopleGroup),
              label: Text("Add players to team maker"))
        ],
      ),
    );
  }
}
