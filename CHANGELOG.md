## [0.5.0]

- feat: add horizontal line, vertical line, and trend line drawing tools with multi-platform support
- feat: add color and line thickness options for drawing tools
- feat: revamp chart markers system with new markers and improved performance
- feat: add default tick offset for X-axis configuration
- feat: add web support for example app
- feat: redesign crosshair UI
- fix: dispose old animation controllers to prevent stale state
- fix: stretched line glitch when resuming from web browser background tab
- fix: improve tap target accessibility for contract markers
- fix: various drawing tools issues including restoration on reload and symbol change
- refactor: reduce bundle size by moving assets to example app

## [0.4.1]

- refactor: restructure drawing tools for better repainting control
- refactor: remove saveLayer usage and draw lines in two segments for improved performance
- fix: example area line rendering
- fix: override shouldRepaint in vertical barrier

## [0.4.0]

- feat: improve package theme interface

## [0.3.9]

- feat: add rise and fall contract markers
- feat: add chart showcase app
- fix: adjust padding of indicator label

## [0.3.8]

- Make XAxis smooth auto-scrolling customizable through ChartAxisConfig

## [0.3.7]

- Update documentations

## [0.3.6]

- Update package description

## [0.3.5]

- Update documentations

## [0.3.4]

- Update documentations
- Update technical analysis dependency to the published one
- Add LineDrawingMobile, a LineDrawing more suitable for mobile

## [0.3.2]

- Add horizontal and vertical barriers for selected line drawing tool on the mobile version
- Add step 300 and step 400 icon assets

## [0.3.0]

- Fix overlay indicators' label spacing
- Add numbering logic to drawing tools
- Upgrade Flutter version to 3.24.x

## [0.2.1]

- New look for mobile chart with chart and bottom indicators dividers.

## [0.2.0]

- Support different layout for Mobile and Web.
- Support copyWith method for IndicatorConfig classes.

## [0.1.0]

- Add drawing tools.
- Make the chart compatible with the `flutter_web` platform.

## [0.0.1]

- TODO: Describe initial release.
