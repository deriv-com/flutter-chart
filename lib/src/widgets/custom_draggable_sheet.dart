import 'package:flutter/material.dart';

/// A widget to manage the over-scroll to dismiss for a scrollable inside its [child]
/// that being shown by calling [showBottomSheet()].
///
/// This widget will listen to [OverscrollNotification] inside its [child] to detect
/// that it has reached its top scroll limit. when user is closing the [child] by over-scrolling,
/// it will call [Navigator.pop()], to fully dismiss the [BottomSheet].
class CustomDraggableSheet extends StatefulWidget {
  /// Initializes a widget to manage the over-scroll to dismiss for a scrollable inside its [child].
  const CustomDraggableSheet({
    required this.child,
    Key? key,
    this.animationDuration = const Duration(milliseconds: 100),
    this.introAnimationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  /// The sheet that was popped-up inside a [BottomSheet] throw calling [showBottomSheet()].
  final Widget child;

  /// The duration of animation whether sheet will fling back to top or dismiss.
  final Duration animationDuration;

  /// The duration of the starting animation.
  final Duration introAnimationDuration;

  @override
  _CustomDraggableSheetState createState() => _CustomDraggableSheetState();
}

class _CustomDraggableSheetState extends State<CustomDraggableSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final _sheetKey = GlobalKey();

  Size? _sheetSize;

  bool _overScrolled = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController.unbounded(vsync: this, value: 1)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed &&
            _animationController.value > 0.9) {
          Navigator.of(context).pop();
        }
      });

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _sheetSize = _initSizes();
      _animationController.animateTo(
        0,
        duration: widget.introAnimationDuration,
        curve: Curves.easeOut,
      );
    });
  }

  Size _initSizes() {
    final RenderBox chartBox =
        _sheetKey.currentContext!.findRenderObject() as RenderBox;
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
          child: widget.child,
        ),
      );

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(Notification notification) {
    if (_sheetSize != null && notification is OverscrollNotification) {
      _overScrolled = true;
      _panToBottom(notification);
    } else if (notification is ScrollUpdateNotification && _overScrolled) {
      _panToTop(notification);
    } else if (!_animationController.isAnimating &&
        notification is ScrollEndNotification &&
        _overScrolled) {
      _overScrolled = false;
      _flingToTopOrBottom();
    }

    return false;
  }

  void _panToTop(ScrollUpdateNotification notification) {
    final deltaPercent = notification.scrollDelta! / _sheetSize!.height;

    if (deltaPercent > 0) {
      _updateSheetHeightBy(deltaPercent);
    }
  }

  void _panToBottom(OverscrollNotification notification) {
    final deltaPercent = notification.overscroll / _sheetSize!.height;

    if (deltaPercent < 0) {
      _updateSheetHeightBy(deltaPercent);
    }
  }

  void _updateSheetHeightBy(double deltaPercent) {
    _animationController.value -= deltaPercent;
    _animationController.value = _animationController.value.clamp(0.0, 1.0);
  }

  void _flingToTopOrBottom() {
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
}
