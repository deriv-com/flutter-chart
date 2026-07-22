import 'package:flutter/material.dart';

/// The set of icons used by the on-chart indicator label
/// (`IndicatorLabelMobile`) - the eye (hide/unhide), reorder arrows, settings
/// (gear), delete (trash) and expand/collapse chevron.
///
/// Every icon is an [IconData] and defaults to a Material icon, so the library
/// works out of the box. A consumer app can override any subset of them - e.g.
/// with its own design-system glyphs so the label matches its design - by
/// passing an [IndicatorLabelIcons] to `DerivChart`/`Chart`. Icons that aren't
/// overridden keep their Material default. The library keeps applying its own
/// size and color to whichever [IconData] is supplied.
@immutable
class IndicatorLabelIcons {
  /// Creates an icon set for the indicator label. Any omitted icon falls back
  /// to its Material default.
  const IndicatorLabelIcons({
    this.show = Icons.visibility_outlined,
    this.hide = Icons.visibility_off_outlined,
    this.settings = Icons.settings,
    this.delete = Icons.delete_outline,
    this.moveUp = Icons.arrow_upward,
    this.moveDown = Icons.arrow_downward,
    this.expandCollapse = Icons.chevron_right,
  });

  /// Icon for the hide/unhide (eye) toggle while the indicator is shown.
  final IconData show;

  /// Icon for the hide/unhide (eye) toggle while the indicator is hidden.
  final IconData hide;

  /// Icon for the settings (gear) action.
  final IconData settings;

  /// Icon for the delete (trash) action.
  final IconData delete;

  /// Icon for the move-up reorder action.
  final IconData moveUp;

  /// Icon for the move-down reorder action.
  final IconData moveDown;

  /// Icon for the expand/collapse chevron.
  ///
  /// It is rotated 180° when the label is expanded, so it should point in the
  /// "expand" direction while collapsed (e.g. a right-pointing chevron).
  final IconData expandCollapse;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndicatorLabelIcons &&
          runtimeType == other.runtimeType &&
          show == other.show &&
          hide == other.hide &&
          settings == other.settings &&
          delete == other.delete &&
          moveUp == other.moveUp &&
          moveDown == other.moveDown &&
          expandCollapse == other.expandCollapse;

  @override
  int get hashCode => Object.hash(
        show,
        hide,
        settings,
        delete,
        moveUp,
        moveDown,
        expandCollapse,
      );
}
