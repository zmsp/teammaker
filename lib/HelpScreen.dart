import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpExample extends StatefulWidget {
  @override
  _HelpExampleState createState() => _HelpExampleState();
}

enum Status { none, running, stopped, paused }

class _HelpExampleState extends State<HelpExample> {
  Future<void> _launchInBrowser(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HELP PAGE"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Getting Started',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(FontAwesomeIcons.circlePlay,
                    color: Colors.white, size: 20),
              ),
              title: const Text('How to create teams?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text(
                  'Watch a short video tutorial on adding players and generating balanced teams.'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoApp('asset/video/meetup.mp4',
                            "Meetup entry", "how to add from meetup")));
              },
            ),
          ),
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 24.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.redAccent,
                child: Icon(FontAwesomeIcons.meetup,
                    color: Colors.white, size: 20),
              ),
              title: const Text('Import from Meetup',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text(
                  'Learn how to seamlessly pull player RSVPs directly from your Meetup event.'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoApp('asset/video/meetup.mp4',
                            "Meetup entry", "how to add from meetup")));
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Resources & Support',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(FontAwesomeIcons.bookOpen,
                      color: Colors.white, size: 20),
                ),
                title: const Text('Read the User Manual',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text(
                    'Detailed documentation on all available features, generation strategies, and match management.'),
                onTap: () {
                  _launchInBrowser(
                      "https://github.com/zmsp/teammaker/wiki/user-manual");
                }),
          ),
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(FontAwesomeIcons.mobileScreen,
                      color: Colors.white, size: 20),
                ),
                title: const Text('Installation Guide',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text(
                    'Instructions for installing Teammaker directly to your device as a PWA (Progressive Web App).'),
                onTap: () {
                  _launchInBrowser(
                      "https://github.com/zmsp/teammaker/wiki/installation");
                }),
          ),
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.purple,
                  child:
                      Icon(FontAwesomeIcons.bug, color: Colors.white, size: 20),
                ),
                title: const Text('Report Issues',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text(
                    'Found a bug or have a suggestion? Open an issue on our GitHub tracker.'),
                onTap: () {
                  _launchInBrowser('https://github.com/zmsp/teammaker/issues');
                }),
          ),
        ],
      ),
    );
  }
}
