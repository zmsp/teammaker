import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import './home_screen.dart';


class TeamScreen extends StatefulWidget {
  static const routeName = 'feature/team';
  final Map <String, List<String>>? teams_list;
  TeamScreen({
    this.teams_list,
  });

  @override
  _TeamScreenState createState() => _TeamScreenState(teams_list:teams_list);
}

class _TeamScreenState extends State<TeamScreen> {
  final Map <String, List<String>>? teams_list;
  _TeamScreenState({
    this.teams_list,
  });
  String text_data = "";
  @override
  void initState() {
    super.initState();
    teams_list?.forEach((key, value) {
      text_data =  text_data + "team: " + key + " -players: " + value.join(" ,") + "\n";
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: Column(
          children: [
            Text('$text_data'),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Go back")
            ),
          ],
        ),
      ),
    );
  }
}