import 'package:call_manager/about_screen.dart';
import 'package:call_manager/bottom_sheets.dart';
import 'package:call_manager/utils/page_transitions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:modal_drawer_handle/modal_drawer_handle.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:call_manager/globals.dart' as globals;

class CMBottomAppBar extends StatefulWidget {
  @override
  _CMBottomAppBarState createState() => _CMBottomAppBarState();
}

class _CMBottomAppBarState extends State<CMBottomAppBar> {

  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark? Brightness.light: Brightness.dark);
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
