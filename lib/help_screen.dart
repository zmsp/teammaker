import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:teammaker/video_player.dart';

class HelpExample extends StatefulWidget {
  const HelpExample({super.key});

  @override
  State<HelpExample> createState() => _HelpExampleState();
}

class _HelpExampleState extends State<HelpExample> {
  Future<void> _launchInBrowser(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("HELP & GUIDE",
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildHeader("Mastering Team Buddy"),
          const SizedBox(height: 12),
          _buildHelpSection(
            context,
            icon: Icons.people_alt,
            color: Colors.blue,
            title: "1. Managing the Roster",
            content: "• Add players using the '+' buttons.\n"
                "• Check the boxes next to players who are present.\n"
                "• Toggle 'Edit Mode' to quickly rewrite names or change levels.\n"
                "• Scores and names are automatically saved to your device.",
          ),
          _buildHelpSection(
            context,
            icon: Icons.auto_awesome,
            color: Colors.purple,
            title: "2. Balancing Teams",
            content:
                "• Choose a strategy (Fair Mix is recommended for most games).\n"
                "• Set 'Players per team' to your desired group size.\n"
                "• Press 'GENERATE TEAMS' at the bottom to see results.\n"
                "• You can lock specific players to teams if needed.",
          ),
          _buildHelpSection(
            context,
            icon: Icons.bolt,
            color: Colors.orange,
            title: "3. Using Quick Tools",
            content:
                "• TAP SCORE: A fast scoreboard and timer. It starts automatically so you can get playing immediately.\n"
                "• PLAYER QUEUE: A virtual deck for queue management. Set your player count and tap the card to issue a position number.",
          ),
          _buildHelpSection(
            context,
            icon: Icons.emoji_events,
            color: Colors.amber,
            title: "4. Running a Match Maker",
            content: "• Set your court count and round count.\n"
                "• Tap 'Create Matches' to see who plays where.\n"
                "• Launch the Scoreboard directly from any match to record wins.\n"
                "• The system tracks participation to ensure everyone gets a game.",
          ),
          const SizedBox(height: 32),
          _buildHeader("Video Tutorials"),
          const SizedBox(height: 12),
          _buildVideoTile(
            context,
            title: "How to create teams?",
            subtitle: "Short video on adding players and generating teams.",
            url: 'asset/video/meetup.mp4',
            color: Colors.blueAccent,
          ),
          _buildVideoTile(
            context,
            title: "Import from Meetup",
            subtitle: "Learn how to pull player RSVPs from Meetup.",
            url: 'asset/video/meetup.mp4',
            color: Colors.redAccent,
          ),
          const SizedBox(height: 32),
          _buildHeader("Resources"),
          const SizedBox(height: 12),
          _buildResourceLink(
              "Full User Manual",
              FontAwesomeIcons.bookOpen,
              Colors.teal,
              "https://github.com/zmsp/teammaker/wiki/user-manual"),
          _buildResourceLink("Report a Problem", FontAwesomeIcons.bug,
              Colors.redAccent, "https://github.com/zmsp/teammaker/issues"),
          const SizedBox(height: 40),
          Center(
            child: Text(
              "Team Buddy v2.0 • Premium Edition",
              style: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: Colors.grey),
    );
  }

  Widget _buildHelpSection(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      required String content}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(72, 0, 24, 20),
            child: Text(
              content,
              style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceLink(
      String title, IconData icon, Color color, String url) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 18),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        trailing: const Icon(Icons.open_in_new, size: 14, color: Colors.grey),
        onTap: () => _launchInBrowser(url),
      ),
    );
  }

  Widget _buildVideoTile(BuildContext context,
      {required String title,
      required String subtitle,
      required String url,
      required Color color}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(Icons.play_circle_filled, color: color, size: 24),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        subtitle:
            Text(subtitle, style: const TextStyle(fontSize: 12, height: 1.3)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VideoApp(
                      videoUrl: url, title: title, description: subtitle)));
        },
      ),
    );
  }
}
