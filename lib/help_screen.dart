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
        title: const Text("USER GUIDE",
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
        
          const SizedBox(height: 32),
          _buildHeader(context, "Support & Tutorials"),
          const SizedBox(height: 12),
          _buildVideoTile(
            context,
            title: "Visual Walkthrough",
            subtitle:
                "Technical guide on roster optimization and team generation.",
            url: 'assets/demo.mp4',
            color: Colors.blueAccent,
          ),
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
            color: colorScheme.secondaryContainer.withValues(alpha: 0.1),
            child: ListTile(
              leading: Icon(Icons.play_circle_fill,
                  color: colorScheme.secondary, size: 20),
              title: const Text("Re-initiate Application Tour",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle:
                  const Text("Start the guided tutorial from the beginning."),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('tour_shown', false);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                widget.onRestartTour?.call();
              },
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Text(
                  "Team Maker Buddy v3.1",
                  style: TextStyle(
                      color: colorScheme.primary.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Offline Capable • Privacy First",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMarkdownSection(BuildContext context,
      {required String title,
      required String content,
      required String imageUrl}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 2,
                color: colorScheme.primary)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 120,
                width: double.infinity,
                color: colorScheme.surfaceContainerHighest,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              height: 40,
              width: double.infinity,
              color: colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content.split('\n').map((line) {
              if (line.trim().isEmpty) return const SizedBox(height: 8);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  line,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpTile(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      required String subtitle}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
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
