import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/InfoCard.dart';
import 'package:teammaker/model/data_model.dart';

class Review extends StatefulWidget {
  @override
  ReviewState createState() {
    return new ReviewState();
  }
}

class ReviewState extends State<Review> {
  final List<int> _levels = [1, 2, 3, 4, 5];
  final List<String> _genders = ["male", "female", "x"];
  final TextEditingController _commentController = TextEditingController();
  int _selectedLevel = 3;
  String _selectedGender = "male";
  TextEditingController textarea = TextEditingController();
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: "Add listed players",
        onPressed: () {
          Navigator.pop(context);
          // print(rows.length);
          // showDialog<void>(
          //   context: context,
          //   builder: HelpDialog,
          // );
        },
        child: const FaIcon(
          FontAwesomeIcons.plus,
          color: Colors.white,
        ),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 12.0),
          ListTile(
            title: const Text('Batch add'),
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

          useEditor ? Row(
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
                      _selectedGender = item ?? "male";
                    });
                  },
                ),
              ),
              Container(
                child: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: Icon(Icons.person_add),
                      onPressed: () {},
                    );
                  },
                ),
              ),
            ],
          ) : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[

                  ElevatedButton.icon(
                      icon: Icon(FontAwesomeIcons.meetup,
                        size: 25.0,),
                      onPressed: (){
                        print(textarea.text);
                      },
                      label: Text("Paste Meetup")
                  ),

                  ElevatedButton.icon(
                      icon: Icon(FontAwesomeIcons.alignRight,
                        size: 25.0,),
                      onPressed: (){
                        print(textarea.text);
                      },
                      label: Text("Format Lines")
                  ),
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

                keyboardType: TextInputType.multiline,
                maxLines: 6,
                decoration: InputDecoration(
                    hintText: "Enter players levels and gender. One player per line.\nFormat: <Name>,<Level>,<Gender>"
                        "\n---Example--- \nZobair,3,M, \nMary,2,Female \nZach,5,male",
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.redAccent)
                    )
                ),

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
                  "Players List",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          //contains list of reviews
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Text("None yet"),
            ),
          ),
        ],
      ),
    );
  }
}
