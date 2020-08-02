import 'package:flutter/material.dart';

/// A widget to play a pulse highlight animation on its child
class AnimatedHighlight extends StatefulWidget {
  const AnimatedHighlight({
    Key key,
    this.child,
    this.duration = const Duration(milliseconds: 500),
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
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _playAnimation();
    super.initState();
  }

  void _playAnimation() async {
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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget child) => Ink(
        color: Colors.grey.withOpacity(
          0.08 + (0.2 * _animationController.value),
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}
