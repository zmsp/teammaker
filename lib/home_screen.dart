import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:teammaker/HelpScreen.dart';
import 'package:teammaker/SettingsScreen.dart';
import 'package:teammaker/add_players.dart';
import 'package:teammaker/model/data_model.dart';
import 'package:teammaker/model/player_model.dart';
import 'package:teammaker/team_screen.dart';
import 'package:pluto_grid_export/pluto_grid_export.dart' as pluto_grid_export;

import 'package:flutter/material.dart';
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
  SettingsData settingsData = new SettingsData();
  final storage = new LocalStorage('my_data.json');

  void exportToCsv() async {
    String title = "pluto_grid_export";
    if (stateManager != null){
      var exported = const Utf8Encoder()
          .convert(pluto_grid_export.PlutoGridExport.exportCSV(stateManager!));

      var test = pluto_grid_export.PlutoGridExport.exportCSV(stateManager!, fieldDelimiter: ",", textDelimiter: "", textEndDelimiter: "")
      ;
      Clipboard.setData(
          new ClipboardData(text:test));
      print(test);


    }



    // use file_saver from pub.dev
  }

  // void saveData() {
  //   final Iterable<Map<String, dynamic>>? rowsToUpdate =
  //       stateManager?.rows.map((e) {
  //     return {
  //       'name_field': e?.cells['name_field']?.value,
  //       'skill_level_field': e?.cells['skill_level_field']?.value,
  //       'gender_field': e?.cells['gender_field']?.value,
  //       'team_field': e?.cells['team_field']?.value,
  //     };
  //   });
  //   // update rowsToUpdate
  //
  //   print(jsonEncode(rowsToUpdate));
  //
  //   storage.setItem('todos', jsonEncode(rowsToUpdate));
  // }

  void loadData() {
    print(storage.getItem('todos'));
  }

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
      title: 'Level',
      field: 'skill_level_field',
      type: PlutoColumnType.select([1, 2, 3, 4, 5]),
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
        'name_field': PlutoCell(value: 'Sample Player'),
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

  String data = """
John,3,M
Jane,4,F""";

  AlertDialog reportingDialog(BuildContext context) {
    TextEditingController player_text = new TextEditingController(text: data);

    return AlertDialog(
      title: const Text('Add Players'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Add  player name and info'),
            const Text(
                'One line per player. Format should be <NAME>,<LeveL>,<GENDER>'),
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
            ElevatedButton.icon(
              icon: Icon(
                FontAwesomeIcons.meetup,
                size: 25.0,
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                    EdgeInsets.fromLTRB(20, 15, 10, 20)),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.redAccent),
              ),
              label: const Text('Format Text from meetup'),
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
                    player_line.add(lines[i] + ",3" + ",M");
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
            ElevatedButton.icon(
              icon: Icon(
                FontAwesomeIcons.addressCard,
                size: 25.0,
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                    EdgeInsets.fromLTRB(20, 15, 10, 20)),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.redAccent),
              ),
              label: const Text('Add default level and gender'),
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
            ElevatedButton.icon(
              icon: Icon(
                FontAwesomeIcons.search,
                size: 25.0,
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                    EdgeInsets.fromLTRB(20, 15, 10, 20)),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.redAccent),
              ),
              label: const Text("Check/Validate"),
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
                      map_data["level"] = int.tryParse(data[1]) ?? 3;
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

  void addPlayers(List<PlayerModel> players) {
    for (var player in players) {
      stateManager!.appendRows([
        PlutoRow(
          checked: true,
          cells: {
            'name_field': PlutoCell(value: player.name),
            'skill_level_field': PlutoCell(value: player.level),
            'team_field': PlutoCell(value: player.team),
            'gender_field': PlutoCell(value: player.gender),
          },
        )
      ]);
    }
  }

  void navigateToTeam() {
    //sort by team name

    stateManager!.sortAscending(columns[3]);
    List<PlutoRow?> dat = stateManager?.rows ?? [];

    Map<String, List<String>> teams_name_list = Map();
    Map<String, double> teams_total_score = Map();
    Map<String, double> teams_avg_score = Map();
    //find checked items

    List<PlutoRow?> tmp_rows = [];
    for (var i = 0; i < dat.length; i++) {
      if (dat[i]?.checked ?? false) {
        // teams_name_list.update(dat[i]?.cells?["team_field"]?.value?? "None", (value) => null)
        var t = dat[i]?.cells?["skill_level_field"]?.value;
        print(t.runtimeType);
        teams_total_score.update(
          dat[i]?.cells?["team_field"]?.value ?? "None",
          // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
          (existingValue) =>
              existingValue +
              (dat[i]?.cells?["skill_level_field"]?.value ?? 0).toDouble(),
          ifAbsent: () =>
              (dat[i]?.cells?["skill_level_field"]?.value ?? 0).toDouble(),
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
    }

    Map<String, List<String>> teams_list = Map();
    // for (var i = 1; i <= teams; i++) {
    //   teams_list[i.toString()] = [];
    // }
    List<ListItem> teams_list_data = [];
    // print(teams_list.toString());
    teams_name_list.keys.toList().forEach((value) {
      teams_list_data.add(HeadingItem(
          'TEAM#: $value', 'Level total:' + teams_total_score[value].toString()));
      teams_name_list[value]?.toList().forEach((name) {
        teams_list_data.add(MessageItem(name.toString(), name.toString()));
      });
    });
    // print(teams_list_data);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TeamList(items: teams_list_data)));
  }

  void generateTeams() {
    switch (settingsData.o) {
      case GEN_OPTION.random:
        {}
        break;

      case GEN_OPTION.division:
        {
          stateManager!.sortAscending(columns[1]);
        }
        break;
      case GEN_OPTION.distribute:
        {
          stateManager!.sortAscending(columns[1]);
          stateManager!.sortDescending(columns[2]);
          //statements;
        }
        break;
      case GEN_OPTION.proportion:
        {
          stateManager!.sortAscending(columns[1]);
          stateManager!.sortDescending(columns[2]);
          int player_num = stateManager?.checkedRows.length ?? 1;
          settingsData.teamCount =  (player_num/settingsData.proportion).round();
          print("TEASM ${ settingsData.teamCount}");
          //statements;
        }
        break;

      default:
        {
          //statements;
        }
        break;
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
    for (var i = 1; i <= settingsData.teamCount; i++) {
      teams_list[i.toString()] = [];
    }
    var keys = teams_list.keys.toList();
    int size = teams_list.length;
    print(tmp_rows.length);
    var start = 0;
    if (settingsData.o == GEN_OPTION.division) {
      var subKeys = keys.length / settingsData.division;
      var chunks = [];
      for (var i = 0; i < keys.length; i += 2) {
        chunks.add(keys.sublist(i, i + 2 > keys.length ? keys.length : i + 2));
      }
      double dat = (tmp_rows.length / chunks.length);

      int size = chunks.length;

      for (var i = 0; i < tmp_rows.length; i = i + size) {
        int row = (i / dat).toInt();
        int end = i + size <= tmp_rows.length ? i + size : tmp_rows.length;
        List<PlutoRow?> sublist = tmp_rows.sublist(start, end);
        var key1 = chunks[row];
        key1.shuffle();
        int key_i = 0;

        sublist.forEach((value) {
          var text = value?.cells?["name_field"]?.value.toString() ?? "";

          setState(() {
            value?.cells?["team_field"]?.value = key1[key_i].toString();
          });
          print(text);

          teams_list[key1[key_i]]?.add(text);
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
    } else {
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ButtonBar(
              children: [
                Tooltip(
                  message: 'Shuffle players into teams!',
                  child: IconButton(
                      onPressed: generateTeams,
                      icon: FaIcon(FontAwesomeIcons.random)),
                ),

                Tooltip(
                  message: 'View Current Teams',
                  child: IconButton(
                      onPressed: navigateToTeam,
                      icon: FaIcon(FontAwesomeIcons.users)),
                ),
                // IconButton(onPressed: saveData, icon: Icon(Icons.save)),
                // IconButton(onPressed: loadData, icon: Icon(Icons.cloud_download)),

                Tooltip(
                  message: 'Add a list of players',
                  child: IconButton(
                    onPressed: () async {
                      final List<PlayerModel> players = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddPlayersScreen()));

                      addPlayers(players);
                    },

                    //
                    // onPressed: () {
                    //   // print(rows.length);
                    //   showDialog<void>(
                    //     context: context,
                    //     builder: reportingDialog,
                    //   );
                    // },
                    icon: FaIcon(FontAwesomeIcons.plus),
                  ),
                )
              ],
            ),
            ButtonBar(
              children: [
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
                Tooltip(
                  message: 'Get help',
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HelpExample()));
                    },
                    icon: FaIcon(FontAwesomeIcons.questionCircle),
                  ),
                ),
                Tooltip(
                  message: 'Export',
                  child: IconButton(
                    onPressed: () {
                      exportToCsv();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Text Copied! Save it somewhere for future!"),
                      ));


                    },
                    icon: FaIcon(FontAwesomeIcons.share),
                  ),
                ),
                Tooltip(
                  message: 'Team-maker settings',
                  child: IconButton(
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SettingsScreen(settingsData)));

                      print(settingsData.o);
                    },
                    icon: FaIcon(FontAwesomeIcons.cog),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final List<PlayerModel> players = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddPlayersScreen()));

          addPlayers(players);
          // print(rows.length);
          // showDialog<void>(
          //   context: context,
          //   builder: HelpDialog,
          // );
        },
        child: const FaIcon(
          FontAwesomeIcons.plus,
        ),
      ),
    );
  }
}
