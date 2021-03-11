import 'package:flutter/material.dart';

extension MediaQueryX on MediaQueryData {
  bool get keyboardOpen => this.viewInsets.bottom != 0;
}