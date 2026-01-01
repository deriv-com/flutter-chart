## Contributing Guidelines

Contributions to the **Deriv Flutter chart package** are welcome and encouraged! Whether you're interested in adding new features, fixing bugs, or improving documentation, we appreciate your support in making this package better. To ensure a smooth and collaborative contribution process, please adhere to the following guidelines:

**Familiarize Yourself**: Before contributing, Familiarize yourself with the structure and organization of the current chart package. Gain an understanding of the available chart types, data models, and rendering techniques. Study how the current Chart widgets and their rendering pipeline work, how it handles the coordinate system, the paintings, the layers it has for each component set (main chart data, indicators, cross-hair, etc), the gestures, and so on. for more information you can refer to [this documentation](https://github.com/deriv-com/flutter-chart/blob/dev/docs/how_chart_lib_works.md).

**Code Style**: Follow the established code style conventions in the project. Consistent code formatting enhances readability and maintainability. We have a set of code styling rules which are defined inside the Mobile development team's [deriv_lint package](https://github.com/deriv-com/flutter-deriv-packages/blob/dev/packages/deriv_lint/lib/analysis_options.yaml). 
Also please check out this [Mobile team's code style convention doc in WikiJS](https://wikijs.deriv.cloud/en/Mobile/code_conventions/flutter_team_coding_conventions).

**Pull Requests description**: When submitting a pull request, provide a clear and concise description of the changes you've made. Ensure that your code is well-tested, and include relevant documentation updates, if necessary. If it's a big PR and brings a lot of changes, providing some information about the changes in the PR comment would really help the reviewer. For example [this PR](https://github.com/deriv-com/flutter-chart/pull/22#issue-694383974) in the package.

**Documentation**: Apart from code contributions, helping improve the documentation is highly valuable. Update the documentation and provide clear examples for using the new features or modifications. Include explanations of the API, usage scenarios, and any required configurations. Illustrate the expected results and provide sample code to help users of the package or other contributors to understand how to integrate the new functionality. If you notice areas where the documentation can be enhanced or expanded, feel free to add or edit the documentation of the components. 
For example in class [AbstractSingleIndicatorSeries](https://github.com/deriv-com/flutter-chart/blob/1adc9ef463195a33fc331ef9fd0a45a1ab0cb4a8/lib/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/abstract_single_indicator_series.dart#L60) as we can see, it's mentioned what are the property and the purpose of this field, even illustrated in a way so the reader can imagine how it works. The best time to write the documentation is for sure the time we develop that piece of code.

```Dart
...
  /// The offset of this indicator.
  ///
  /// Indicator's data will be shifted by this number of tick while they are
  /// being painted. For example if we consider `*`s as indicator data on the
  /// chart below with default [offset] = 0:
  /// |                                 (Tick5)
  /// |    *            (Tick3) (Tick4)    *
  /// | (Tick1)    *             *
  /// |         (Tick2)   *
  ///  ------------------------------------------->
  ///
  /// Indicator's data with [offset] = 1 will be like:
  /// |                                 (Tick5)
  /// |            *    (Tick3) (Tick4)          *
  /// | (Tick1)            *              *
  /// |         (Tick2)           *
  ///  ------------------------------------------->
  final int offset;
...
```



_____________
### The general steps for adding new features or modifying existing ones:

**1. Plan the Architecture**: Consider the best approach for implementing the new features within the existing package architecture. Determine if it's necessary to introduce new widgets, data models, or rendering techniques. Evaluate the impact on performance, code organization, and maintainability. One key factor is to make the Chart know less about what it is rendering and have a consistent rendering step and depend on abstraction to function. To have functionality in small pieces and components and encapsulate them in a way that makes sense. One example from the package is using defining `ChartData` and `Series` abstractions, in order to delegate functionalities and depend on abstraction and make the functionality of the [Chart widget](https://github.com/deriv-com/flutter-chart/blob/1adc9ef463195a33fc331ef9fd0a45a1ab0cb4a8/lib/src/deriv_chart/chart/chart.dart#L39) more dynamic and customizable, the `Chart` widget is depending on it. 

It's important to keep in mind that after making some progress in the implementation of a feature we rethink and analyze if any improvement can be done in the structure of the components to make it more scalable, and maintainable and remove duplicated codes.

**2. Define a Clear API**: define a clear and intuitive API for adding new features. Consider how the users of the package will interact with the new functionality and design an API that is consistent with the existing package conventions.

**3. Handle Customization**: Consider adding configuration options or callbacks to enable users to modify chart behavior.

**4. Consider Performance**: Optimize performance by implementing techniques such as caching, and rendering only visible data points. Some examples are already used in implemented features, like calculating the chart's [visible data using binary search](https://github.com/deriv-com/flutter-chart/blob/1adc9ef463195a33fc331ef9fd0a45a1ab0cb4a8/lib/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart#L204) and [caching indicators' values on real-time chart updates](https://github.com/deriv-com/flutter-chart/blob/1adc9ef463195a33fc331ef9fd0a45a1ab0cb4a8/lib/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/abstract_single_indicator_series.dart#L17). 
Ensure that the package performs well on different devices and handles large datasets efficiently. 

**5. Test on Real Financial Data**: Validate the functionality and accuracy of the financial chart package by testing it with real financial data. Ensure that the charts can handle various data patterns, such as irregular time intervals, different chart types, and large data ranges.

**6 Dart analyzer and unit tests**: When the new functionality is ready for review please do a self-review first before passing to review. when submitting PR regardless of whether there is CI integration that runs and checks Dart static analyzer and test, you should also make sure that the following commands run on your local machine without any warnings or issues:

```
flutter analyze
flutter test
```


### Some general notes:

**Readability and Maintainability**: Ensure that the code is easy to read, understand, and maintain. Consider the following aspects:

- Use meaningful and descriptive names for variables, functions, and classes.
Break down complex code into smaller, modular functions or methods.
Follow a consistent coding style and formatting conventions.
Add comments where necessary to clarify the intent or complex sections.

- Code Structure and Organization: Check if the code is well-structured and organized. Look for:

- Proper separation of concerns and adherence to the Single Responsibility Principle (SRP).
Many functionalities in the package would have two parts, calculation logic, and painting operations. It's better to keep these two separate to achieve the SRP. One example in the package could be the [Series](https://github.com/deriv-com/flutter-chart/blob/1adc9ef463195a33fc331ef9fd0a45a1ab0cb4a8/lib/src/deriv_chart/chart/data_visualization/chart_series/series.dart#L11) class which handles the logic of calculation for the Chart series data and it works with a [SeriesPainter](https://github.com/deriv-com/flutter-chart/blob/1adc9ef463195a33fc331ef9fd0a45a1ab0cb4a8/lib/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart#L8) to delegate the painting operation

- Avoidance of code duplication and the use of appropriate abstractions.
Consistent indentation, code grouping, and file organization.

### Immutability:
For model classes, prefer using immutable objects, and we want to gain use of the language features which is encouraged. It will bring more reliability to the code and will increase maintenance. [Immutablity in Flutter](https://dart.academy/immutable-data-patterns-in-dart-and-flutter/#:~:text=There%20are%20a%20number%20of,what%20code%20is%20accessing%20it.)

Immutability means that once an object is created, its state cannot be changed. Any modification to the object will create a new instance with the updated data, leaving the original object unchanged. On the other hand, mutability means that the object's state can be modified directly after creation.

Flutter strongly advocates for immutability, and there are several reasons for this:

Predictability: Immutable objects have a predictable state throughout their lifetime, making it easier to reason about the flow of data in your application. This will avoid an object to be modified in different places, and can lead to fewer bugs and easier debugging.

Consistency: In an immutable approach, objects don't change unexpectedly, which helps maintain a consistent state and behavior within the app.

Performance: Immutability can offer performance benefits, especially in the context of Flutter's "Widget tree" where UI elements are rebuilt when the underlying data changes. With immutable objects, Flutter can optimize the UI updates and avoid unnecessary rebuilds.

Concurrency: Immutable data is inherently thread-safe, making it easier to work with concurrent programming and avoid data race conditions.


## PR format:
Please follow the conventional commit format for the PR title. For more information, please check [conventionalcommits](https://www.conventionalcommits.org/en/v1.0.0/)
