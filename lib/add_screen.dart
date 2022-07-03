import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/model/data_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class AddScreen extends StatefulWidget {
  SettingsData settingsData;
  AddScreen(this.settingsData);

  @override
  _AddScreenState createState() => _AddScreenState(settingsData);
}

// enum SingingCharacter { lafayette, jefferson }

class _AddScreenState extends State<AddScreen> {
  final List<int> _levels = [1, 2, 3, 4, 5];
  final List<String> _genders= ["Male", "Female", "X"];
  final TextEditingController _commentController = TextEditingController();
  int _selectedLevel = 3;
  String _selectedGender = "Male";
  SettingsData settingsData;

  _AddScreenState(this.settingsData);



  TextEditingController player_text = new TextEditingController(text: ""
  );

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
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add players"),
      ),
      body: Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              width: screenWidth * 0.4,
              child: TextField(
                controller: _commentController,
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

                hint: Text("Level"),
                elevation: 0,
                value: _selectedLevel,
                onChanged: (int? item){
                    setState(() {
                      _selectedLevel = item ?? 0;
                    });
                },
                items: _levels.map((star) {
                  return DropdownMenuItem<int>(
                    child: Text(star.toString()),
                    value: star,
                  );
                }).toList(),

              ),
            ),
            Container(
              child: DropdownButton(
                  value: _selectedGender,
                  items: _genders.map((gender) {
                    return DropdownMenuItem<String>(
                      child: Text(gender),
                      value: gender,
                    );
                  }).toList(),

                  onChanged: (String? value) {
                    setState(() {
                      _selectedGender = value ?? "Male";
                    });
                  },
                  hint:Text("Select item")
              ),
            ),

            // Container(
            //   child: DropdownButton(
            //     hint: Text("Gender"),
            //     elevation: 0,
            //     value: _selectedGender,
            //     onChanged: (String? newValue){
            //       setState(() {
            //         _selectedGender = newValue ?? 0;
            //       });
            //     },
            //     items: _stars.map((star) {
            //       return DropdownMenuItem<int>(
            //         child: Text(star.toString()),
            //         value: star,
            //       );
            //     }).toList(),
            //
            //   ),
            // ),
            Container(
              child: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Icon(Icons.done),
                    onPressed: () {},
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 12.0),
        //contains average stars and total reviews card
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // InfoCard(
            //     infoValue: '2',
            //     infoLabel: "reviews",
            //     cardColor: Colors.green,
            //     iconData: Icons.comment),
            // InfoCard(
            //   infoValue: '2',
            //   infoLabel: "average stars",
            //   cardColor: Colors.lightBlue,
            //   iconData: Icons.star,
            //   key: Key('avgStar'),
            // ),
          ],
        ),
        SizedBox(height: 24.0),
        //the review menu label
        Container(
          color: Colors.grey[200],
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.comment),
              SizedBox(width: 10.0),
              Text(
                "Reviews",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        //contains list of reviews
        Expanded(
          child: Container(
            child: Text("No reviews yet"),
          ),
        ),
      ],
    ),
    ),



      // ListView(
      //   children: <Widget>[
      //     Column(
      //       children: [
      //         const Text('Add  player name and info'),
      //         const Text('One line per player. Format should be <NAME>,<LeveL>,<GENDER>'),
      //         TextField(
      //           decoration: InputDecoration(
      //             border: OutlineInputBorder(),
      //             hintText: 'zobair,4\nmike,1,MALE\njohn,1,MALE,TEAM#1',
      //           ),
      //           controller: player_text,
      //           keyboardType: TextInputType.multiline,
      //           maxLines: null,
      //         ),
      //         const Text(
      //             'if you are pasting the information from meetup, press format text from meetup'),
      //         ElevatedButton.icon(
      //           icon: Icon(FontAwesomeIcons.meetup,
      //             size: 25.0,),
      //
      //           style: ButtonStyle(
      //             padding: MaterialStateProperty.all<EdgeInsetsGeometry?>( EdgeInsets.fromLTRB(20, 15, 10, 20)),
      //             backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
      //
      //           ),
      //
      //           label: const Text('Format Text from meetup'),
      //           onPressed: () {
      //             String text = player_text.text;
      //             var lines = text.split("\n");
      //             var player_line = [];
      //             var date_field_regex =
      //             RegExp(r'^(J|F|M|A|M|J|A|S|O|N|D).*(AM|PM)$');
      //             var record_flag = true;
      //             for (var i = 0; i <= lines.length - 1; i++) {
      //               if ((record_flag == true) && (lines[i].trim() != "")) {
      //                 print(lines[i]);
      //                 player_line.add(lines[i]+ ",3" + ",M");
      //                 record_flag = false;
      //                 continue;
      //               }
      //               // Here if we find a pattern for date field, we record the next line.
      //               print(lines[i]);
      //               print(date_field_regex.hasMatch(lines[i]));
      //               if (date_field_regex.hasMatch(lines[i]) == true) {
      //                 // print()
      //                 record_flag = true;
      //               }
      //             }
      //             player_text.text = player_line.join("\n");
      //
      //
      //           },
      //         ),
      //         const Text(
      //             'if you want to add default level(3) and gender info(male), press the next button'),
      //         ElevatedButton.icon(
      //           icon: Icon(FontAwesomeIcons.addressCard,
      //             size: 25.0,),
      //
      //           style: ButtonStyle(
      //             padding: MaterialStateProperty.all<EdgeInsetsGeometry?>( EdgeInsets.fromLTRB(20, 15, 10, 20)),
      //             backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
      //
      //           ),
      //           label: const Text('Add default level and gender'),
      //           onPressed: () {
      //             String text = player_text.text;
      //             var lines = text.split("\n");
      //             var data = [];
      //             for (var i = 0; i <= lines.length - 1; i++) {
      //               data.add(lines[i] + ",3" + ",M");
      //             }
      //             player_text.text = data.join("\n");
      //           },
      //         ),
      //         const Text('Press check button to see what will be added'),
      //         ElevatedButton.icon(
      //           icon: Icon(FontAwesomeIcons.search,
      //             size: 25.0,),
      //
      //           style: ButtonStyle(
      //             padding: MaterialStateProperty.all<EdgeInsetsGeometry?>( EdgeInsets.fromLTRB(20, 15, 10, 20)),
      //             backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
      //
      //           ),
      //           label: const Text("Check/Validate"),
      //           onPressed: () {
      //             var lines = player_text.text.split("\n");
      //             var string_data = [];
      //
      //             for (var i = 0; i <= lines.length - 1; i++) {
      //               var map_data = {
      //                 "name": "x",
      //                 "level": 3,
      //                 "gender": "MALE",
      //                 "team": "None"
      //               };
      //
      //               var data = lines[i].split(",");
      //               for (var j = 0; j < data.length; j++) {
      //                 switch (j) {
      //                   case 0:
      //                     {
      //                       map_data["name"] = data[0];
      //                     }
      //                     break;
      //                   case 1:
      //                     {
      //                       map_data["level"] = double.tryParse(data[1]) ?? 3;
      //                     }
      //                     break;
      //                   case 2:
      //                     {
      //                       if (data[2].trim().toUpperCase().startsWith("M")) {
      //                         map_data["gender"] = "MALE";
      //                       } else if (data[2]
      //                           .trim()
      //                           .toUpperCase()
      //                           .startsWith("F")) {
      //                         map_data["gender"] = "FEMALE";
      //                       } else {
      //                         map_data["gender"] = "X";
      //                       }
      //                     }
      //                     break;
      //                   case 3:
      //                     {
      //                       map_data["team"] = data[3];
      //                     }
      //                     break;
      //                   default:
      //                     {
      //                       break;
      //                     }
      //                 }
      //               }
      //               string_data.add(map_data.toString() + "\n");
      //             }
      //             showTextDialog(context, "Following players will be added",
      //                 string_data.join("\n"));
      //           },
      //         ),
      //         ElevatedButton.icon(
      //           icon: Icon(FontAwesomeIcons.copy,
      //             size: 25.0,),
      //
      //           style: ButtonStyle(
      //             padding: MaterialStateProperty.all<EdgeInsetsGeometry?>( EdgeInsets.fromLTRB(20, 15, 10, 20)),
      //             backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
      //
      //           ),
      //           label: const Text("Check/Validate"),
      //           onPressed: () {
      //             Clipboard.setData(ClipboardData(text: player_text.value.text));
      //           },
      //         ),
      //       ],
      //     ),
      //   ],
      // ),
    );
  }
}
