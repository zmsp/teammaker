// ignore_for_file: deprecated_member_use, must_be_immutable
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
                    title: const Text('Fair Mix (Recommended)'),
                    leading: Radio<GEN_OPTION>(
                      value: GEN_OPTION.even_gender,
                      groupValue: settingsData.o,
                      onChanged: (GEN_OPTION? value) {
                        setState(() {
                          settingsData.o = value ?? settingsData.o;
                        });
                      },
                    ),
                    subtitle: settingsData.o == GEN_OPTION.even_gender
                        ? TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Players per team'),
                              hintText:
                                  'Mixes players by gender and skill fairly',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue: settingsData.proportion.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              settingsData.proportion = int.tryParse(value) ??
                                  settingsData.proportion;
                            },
                            textAlign: TextAlign.left)
                        : const Text(""),
                  ),
                  ListTile(
                    title: const Text('Skill Balance'),
                    leading: Radio<GEN_OPTION>(
                      value: GEN_OPTION.distribute,
                      groupValue: settingsData.o,
                      onChanged: (GEN_OPTION? value) {
                        setState(() {
                          settingsData.o = value ?? settingsData.o;
                        });
                      },
                    ),
                    subtitle: settingsData.o == GEN_OPTION.distribute
                        ? TextFormField(
                            decoration: const InputDecoration(
                              label: Text("Number of teams"),
                              hintText: 'Splits players by skill level only',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue: settingsData.teamCount.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              settingsData.teamCount =
                                  int.tryParse(value) ?? settingsData.teamCount;
                            },
                            textAlign: TextAlign.left)
                        : const Text(""),
                  ),
                  ListTile(
                    title: const Text('Ranked Groups'),
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
                                    label: Text('Number of groups'),
                                    hintText: 'Keeps strong players together',
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
                                    hintText: 'Total teams to create',
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
                        : const Text(""),
                  ),
                  ListTile(
                    title: const Text('Random Mix'),
                    leading: Radio<GEN_OPTION>(
                      value: GEN_OPTION.random,
                      groupValue: settingsData.o,
                      onChanged: (GEN_OPTION? value) {
                        setState(() {
                          settingsData.o = value ?? settingsData.o;
                        });
                      },
                    ),
                    subtitle: settingsData.o == GEN_OPTION.random
                        ? TextFormField(
                            decoration: const InputDecoration(
                              label: Text("Number of teams"),
                              hintText: 'Pure random splitting',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue: settingsData.teamCount.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              settingsData.teamCount =
                                  int.tryParse(value) ?? settingsData.teamCount;
                            },
                            textAlign: TextAlign.left)
                        : const Text(""),
                  ),
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
