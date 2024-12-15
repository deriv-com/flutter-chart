### How to use DerivChart chart component

`DerivChart` is a wrapper around the `chart` widget that provides the ability to add/remove indicators and manage saving/restoring added ones in storage.
By default, this widget shows two buttons at the top left to add/remove indicators and drawing tools. This can be used when you don't need to customize the look and functionalities of the menus and dialogs for adding/removing indicators and changing their settings and want to use the chart's default menu interfaces.

We can also implement our own interface to do all the above and integrate it with the `DerivChart` component.
This can be done by creating an instance of `AddOnsRepository` and passing it to the chart. For example, in the case of indicators, we can create an instance of `AddOnsRepository<IndicatorConfig>` as shown below:

```Dart
_indicatorsRepo = AddOnsRepository<IndicatorConfig>(
      // Is called when fetching the saved indicators from the shared preferences.
      // To handle how an IndicatorConfig object should be created from a saved JSON object.
      createAddOn: (Map<String, dynamic> map) => IndicatorConfig.fromJson(map),
      onEditCallback: (int index) {
       // handle edit of an indicator on index from _indicatorsRepo.items
      },
      // A string acts as a key for the set of indicators that are saved. so we can have a separate set of saved indicators per key
      // For example we can have saved indicators per symbol if we pass the symbol code every time it changes to the indicator repo.
      sharedPrefKey: 'R_100',
    );
```

After creating the instance you can pass it to the DerivChart component.

```Dart
 DerivChart(
      indicatorsRepo: _indicatorsRepo,
      ...
      ...
```

To load the saved indicators we should call the below method and pass the instance of SharedPref:

```Dart
_indicatorsRepo.loadFromPrefs(
      await SharedPreferences.getInstance(),
      'R_100',
);
```

`AddOnsRepository` is a subtype of `ChangeNotifier` so when we call this method, later `DerivChart` will be informed about the change in the list of indicators.

#### Add/remove/update indicators
Now that we have the instance of `AddsOnRepository` we can use it to know the current list of added indicators. and use its method to add/remove/update, from our menu interfaces.

To add:

```Dart
_indicatorRepo.add(MACDIndicatorConfig());
```

To remove: 

`index` is the index of the indicator item in `_indicatorRepo.items` list.

```Dart
_indicatorRepo.removeAt(index);
```

To update:

```Dart
 repo.updateAt(index, updatedConfig),
```
