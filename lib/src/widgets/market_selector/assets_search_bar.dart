import 'package:flutter/material.dart';

class AssetsSearchBar extends StatefulWidget {
  const AssetsSearchBar({Key key, this.onSearchTextChanged}) : super(key: key);

  final ValueChanged<String> onSearchTextChanged;

  @override
  _AssetsSearchBarState createState() => _AssetsSearchBarState();
}

class _AssetsSearchBarState extends State<AssetsSearchBar> {
  bool _isSearching = false;
  FocusNode _searchFieldFocusNode;

  @override
  void initState() {
    super.initState();

    _searchFieldFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: _isSearching
              ? TextFormField(
                  focusNode: _searchFieldFocusNode,
                  onChanged: (String text) =>
                      widget.onSearchTextChanged?.call(text),
                  cursorColor: Colors.white70,
                  textAlign: TextAlign.center,
                  decoration: new InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: 'Search in assets'),
                )
              : InkWell(
                  child: Text(
                    'Assets',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  onTap: () => _setToSearchMode(),
                ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: _isSearching
              ? IconButton(
                  icon: Icon(Icons.close, size: 20),
                  onPressed: () => setState(() {
                    FocusScope.of(context).requestFocus(FocusNode());
                    widget.onSearchTextChanged?.call('');
                    _isSearching = false;
                  }),
                )
              : IconButton(
                  icon: Icon(Icons.search, size: 20),
                  onPressed: () => _setToSearchMode(),
                ),
        ),
      ],
    );
  }

  void _setToSearchMode() {
    _searchFieldFocusNode.requestFocus();
    setState(() => _isSearching = true);
  }
}
