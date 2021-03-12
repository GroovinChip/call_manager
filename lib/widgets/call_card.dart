import 'dart:typed_data';
import 'package:call_manager/screens/edit_call_screen.dart';
import 'package:call_manager/firebase/firebase_mixin.dart';
import 'package:call_manager/utils/pass_notification.dart';
import 'package:call_manager/widgets/schedule_notification_sheet.dart';
import 'package:call_number/call_number.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:intl/intl.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:url_launcher/url_launcher.dart';

class CallCard extends StatefulWidget {
  final QueryDocumentSnapshot callSnapshot;

  CallCard({
    this.callSnapshot,
  });

  @override
  CallCardState createState() {
    return CallCardState();
  }
}

class CallCardState extends State<CallCard> with FirebaseMixin {
  String numberToCallOnNotificationTap;

  final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
  final timeFormat = DateFormat('h:mm a');

  DateTime reminderDate;
  TimeOfDay reminderTime;

  List<PopupMenuItem> overflowItemsCallCard = [
    PopupMenuItem(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text('Send Email'),
          ),
          Icon(GroovinMaterialIcons.send_outline),
        ],
      ),
      value: 'Send Email',
    ),
  ];

  Future scheduleNotificationReminder(String name, String phoneNumber) async {
    var scheduledNotificationDateTime = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '1',
      'Call Reminders',
      'Allow Call Manager to create and send notifications about Call Reminders',
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await PassNotification.of(context).schedule(
      0,
      'Reminder: call ' + name,
      'Tap to call ' + name,
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      payload: phoneNumber,
    );

    Navigator.of(context).pop();
  }

  bool isExpanded = false;

  Widget descriptionRow;

  @override
  void initState() {
    super.initState();
    initDescription();
  }

  void initDescription() {
    if ('${widget.callSnapshot['Description']}'.isNotEmpty) {
      descriptionRow = Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
            child: Text("${widget.callSnapshot['Description']}"),
          ),
        ],
      );
    } else {
      descriptionRow = Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text('No description'),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      child: GroovinExpansionTile(
        leading: '${widget.callSnapshot.data()['Avatar']}' != 'null'
            ? ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Image.memory(
                    Uint8List.fromList(
                        '${widget.callSnapshot.data()['Avatar']}'.codeUnits),
                    gaplessPlayback: true,
                  ),
                ),
              )
            : CircleAvatar(
                child: Icon(
                  Theme.of(context).brightness == Brightness.light
                      ? Icons.person_outline
                      : Icons.person,
                  color: Colors.white,
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
        title: Text(
          '${widget.callSnapshot.data()['Name']}',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${widget.callSnapshot.data()['PhoneNumber']}'),
        onExpansionChanged: (value) {
          setState(() => isExpanded = value);
        },
        inkwellRadius: !isExpanded
            ? BorderRadius.all(Radius.circular(5.0))
            : BorderRadius.only(
                topRight: Radius.circular(5.0),
                topLeft: Radius.circular(5.0),
              ),
        children: [
          descriptionRow,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Theme.of(context).brightness == Brightness.light
                    ? Icon(Icons.delete_outline)
                    : Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Delete Call'),
                      content:
                          Text('Are you sure you want to delete this call?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('No'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: Text('Yes'),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('Users')
                                .doc(currentUser.uid)
                                .collection('Calls')
                                .doc(widget.callSnapshot.id)
                                .delete();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
                tooltip: 'Delete call',
              ),
              IconButton(
                icon: Theme.of(context).brightness == Brightness.light
                    ? Icon(Icons.notifications_none)
                    : Icon(Icons.notifications),
                onPressed: () {
                  numberToCallOnNotificationTap =
                      '${widget.callSnapshot.data()['PhoneNumber']}';

                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    builder: (_) => ScheduleNotificationSheet(
                      callSnapshot: widget.callSnapshot,
                    ),
                  );
                },
                tooltip: 'Set reminder',
              ),
              IconButton(
                icon: Theme.of(context).brightness == Brightness.light
                    ? Icon(GroovinMaterialIcons.edit_outline)
                    : Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditCallScreen(
                          callId: widget.callSnapshot.reference.id),
                    ),
                  );
                  /*Navigator.push(
                      context,
                      SlideLeftRoute(widget: EditCallScreen())
                  );*/
                },
                tooltip: 'Edit this call',
              ),
              IconButton(
                icon: Theme.of(context).brightness == Brightness.light
                    ? Icon(GroovinMaterialIcons.comment_text_outline)
                    : Icon(GroovinMaterialIcons.comment_text),
                onPressed: () {
                  launch('sms:${widget.callSnapshot['PhoneNumber']}');
                },
                tooltip: 'Text ${widget.callSnapshot['Name']}',
              ),
              IconButton(
                icon: Theme.of(context).brightness == Brightness.light
                    ? Icon(GroovinMaterialIcons.phone_outline)
                    : Icon(Icons.phone),
                onPressed: () async {
                  await CallNumber()
                      .callNumber('${widget.callSnapshot['PhoneNumber']}');
                },
                tooltip: 'Call ${widget.callSnapshot['Name']}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}