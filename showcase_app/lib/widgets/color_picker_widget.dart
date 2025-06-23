import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import '../utils/color_utils.dart';

/// A reusable color picker widget that displays a row of color options.
class DerivColorPicker extends StatelessWidget {
  /// Creates a DerivColorPicker widget.
  const DerivColorPicker({
    required this.selectedColor,
    required this.onColorChanged,
    Key? key,
    this.presetColors,
    this.showCustomColorOption = true,
    this.label,
    this.labelWidth = 120,
    this.colorSize = 24,
    this.spacing = 8,
  }) : super(key: key);

  /// The currently selected color.
  final Color selectedColor;

  /// Callback function when a color is selected.
  final Function(Color) onColorChanged;

  /// Optional list of preset colors to display.
  /// If not provided, default colors will be used based on the current theme.
  final List<Color>? presetColors;

  /// Whether to show a button to open a custom color picker dialog.
  final bool showCustomColorOption;

  /// Label to display before the color options.
  final String? label;

  /// Width of the label section.
  final double labelWidth;

  /// Size of each color circle.
  final double colorSize;

  /// Spacing between color options.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final colors = presetColors ?? _getDefaultColors(isDarkTheme);

    return Row(
      children: [
        if (label != null)
          SizedBox(
            width: labelWidth,
            child: Text(label!),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              ...colors.map((color) => _buildColorButton(color)),
              if (showCustomColorOption) _buildCustomColorButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorButton(Color color) {
    return InkWell(
      onTap: () => onColorChanged(color),
      child: Container(
        width: colorSize,
        height: colorSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == color ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomColorButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        final color = await showDerivColorPickerDialog(
          context,
          initialColor: selectedColor,
        );
        if (color != null) {
          onColorChanged(color);
        }
      },
      child: Container(
        width: colorSize,
        height: colorSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: const Icon(
          Icons.add,
          size: 16,
        ),
      ),
    );
  }

  /// Returns default colors based on the current theme.
  List<Color> _getDefaultColors(bool isDarkTheme) {
    return ColorUtils.getThemeColors(isDarkTheme: isDarkTheme);
  }
}

/// Shows a dialog with advanced color picking options.
Future<Color?> showDerivColorPickerDialog(
  BuildContext context, {
  required Color initialColor,
  String title = 'Select Color',
}) async {
  final colorPickerKey = GlobalKey<_DerivColorPickerDialogState>();

  final result = await showDialog<Color>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: DerivColorPickerDialog(
          key: colorPickerKey,
          initialColor: initialColor,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final selectedColor =
                colorPickerKey.currentState?._selectedColor ?? initialColor;
            Navigator.of(context).pop(selectedColor);
          },
          child: const Text('Select'),
        ),
      ],
    ),
  );

  return result;
}

/// A dialog with advanced color picking options.
class DerivColorPickerDialog extends StatefulWidget {
  /// Creates a DerivColorPickerDialog.
  const DerivColorPickerDialog({
    required this.initialColor,
    Key? key,
  }) : super(key: key);

  /// The initial color to display.
  final Color initialColor;

  @override
  State<DerivColorPickerDialog> createState() => _DerivColorPickerDialogState();
}

class _DerivColorPickerDialogState extends State<DerivColorPickerDialog> {
  late Color _selectedColor;
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _hexController = TextEditingController(
      text:
          '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkTheme ? Colors.black : Colors.white;
    final colorName = ColorUtils.getColorName(_selectedColor);
    final contrastInfo =
        ColorUtils.checkContrast(_selectedColor, backgroundColor);

    return Container(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color preview
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: _selectedColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    colorName,
                    style: TextStyle(
                      color: _getContrastColor(_selectedColor),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RGB(${_selectedColor.red}, ${_selectedColor.green}, ${_selectedColor.blue})',
                    style: TextStyle(
                      color: _getContrastColor(_selectedColor),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contrast information
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                contrastInfo['normalText'] ? Icons.check_circle : Icons.warning,
                color:
                    contrastInfo['normalText'] ? Colors.green : Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Contrast: ${contrastInfo['ratio'].toStringAsFixed(1)}:1',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      contrastInfo['normalText'] ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // RGB sliders
          _buildColorSlider('R', _selectedColor.red.toDouble(), Colors.red,
              (value) {
            setState(() {
              _selectedColor = _selectedColor.withRed(value.round());
              _updateHexController();
            });
          }),
          _buildColorSlider('G', _selectedColor.green.toDouble(), Colors.green,
              (value) {
            setState(() {
              _selectedColor = _selectedColor.withGreen(value.round());
              _updateHexController();
            });
          }),
          _buildColorSlider('B', _selectedColor.blue.toDouble(), Colors.blue,
              (value) {
            setState(() {
              _selectedColor = _selectedColor.withBlue(value.round());
              _updateHexController();
            });
          }),
          _buildColorSlider('A', _selectedColor.alpha.toDouble(), Colors.grey,
              (value) {
            setState(() {
              _selectedColor = _selectedColor.withAlpha(value.round());
              _updateHexController();
            });
          }),

          // Hex input
          const SizedBox(height: 16),
          TextField(
            controller: _hexController,
            decoration: const InputDecoration(
              labelText: 'Hex Color',
              prefixText: '#',
            ),
            onChanged: (value) {
              if (value.length == 6) {
                try {
                  final color = Color(int.parse('FF$value', radix: 16));
                  setState(() {
                    _selectedColor = color;
                  });
                } on FormatException catch (e) {
                  // Invalid hex color
                  debugPrint('Invalid hex color: $e');
                }
              }
            },
          ),
          // Deriv theme colors
          const SizedBox(height: 16),
          const Text('Deriv Theme Colors'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMaterialColorButton(BrandColors.coral),
              _buildMaterialColorButton(BrandColors.greenish),
              _buildMaterialColorButton(BrandColors.orange),
              _buildMaterialColorButton(
                  CandleBullishThemeColors.candleBullishBodyDefault),
              _buildMaterialColorButton(
                  CandleBearishThemeColors.candleBearishBodyDefault),
              _buildMaterialColorButton(LegacyLightThemeColors.accentYellow),
            ],
          ),

          // Material color palette
          const SizedBox(height: 16),
          const Text('Material Colors'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMaterialColorButton(Colors.red),
              _buildMaterialColorButton(Colors.pink),
              _buildMaterialColorButton(Colors.purple),
              _buildMaterialColorButton(Colors.deepPurple),
              _buildMaterialColorButton(Colors.indigo),
              _buildMaterialColorButton(Colors.blue),
              _buildMaterialColorButton(Colors.lightBlue),
              _buildMaterialColorButton(Colors.cyan),
              _buildMaterialColorButton(Colors.teal),
              _buildMaterialColorButton(Colors.green),
              _buildMaterialColorButton(Colors.lightGreen),
              _buildMaterialColorButton(Colors.lime),
              _buildMaterialColorButton(Colors.yellow),
              _buildMaterialColorButton(Colors.amber),
              _buildMaterialColorButton(Colors.orange),
              _buildMaterialColorButton(Colors.deepOrange),
              _buildMaterialColorButton(Colors.brown),
              _buildMaterialColorButton(Colors.grey),
              _buildMaterialColorButton(Colors.blueGrey),
              _buildMaterialColorButton(Colors.black),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorSlider(
      String label, double value, Color color, Function(double) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(label),
        ),
        Expanded(
          child: Slider(
            value: value,
            max: label == 'A' ? 255 : 255,
            divisions: 255,
            activeColor: color,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(value.round().toString()),
        ),
      ],
    );
  }

  Widget _buildMaterialColorButton(Color color) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedColor = color;
          _updateHexController();
        });
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor.value == color.value
                ? Colors.white
                : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  void _updateHexController() {
    _hexController.text =
        _selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2);
  }

  /// Returns either black or white depending on which provides better contrast with the given color.
  Color _getContrastColor(Color color) {
    // Calculate the perceptive luminance (perceived brightness) of the color
    // This formula gives more weight to green as the human eye is more sensitive to green
    final double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

    // Return black for bright colors and white for dark colors
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
