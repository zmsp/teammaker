import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:teammaker/HelpScreen.dart';
import 'package:teammaker/team_screen.dart';

class PlutoExampleScreen extends StatefulWidget {
  final String? title;
  final String? topTitle;
  final List<Widget>? topContents;
  final List<Widget>? topButtons;
  final Widget? body;

  PlutoExampleScreen({
    this.title,
    this.topTitle,
    this.topContents,
    this.topButtons,
    this.body,
  });

  @override
  _PlutoExampleScreenState createState() => _PlutoExampleScreenState();
}

enum Status { none, running, stopped, paused }

class _PlutoExampleScreenState extends State<PlutoExampleScreen> {
  PlutoGridStateManager? stateManager;
  final storage = new LocalStorage('my_data.json');

  void saveData() {
    final Iterable<Map<String, dynamic>>? rowsToUpdate =
        stateManager?.rows.map((e) {
      return {
        'name_field': e?.cells['name_field']?.value,
        'skill_level_field': e?.cells['skill_level_field']?.value,
        'gender_field': e?.cells['gender_field']?.value,
        'team_field': e?.cells['team_field']?.value,
      };
    });
    // update rowsToUpdate

    print(jsonEncode(rowsToUpdate));

    storage.setItem('todos', jsonEncode(rowsToUpdate));
  }

  void loadData() {
    print(storage.getItem('todos'));
  }

  int teams = 4;

  int level = 4;

  List<PlutoColumn> columns = [
    /// Text Column definition

    PlutoColumn(
      enableRowDrag: true,
      enableHideColumnMenuItem: false,
      enableRowChecked: true,
      title: "name",
      field: "name_field",
      frozen: PlutoColumnFrozen.left,
      width: 250,
      type: PlutoColumnType.text(),
      renderer: (rendererContext) {
        return Row(
          children: [
            Expanded(
              child: Text(
                rendererContext.row!.cells[rendererContext.column!.field]!.value
                    .toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white70),
              ),
            ),
            Wrap(
              children: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                  ),
                  onPressed: () {
                    rendererContext.stateManager!.insertRows(
                      rendererContext.rowIdx!,
                      [rendererContext.stateManager!.getNewRow()],
                    );
                  },
                  iconSize: 25,
                  color: Colors.green,
                  padding: const EdgeInsets.all(0),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outlined,
                  ),
                  onPressed: () {
                    rendererContext.stateManager!
                        .removeRows([rendererContext.row]);
                  },
                  iconSize: 25,
                  color: Colors.red,
                  padding: const EdgeInsets.all(0),
                ),
              ],
            ),
          ],
        );
      },
    ),
    PlutoColumn(
      title: 'rank#',
      field: 'skill_level_field',
      type: PlutoColumnType.number(),
      width: 80,
      textAlign: PlutoColumnTextAlign.right,
    ),

    PlutoColumn(
        title: 'gender',
        field: 'gender_field',
        width: 80,
        type: PlutoColumnType.select(["MALE", "FEMALE", "X"])),

    /// Number Column definition

    PlutoColumn(
      title: 'team',
      field: 'team_field',
      textAlign: PlutoColumnTextAlign.right,
      width: 80,
      type: PlutoColumnType.text(),
    ),
  ];

  List<PlutoRow> rows = [
    PlutoRow(
      cells: {
        'name_field': PlutoCell(value: 'Zobair'),
        'skill_level_field': PlutoCell(value: 3),
        'team_field': PlutoCell(value: "0"),
        'gender_field': PlutoCell(value: "X"),
      },
    ),
  ];

  void rebuild_options() {
    // var team_list = new List<int>.generate(level, (i) => i + 1);
    // var level_list = new List<int>.generate(teams, (i) => i + 1);
    // columns[1] = PlutoColumn(
    //   title: 'level',
    //   field: 'skill_level_field',
    //   type: PlutoColumnType.number(),
    // );

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    rebuild_options();
  }

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

  AlertDialog todo(BuildContext context) {
    return AlertDialog(
      title: const Text('We are adding this feature later'),
      content: Container(
        width: 300,
        child: Text("TODO"),
      ),
      actions: [
        TextButton(
          child: const Text(
            'No',
            style: TextStyle(
              color: Colors.deepOrange,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  TextEditingController team_text_controller =
      new TextEditingController(text: "4");
  TextEditingController level_text_controller =
      new TextEditingController(text: "4");

  AlertDialog settings(BuildContext context) {
    return AlertDialog(
      title: const Text("Teammaker settings"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(maxHeight: 200),
              child: TextFormField(
                validator: (value) {
                  if (null != value && value.isEmpty) {
                    return 'Enter number of teams';
                  }
                  return null;
                },
                controller: team_text_controller,
                decoration: InputDecoration(
                  labelText: "Enter number of teams",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  // The validator receives the text that the user has entered.
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            'No',
            style: TextStyle(
              color: Colors.deepOrange,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text(
            'Save',
            style: TextStyle(
              color: Colors.green,
            ),
          ),
          onPressed: () {
            setState(() {
              teams = int.parse(team_text_controller.text);
              level = int.parse(level_text_controller.text);
            });
            rebuild_options();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  AlertDialog reportingDialog(BuildContext context) {
    TextEditingController player_text = new TextEditingController();

    return AlertDialog(
      title: const Text('Add Players'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Add  player name and info.'
                '\ncomma separated info:'
                '\nNAME,SKILL LEVEL, GENDER, Team'
                '\n\nname is required, all the other value is optional'),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'zobair,4\nmike,1,MALE\njohn,1,MALE,TEAM#1',
              ),
              controller: player_text,
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            const Text(
                'if you are pasting the information from meetup, press format text from meetup'),
            ElevatedButton(
              child: const Text('Format text from meetup'),
              onPressed: () {
                String text = player_text.text;
                var lines = text.split("\n");
                var player_line = [];
                var date_field_regex =
                    RegExp(r'^(J|F|M|A|M|J|A|S|O|N|D).*(AM|PM)$');
                var record_flag = true;
                for (var i = 0; i <= lines.length - 1; i++) {
                  if ((record_flag == true) && (lines[i].trim() != "")) {
                    print(lines[i]);
                    player_line.add(lines[i]);
                    record_flag = false;
                    continue;
                  }
                  // Here if we find a pattern for date field, we record the next line.
                  print(lines[i]);
                  print(date_field_regex.hasMatch(lines[i]));
                  if (date_field_regex.hasMatch(lines[i]) == true) {
                    // print()
                    record_flag = true;
                  }
                }
                player_text.text = player_line.join("\n");
              },
            ),
            const Text(
                'if you want to add default level(3) and gender info(male), press the next button'),
            ElevatedButton(
              child: const Text("add default skill level and gender"),
              onPressed: () {
                String text = player_text.text;
                var lines = text.split("\n");

                var data = [];

                for (var i = 0; i <= lines.length - 1; i++) {
                  data.add(lines[i] + ",3" + ",M");
                }
                player_text.text = data.join("\n");
              },
            ),
            const Text('Press check button to see what will be added'),
            ElevatedButton(
              child: const Text("Check/Validate"),
              onPressed: () {
                var lines = player_text.text.split("\n");
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
                          map_data["level"] = double.tryParse(data[1]) ?? 3;
                        }
                        break;
                      case 2:
                        {
                          if (data[2].trim().toUpperCase().startsWith("M")) {
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
                showTextDialog(context, "Following players will be added",
                    string_data.join("\n"));
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            'No',
            style: TextStyle(
              color: Colors.deepOrange,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Add'),
          onPressed: () {
            var lines = player_text.text.split("\n");

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
                      map_data["level"] = double.tryParse(data[1]) ?? 3;
                    }
                    break;
                  case 2:
                    {
                      if (data[2].trim().toUpperCase().startsWith("M")) {
                        map_data["gender"] = "MALE";
                      } else if (data[2].trim().toUpperCase().startsWith("F")) {
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

              stateManager!.appendRows([
                PlutoRow(
                  checked: true,
                  cells: {
                    'name_field': PlutoCell(value: map_data["name"]),
                    'skill_level_field': PlutoCell(value: map_data["level"]),
                    'team_field': PlutoCell(value: map_data["team"]),
                    'gender_field': PlutoCell(value: map_data["gender"]),
                  },
                )
              ]);
            }
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  AlertDialog HelpDialog(BuildContext context) {
    TextEditingController player_text = new TextEditingController();

    return AlertDialog(
      title: const Text('Instructions'),
      content: Container(
        width: 300,
        child: Column(
          children: [
            const Text(
                'Add  player name and level. One player/level per line.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            'No',
            style: TextStyle(
              color: Colors.deepOrange,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void navigateToTeam() {
    //sort by team name
    print("1");
    stateManager!.sortAscending(columns[3]);
    List<PlutoRow?> dat = stateManager?.rows ?? [];

    Map<String, List<String>> teams_name_list = Map();
    Map<String, double> teams_score = Map();

    //find checked items

    List<PlutoRow?> tmp_rows = [];
    for (var i = 0; i < dat.length; i++) {
      if (dat[i]?.checked ?? false) {
        // teams_name_list.update(dat[i]?.cells?["team_field"]?.value?? "None", (value) => null)

        teams_score.update(
          dat[i]?.cells?["team_field"]?.value ?? "None",
          // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
          (existingValue) =>
              existingValue + (dat[i]?.cells?["skill_level_field"]?.value ?? 0),
          ifAbsent: () => (dat[i]?.cells?["skill_level_field"]?.value ?? 0),
        );

        teams_name_list.update(
          dat[i]?.cells?["team_field"]?.value ?? "None",
          // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
          (existingValue) {
            existingValue.add(dat[i]?.cells?["name_field"]?.value +
                "\nLevel:" +
                dat[i]?.cells?["skill_level_field"]?.value.toString() +
                "|Gender:" +
                dat[i]?.cells?["gender_field"]?.value);
            return existingValue;
          },
          ifAbsent: () => [
            (dat[i]?.cells?["name_field"]?.value +
                "\nLevel:" +
                dat[i]?.cells?["skill_level_field"]?.value.toString() +
                "|Gender:" +
                dat[i]?.cells?["gender_field"]?.value)
          ],
        );
      } else {
        //TODO unassign team

      }
      print("HI");
    }
    print("HI");
    Map<String, List<String>> teams_list = Map();
    // for (var i = 1; i <= teams; i++) {
    //   teams_list[i.toString()] = [];
    // }
    List<ListItem> teams_list_data = [];
    print(teams_list.toString());
    teams_name_list.keys.toList().forEach((value) {
      teams_list_data.add(HeadingItem(
          'TEAM#: $value', 'Level total:' + teams_score[value].toString()));
      teams_name_list[value]?.toList().forEach((name) {
        teams_list_data.add(MessageItem(name.toString(), name.toString()));
      });
    });
    print(teams_list_data);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TeamList(items: teams_list_data)));
  }

  void generateTeams({bool skill = true, gender = true}) {
    if (skill) {
      stateManager!.sortAscending(columns[1]);
    }
    if (gender) {
      stateManager!.sortDescending(columns[2]);
    }

    List<PlutoRow?> dat = stateManager?.rows ?? [];

    List<PlutoRow?> tmp_rows = [];
    for (var i = 0; i < dat.length; i++) {
      if (dat[i]?.checked ?? false) {
        tmp_rows.add(dat[i]);
      } else {
        //TODO unassign team

      }
    }

    Map<String, List<String>> teams_list = Map();
    for (var i = 1; i <= teams; i++) {
      teams_list[i.toString()] = [];
    }
    var keys = teams_list.keys.toList();
    int size = teams_list.length;
    print(tmp_rows.length);
    var start = 0;
    for (var i = 0; i < tmp_rows.length; i = i + size) {
      int end = i + size <= tmp_rows.length ? i + size : tmp_rows.length;
      List<PlutoRow?> sublist = tmp_rows.sublist(start, end);
      keys.shuffle();
      int key_i = 0;

      sublist.forEach((value) {
        var text = value?.cells?["name_field"]?.value.toString() ?? "";

        print(value?.cells?["name_field"]?.value);
        print(value?.cells?["gender_field"]?.value);
        print(value?.cells?["skill_level_field"]?.value);
        setState(() {
          value?.cells?["team_field"]?.value = keys[key_i].toString();
        });
        print(text);

        teams_list[keys[key_i]]?.add(text);
        key_i++;
      });
      start = i + size;

      // print(keys);
      // for (var j = 0; j <= keys.length - 1; j+teams) {
      //   if (tmp_rows[j] == null) {
      //     continue;
      //   }
      //
      //
      // }
    }

    navigateToTeam();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balanced Team Maker'),
      ),
      body: Container(
          child: PlutoGrid(
        columns: columns,
        rows: rows,
        configuration: PlutoGridConfiguration.dark(
          enableColumnBorder: false,
          enableMoveDownAfterSelecting: true,
          enterKeyAction: PlutoGridEnterKeyAction.editingAndMoveDown,
        ),
        onLoaded: (PlutoGridOnLoadedEvent event) {
          stateManager = event.stateManager;
        },
      )),
      bottomNavigationBar: BottomAppBar(
        child: ButtonBar(
          children: [
            IconButton(onPressed: generateTeams, icon: Icon(Icons.update)),
            IconButton(
                onPressed: navigateToTeam, icon: Icon(Icons.remove_red_eye)),
            // IconButton(onPressed: saveData, icon: Icon(Icons.save)),
            // IconButton(onPressed: loadData, icon: Icon(Icons.cloud_download)),

            IconButton(
                onPressed: () {
                  // print(rows.length);
                  showDialog<void>(
                    context: context,
                    builder: reportingDialog,
                  );
                },
                icon: Icon(Icons.add)),
            // IconButton(
            //     onPressed: () {
            //       showDialog<void>(
            //         context: context,
            //         builder: todo,
            //       );
            //     },
            //     icon: Icon(Icons.add)),
            // IconButton(
            //     onPressed: () {
            //       showDialog<void>(
            //         context: context,
            //         builder: todo,
            //       );
            //     },
            //     icon: Icon(Icons.person_off)),
            // IconButton(
            //     onPressed: () {
            //       showDialog<void>(
            //         context: context,
            //         builder: todo,
            //       );
            //     },
            //     icon: Icon(Icons.remove)),
            //
            IconButton(
              onPressed: () {
                rebuild_options();
                showDialog<void>(
                  context: context,
                  builder: settings,
                );
              },
              icon: Icon(Icons.settings),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HelpExample()));
          // print(rows.length);
          // showDialog<void>(
          //   context: context,
          //   builder: HelpDialog,
          // );
        },
        child: const FaIcon(
          FontAwesomeIcons.exclamation,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF33BDE5),
      ),
    );
  }
}
