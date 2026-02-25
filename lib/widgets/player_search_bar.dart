import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlayerSearchBar extends StatefulWidget {
  final PlutoGridStateManager stateManager;

  const PlayerSearchBar({
    super.key,
    required this.stateManager,
  });

  @override
  State<PlayerSearchBar> createState() => _PlayerSearchBarState();
}

class _PlayerSearchBarState extends State<PlayerSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.stateManager.setFilter((row) {
        final name =
            row.cells['name_field']?.value.toString().toLowerCase() ?? '';
        return name.contains(v.toLowerCase());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search players...',
        prefixIcon: const Icon(Icons.search, size: 20),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
    );
  }
}
