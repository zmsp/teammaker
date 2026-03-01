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
        title: const Text("HELP & RESOURCES",
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildHeader(context, "Optimization Guide"),
          const SizedBox(height: 12),
          _buildHelpSection(
            context,
            icon: Icons.people_alt,
            color: Colors.blue,
            title: "1. Roster Management",
            content:
                "• Efficiently add players using 'Quick Add' or bulk 'Add Row' options.\n"
                "• Mark attendance by selecting active participants for current sessions.\n"
                "• Enable 'Edit Mode' for rapid synchronization of player details.\n"
                "• Locally encrypted storage ensures your squad data remains private.",
          ),
          _buildHelpSection(
            context,
            icon: Icons.auto_awesome,
            color: Colors.purple,
            title: "2. Advanced Team Balancing",
            content:
                "• Utilize 'Fair Mix' for sophisticated skill and gender distribution.\n"
                "• Scale match dynamics by adjusting the 'Players per team' parameter.\n"
                "• Generate optimized team compositions with a single tap.\n"
                "• Manage unassigned players seamlessly through the rotation queue.",
          ),
          _buildHelpSection(
            context,
            icon: Icons.bolt,
            color: Colors.orange,
            title: "3. Professional Utility Tools",
            content:
                "• TAP SCORE: High-performance scoreboard with integrated timers and custom configurations.\n"
                "• PLAYER QUEUE: Automated sequential system for organized entry and fair turn-taking.",
          ),
          _buildHelpSection(
            context,
            icon: Icons.emoji_events,
            color: Colors.amber,
            title: "4. Tournament Match Making",
            content: "• Define venue capacity and desired competitive rounds.\n"
                "• Architect full tournament schedules with intelligent court balancing.\n"
                "• Track performance metrics through integrated results management.\n"
                "• Ensure equitable participation across all skill levels.",
          ),
          const SizedBox(height: 32),
          _buildHeader(context, "Video Learning Center"),
          const SizedBox(height: 12),
          _buildVideoTile(
            context,
            title: "Squad Configuration",
            subtitle: "Technical walkthrough of roster optimization and team generation.",
            url: 'asset/video/meetup.mp4',
            color: Colors.blueAccent,
          ),
          _buildVideoTile(
            context,
            title: "Scoreboard Analytics",
            subtitle: "Master the advanced features of the interactive Tap Score system.",
            url: 'asset/video/meetup.mp4',
            color: Colors.redAccent,
          ),
          const SizedBox(height: 32),
          _buildHeader(context, "Reference Materials"),
          const SizedBox(height: 12),
          _buildResourceLink(
              "Operational Manual",
              FontAwesomeIcons.bookOpen,
              Colors.teal,
              "https://github.com/zmsp/teammaker/wiki/user-manual"),
          _buildResourceLink("Technical Support", FontAwesomeIcons.bug,
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
              title: const Text("Re-initiate Application Tour",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text("Comprehensive walkthrough of platform features."),
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
                  "Team Maker Buddy v3.0",
                  style: TextStyle(
                      color: colorScheme.primary.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Professional Edition • High Integrity Privacy",
                  style: TextStyle(
                      color:
                          Colors.grey,
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
