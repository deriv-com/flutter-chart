import 'package:flutter/material.dart';

/// A widget to handle search interaction and its TextFiled.
class AssetsSearchBar extends StatefulWidget {
  /// Creates a search bar
  /// [onSearchTextChanged] will get called when the search query changes
  const AssetsSearchBar({Key key, this.onSearchTextChanged}) : super(key: key);

  /// Will be called whenever the text in search bar has changed.
  final ValueChanged<String> onSearchTextChanged;

  @override
  _AssetsSearchBarState createState() => _AssetsSearchBarState();
}

class _AssetsSearchBarState extends State<AssetsSearchBar> {
  bool _isSearching = false;
  FocusNode _searchFieldFocusNode;

  TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();

    _searchFieldFocusNode = FocusNode();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    _searchFieldFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _isSearching
      ? Row(
          children: <Widget>[
            _buildBackButton(),
            Expanded(child: _buildTextField()),
            _buildClearButton(),
          ],
        )
      : Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _buildHeaderText(),
            Align(
              alignment: Alignment.centerRight,
              child: _buildSearchButton(),
            ),
          ],
        );

  Widget _buildHeaderText() => GestureDetector(
        child: Text(
          'Assets',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        onTap: () => _switchToSearchMode(),
      );

  Widget _buildBackButton() => IconButton(
        icon: Icon(Icons.arrow_back, size: 20),
        onPressed: () => _switchToNormalMode(),
      );

  Widget _buildSearchButton() => IconButton(
        icon: Icon(Icons.search, size: 20),
        onPressed: () => _switchToSearchMode(),
      );

  Widget _buildClearButton() => IconButton(
        icon: Icon(Icons.close, size: 20),
        onPressed: _textEditingController.value.text.isEmpty
            ? null
            : () {
                _textEditingController.clear();
                widget.onSearchTextChanged?.call('');
              },
      );

  Widget _buildTextField() => TextFormField(
        key: ValueKey<String>('search-bar-text-field'),
        controller: _textEditingController,
        focusNode: _searchFieldFocusNode,
        onChanged: (String text) => widget.onSearchTextChanged?.call(text),
        cursorColor: Colors.white70,
        textAlign: TextAlign.left,
        decoration: new InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: 'Search assets',
        ),
      );

  void _switchToNormalMode() {
    FocusScope.of(context).requestFocus(FocusNode());
    widget.onSearchTextChanged?.call('');
    setState(() => _isSearching = false);
  }

  void _switchToSearchMode() {
    _searchFieldFocusNode.requestFocus();
    setState(() => _isSearching = true);
  }
}
