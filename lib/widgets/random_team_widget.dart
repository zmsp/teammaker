import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RandomTeamScreen extends StatefulWidget {
  final int initialTotal;
  const RandomTeamScreen({super.key, this.initialTotal = 6});

  @override
  State<RandomTeamScreen> createState() => _RandomTeamScreenState();
}

class _RandomTeamScreenState extends State<RandomTeamScreen>
    with SingleTickerProviderStateMixin {
  late int _total;
  List<int> _pool = [], _taken = [];
  int? _res;
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _flip = false;

  @override
  void initState() {
    super.initState();
    _total = widget.initialTotal;
    _gen();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    _anim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi / 2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -pi / 2, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  void _gen() => setState(() {
        _pool = List.generate(_total, (i) => i + 1)..shuffle();
        _taken = [];
        _res = null;
      });

  void _draw() {
    if (_flip || _pool.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() => _flip = true);
    _ctrl.forward(from: 0).then((_) => setState(() {
          _res = _pool.removeAt(0);
          _taken.add(_res!);
          _flip = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("PLAYER QUEUE",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontSize: 13,
                  color: Colors.white)),
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                onPressed: _gen)
          ]),
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.all(20),
            child: _inp("DECK SIZE", _total, (v) {
              _total = int.tryParse(v) ?? 1;
              _gen();
            })),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_total, (i) {
                  final n = i + 1, ok = _taken.contains(n);
                  return Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                          color: ok ? Colors.white : Colors.white10,
                          borderRadius: BorderRadius.circular(4)),
                      child: Center(
                          child: Text("$n",
                              style: TextStyle(
                                  color: ok ? Colors.black : Colors.white24,
                                  fontWeight: FontWeight.bold))));
                }))),
        const Spacer(),
        GestureDetector(
            onTap: _pool.isEmpty ? null : _draw,
            child: AnimatedBuilder(
                animation: _ctrl,
                builder: (c, w) {
                  final s = 1.0 + (sin(_ctrl.value * pi) * 0.08);
                  return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_anim.value)
                        ..scale(s),
                      child:
                          _Card(res: _res, flip: _flip, has: _pool.isNotEmpty));
                })),
        const Spacer(),
        Padding(
            padding: const EdgeInsets.all(30),
            child: Column(children: [
              SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                      onPressed: _pool.isEmpty ? _gen : _draw,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: const RoundedRectangleBorder()),
                      child: Text(_pool.isEmpty ? "REFILL" : "DRAW CARD",
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, letterSpacing: 2)))),
              const SizedBox(height: 10),
              Text("${_pool.length} REMAINING",
                  style: const TextStyle(
                      color: Colors.white24,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ])),
      ]),
    );
  }

  Widget _inp(String l, int v, ValueChanged<String> fn) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
        TextField(
            controller: TextEditingController(text: "$v")
              ..selection =
                  TextSelection.fromPosition(TextPosition(offset: "$v".length)),
            keyboardType: TextInputType.number,
            style: const TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
            decoration:
                const InputDecoration(border: InputBorder.none, isDense: true),
            onChanged: fn,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
      ]);
}

class _Card extends StatelessWidget {
  final int? res;
  final bool flip, has;
  const _Card({this.res, required this.flip, required this.has});

  @override
  Widget build(BuildContext context) {
    final front = res != null && !flip;
    return Container(
      width: 210,
      height: 300,
      decoration: BoxDecoration(
          color: front ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 30)
          ]),
      child: Center(
          child: front
              ? Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text("NUMBER",
                      style: TextStyle(
                          color: Colors.black38,
                          fontSize: 10,
                          fontWeight: FontWeight.w900)),
                  Text("$res",
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 110,
                          fontWeight: FontWeight.w900,
                          height: 1)),
                  const Text("ASSIGNED",
                      style: TextStyle(
                          color: Colors.black26,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2)),
                ])
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          shape: BoxShape.circle),
                      child: const Center(
                          child: Icon(Icons.casino,
                              color: Colors.white, size: 30))),
                  const SizedBox(height: 20),
                  Text(has ? "TAP" : "EMPTY",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4)),
                ])),
    );
  }
}
