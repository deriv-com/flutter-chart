# Color Picker Widgets

This directory contains reusable widgets for color selection in the Deriv Chart showcase app.

## DerivColorPicker

A simple, customizable color picker that displays a row of color options as circular buttons.

### Features

- Displays a row of color options as circular buttons
- Supports custom color presets or uses theme-aware defaults
- Includes an option to open an advanced color picker dialog
- Customizable label, size, and spacing

### Usage

```dart
DerivColorPicker(
  label: 'Text Color:',
  selectedColor: _textColor,
  onColorChanged: (color) {
    setState(() {
      _textColor = color;
    });
  },
  // Optional: provide custom color presets
  presetColors: [Colors.black, Colors.blue, Colors.red],
  // Optional: hide the custom color option
  showCustomColorOption: true,
)
```

## DerivColorPickerDialog

An advanced color picker dialog with RGB sliders, hex input, and color palettes.

### Features

- RGB and Alpha sliders for precise color selection
- Hex color code input
- Material Design color palette
- Theme-aware color palette
- Color name display
- Contrast ratio checking for accessibility
- Color preview

### Usage

```dart
final color = await showDerivColorPickerDialog(
  context,
  initialColor: Colors.blue,
  title: 'Select Text Color',
);

if (color != null) {
  // Use the selected color
  setState(() {
    _textColor = color;
  });
}
```

## ColorUtils

A utility class for color-related operations.

### Features

- Theme-aware color presets
- Color contrast calculation
- WCAG accessibility guidelines checking
- Color name identification

### Usage

```dart
// Get theme-aware color presets
final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
final themeColors = ColorUtils.getThemeColors(isDarkTheme);

// Get positive/negative color presets
final positiveColors = ColorUtils.getPositiveColors();
final negativeColors = ColorUtils.getNegativeColors();

// Check contrast for accessibility
final contrastInfo = ColorUtils.checkContrast(foregroundColor, backgroundColor);
final isAccessible = contrastInfo['normalText']; // true if contrast ratio >= 4.5:1

// Get color name
final colorName = ColorUtils.getColorName(myColor);
```

## Integration with Chart Themes

The color picker widgets are designed to work seamlessly with the chart theme system. They can be used to customize various aspects of the chart appearance, such as:

- Positive/negative candle colors
- Grid colors
- Background colors
- Line colors
- Indicator colors

Example:

```dart
DerivColorPicker(
  label: 'Positive Color:',
  selectedColor: _positiveColor,
  onColorChanged: (color) {
    setState(() {
      _positiveColor = color;
      
      // Update the chart theme
      _chartTheme = CustomDarkTheme(
        customPositiveColor: _positiveColor,
        // other properties...
      );
    });
  },
  // Use predefined positive color presets
  presetColors: ColorUtils.getPositiveColors(),
)
