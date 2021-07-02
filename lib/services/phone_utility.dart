import 'package:direct_dialer/direct_dialer.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

/// Responsible for handling various phone-related functionality.
///
/// Handles permissions, making phone calls, and launching the SMS app.
class PhoneUtility {
  PhoneUtility._();

  static Future<PhoneUtility> init() async {
    final service = PhoneUtility._();
    await service._init();

    return service;
  }

  Future<void> _init() async {
    phonePermissionStatus = await Permission.phone.status;
  }

  PermissionStatus? phonePermissionStatus;

  ///
  void requestPhonePermission() {
    Permission.phone.request().then((status) {
      phonePermissionStatus = status;
    });
  }

  ///
  Future<void> callNumber(String phoneNumber) async {
    final dialer = await DirectDialer.instance;
    await dialer.dial(phoneNumber);
  }

  ///
  void sendSms(String? phoneNumber) async {
    final url = 'sms:$phoneNumber';
    try {
      if (await url_launcher.canLaunch(url)) {
        await url_launcher.launch(url);
      }
    } catch (e) {
      debugPrint('Error sending SMS: $e');
    }
  }
}
