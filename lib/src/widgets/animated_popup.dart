import 'package:flutter/material.dart';

/// To be used as the container of the popup dialogs with animation
class AnimatedPopupDialog extends StatefulWidget {
  /// Initializes
  const AnimatedPopupDialog({
    Key? key,
    this.child,
    this.animationDuration = const Duration(milliseconds: 150),
  }) : super(key: key);

  /// content of this dialog
  final Widget? child;

  /// Animation duration
  final Duration animationDuration;

  @override
  State<StatefulWidget> createState() => _AnimatedPopupDialogState();
}

class _AnimatedPopupDialogState extends State<AnimatedPopupDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final Curve _curve = Curves.easeOut;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: widget.animationDuration)
          ..forward();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) => Transform.scale(
          scale: _curve.transform(controller.value),
          child: child,
        ),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: _calculateHorizontalPadding(context),
            vertical: 40,
          ),
          child: Card(
            color: Colors.transparent,
            elevation: 4,
            child: Container(
              decoration: const ShapeDecoration(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
              ),
              child: Material(
                color: const Color(0xFF0E0E0E).withValues(alpha: 0.5),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      );

  double _calculateHorizontalPadding(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 900) {
      return 0.25 * screenWidth;
    } else if (screenWidth > 750) {
      return 0.2 * screenWidth;
    } else if (screenWidth < 400) {
      return 0.02 * screenWidth;
    } else if (screenWidth < 500) {
      return 0.05 * screenWidth;
    } else {
      return 0.1 * screenWidth;
    }
  }
}
