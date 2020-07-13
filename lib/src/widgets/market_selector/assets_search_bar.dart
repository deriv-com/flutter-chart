import 'package:flutter/material.dart';

class AssetsSearchBar extends StatefulWidget {
  const AssetsSearchBar({Key key, this.onSearchTextChanged}) : super(key: key);

  final ValueChanged<String> onSearchTextChanged;

  @override
  _AssetsSearchBarState createState() => _AssetsSearchBarState();
}

class _AssetsSearchBarState extends State<AssetsSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: TextFormField(
            onChanged: (String text) => widget.onSearchTextChanged?.call(text),
            cursorColor: Colors.white70,
            textAlign: TextAlign.center,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: 'Asset',
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
