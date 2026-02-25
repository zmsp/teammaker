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
        children: <Widget>[
          Card(
            child: ListTile(
              leading: Icon(FontAwesomeIcons.magnifyingGlass),
              title: Text('How to create teams?'),
              subtitle: Text('Click here to watch help video'),
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
            child: ListTile(
              leading: Icon(FontAwesomeIcons.meetup),
              title: Text('How to add data from meetup?'),
              subtitle: Text('Click here to watch help video'),
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
            child: ListTile(
                leading: Icon(FontAwesomeIcons.question),
                subtitle: Text('Read the user manual'),
                title: Text('Need help on using?'),
                onTap: () {
                  _launchInBrowser(
                      "https://github.com/zmsp/teammaker/wiki/user-manual");
                }),
          ),
          Card(
            child: ListTile(
                leading: Icon(FontAwesomeIcons.download),
                subtitle: Text('How do you install this app to your phone?'),
                title: Text('Install this app'),
                onTap: () {
                  _launchInBrowser(
                      "https://github.com/zmsp/teammaker/wiki/installation");
                }),
          ),
          Card(
            child: ListTile(
                leading: Icon(FontAwesomeIcons.handshakeAngle),
                subtitle: Text('Add issues to github issue tracker'),
                title: Text('Having issues or need new features?'),
                onTap: () {
                  _launchInBrowser('https://github.com/zmsp/teammaker/issues');
                }),
          ),
        ],
      ),
    );
  }
}
