import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Persistence keys
// ---------------------------------------------------------------------------
const _kDeckSize = 'pq_deck_size';
const _kShowNumbers = 'pq_show_numbers';
const _kEnableHaptics = 'pq_haptics';
const _kCardStyle = 'pq_card_style';

// Card style options
enum CardStyle { classic, neon, gradient }

// ---------------------------------------------------------------------------
// Main screen
// ---------------------------------------------------------------------------

class RandomTeamScreen extends StatefulWidget {
  final int initialTotal;
  const RandomTeamScreen({super.key, this.initialTotal = 6});

  @override
  State<RandomTeamScreen> createState() => _RandomTeamScreenState();
}

class _RandomTeamScreenState extends State<RandomTeamScreen>
    with TickerProviderStateMixin {
  // ── State ─────────────────────────────────────────────────────────────────
  late int _total;
  List<int> _pool = [];
  List<int> _taken = [];
  int? _current;

  // ── Settings ──────────────────────────────────────────────────────────────
  bool _showNumbers = true;
  bool _enableHaptics = true;
  CardStyle _cardStyle = CardStyle.gradient;

  // ── Prefs cache ───────────────────────────────────────────────────────────
  SharedPreferences? _prefs;

  // ── Animations ────────────────────────────────────────────────────────────
  late final AnimationController _flipCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _slideCtrl;
  late final Animation<double> _flipAnim;
  late final Animation<double> _pulseAnim;
  late final Animation<Offset> _slideAnim;
  bool _isFlipping = false;

  // ── Glow animation ────────────────────────────────────────────────────────
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _total = widget.initialTotal;

    // ── Controllers must be set up BEFORE _regenerate() which calls _slideCtrl.reset()
    // Flip: card rotates on Y axis (half-spin illusion)
    _flipCtrl = AnimationController(
        duration: const Duration(milliseconds: 420), vsync: this);
    _flipAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi / 2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -pi / 2, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut));

    // Pulse: subtle scale bounce on reveal
    _pulseCtrl = AnimationController(
        duration: const Duration(milliseconds: 260), vsync: this);
    _pulseAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));

    // Slide: taken chip pops in from the right
    _slideCtrl = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _slideAnim = Tween<Offset>(begin: const Offset(0.6, 0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutBack));

    // Glow: idle ambient breathing effect on card border
    _glowCtrl = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    _glowCtrl.repeat(reverse: true);

    // Now safe to call _regenerate() since all controllers are initialized
    _regenerate();
    _initPrefs();
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _pulseCtrl.dispose();
    _slideCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  // ── SharedPreferences ─────────────────────────────────────────────────────

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _total = _prefs!.getInt(_kDeckSize) ?? widget.initialTotal;
      _showNumbers = _prefs!.getBool(_kShowNumbers) ?? true;
      _enableHaptics = _prefs!.getBool(_kEnableHaptics) ?? true;
      final styleIdx = _prefs!.getInt(_kCardStyle) ?? CardStyle.gradient.index;
      _cardStyle =
          CardStyle.values[styleIdx.clamp(0, CardStyle.values.length - 1)];
      _regenerate();
    });
  }

  void _savePrefs() {
    _prefs?.setInt(_kDeckSize, _total);
    _prefs?.setBool(_kShowNumbers, _showNumbers);
    _prefs?.setBool(_kEnableHaptics, _enableHaptics);
    _prefs?.setInt(_kCardStyle, _cardStyle.index);
  }

  // ── Game logic ────────────────────────────────────────────────────────────

  void _regenerate() {
    setState(() {
      _pool = List.generate(_total, (i) => i + 1)..shuffle();
      _taken = [];
      _current = null;
    });
    _slideCtrl.reset();
  }

  Future<void> _draw() async {
    if (_isFlipping || _pool.isEmpty) return;
    if (_enableHaptics) HapticFeedback.mediumImpact();
    setState(() => _isFlipping = true);

    await _flipCtrl.forward(from: 0);

    if (!mounted) return;
    final drawn = _pool.removeAt(0);
    setState(() {
      _current = drawn;
      _taken.add(drawn);
      _isFlipping = false;
    });

    _pulseCtrl.forward(from: 0);
    _slideCtrl.forward(from: 0);
  }

  // ── Settings popup ────────────────────────────────────────────────────────

  void _showSettings(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textCtrl = TextEditingController(text: '$_total');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 8,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1218),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
                top: BorderSide(
                    color: cs.primary.withValues(alpha: 0.3), width: 1.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text('QUEUE SETTINGS',
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  )),
              const SizedBox(height: 20),

              // ── Deck size ──────────────────────────────────────────────
              Text('DECK SIZE',
                  style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: textCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.w900),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: cs.primary.withValues(alpha: 0.4))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: cs.primary, width: 2)),
                      filled: true,
                      fillColor: cs.primary.withValues(alpha: 0.08),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) {
                      final parsed = int.tryParse(v) ?? 1;
                      if (parsed >= 1) {
                        setSheet(() => _total = parsed.clamp(1, 99));
                        setState(() {});
                        _savePrefs();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Quick-pick chips
                Wrap(
                  spacing: 6,
                  children: [6, 10, 16, 20, 24].map((n) {
                    final sel = _total == n;
                    return GestureDetector(
                      onTap: () {
                        setSheet(() => _total = n);
                        textCtrl.text = '$n';
                        setState(() {});
                        _savePrefs();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel
                              ? cs.primary
                              : cs.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: sel
                                  ? cs.primary
                                  : cs.primary.withValues(alpha: 0.25)),
                        ),
                        child: Text('$n',
                            style: TextStyle(
                              color: sel ? cs.onPrimary : cs.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            )),
                      ),
                    );
                  }).toList(),
                ),
              ]),

              const SizedBox(height: 24),

              // ── Card style ─────────────────────────────────────────────
              Text('CARD STYLE',
                  style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2)),
              const SizedBox(height: 10),
              Row(
                children: CardStyle.values.map((style) {
                  final sel = _cardStyle == style;
                  final labels = ['Classic', 'Neon', 'Gradient'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setSheet(() => _cardStyle = style);
                        setState(() {});
                        _savePrefs();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: sel
                              ? cs.primary.withValues(alpha: 0.2)
                              : cs.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel
                                ? cs.primary
                                : cs.primary.withValues(alpha: 0.15),
                            width: sel ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              sel ? Icons.style : Icons.style_outlined,
                              color: sel
                                  ? cs.primary
                                  : cs.onSurface.withValues(alpha: 0.4),
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              labels[style.index],
                              style: TextStyle(
                                color: sel
                                    ? cs.primary
                                    : cs.onSurface.withValues(alpha: 0.5),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // ── Toggles ────────────────────────────────────────────────
              _SettingsToggle(
                label: 'Show number grid',
                subtitle: 'Show drawn numbers below card',
                value: _showNumbers,
                colorScheme: cs,
                onChanged: (v) {
                  setSheet(() => _showNumbers = v);
                  setState(() {});
                  _savePrefs();
                },
              ),
              _SettingsToggle(
                label: 'Haptic feedback',
                subtitle: 'Vibrate on card draw',
                value: _enableHaptics,
                colorScheme: cs,
                onChanged: (v) {
                  setSheet(() => _enableHaptics = v);
                  setState(() {});
                  _savePrefs();
                },
              ),

              const SizedBox(height: 24),

              // ── Apply / Reset ──────────────────────────────────────────
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _regenerate();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.error,
                      side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('RESHUFFLE',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('DONE',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D1218) : const Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PLAYER QUEUE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            fontSize: 13,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: cs.primary, size: 22),
            tooltip: 'Settings',
            onPressed: () => _showSettings(context),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                color: cs.onSurface.withValues(alpha: 0.6), size: 22),
            tooltip: 'Reshuffle',
            onPressed: () {
              if (_enableHaptics) HapticFeedback.lightImpact();
              _regenerate();
            },
          ),
          const SizedBox(width: 4),
        ],
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      body: Column(
        children: [
          // ── Stats bar ───────────────────────────────────────────────────
          _StatsBar(
            pool: _pool.length,
            taken: _taken.length,
            total: _total,
            colorScheme: cs,
          ),

          // ── Number grid ─────────────────────────────────────────────────
          if (_showNumbers)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: RepaintBoundary(
                child: _NumberGrid(
                  total: _total,
                  taken: _taken,
                  current: _current,
                  colorScheme: cs,
                  slideAnim: _slideAnim,
                ),
              ),
            ),

          const Spacer(),

          // ── Card ────────────────────────────────────────────────────────
          GestureDetector(
            onTap: _pool.isEmpty ? null : _draw,
            child: AnimatedBuilder(
              animation: Listenable.merge([_flipCtrl, _pulseCtrl, _glowCtrl]),
              builder: (context, _) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_flipAnim.value)
                    ..scaleByDouble(
                        _pulseAnim.value, _pulseAnim.value, 1.0, 1.0),
                  child: RepaintBoundary(
                    child: _QueueCard(
                      current: _current,
                      isFlipping: _isFlipping,
                      hasMore: _pool.isNotEmpty,
                      cardStyle: _cardStyle,
                      colorScheme: cs,
                      glowIntensity: _glowAnim.value,
                    ),
                  ),
                );
              },
            ),
          ),

          const Spacer(),

          // ── Draw button ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
            child: Column(children: [
              SizedBox(
                width: double.infinity,
                height: 58,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _pool.isEmpty
                      ? OutlinedButton.icon(
                          onPressed: _regenerate,
                          icon: Icon(Icons.shuffle_rounded, color: cs.primary),
                          label: Text('RESHUFFLE DECK',
                              style: TextStyle(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: cs.primary, width: 2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _draw,
                          icon: const Icon(Icons.touch_app_rounded,
                              color: Colors.white),
                          label: const Text('DRAW CARD',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  fontSize: 15)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: cs.primary.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _pool.isEmpty
                    ? 'ALL $_total DRAWN'
                    : '${_pool.length} OF $_total REMAINING',
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.3),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _StatsBar — progress indicator at the top
// ---------------------------------------------------------------------------

class _StatsBar extends StatelessWidget {
  final int pool;
  final int taken;
  final int total;
  final ColorScheme colorScheme;

  const _StatsBar({
    required this.pool,
    required this.taken,
    required this.total,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    final progress = total > 0 ? taken / total : 0.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$taken DRAWN',
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '$pool LEFT',
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.45),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 400),
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 5,
                backgroundColor: cs.primary.withValues(alpha: 0.12),
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _NumberGrid — shows all slots; drawn = highlighted, latest = pulsing
// ---------------------------------------------------------------------------

class _NumberGrid extends StatelessWidget {
  final int total;
  final List<int> taken;
  final int? current;
  final ColorScheme colorScheme;
  final Animation<Offset> slideAnim;

  const _NumberGrid({
    required this.total,
    required this.taken,
    required this.current,
    required this.colorScheme,
    required this.slideAnim,
  });

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: List.generate(total, (i) {
        final n = i + 1;
        final drawn = taken.contains(n);
        final isCurrent = n == current;

        Widget chip = AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCurrent
                ? cs.primary
                : drawn
                    ? cs.primary.withValues(alpha: 0.35)
                    : cs.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrent
                  ? cs.primary
                  : drawn
                      ? cs.primary.withValues(alpha: 0.4)
                      : cs.primary.withValues(alpha: 0.15),
              width: isCurrent ? 2 : 1,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                        color: cs.primary.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 1)
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '$n',
              style: TextStyle(
                color: isCurrent
                    ? cs.onPrimary
                    : drawn
                        ? cs.primary
                        : cs.onSurface.withValues(alpha: 0.2),
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
        );

        // Slide the latest drawn chip in
        if (isCurrent) {
          chip = SlideTransition(position: slideAnim, child: chip);
        }

        return chip;
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// _QueueCard — the main animated card, supports 3 visual styles
// ---------------------------------------------------------------------------

class _QueueCard extends StatelessWidget {
  final int? current;
  final bool isFlipping;
  final bool hasMore;
  final CardStyle cardStyle;
  final ColorScheme colorScheme;
  final double glowIntensity;

  const _QueueCard({
    required this.current,
    required this.isFlipping,
    required this.hasMore,
    required this.cardStyle,
    required this.colorScheme,
    required this.glowIntensity,
  });

  bool get _showFront => current != null && !isFlipping;

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Card color based on style
    final Color frontBg;
    final Color backBg;
    final List<Color>? frontGradient;
    final List<Color>? backGradient;

    switch (cardStyle) {
      case CardStyle.classic:
        frontBg = isDark ? const Color(0xFFE8EDF2) : Colors.white;
        backBg = isDark ? const Color(0xFF1A2435) : const Color(0xFF0D1218);
        frontGradient = null;
        backGradient = null;
        break;
      case CardStyle.neon:
        frontBg = const Color(0xFF0D1218);
        backBg = const Color(0xFF0D1218);
        frontGradient = null;
        backGradient = null;
        break;
      case CardStyle.gradient:
        frontBg = Colors.transparent;
        backBg = Colors.transparent;
        frontGradient = [
          cs.primary.withValues(alpha: 0.9),
          cs.primary.withValues(alpha: 0.5),
          cs.secondary.withValues(alpha: 0.8),
        ];
        backGradient = [
          const Color(0xFF131A22),
          cs.primary.withValues(alpha: 0.12),
          const Color(0xFF131A22),
        ];
        break;
    }

    final borderColor = cardStyle == CardStyle.neon
        ? cs.primary
        : isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.08);

    return Container(
      width: 200,
      height: 286,
      decoration: BoxDecoration(
        color: _showFront ? frontBg : backBg,
        gradient: _showFront
            ? (frontGradient != null
                ? LinearGradient(
                    colors: frontGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null)
            : (backGradient != null
                ? LinearGradient(
                    colors: backGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cardStyle == CardStyle.neon
              ? cs.primary.withValues(alpha: glowIntensity)
              : borderColor,
          width: cardStyle == CardStyle.neon ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: glowIntensity * 0.3),
            blurRadius: 24 + (glowIntensity * 16),
            spreadRadius: 1,
          ),
          if (isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: _showFront
          ? _frontFace(cs, cardStyle)
          : _backFace(cs, hasMore, cardStyle),
    );
  }

  Widget _frontFace(ColorScheme cs, CardStyle style) {
    final textColor = style == CardStyle.classic ? Colors.black : Colors.white;
    final labelColor = style == CardStyle.classic
        ? Colors.black38
        : Colors.white.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: textColor.withValues(
                  alpha: style == CardStyle.classic ? 0.06 : 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'YOU\'RE UP',
              style: TextStyle(
                color: labelColor,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),

          // Big number
          Center(
            child: Text(
              '$current',
              style: TextStyle(
                color: textColor,
                fontSize: 112,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),

          // Bottom row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports, color: labelColor, size: 14),
              const SizedBox(width: 6),
              Text(
                'PLAYER $current',
                style: TextStyle(
                  color: labelColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _backFace(ColorScheme cs, bool hasMore, CardStyle style) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: cs.primary.withValues(alpha: 0.6), width: 2),
              color: cs.primary.withValues(alpha: 0.1),
            ),
            child: Icon(
              hasMore ? Icons.touch_app_rounded : Icons.block_rounded,
              color: cs.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            hasMore ? 'TAP TO DRAW' : 'DECK EMPTY',
            style: TextStyle(
              color: hasMore ? cs.primary : cs.error,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          if (hasMore) ...[
            const SizedBox(height: 8),
            Text(
              'tap card or button below',
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.3),
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SettingsToggle
// ---------------------------------------------------------------------------

class _SettingsToggle extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ColorScheme colorScheme;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.colorScheme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(label,
            style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
        subtitle: Text(subtitle,
            style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.4), fontSize: 11)),
        value: value,
        activeThumbColor: cs.primary,
        activeTrackColor: cs.primary.withValues(alpha: 0.5),
        onChanged: onChanged,
      ),
    );
  }
}
