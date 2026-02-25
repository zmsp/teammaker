import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';

class RandomTeamScreen extends StatefulWidget {
  final int initialTeamCount;
  final int initialPlayersPerTeam;

  const RandomTeamScreen({
    super.key,
    this.initialTeamCount = 1, // Defaulting to 1 team as requested
    this.initialPlayersPerTeam = 6, // Defaulting to 6 players as requested
  });

  @override
  State<RandomTeamScreen> createState() => _RandomTeamScreenState();
}

class _RandomTeamScreenState extends State<RandomTeamScreen>
    with SingleTickerProviderStateMixin {
  late int _totalPlayers;
  late int _playersPerTeam;
  List<int> _pool = [];
  List<int> _taken = [];
  int? _result;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipping = false;

  @override
  void initState() {
    super.initState();
    _playersPerTeam = widget.initialPlayersPerTeam;
    _totalPlayers = widget.initialTeamCount * widget.initialPlayersPerTeam;
    _generatePool();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 450), // Sped up as requested
      vsync: this,
    );
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi / 2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -pi / 2, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _generatePool() {
    _pool = List.generate(_totalPlayers, (i) => i + 1);
    _pool.shuffle();
    _taken = [];
    _result = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _drawCard() {
    if (_isFlipping || _pool.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isFlipping = true;
    });

    _controller.forward(from: 0.0).then((_) {
      setState(() {
        _result = _pool.removeAt(0);
        _taken.add(_result!);
        _isFlipping = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int remaining = _pool.length;
    int takenCount = _taken.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("VIRTUAL DECK",
            style: TextStyle(
                fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rotateRight, size: 18),
            tooltip: "Reshuffle",
            onPressed: () {
              HapticFeedback.mediumImpact();
              setState(() => _generatePool());
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Config Header - Modern Glassmorphism
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ConfigInput(
                    label: "DECK SIZE",
                    value: _totalPlayers.toString(),
                    onChanged: (v) => setState(() {
                      _totalPlayers = int.tryParse(v) ?? 1;
                      _generatePool();
                    }),
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.white12),
                const SizedBox(width: 20),
                Expanded(
                  child: _ConfigInput(
                    label: "TEAM SIZE",
                    value: _playersPerTeam.toString(),
                    onChanged: (v) =>
                        setState(() => _playersPerTeam = int.tryParse(v) ?? 1),
                  ),
                ),
              ],
            ),
          ),

          // History Tracker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("ACTIVE QUEUE",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2)),
                    Text("$takenCount / $_totalPlayers",
                        style: const TextStyle(
                            color: Color(0xFF2196F3),
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _totalPlayers,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      int num = index + 1;
                      bool isTaken = _taken.contains(num);
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: isTaken
                              ? const LinearGradient(
                                  colors: [
                                      Color(0xFF2196F3),
                                      Color(0xFF1976D2)
                                    ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight)
                              : null,
                          color:
                              isTaken ? null : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isTaken ? Colors.white24 : Colors.white10),
                          boxShadow: isTaken
                              ? [
                                  BoxShadow(
                                      color: const Color(0xFF2196F3)
                                          .withOpacity(0.3),
                                      blurRadius: 8)
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            num.toString(),
                            style: TextStyle(
                              color: isTaken ? Colors.white : Colors.white24,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Fancy Animated Card
          GestureDetector(
            onTap: _pool.isEmpty ? null : _drawCard,
            child: Center(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_animation.value),
                    alignment: Alignment.center,
                    child: _CardView(
                        result: _result,
                        isFlipping: _isFlipping,
                        hasCards: _pool.isNotEmpty),
                  );
                },
              ),
            ),
          ),

          const Spacer(),

          // Bottom Action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: _pool.isEmpty
                          ? [Colors.green.shade600, Colors.green.shade800]
                          : [const Color(0xFF2196F3), const Color(0xFF0D47A1)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_pool.isEmpty
                                ? Colors.green
                                : const Color(0xFF2196F3))
                            .withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _pool.isEmpty
                        ? () => setState(() => _generatePool())
                        : _drawCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      _pool.isEmpty ? "REFILL PACK" : "TAP TO DEAL",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _pool.isEmpty
                      ? "PACK EXHAUSTED"
                      : "$remaining CARDS REMAINING",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigInput extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _ConfigInput(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF2196F3),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
        const SizedBox(height: 4),
        TextField(
          controller: TextEditingController(text: value)
            ..selection =
                TextSelection.fromPosition(TextPosition(offset: value.length)),
          keyboardType: TextInputType.number,
          style: const TextStyle(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero),
          onChanged: onChanged,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }
}

class _CardView extends StatelessWidget {
  final int? result;
  final bool isFlipping;
  final bool hasCards;

  const _CardView(
      {this.result, required this.isFlipping, required this.hasCards});

  @override
  Widget build(BuildContext context) {
    // Determine if we show front or back based on state
    // If not flipping and result is null -> show back
    // If flipping and mid-flip -> it depends on the animation angle which is handled by parent Transform
    // Basically, we show the "Front" if we have a result and are not mid-first-half of flip.

    bool showFront = result != null && !isFlipping;

    return Container(
      width: 240,
      height: 360,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: showFront
              ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
              : [const Color(0xFF2196F3), const Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (showFront ? Colors.black : const Color(0xFF2196F3))
                .withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(showFront ? 0.05 : 0.2),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Pattern for card back
            if (!showFront)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: CustomPaint(painter: _CardPatternPainter()),
                ),
              ),

            Center(
              child: showFront ? _buildCardFront() : _buildCardBack(),
            ),

            // Premium "Holographic" Reflection
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                    ],
                    stops: const [0, 0.5, 1],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const FaIcon(FontAwesomeIcons.bolt, color: Colors.white, size: 60),
        const SizedBox(height: 30),
        Text(
          hasCards ? "TAP TO REVEAL" : "EMPTY PACK",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildCardFront() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 20, height: 2, color: const Color(0xFF2196F3)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text("POSITION",
                  style: TextStyle(
                      color: Color(0xFF2196F3),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3)),
            ),
            Container(width: 20, height: 2, color: const Color(0xFF2196F3)),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          result.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 140,
            fontWeight: FontWeight.w900,
            height: 1,
            shadows: [
              Shadow(
                  color: Colors.black54, blurRadius: 20, offset: Offset(0, 10))
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "QUEUED",
          style: TextStyle(
              color: Colors.white38,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 8),
        ),
      ],
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;
    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
          Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
