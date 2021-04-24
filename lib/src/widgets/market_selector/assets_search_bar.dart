// @dart=2.9

import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A widget to handle search interaction and its TextFiled.
class AssetsSearchBar extends StatefulWidget {
  /// Creates a search bar.
  ///
  /// [onSearchTextChanged] will get called when the search query changes.
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

  ChartTheme _theme;

  @override
  void initState() {
    super.initState();

    _searchFieldFocusNode = FocusNode();
    _textEditingController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _theme = Provider.of<ChartTheme>(context);
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
          style: _theme.textStyle(
            textStyle: _theme.subheading,
            color: _theme.base01Color,
          ),
        ),
        onTap: () => _switchToSearchMode(),
      );

  Widget _buildBackButton() => IconButton(
        icon: const Icon(Icons.arrow_back, size: 20),
        onPressed: () => _switchToNormalMode(),
      );

  Widget _buildSearchButton() => IconButton(
        icon: const Icon(Icons.search, size: 20),
        onPressed: () => _switchToSearchMode(),
      );

  Widget _buildClearButton() => IconButton(
        icon: const Icon(Icons.close, size: 20),
        onPressed: _textEditingController.value.text.isEmpty
            ? null
            : () {
                _textEditingController.clear();
                widget.onSearchTextChanged?.call('');
              },
      );

  Widget _buildTextField() => TextFormField(
        key: const ValueKey<String>('search-bar-text-field'),
        controller: _textEditingController,
        focusNode: _searchFieldFocusNode,
        onChanged: (String text) => widget.onSearchTextChanged?.call(text),
        cursorColor: Colors.white70,
        textAlign: TextAlign.left,
        style: _theme.textStyle(
          textStyle: _theme.subheading,
          color: _theme.base01Color,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: ChartLocalization.of(context).labelSearchAssets,
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
