import 'package:deriv_chart/src/add_ons/add_on_config_wrapper.dart';

import 'drawing_tool_config.dart';

/// Callback to update drawing tool with new [drawingToolConfig].
typedef UpdateDrawingTool = Function(
  AddOnConfigWrapper<DrawingToolConfig> drawingToolConfig,
);
