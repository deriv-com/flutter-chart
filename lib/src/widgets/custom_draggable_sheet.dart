import 'package:flutter/material.dart';

class CustomDraggableSheet extends StatefulWidget {
  const CustomDraggableSheet({
    Key key,
    @required this.sheet,
    this.animationDuration = const Duration(milliseconds: 100),
  }) : super(key: key);

  /// The sheet that was popped-up inside a [BottomSheet] throw calling [showBottomSheet()]
  final Widget sheet;

  /// The duration of animation whether sheet will fling back to top or dismiss
  final Duration animationDuration;

  @override
  _CustomDraggableSheetState createState() => _CustomDraggableSheetState();
}

class _CustomDraggableSheetState extends State<CustomDraggableSheet>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  GlobalKey _sheetKey = GlobalKey();

  Size _sheetSize;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController.unbounded(vsync: this, value: 0)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed &&
            _animationController.value > 0.9) {
          Navigator.of(context).pop();
        }
      });

    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => _sheetSize = _initSizes());
  }

  Size _initSizes() {
    final RenderBox chartBox = _sheetKey.currentContext.findRenderObject();
    return chartBox.size;
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        key: _sheetKey,
        animation: _animationController,
        builder: (context, child) => FractionalTranslation(
          translation: Offset(0, _animationController.value),
          child: child,
        ),
        child: NotificationListener(
          onNotification: _handleScrollNotification,
          child: widget.sheet,
        ),
      );

  @override
  void dispose() {
    _animationController?.dispose();

    super.dispose();
  }

  bool _handleScrollNotification(Notification notification) {
    if (_sheetSize != null && notification is OverscrollNotification) {
      final deltaPercent = notification.overscroll / _sheetSize.height;

      if (deltaPercent < 0) {
        _animationController.value -= deltaPercent;
      }
    }

    if (!_animationController.isAnimating &&
        notification is ScrollEndNotification) {
      if (_animationController.value > 0.5) {
        _animationController.animateTo(
          1,
          duration: widget.animationDuration,
          curve: Curves.easeOut,
        );
      } else {
        _animationController.animateTo(
          0,
          duration: widget.animationDuration,
          curve: Curves.easeOut,
        );
      }
    }

    return true;
  }
}
