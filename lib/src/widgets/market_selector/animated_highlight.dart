import 'package:flutter/material.dart';

/// A widget to play a pulse highlight animation on its child.
class AnimatedHighlight extends StatefulWidget {
  const AnimatedHighlight({
    @required this.child,
    Key key,
    this.duration = const Duration(milliseconds: 400),
    this.playAfter = const Duration(seconds: 1),
  }) : super(key: key);

  final Widget child;

  final Duration duration;

  /// Play the pulse animation after this duration
  final Duration playAfter;

  @override
  _AnimatedHighlightState createState() => _AnimatedHighlightState();
}

class _AnimatedHighlightState extends State<AnimatedHighlight>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: 0.1,
      upperBound: 0.3,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _playAnimation();
  }

  Future<void> _playAnimation() async {
    await Future<void>.delayed(widget.playAfter);
    await _animationController.forward();
    _animationController.reverse();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (BuildContext context, Widget child) => Ink(
          color: Colors.grey.withOpacity(_animation.value),
          child: child,
        ),
        child: widget.child,
      );
}
