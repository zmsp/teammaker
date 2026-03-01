import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:teammaker/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpExample extends StatefulWidget {
  final VoidCallback? onRestartTour;
  const HelpExample({super.key, this.onRestartTour});

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
          _buildHeader(context, "Mastering Team Maker Buddy"),
          const SizedBox(height: 12),
          _buildHelpSection(
            context,
            icon: Icons.people_alt,
            color: Colors.blue,
            title: "1. Managing the Roster",
            content:
                "• Add players using the dedicated '+' and 'Add Row' buttons.\n"
                "• Check the boxes next to players who are present for today's session.\n"
                "• Toggle 'Edit Mode' (Pencil Icon) to quickly update names, levels, or gender.\n"
                "• All roster data is automatically persisted to your device.",
          ),
          _buildHelpSection(
            context,
            icon: Icons.auto_awesome,
            color: Colors.purple,
            title: "2. Balancing Teams",
            content:
                "• Choose a balancing strategy: 'Fair Mix' is best for balanced skill and gender distribution.\n"
                "• Adjust 'Players per team' to scale the game size.\n"
                "• Press 'GENERATE TEAMS' to produce optimized matchups.\n"
                "• Unassigned players are listed separately for easy rotation.",
          ),
          _buildHelpSection(
            context,
            icon: Icons.bolt,
            color: Colors.orange,
            title: "3. Using Quick Tools",
            content:
                "• TAP SCORE: A professional scoreboard for HOME vs AWAY. Features automatic timers, custom max scores, and country-themed color palettes.\n"
                "• PLAYER QUEUE: A digital 'next-up' system. Set the count and tap cards to issue playing numbers fairly.",
          ),
          _buildHelpSection(
            context,
            icon: Icons.emoji_events,
            color: Colors.amber,
            title: "4. Running a Match Maker",
            content: "• Set your court count and desired rounds.\n"
                "• Tap 'Create Matches' to generate a full tournament or session schedule.\n"
                "• Track wins/losses with the built-in score tracking.\n"
                "• The system balances court time so everyone plays an equal amount.",
          ),
          const SizedBox(height: 32),
          _buildHeader(context, "Video Tutorials"),
          const SizedBox(height: 12),
          _buildVideoTile(
            context,
            title: "How to create teams?",
            subtitle: "Quick walkthrough of the roster and generation process.",
            url: 'asset/video/meetup.mp4',
            color: Colors.blueAccent,
          ),
          _buildVideoTile(
            context,
            title: "Scoreboard Features",
            subtitle: "Learn how to use the interactive Tap Score tool.",
            url: 'asset/video/meetup.mp4',
            color: Colors.redAccent,
          ),
          const SizedBox(height: 32),
          _buildHeader(context, "Resources"),
          const SizedBox(height: 12),
          _buildResourceLink(
              "Full User Manual",
              FontAwesomeIcons.bookOpen,
              Colors.teal,
              "https://github.com/zmsp/teammaker/wiki/user-manual"),
          _buildResourceLink("Report an Issue", FontAwesomeIcons.bug,
              Colors.redAccent, "https://github.com/zmsp/teammaker/issues"),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
            color: Colors.blueAccent.withValues(alpha: 0.1),
            child: ListTile(
              leading: const Icon(Icons.play_circle_fill,
                  color: Colors.blueAccent, size: 20),
              title: const Text("Take App Tour Again",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text("Guided walkthrough of all features."),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('tour_shown', false);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                widget.onRestartTour?.call();
              },
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Text(
                  "Team Maker Buddy v2.1",
                  style: TextStyle(
                      color: colorScheme.primary.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Premium Edition • Zero Data Collection",
                  style: TextStyle(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: Theme.of(context).colorScheme.primary),
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
