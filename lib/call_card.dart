import 'package:call_manager/edit_call_screen.dart';
import 'package:call_manager/pass_notification.dart';
import 'package:call_manager/utils/page_transitions.dart';
import 'package:call_number/call_number.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:datetime_picker_formfield/time_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:intl/intl.dart';
import 'package:modal_drawer_handle/modal_drawer_handle.dart';
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

  void _chooseCallCardOverflowAction(value){
    switch(value){
      case "Send Email":
        launch("mailto:");
        break;
    }
  }

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
        'Call Reminder',
        "Don't forget to call " + name + "!",
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        payload: phoneNumber
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "${widget.callSnapshot['Name']}",
                  style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.expand_more),
                  itemBuilder: (BuildContext context) {
                    return overflowItemsCallCard;
                  },
                  tooltip: "More",
                  onSelected: (value){
                    _chooseCallCardOverflowAction(value);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text("${widget.callSnapshot['PhoneNumber']}"),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text("${widget.callSnapshot['Description']}"),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
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
                      builder: (builder){
                        return Container(
                          height: 250.0,
                          color: Colors.transparent,
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: ModalDrawerHandle(),
                                ),
                                ListTile(
                                  leading: Icon(Icons.today),
                                  title: DateTimePickerFormField(
                                    format: dateFormat,
                                    dateOnly: true,
                                    firstDate: DateTime.now(),
                                    onChanged: (date) {
                                      reminderDate = date;
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Reminder Date",
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(Icons.access_time),
                                  title: TimePickerFormField(
                                    format: timeFormat,
                                    enabled: true,
                                    initialTime: TimeOfDay.now(),
                                    onChanged: (timeOfDay) {
                                      reminderTime = timeOfDay;
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Reminder Time",
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    FloatingActionButton.extended(
                                      backgroundColor: Colors.blue[700],
                                      icon: Icon(Icons.add_alert),
                                      label: Text("Create Reminder"),
                                      onPressed: () async {
                                        scheduleNotificationReminder("${widget.callSnapshot['Name']}", "${widget.callSnapshot['PhoneNumber']}");
                                      },
                                    )
                                  ],
                                )
                              ],
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
                    //Navigator.of(context).pushNamed("/EditCallScreen");
                    Navigator.push(
                        context,
                        SlideLeftRoute(widget: EditCallScreen())
                    );
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
          ),
        ],
      ),
    );
  }
}