import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedHealthBackground extends StatefulWidget {
  const AnimatedHealthBackground({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  State<AnimatedHealthBackground> createState() => _AnimatedHealthBackgroundState();
}

class _AnimatedHealthBackgroundState extends State<AnimatedHealthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE7F5FF), Color(0xFFF6FCFF)],
                  ),
                ),
              ),
            ),
            _MovingBlob(
              alignment: Alignment(-0.9 + 0.25 * math.sin(t * 2 * math.pi), -0.8),
              size: 190,
              color: const Color(0x4D8ED2FF),
            ),
            _MovingBlob(
              alignment: Alignment(0.8, -0.1 + 0.22 * math.cos(t * 2 * math.pi)),
              size: 150,
              color: const Color(0x3D62B6F7),
            ),
            _MovingBlob(
              alignment: Alignment(-0.7 + 0.35 * math.cos(t * 2 * math.pi), 0.95),
              size: 220,
              color: const Color(0x337FDBFF),
            ),
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: widget.padding,
                  child: widget.child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MovingBlob extends StatelessWidget {
  const _MovingBlob({
    required this.alignment,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 30,
              spreadRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}
