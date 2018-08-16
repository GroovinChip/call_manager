package com.groovinchip.flutter.callmanager;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
      /*if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          getWindow().setStatusBarColor(0x00000000);
      }*/
      GeneratedPluginRegistrant.registerWith(this);
  }
}
