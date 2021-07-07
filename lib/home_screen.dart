import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pluto_grid/pluto_grid.dart';

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

class _PlutoExampleScreenState extends State<PlutoExampleScreen> {
  PlutoGridStateManager? stateManager;
  int teams = 4;

  int level = 4;
  List<PlutoColumn> columns = [
    /// Text Column definition
    PlutoColumn(
      title: 'name',
      field: 'name_field',
      type: PlutoColumnType.text(),
    ),

    /// Number Column definition
    PlutoColumn(
      title: 'levels',
      field: 'skill_level_field',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: 'team',
      field: 'team_field',
      type: PlutoColumnType.number(),
    )
  ];

  List<PlutoRow> rows = [
    PlutoRow(
      cells: {
        'name_field': PlutoCell(value: 'Text cell gg'),
        'skill_level_field': PlutoCell(value: 1),
        'team_field': PlutoCell(value: 1),
      },
    )
  ];
  void rebuild_options() {
    var team_list = new List<int>.generate(level, (i) => i + 1);
    var level_list = new List<int>.generate(teams, (i) => i + 1);
    columns[1] = PlutoColumn(
      title: 'skill_level_field',
      field: 'skill_level_field',
      type: PlutoColumnType.select(team_list, readOnly: false, defaultValue: 2),
    );
    columns[2] = PlutoColumn(
      title: 'team_field',
      field: 'team_field',
      type: PlutoColumnType.select([1, 2, 3, 4, 5, 4, 4]),
    );
    columns[2] = PlutoColumn(
      title: 'team_field',
      field: 'team_field',
      type: PlutoColumnType.select([5, 2, 3, 2, 5, 4, 4]),
    );

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    rebuild_options();

    //
    //
    // columns = [
    //   /// Text Column definition
    //   PlutoColumn(
    //     title: 'name',
    //     field: 'name_field',
    //     type: PlutoColumnType.text(),
    //   ),
    //
    //   /// Number Column definition
    //   PlutoColumn(
    //     title: 'number column',
    //     field: 'skill_level_field',
    //     type: PlutoColumnType.number(),
    //   ),
    //
    //   /// Select Column definition
    //   PlutoColumn(
    //     title: 'select column',
    //     field: 'select_field',
    //     type: PlutoColumnType.select(['item1', 'item2', 'item3']),
    //   ),
    //
    //   /// Datetime Column definition
    //   PlutoColumn(
    //     title: 'date column',
    //     field: 'date_field',
    //     type: PlutoColumnType.date(),
    //   ),
    //
    //   /// Time Column definition
    //   PlutoColumn(
    //     title: 'time column',
    //     field: 'time_field',
    //     type: PlutoColumnType.time(),
    //   ),
    // ];
    //
    // List<PlutoRow> rows = [
    //   PlutoRow(
    //     cells: {
    //       'name_field': PlutoCell(value: 'Text cell gg'),
    //       'skill_level_field': PlutoCell(value: 2020),
    //       'select_field': PlutoCell(value: 'item1'),
    //       'date_field': PlutoCell(value: '2020-08-06'),
    //       'time_field': PlutoCell(value: '12:30'),
    //     },
    //   ),
    //   PlutoRow(
    //     cells: {
    //       'name_field': PlutoCell(value: 'Text cell value2'),
    //       'skill_level_field': PlutoCell(value: 2021),
    //       'select_field': PlutoCell(value: 'item2'),
    //       'date_field': PlutoCell(value: '2020-08-07'),
    //       'time_field': PlutoCell(value: '18:45'),
    //     },
    //   ),
    //   PlutoRow(
    //     cells: {
    //       'name_field': PlutoCell(value: 'Text cell value3'),
    //       'skill_level_field': PlutoCell(value: 2022),
    //       'select_field': PlutoCell(value: 'item3'),
    //       'date_field': PlutoCell(value: '2020-08-08'),
    //       'time_field': PlutoCell(value: '23:59'),
    //     },
    //   ),
    // ];
  }

  AlertDialog todo(BuildContext context) {
    TextEditingController emailController = new TextEditingController();
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

  AlertDialog settings(BuildContext context) {
    TextEditingController team_text_controller =
        new TextEditingController(text: teams.toString());
    TextEditingController level_text_controller =
        new TextEditingController(text: level.toString());
    return AlertDialog(
      title: const Text('Set number of teams and skill levels'),
      content: Container(
        height: 200,
        width: 400,
        child: Column(
          children: [
            TextFormField(
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
            TextFormField(
              controller: level_text_controller,
              validator: (value) {
                if (null != value && value.isEmpty) {
                  return 'Enter number of teams';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: "Enter number of skill levels",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                // The validator receives the text that the user has entered.
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
    TextEditingController emailController = new TextEditingController();
    return AlertDialog(
      title: const Text('Add Players'),
      content: Container(
        width: 300,
        child: Column(
          children: [
            const Text('Paste from meetup, or type one player per line'),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            TextButton(
              child: const Text('Format text from meetup'),
              onPressed: () {
                String text = emailController.text;
                var lines = text.split("\n");
                var player_line = [lines[0]];

                for (var i = 0; i <= lines.length - 1; i++) {
                  String line = lines[i];
                  String last = player_line.last;

                  if (line == last) {
                    continue;
                  } else if ((line.endsWith("PM")) || (line.endsWith("AM"))) {
                    continue;
                  } else if ((line.trim() == "")) {
                    continue;
                  } else {
                    player_line.add(lines[i]);
                  }
                }
                print(player_line);
                emailController.text = player_line.join("\n");
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
          child: const Text('add players'),
          onPressed: () {
            var lines = emailController.text.split("\n");

            for (var i = 0; i <= lines.length - 1; i++) {
              var data = lines[i].split(",");
              int skill = 3;
              int team = 0;
              if (data.length == 2) {
                skill = int.parse(data[1]);
              }
              if (data.length == 3) {
                team = int.parse(data[2]);
              }

              stateManager!.appendRows([
                PlutoRow(
                  cells: {
                    'name_field': PlutoCell(value: data[0]),
                    'skill_level_field': PlutoCell(value: skill),
                    'team_field': PlutoCell(value: team),
                  },
                )
              ]);
            }
            ;
            print(rows.length);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlutoGrid Demo'),
      ),
      body: Container(
          child: PlutoGrid(
        columns: columns,
        rows: rows,
        onLoaded: (PlutoGridOnLoadedEvent event) {
          stateManager = event.stateManager;
        },
      )),
      bottomNavigationBar: BottomAppBar(
        child: ButtonBar(
          children: [
            IconButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: todo,
                  );
                },
                icon: Icon(Icons.add)),
            IconButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: todo,
                  );
                },
                icon: Icon(Icons.person_off)),
            IconButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: todo,
                  );
                },
                icon: Icon(Icons.remove)),
            IconButton(
                onPressed: () {

                  stateManager!.sortAscending(columns[1]);
                  var tmp_rows = stateManager!.rows;
                  Map <String, List<String>> teams_list = Map();
                  for (var i = 0; i < teams; i ++){
                    teams_list[i.toString()] = [];
                  }


                  var keys = teams_list.keys.toList();
                  for (var i = 0; i <= tmp_rows.length - 1; i+teams) {
                    var subrows = tmp_rows.getRange(i, i+teams).toList();
                    keys.shuffle();
                    for (var j = 0; j <= keys.length - 1; j+teams) {
                      if (subrows[j] == null) {
                        continue;
                      }

                      teams_list[keys[j]]?.add(subrows[i]?.cells?["a"].toString()??"None");
                    }
                  }
                  print(teams_list.toString());
                  }
,
                icon: Icon(Icons.update)),
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
          // print(rows.length);
          showDialog<void>(
            context: context,
            builder: reportingDialog,
          );
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
