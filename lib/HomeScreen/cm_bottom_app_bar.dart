import 'package:call_manager/HomeScreen/bottom_sheets.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';

/// This class represents the BottomAppBar on the
/// HomeScreen widget
class CMBottomAppBar extends StatefulWidget {
  @override
  _CMBottomAppBarState createState() => _CMBottomAppBarState();
}

class _CMBottomAppBarState extends State<CMBottomAppBar> {

  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(
      Theme.of(context).brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onVerticalDragStart: (_) {
          BottomSheets(context).showBottomAppBarSheet();
        },
        child: BottomAppBar(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: (){
                    BottomSheets(context).showBottomAppBarSheet();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}