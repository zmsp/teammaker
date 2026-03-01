import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/model/player_model.dart';
import 'package:teammaker/theme/app_theme.dart';
import 'package:teammaker/widget/player.dart';

class AddPlayersScreen extends StatefulWidget {
  const AddPlayersScreen({super.key});

  @override
  AddPlayersScreenState createState() => AddPlayersScreenState();
}

class AddPlayersScreenState extends State<AddPlayersScreen> {
  final List<int> _levels = [1, 2, 3, 4, 5];

  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _playerNameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  int _selectedLevel = 3;
  String _selectedGender = "MALE";
  bool _useBulkMode = false;
  SportPalette _selectedSport = SportPalette.volleyball;
  String _selectedRole = "Any";

  List<PlayerModel> players = [];

  void _addSinglePlayer() {
    if (_playerNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a player name")),
      );
      return;
    }

    setState(() {
      players.insert(
          0,
          PlayerModel(_selectedLevel, _playerNameController.text.trim(), "0",
              _selectedGender, _selectedRole));
      _playerNameController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Added ${players.first.name}"),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        width: 200,
      ),
    );

    _nameFocusNode.requestFocus();
  }

  void _processBulkPlayers() {
    if (_batchController.text.trim().isEmpty) return;

    var lines = _batchController.text.split("\n");
    int addedCount = 0;

    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      PlayerModel player = PlayerModel(3, "Unknown", "0", "X");
      var data = line.split(",");

      if (data.isNotEmpty) player.name = data[0].trim();
      if (data.length > 1) player.level = int.tryParse(data[1].trim()) ?? 3;
      if (data.length > 2) {
        String g = data[2].trim().toUpperCase();
        if (g.startsWith("M")) {
          player.gender = "MALE";
        } else if (g.startsWith("F")) {
          player.gender = "FEMALE";
        } else {
          player.gender = "X";
        }
      }
      if (data.length > 3) player.team = data[3].trim();
      if (data.length > 4) player.role = data[4].trim();

      players.insert(0, player);
      addedCount++;
    }

    setState(() {
      _batchController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$addedCount players added from text"),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _formatMeetup() {
    String text = _batchController.text;
    var lines = text.split("\n");
    var playerLines = [];
    var dateFieldRegex = RegExp(r'^(J|F|M|A|M|J|A|S|O|N|D).*(AM|PM)$');
    var recordFlag = true;

    for (var i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.isEmpty) continue;

      if (recordFlag && !dateFieldRegex.hasMatch(line)) {
        String name = line;
        String position = "Any";
        if (line.contains("(") && line.contains(")")) {
          final start = line.lastIndexOf("(");
          final end = line.lastIndexOf(")");
          if (end > start) {
            position = line.substring(start + 1, end).trim();
            name = line.substring(0, start).trim();
          }
        }
        playerLines.add("$name,3,M,,$position");
        recordFlag = false;
        continue;
      }

      if (dateFieldRegex.hasMatch(line)) {
        recordFlag = true;
      }
    }

    setState(() {
      _batchController.text = playerLines.join("\n");
    });
  }

  void _editPlayer(int index) {
    final player = players[index];
    final theme = Theme.of(context);

    String editName = player.name;
    int editLevel = player.level;
    String editGender = player.gender;
    SportPalette editSport = SportPalette.volleyball;
    String editRole = player.role;

    // Try to find the matching sport for the role if possible
    for (var s in SportPalette.values) {
      if (s.roles.contains(player.role)) {
        editSport = s;
        break;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text("Edit Player", style: theme.textTheme.headlineSmall),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                controller: TextEditingController(text: editName),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Player Name",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) => editName = v.trim(),
              ),
              const SizedBox(height: 20),
              Text("Skill Level", style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: _levels
                    .map((l) => ButtonSegment(value: l, label: Text("$l")))
                    .toList(),
                selected: {editLevel},
                onSelectionChanged: (val) =>
                    setModalState(() => editLevel = val.first),
              ),
              const SizedBox(height: 20),
              Text("Gender", style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: "MALE", label: Text("M"), icon: Icon(Icons.male)),
                  ButtonSegment(
                      value: "FEMALE",
                      label: Text("F"),
                      icon: Icon(Icons.female)),
                  ButtonSegment(
                      value: "X",
                      label: Text("X"),
                      icon: Icon(Icons.horizontal_rule)),
                ],
                selected: {editGender},
                onSelectionChanged: (val) =>
                    setModalState(() => editGender = val.first),
              ),
              const SizedBox(height: 20),
              Text("Sport", style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<SportPalette>(
                value: editSport,
                decoration: InputDecoration(
                  prefixIcon: Icon(editSport.icon),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: SportPalette.values.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() {
                      editSport = val;
                      editRole = "Any";
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Text("Role / Position", style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: editSport.roles.map((r) {
                  final isSelected = editRole == r;
                  return ChoiceChip(
                    label: Text(r),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setModalState(() => editRole = r);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  if (editName.isEmpty) return;
                  setState(() {
                    players[index] = PlayerModel(
                        editLevel, editName, player.team, editGender, editRole);
                  });
                  Navigator.pop(context);
                },
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Players',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (players.isNotEmpty)
            TextButton.icon(
              onPressed: () => setState(() => players.clear()),
              icon: const Icon(Icons.clear_all, size: 20),
              label: const Text("Clear List"),
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            ),
        ],
      ),
      floatingActionButton: players.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pop(context, players),
              label: const Text("Confirm & Add"),
              icon: const Icon(Icons.check),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mode Toggle
                  Center(
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text("Single"),
                          icon: Icon(Icons.person_add_alt_1),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text("Bulk/Text"),
                          icon: Icon(Icons.view_headline),
                        ),
                      ],
                      selected: {_useBulkMode},
                      onSelectionChanged: (value) {
                        setState(() => _useBulkMode = value.first);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Input Section
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child:
                        _useBulkMode ? _buildBulkInput() : _buildSingleInput(),
                  ),

                  const SizedBox(height: 32),

                  // List Header
                  if (players.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.people, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          "Added Players (${players.length})",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        const Text("Recent on top",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  if (players.isNotEmpty) const Divider(),
                ],
              ),
            ),
          ),

          // Players List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final player = players[index];
                return Dismissible(
                  key: Key("${player.name}_$index"),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: colorScheme.error,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    setState(() => players.removeAt(index));
                  },
                  child: PlayerWidget(
                    player: player,
                    onTap: () => _editPlayer(index),
                  ),
                );
              },
              childCount: players.length,
            ),
          ),

          if (players.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_add_outlined,
                        size: 64, color: colorScheme.outlineVariant),
                    const SizedBox(height: 16),
                    Text(
                      "No players added yet",
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: colorScheme.outline),
                    ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildSingleInput() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _playerNameController,
              focusNode: _nameFocusNode,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: "Player Name",
                hintText: "Enter name",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _addSinglePlayer(),
            ),
            const SizedBox(height: 20),
            Text("Skill Level", style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Center(
              child: SegmentedButton<int>(
                segments: _levels
                    .map((l) => ButtonSegment(
                          value: l,
                          label: Text(l.toString()),
                        ))
                    .toList(),
                selected: {_selectedLevel},
                onSelectionChanged: (val) =>
                    setState(() => _selectedLevel = val.first),
              ),
            ),
            const SizedBox(height: 20),
            Text("Gender", style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Center(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: "MALE",
                    label: Text("Male"),
                    icon: Icon(Icons.male),
                  ),
                  ButtonSegment(
                    value: "FEMALE",
                    label: Text("Female"),
                    icon: Icon(Icons.female),
                  ),
                  ButtonSegment(
                    value: "X",
                    label: Text("Other"),
                    icon: Icon(Icons.horizontal_rule),
                  ),
                ],
                selected: {_selectedGender},
                onSelectionChanged: (val) =>
                    setState(() => _selectedGender = val.first),
              ),
            ),
            const SizedBox(height: 20),
            Text("Sport", style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<SportPalette>(
              value: _selectedSport,
              decoration: InputDecoration(
                prefixIcon: Icon(_selectedSport.icon),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: SportPalette.values.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s.label),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedSport = val;
                    _selectedRole = "Any"; // Reset on sport change
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            Text("Role / Position", style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            // Use Wrap so roles that don't fit wrap cleanly to next line
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedSport.roles.map((r) {
                final isSelected = _selectedRole == r;
                return ChoiceChip(
                  label: Text(r),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedRole = r);
                    }
                  },
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  selectedColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: isSelected
                      ? BorderSide.none
                      : BorderSide(color: theme.colorScheme.outlineVariant),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _addSinglePlayer,
                icon: const Icon(Icons.add),
                label: const Text("Add to List"),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkInput() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        TextField(
          controller: _batchController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText:
                "Name, Level, Gender, Team, Position\nJohn, 3, M, 1, Setter\nJane, 4, F, 2, Libero",
            helperText: "Format: Name, Level, Gender, Team, Position",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor:
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _formatMeetup,
                icon: const FaIcon(FontAwesomeIcons.meetup, size: 16),
                label: const Text("Meetup Format"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: _processBulkPlayers,
                icon: const Icon(Icons.playlist_add),
                label: const Text("Add All"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
