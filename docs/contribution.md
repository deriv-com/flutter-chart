**Contributing Guidelines**

Contributions to the **Deriv Flutter chart package** are welcome and encouraged! Whether you're interested in adding new features, fixing bugs, or improving documentation, we appreciate your support in making this package even better. To ensure a smooth and collaborative contribution process, please adhere to the following guidelines:

Familiarize Yourself: Before contributing, Familiarize yourself with the structure and organization of the current chart package. Gain an understanding of the available chart types, data models, and rendering techniques. Study how the current Chart widgets and their rendering pipeline work, how it handles the coordinate system, the paintings, the layers it has for each component set (main chart data, indicators, cross-hair, etc), the gestures, and so on. for more information you can refer to [this documentation](https://github.com/regentmarkets/flutter-chart/blob/dev/docs/how_chart_lib_works.md).

Code Style: Follow the established code style conventions in the project. Consistent code formatting enhances readability and maintainability. We have a set of code styling rules which are defined inside the Mobile development team's [deriv_lint package](https://github.com/regentmarkets/flutter-deriv-packages/blob/dev/packages/deriv_lint/lib/analysis_options.yaml). 
Also please check out this [Mobile team's code style convention doc in WikiJS](https://wikijs.deriv.cloud/en/Mobile/code_conventions/flutter_team_coding_conventions).

Pull Requests description: When submitting a pull request, provide a clear and concise description of the changes you've made. Ensure that your code is well-tested, and include relevant documentation updates, if necessary.

Documentation: Apart from code contributions, helping improve the documentation is highly valuable. Update the documentation and provide clear examples for using the new features or modifications. Include explanations of the API, usage scenarios, and any required configurations. Illustrate the expected results and provide sample code to help users of the package or other contributors to understand how to integrate the new functionality. If you notice areas where the documentation can be enhanced or expanded, feel free to add or edit the documentation of the components.


Adding new features or modifying existing ones:

Plan the Architecture: Consider the best approach for implementing the new features within the existing package architecture. Determine if it's necessary to introduce new widgets, data models, or rendering techniques. Evaluate the impact on performance, code organization, and maintainability. One key factor is to make the Chart to know less about what it is rendering and have a consistent rendering step and depend on abstraction to function.

Define a Clear API: define a clear and intuitive API for adding new features. Consider how the users of the package will interact with the new functionality and design an API that is consistent with the existing package conventions.

Handle Customization: Consider adding configuration options or callbacks to enable users to modify chart behavior.

Consider Performance: Optimize performance by implementing techniques such as caching, rendering only visible data points, or utilizing hardware acceleration when possible. Ensure that the package performs well on different devices and handles large datasets efficiently.

Test on Real Financial Data: Validate the functionality and accuracy of the financial chart package by testing it with real financial data. Ensure that the charts can handle various data patterns, such as irregular time intervals, different chart types, and large data ranges.

When the new functionality is ready for review please do a self-review first before passing to review. when submitting PR regardless of whether there is CI integration that runs and checks Dart static analyzer and test, you should also make sure that the following commands also run without any warning or issue:

```
flutter analyze
flutter test
```


Some general notes:
Readability and Maintainability: Ensure that the code is easy to read, understand, and maintain. Consider the following aspects:

Use meaningful and descriptive names for variables, functions, and classes.
Break down complex code into smaller, modular functions or methods.
Follow a consistent coding style and formatting conventions.
Add comments where necessary to clarify the intent or complex sections.

Performance and Efficiency: Evaluate the code's performance and efficiency. Consider:

Unnecessary or redundant computations, loops, or database queries.
Potential memory leaks or resource-intensive operations.
Proper usage of data structures and algorithms for optimal performance.

Code Structure and Organization: Check if the code is well-structured and organized. Look for:

Proper separation of concerns and adherence to the Single Responsibility Principle (SRP).
Avoidance of code duplication and the use of appropriate abstractions.
Consistent indentation, code grouping, and file organization.

Polymorphism: with example, avoid using String in switch cases as much as possible. 

In Flutter, immutability is an important concept that promotes predictable and efficient UI rendering. Immutability refers to the practice of creating objects that cannot be changed after they are created. Instead of modifying an existing object, immutable objects are replaced with new instances that incorporate the desired changes.

Why is immutability encouraged?

Performance benefits: Immutable objects allow Flutter to optimize the rendering process. When a widget is updated, Flutter compares the new widget with the previous one and determines if the UI needs to be rebuilt. Immutable objects make this comparison easier and faster since Flutter can rely on object identity rather than deep value comparisons.

Predictable UI updates: By following immutability principles, you ensure that widget updates are predictable and consistent. Once a widget is created, its properties cannot be modified, reducing the risk of accidental mutations or unexpected behavior.

Guidelines for immutability:

Design widget properties as final: When defining properties for your chart widgets, make them final whenever possible. This enforces immutability and prevents accidental modifications.

Create new instances for updates: Instead of modifying existing widget instances, create new instances with updated properties. This ensures that the UI update mechanism works correctly and minimizes unnecessary rebuilds.

Utilize const constructors: Consider using const constructors when appropriate. const constructors allow Flutter to optimize widget creation by caching and reusing instances with identical properties.

Use immutable data structures: When managing data within your chart package, prefer using immutable data structures such as List and Map. Immutable data structures provide safety against unintended modifications and simplify the reasoning about data flow.

Leverage functional programming principles: Functional programming concepts like pure functions and avoiding side effects can complement the practice of immutability. Consider applying these principles where applicable within your chart package.



Documentation


