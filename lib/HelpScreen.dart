import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpExample extends StatefulWidget {
  @override
  _HelpExampleState createState() => _HelpExampleState();
}

enum Status { none, running, stopped, paused }

class _HelpExampleState extends State<HelpExample> {
  Future<void>? _launched;
  String _phone = '';

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => setState(() {
                  _launched = _launchInBrowser(
                      "https://github.com/zmsp/teammaker/wiki/installation");
                }),
                child: const Text('Install this app'),
              ),
              const Padding(padding: EdgeInsets.all(16.0)),
              ElevatedButton(
                onPressed: () => setState(() {
                  _launched = _launchInBrowser(
                      "https://github.com/zmsp/teammaker/wiki/user-manual");
                }),
                child: const Text('Need help on using?'),
              ),
              ElevatedButton(
                onPressed: () => setState(() {
                  _launched = _launchInBrowser(
                      "https://github.com/zmsp/teammaker/issues");
                }),
                child: const Text('Have issues?'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
