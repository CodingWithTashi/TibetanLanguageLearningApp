import 'dart:math';

import 'package:flutter/material.dart';

class FlyInAnimation extends StatefulWidget {
  final Widget child;
  final bool animate;
  const FlyInAnimation({Key? key, required this.child, required this.animate})
      : super(key: key);
  @override
  State<FlyInAnimation> createState() => _FlyInAnimationState();
}

class _FlyInAnimationState extends State<FlyInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void didUpdateWidget(FlyInAnimation oldWidget) {
    if (widget.animate && !_controller.isAnimating) {
      _controller.reset();
      _controller.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(milliseconds: 600), vsync: this);
    double begin = 0.0, end = 1.0;
    final flip = Random().nextBool();
    if (flip) {
      begin = 1.0;
      end = 0.0;
    }
    _rotationAnimation =
        Tween<double>(begin: begin, end: end).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
    super.initState();
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
        builder: (context, child) {
          return RotationTransition(
            turns: _rotationAnimation,
            child: ScaleTransition(
              scale: _controller,
              child: widget.child,
            ),
          );
        });
  }
}
