import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pluto_grid/pluto_grid.dart';
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

class _PlutoExampleScreenState extends State<PlutoExampleScreen> {
  PlutoGridStateManager? stateManager;

  int teams = 4;

  int level = 4;
  List<PlutoColumn> columns = [
    /// Text Column definition
    // PlutoColumn(
    //   title: 'column1',
    //   field: 'column1',
    //   type: PlutoColumnType.text(),
    //   enableRowDrag: true,
    //   enableRowChecked: true,
    //   width: 250,
    //   minWidth: 175,
    //   renderer: (rendererContext) {
    //     return Row(
    //       children: [
    //         IconButton(
    //           icon: const Icon(
    //             Icons.add_circle,
    //           ),
    //           onPressed: () {
    //             rendererContext.stateManager!.insertRows(
    //               rendererContext.rowIdx!,
    //               [rendererContext.stateManager!.getNewRow()],
    //             );
    //           },
    //           iconSize: 18,
    //           color: Colors.green,
    //           padding: const EdgeInsets.all(0),
    //         ),
    //         IconButton(
    //           icon: const Icon(
    //             Icons.remove_circle_outlined,
    //           ),
    //           onPressed: () {
    //             rendererContext.stateManager!
    //                 .removeRows([rendererContext.row]);
    //           },
    //           iconSize: 18,
    //           color: Colors.red,
    //           padding: const EdgeInsets.all(0),
    //         ),
    //         Expanded(
    //           child: Text(
    //             rendererContext
    //                 .row!.cells[rendererContext.column!.field]!.value
    //                 .toString(),
    //             maxLines: 1,
    //             overflow: TextOverflow.ellipsis,
    //           ),
    //         ),
    //       ],
    //     );
    //   },
    // ),
    PlutoColumn(
      enableRowDrag: true,
      enableRowChecked: true,
      title: 'name',
      field: 'name_field',
      frozen: PlutoColumnFrozen.left,
      type: PlutoColumnType.text(),
      renderer: (rendererContext) {
        return Row(
          children: [
            Expanded(
              child: Text(
                rendererContext
                    .row!.cells[rendererContext.column!.field]!.value
                    .toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
              iconSize: 18,
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
              iconSize: 18,
              color: Colors.red,
              padding: const EdgeInsets.all(0),
            ),

          ],
        );
      },
    ),
    PlutoColumn(
      title: 'team#',
      field: 'team_field',
      frozen: PlutoColumnFrozen.right,
      type: PlutoColumnType.number(),
    ),

    /// Number Column definition
    PlutoColumn(
      title: 'levels',
      field: 'skill_level_field',
      type: PlutoColumnType.number(),
    )
  ];

  List<PlutoRow> rows = [
    PlutoRow(
      cells: {
        'name_field': PlutoCell(value: 'two'),
        'skill_level_field': PlutoCell(value: 2),
        'team_field': PlutoCell(value: 2),


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
      title: const Text('Set number of teams and skill levels'),
      content: SingleChildScrollView(

        child: Column(
          children: [
            Container(
                constraints: BoxConstraints(maxHeight: 200),
                child:   TextFormField(
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
    TextEditingController player_text = new TextEditingController();

    return AlertDialog(
      title: const Text('Add Players'),
      content: Container(
        width: 300,
        child: Column(
          children: [
            const Text('Add  player name and level. One player/level per line.'),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'zobair,4\nmike,1\njohn,1',
              ),
              controller: player_text,
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            ElevatedButton(
              child: const Text('Format text from meetup'),
              onPressed: () {
                String text = player_text.text;
                var lines = text.split("\n");
                var player_line = [lines[0]];
                var data = [lines[0]+",3"];
                var regex = "/(?<!\d)4\d{2}(?!\d)/";

                for (var i = 0; i <= lines.length - 1; i++) {
                  String line = lines[i];
                  String last = player_line.last;

                  if (line == last) {
                    continue;
                  } else if ((line.endsWith("PM")) || (line.endsWith("AM"))|| (line.startsWith("Event")) || int.tryParse(line.trim())!=null) {
                    continue;
                  } else if ((line.trim() == "")) {
                    continue;
                  }
                  else {
                    player_line.add(lines[i]);
                    data.add(lines[i] +",3");
                  }
                }
                print(player_line);
                player_text.text = data.join("\n");
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
            var lines = player_text.text.split("\n");

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
                  checked: true,
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
            Container(
              width:166,
              child: TextField(
                decoration: new InputDecoration(labelText: "How many teams?"),
                keyboardType: TextInputType.number,
                controller:team_text_controller ,
                //
                // onChanged: (value){
                //   if (int.tryParse(value.trim())!=null){
                //     setState(() {
                //       teams = int.parse(value.trim());
                //     });
                //
                //   }
                //
                // },
                // Only numbers can be entered
              ),
            ),
            ElevatedButton.icon(
              label: Text("Generate Team"),
                onPressed: () {

                  stateManager!.sortAscending(columns[1]);
                  var dat=stateManager?.rows ??[];
                  var tmp_rows=[];
                  for (var i = 0; i < dat.length; i++){
                    print(dat[i]?.checked);
                    if (dat[i]?.checked?? false){
                      tmp_rows.add(dat[i]);
                    }
                  }


                  Map <String, List<String>> teams_list = Map();
                  for (var i = 0; i < teams; i ++){
                    teams_list[i.toString()] = [];
                  }
                  var keys = teams_list.keys.toList();
                  int size = teams_list.length;
                  print(size);
                  var start = 0;
                  for (var i = start; i < tmp_rows.length; i=i+size){
                    int end = i+size < tmp_rows.length? i+size :  tmp_rows.length -1;
                    var sublist = tmp_rows.sublist(start, end);
                    keys.shuffle();
                    int key_i = 0;
                    sublist.forEach((value) {
                      var text = value?.cells?["name_field"]?.value.toString() ?? "";
                      teams_list[keys[key_i]]?.add(text);
                      key_i++;

                    });
                    start = i+size;

                    // print(keys);
                    // for (var j = 0; j <= keys.length - 1; j+teams) {
                    //   if (tmp_rows[j] == null) {
                    //     continue;
                    //   }
                    //
                    //
                    // }
                  }

                  Navigator.push(context, MaterialPageRoute(builder: (context) => TeamScreen(teams_list: teams_list,)));
                }
                ,
                icon: Icon(Icons.update)),
            ElevatedButton.icon(
                label: Text("Add Players"),
                onPressed: () {
                  // print(rows.length);
                  showDialog<void>(
                    context: context,
                    builder: reportingDialog,
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
