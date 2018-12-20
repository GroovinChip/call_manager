import 'dart:typed_data';
import 'package:call_manager/pass_notification.dart';
import 'package:call_number/call_number.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:datetime_picker_formfield/time_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:intl/intl.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:call_manager/globals.dart' as globals;

class CallCard extends StatefulWidget {
  final DocumentSnapshot callSnapshot;

  CallCard({
    this.callSnapshot,
  });

  @override
  CallCardState createState() {
    return CallCardState();
  }
}

class CallCardState extends State<CallCard> {
  String numberToCallOnNotificationTap;

  final dateFormat = DateFormat("EEEE, MMMM d, yyyy");

  final timeFormat = DateFormat("h:mm a");

  DateTime reminderDate;

  TimeOfDay reminderTime;

  List<PopupMenuItem> overflowItemsCallCard = [
    PopupMenuItem(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text("Send Email"),
          ),
          Icon(GroovinMaterialIcons.send_outline),
        ],
      ),
      value: "Send Email",
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

    var androidPlatformChannelSpecifics =  AndroidNotificationDetails(
      '1',
      'Call Reminders',
      'Allow Call Manager to create and send notifications about Call Reminders',
    );

    var iOSPlatformChannelSpecifics =  IOSNotificationDetails();

    var platformChannelSpecifics =  NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await PassNotification.of(context).schedule(
        0,
        'Reminder: call ' + name,
        "Tap to call " + name,
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        payload: phoneNumber
    );

    Navigator.pop(context);
  }

  bool isExpanded = false;

  Widget descriptionRow;

  @override
  void initState() {
    super.initState();
    initDescription();
  }

  void initDescription() {
    if("${widget.callSnapshot['Description']}".isNotEmpty) {
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
            child: Text("No description"),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
      child: GroovinExpansionTile(
        leading: "${widget.callSnapshot['Avatar']}" != "null" ? ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Image.memory(
              Uint8List.fromList("${widget.callSnapshot['Avatar']}".codeUnits),
              gaplessPlayback: true,
            ),
          ),
        ) : CircleAvatar(
          child: Icon(Icons.person_outline, color: Colors.white,),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        title: Text(
          "${widget.callSnapshot['Name']}",
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text("${widget.callSnapshot['PhoneNumber']}"),
        onExpansionChanged: (value) {
          setState(() {
            isExpanded = value;
          });
        },
        inkwellRadius: !isExpanded
            ? BorderRadius.all(Radius.circular(5.0))
            : BorderRadius.only(
          topRight: Radius.circular(5.0),
          topLeft: Radius.circular(5.0),
        ),
        children: <Widget>[
          descriptionRow,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: (){
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Delete Call"),
                        content: Text("Are you sure you want to delete this call?"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("No"),
                            onPressed: (){
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text("Yes"),
                            onPressed: (){
                              Firestore.instance.collection("Users").document(globals.loggedInUser.uid).collection("Calls").document(widget.callSnapshot.documentID).delete();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      )
                  );
                },
                tooltip: "Delete call",
              ),
              IconButton(
                icon: Icon(Icons.notifications_none),
                onPressed: (){
                  numberToCallOnNotificationTap = "${widget.callSnapshot['PhoneNumber']}";
                  showRoundedModalBottomSheet(
                    color: Theme.of(context).canvasColor,
                    context: context,
                    dismissOnTap: false,
                    builder: (builder){
                      return Container(
                        height: 250.0,
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Scaffold(
                            body: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: ModalDrawerHandle(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: DateTimePickerFormField(
                                      format: dateFormat,
                                      dateOnly: true,
                                      firstDate: DateTime.now(),
                                      onChanged: (date) {
                                        reminderDate = date;
                                      },
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.today,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                        labelText: "Reminder Date",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                                    child: TimePickerFormField(
                                      format: timeFormat,
                                      enabled: true,
                                      initialTime: TimeOfDay.now(),
                                      onChanged: (timeOfDay) {
                                        reminderTime = timeOfDay;
                                      },
                                      decoration: InputDecoration(
                                        labelText: "Reminder Time",
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(
                                          Icons.access_time,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                            floatingActionButton: FloatingActionButton.extended(
                              backgroundColor: Colors.blue[700],
                              elevation: 0.0,
                              icon: Icon(Icons.add_alert),
                              label: Text("Set Reminder"),
                              onPressed: () async {
                                scheduleNotificationReminder("${widget.callSnapshot['Name']}", "${widget.callSnapshot['PhoneNumber']}");
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                tooltip: "Set reminder",
              ),
              IconButton(
                icon: Icon(GroovinMaterialIcons.edit_outline),
                onPressed: (){
                  globals.callToEdit = widget.callSnapshot.reference;
                  Navigator.of(context).pushNamed("/EditCallScreen");
                  /*Navigator.push(
                      context,
                      SlideLeftRoute(widget: EditCallScreen())
                  );*/
                },
                tooltip: "Edit this call",
              ),
              IconButton(
                icon: Icon(GroovinMaterialIcons.comment_text_outline),
                onPressed: (){
                  globals.callToEdit = widget.callSnapshot.reference;
                  launch("sms:${widget.callSnapshot['PhoneNumber']}");
                },
                tooltip: "Text ${widget.callSnapshot['Name']}",
              ),
              IconButton(
                icon: Icon(GroovinMaterialIcons.phone_outline),
                onPressed: () async {
                  await CallNumber().callNumber("${widget.callSnapshot['PhoneNumber']}");
                },
                tooltip: "Call ${widget.callSnapshot['Name']}",
              ),
            ],
          ),
        ],
      ),
    );
  }
}