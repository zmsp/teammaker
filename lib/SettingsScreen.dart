import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/model/data_model.dart';

class SettingsScreen extends StatefulWidget {
  SettingsData settingsData;

  SettingsScreen(this.settingsData);

  @override
  _SettingsScreenState createState() => _SettingsScreenState(settingsData);
}

// enum SingingCharacter { lafayette, jefferson }

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsData settingsData;

  _SettingsScreenState(this.settingsData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Options"),
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
          FontAwesomeIcons.check,
        ),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.question_answer_outlined,
                  size: 40.0,
                ),
                title: Text('How do you want your teams?'),
              ),
              ListTile(
                subtitle: Column(children: <Widget>[
                  ListTile(
                    title: const Text('Gender and skill balanced team'),
                    leading: Radio<GEN_OPTION>(
                      value: GEN_OPTION.distribute,
                      groupValue: settingsData.o,
                      onChanged: (GEN_OPTION? value) {
                        setState(() {
                          settingsData.o = value ?? settingsData.o;
                        });
                      },
                    ),
                    subtitle: Column(
                      children: [
                        settingsData.o == GEN_OPTION.distribute
                            ? TextFormField(
                                decoration: const InputDecoration(
                                  label: Text("Number of teams"),
                                  hintText:
                                      'How many teams do you want to split the players to?',
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
                                textAlign: TextAlign.left)
                            : Text(""),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('Division based on skill level'),
                    leading: Radio<GEN_OPTION>(
                      value: GEN_OPTION.division,
                      groupValue: settingsData.o,
                      onChanged: (GEN_OPTION? value) {
                        setState(() {
                          settingsData.o = value ?? settingsData.o;
                        });
                      },
                    ),
                    subtitle: settingsData.o == GEN_OPTION.division
                        ? Column(
                            children: [
                              TextFormField(
                                  decoration: const InputDecoration(
                                    label: Text('Number of divisions'),
                                    hintText:
                                        'Division number means top teams will have better players',
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  initialValue:
                                      settingsData.division.toString(),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    settingsData.division =
                                        int.tryParse(value) ??
                                            settingsData.division;
                                  },
                                  textAlign: TextAlign.left),
                              TextFormField(
                                  decoration: const InputDecoration(
                                    label: Text("Number of teams"),
                                    hintText:
                                        'How many teams do you want to split the players to?',
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  initialValue:
                                      settingsData.teamCount.toString(),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    settingsData.teamCount =
                                        int.tryParse(value) ??
                                            settingsData.teamCount;
                                  },
                                  textAlign: TextAlign.left),
                            ],
                          )
                        : Text(""),
                  ),
                  ListTile(
                    title: const Text('Skill balanced by team size'),
                    leading: Radio<GEN_OPTION>(
                      value: GEN_OPTION.proportion,
                      groupValue: settingsData.o,
                      onChanged: (GEN_OPTION? value) {
                        setState(() {
                          settingsData.o = value ?? settingsData.o;
                        });
                      },
                    ),
                    subtitle: settingsData.o == GEN_OPTION.proportion
                        ? TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Number of players per team'),
                              hintText: 'How many players per team',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue: settingsData.proportion.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              settingsData.proportion =
                                  int.tryParse(value) ?? settingsData.proportion;
                            },
                            textAlign: TextAlign.left)
                        : Text(""),
                  ),
                  ListTile(
                    title: const Text('Random'),
                    leading: Radio<GEN_OPTION>(
                      value: GEN_OPTION.random,
                      groupValue: settingsData.o,
                      onChanged: (GEN_OPTION? value) {
                        setState(() {
                          settingsData.o = value ?? settingsData.o;
                        });
                      },
                    ),
                    subtitle: Column(
                      children: [
                        settingsData.o == GEN_OPTION.random
                            ? TextFormField(
                                decoration: const InputDecoration(
                                  label: Text("Number of teams"),
                                  hintText:
                                      'How many teams do you want to split the players to?',
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
                                textAlign: TextAlign.left)
                            : Text(""),
                      ],
                    ),
                  )
                ]),
              ),
              Divider(
                height: 5.0,
              ),
              ListTile(
                title: ElevatedButton(
                  onPressed: () {
                    // Close the screen and return "Yep!" as the result.
                    print(settingsData);
                    Navigator.pop(context, settingsData);
                  },
                  child: const Text('Update Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
