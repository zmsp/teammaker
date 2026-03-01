import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teammaker/model/data_model.dart';
import 'package:teammaker/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsData settingsData;
  final ThemeController? themeController;

  const SettingsScreen(
    this.settingsData, {
    super.key,
    this.themeController,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsData settingsData;
  late TextEditingController _proportionController;
  late TextEditingController _teamCountController;
  late TextEditingController _divisionController;

  @override
  void initState() {
    super.initState();
    settingsData = widget.settingsData;
    _proportionController =
        TextEditingController(text: settingsData.proportion.toString());
    _teamCountController =
        TextEditingController(text: settingsData.teamCount.toString());
    _divisionController =
        TextEditingController(text: settingsData.division.toString());
    widget.themeController?.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _proportionController.dispose();
    _teamCountController.dispose();
    _divisionController.dispose();
    widget.themeController?.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tc = widget.themeController;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context, settingsData),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Appearance Section ─────────────────────────────────────────
          if (tc != null) ...[
            _sectionHeader(context, 'APPEARANCE', FontAwesomeIcons.paintbrush),
            const SizedBox(height: 12),

            // Dark / Light mode toggle
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      tc.mode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tc.mode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Switch(
                      value: tc.mode == ThemeMode.dark,
                      onChanged: (isDark) {
                        tc.setMode(isDark ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Color palette grid
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COLOUR THEME',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose a palette that matches your sport',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...SportPalette.values.map((palette) {
                      final isSelected = tc.palette == palette;
                      return _PaletteTile(
                        palette: palette,
                        isSelected: isSelected,
                        onTap: () {
                          tc.setPalette(palette);
                          // Auto-apply sport defaults to strategy
                          final d = palette.defaultSettings;
                          setState(() {
                            settingsData.proportion = d.playersPerTeam;
                            settingsData.teamCount = d.teamCount;
                            settingsData.o = d.strategy;
                            _proportionController.text =
                                d.playersPerTeam.toString();
                            _teamCountController.text = d.teamCount.toString();
                          });
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              duration: const Duration(seconds: 3),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              content: Row(
                                children: [
                                  Icon(palette.icon,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${palette.label} defaults applied'
                                      ' — ${d.playersPerTeam} players/team'
                                      ' · ${d.strategy.displayName}',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],

          // ── Team Strategy Section ──────────────────────────────────────
          _sectionHeader(context, 'TEAM STRATEGY', FontAwesomeIcons.gears),
          const SizedBox(height: 12),

          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: RadioGroup<GenOption>(
                groupValue: settingsData.o,
                onChanged: (v) {
                  setState(() {
                    settingsData.o = v ?? settingsData.o;
                  });
                },
                child: Column(
                  children: [
                    _strategyTile(
                      title: 'Sport Roles (Recommended)',
                      subtitle: 'Balances key positions (Setter, Gaffer, etc)',
                      icon: Icons.sports_score,
                      value: GenOption.roleBalanced,
                      extraConfig: settingsData.o == GenOption.roleBalanced
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Column(
                                children: [
                                  if (tc != null) ...[
                                    DropdownButtonFormField<SportPalette>(
                                      decoration: const InputDecoration(
                                        labelText: 'Select Sport Context',
                                        prefixIcon:
                                            Icon(Icons.sports_basketball),
                                      ),
                                      initialValue: tc.palette,
                                      items: SportPalette.values.map((s) {
                                        return DropdownMenuItem(
                                          value: s,
                                          child: Text(s.label),
                                        );
                                      }).toList(),
                                      onChanged: (p) {
                                        if (p != null) {
                                          tc.setPalette(p);
                                          setState(() {
                                            settingsData.proportion = p
                                                .defaultSettings.playersPerTeam;
                                            settingsData.teamCount =
                                                p.defaultSettings.teamCount;
                                            _proportionController.text =
                                                settingsData.proportion
                                                    .toString();
                                            _teamCountController.text =
                                                settingsData.teamCount
                                                    .toString();
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  TextFormField(
                                    controller: _teamCountController,
                                    decoration: const InputDecoration(
                                      labelText: 'Number of teams',
                                      prefixIcon: Icon(Icons.grid_view),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) {
                                      settingsData.teamCount =
                                          int.tryParse(v) ??
                                              settingsData.teamCount;
                                    },
                                  ),
                                ],
                              ),
                            )
                          : null,
                    ),
                    const Divider(height: 1),
                    _strategyTile(
                      title: 'Fair Mix',
                      subtitle: 'Mixes players by gender and skill fairly',
                      icon: Icons.wc,
                      value: GenOption.evenGender,
                      extraConfig: settingsData.o == GenOption.evenGender
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Players per team',
                                  prefixIcon: Icon(Icons.group),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                initialValue:
                                    settingsData.proportion.toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  settingsData.proportion = int.tryParse(v) ??
                                      settingsData.proportion;
                                },
                              ),
                            )
                          : null,
                    ),
                    const Divider(height: 1),
                    _strategyTile(
                      title: 'Skill Balance',
                      subtitle: 'Splits players by skill level only',
                      icon: Icons.balance,
                      value: GenOption.distribute,
                      extraConfig: settingsData.o == GenOption.distribute
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Number of teams',
                                  prefixIcon: Icon(Icons.grid_view),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                initialValue: settingsData.teamCount.toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  settingsData.teamCount =
                                      int.tryParse(v) ?? settingsData.teamCount;
                                },
                              ),
                            )
                          : null,
                    ),
                    const Divider(height: 1),
                    _strategyTile(
                      title: 'Ranked Groups',
                      subtitle: 'Keeps strong players together',
                      icon: Icons.military_tech,
                      value: GenOption.division,
                      extraConfig: settingsData.o == GenOption.division
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Column(
                                children: [
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Number of groups',
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    initialValue:
                                        settingsData.division.toString(),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) {
                                      settingsData.division = int.tryParse(v) ??
                                          settingsData.division;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Number of teams',
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    initialValue:
                                        settingsData.teamCount.toString(),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) {
                                      settingsData.teamCount =
                                          int.tryParse(v) ??
                                              settingsData.teamCount;
                                    },
                                  ),
                                ],
                              ),
                            )
                          : null,
                    ),
                    const Divider(height: 1),
                    _strategyTile(
                      title: 'Random Mix',
                      subtitle: 'Pure random team splitting',
                      icon: Icons.shuffle,
                      value: GenOption.random,
                      extraConfig: settingsData.o == GenOption.random
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Number of teams',
                                  prefixIcon: Icon(Icons.grid_view),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                initialValue: settingsData.teamCount.toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  settingsData.teamCount =
                                      int.tryParse(v) ?? settingsData.teamCount;
                                },
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Save button ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const FaIcon(FontAwesomeIcons.check, size: 16),
              label: const Text('Save Settings'),
              onPressed: () => Navigator.pop(context, settingsData),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _strategyTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required GenOption value,
    Widget? extraConfig,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = settingsData.o == value;

    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            child: Icon(icon,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 20),
          ),
          title: Text(title,
              style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 14)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: Radio<GenOption>(
            value: value,
          ),
          onTap: () {
            setState(() {
              settingsData.o = value;
            });
          },
        ),
        if (extraConfig != null) extraConfig,
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        FaIcon(icon, size: 13, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

// ─── Palette Tile Widget ───────────────────────────────────────────────────
class _PaletteTile extends StatelessWidget {
  final SportPalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaletteTile({
    required this.palette,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? palette.seedColor.withValues(alpha: 0.12)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          border: Border.all(
            color: isSelected ? palette.seedColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Color swatches
            Row(
              children: [
                _Swatch(color: palette.seedColor),
                const SizedBox(width: 4),
                _Swatch(color: palette.accentColor),
              ],
            ),
            const SizedBox(width: 14),
            // Sport icon
            Icon(palette.icon,
                size: 22,
                color: isSelected
                    ? palette.seedColor
                    : colorScheme.onSurfaceVariant),
            const SizedBox(width: 14),
            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(palette.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: isSelected
                            ? palette.seedColor
                            : colorScheme.onSurface,
                      )),
                  const SizedBox(height: 2),
                  Text(palette.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      )),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: palette.seedColor, size: 22),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  const _Swatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
