import 'dart:async';
import 'package:call_manager/add_new_call_screen.dart';
import 'package:call_manager/about_screen.dart';
import 'package:call_manager/edit_call_screen.dart';
import 'package:call_manager/pass_notification.dart';
import 'package:call_manager/utils/page_transitions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:datetime_picker_formfield/time_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:call_number/call_number.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:call_manager/globals.dart' as globals;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

void main() {
  runApp(HomeScreen());
}

/// This class represents the Home Screen of the app.
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  /// Date and Time formats to give the reminder date and reminder time fields
  final dateFormat = DateFormat("EEEE, MMMM d, yyyy");
  final timeFormat = DateFormat("h:mm a");

  /// Holds the reminder date and time
  DateTime reminderDate;
  TimeOfDay reminderTime;

  /// Holds the phone number to call from the notification reminder
  String numberToCallOnNotificationTap;

  /// Represents the current permission status
  PermissionStatus status;

  @override
  void initState() {
    super.initState();
    permissions();
  }

  /// Check current permissions. If phone permission not granted, prompt for it.
  void permissions() async {
    Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler.requestPermissions([PermissionGroup.phone]);
    PermissionStatus permission = await PermissionHandler.checkPermissionStatus(PermissionGroup.phone);
  }

  /// Schedule a notification reminder
  Future scheduleNotificationReminder(String name, String phoneNumber) async {
    var scheduledNotificationDateTime = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      '1',
      'Call Reminders',
      'Allow Call Manager to create and send notifications about Call Reminders',
    );

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

    var platformChannelSpecifics = new NotificationDetails(
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

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark
    ));

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder <QuerySnapshot>(
          stream: Firestore.instance.collection("Users").document(globals.loggedInUser.uid).collection("Calls").snapshots(),
          builder: (context, snapshot) {
            if(snapshot.hasData == false) {
              return Center(child: Text("Getting Calls..."));
            } else {
              return snapshot.data.documents.length > 0 ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.documents[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
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
                                  "${ds['Name']}",
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
                            child: Text("${ds['PhoneNumber']}"),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                            child: Text("${ds['Description']}"),
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
                                              Firestore.instance.collection("Users").document(globals.loggedInUser.uid).collection("Calls").document(ds.documentID).delete();
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
                                    numberToCallOnNotificationTap = "${ds['PhoneNumber']}";
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (builder){
                                        return Container(
                                          height: 250.0,
                                          color: Colors.transparent,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                topLeft: const Radius.circular(10.0),
                                                topRight: const Radius.circular(10.0),
                                              )
                                            ),
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      Container(
                                                        height: 5.0,
                                                        width: 25.0,
                                                        decoration: BoxDecoration(
                                                            color: Colors.grey[300],
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: const Radius.circular(10.0),
                                                              topRight: const Radius.circular(10.0),
                                                              bottomLeft: const Radius.circular(10.0),
                                                              bottomRight: const Radius.circular(10.0),
                                                            )
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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
                                                        scheduleNotificationReminder("${ds['Name']}", "${ds['PhoneNumber']}");
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
                                    globals.callToEdit = ds.reference;
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
                                    globals.callToEdit = ds.reference;
                                    launch("sms:${ds['PhoneNumber']}");
                                  },
                                  tooltip: "Text ${ds['Name']}",
                                ),
                                IconButton(
                                  icon: Icon(GroovinMaterialIcons.phone_outline),
                                  onPressed: () async {
                                    await CallNumber().callNumber("${ds['PhoneNumber']}");
                                  },
                                  tooltip: "Call ${ds['Name']}",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
              : Center(child: Text("No Calls"));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        elevation: 2.0,
        backgroundColor: Colors.blue[700],
        label: Text("Add New Call"),
        onPressed: () {
          //Navigator.of(context).pushNamed("/AddNewCallScreen");
          Navigator.push(
            context,
            SlideLeftRoute(widget: AddNewCallScreen()),
          );
        }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200],
              spreadRadius: 3.0,
            )
          ],
        ),
        child: BottomAppBar(
          //elevation: 4.0,
          //hasNotch: false,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: (){
                    showModalBottomSheet(
                      context: context,
                      builder: (builder){
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(10.0),
                              topRight: const Radius.circular(10.0),
                            )
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        height: 5.0,
                                        width: 25.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(10.0),
                                            topRight: const Radius.circular(10.0),
                                            bottomLeft: const Radius.circular(10.0),
                                            bottomRight: const Radius.circular(10.0),
                                          )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListTile(
                                  leading: CircleAvatar(
                                    child: Text(globals.loggedInUser.displayName[0], style: TextStyle(color: Colors.white),),
                                    backgroundColor: Colors.blue[700],
                                  ),
                                  title: Text(globals.loggedInUser.displayName),
                                  subtitle: Text(globals.loggedInUser.email),
                                  /*leading: Icon(Icons.account_circle, size: 45.0,),
                                  title: Text(globals.loggedInUser.displayName),
                                  subtitle: Text(globals.loggedInUser.email),*/
                                ),
                                Divider(
                                  color: Colors.grey,
                                  height: 0.0,
                                ),
                                Material(
                                  child: ListTile(
                                    title: Text("Delete All Calls"),
                                    leading: Icon(Icons.clear_all),
                                    onTap: () {
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text("Delete All Calls"),
                                          content: Text("Are you sure you want to delete all calls? This cannot be undone."),
                                          actions: <Widget>[
                                            FlatButton(
                                              onPressed: (){
                                                Navigator.pop(context);
                                              },
                                              child: Text("No"),
                                            ),
                                            FlatButton(
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                CollectionReference ref = Firestore.instance.collection("Users").document(globals.loggedInUser.uid).collection("Calls");
                                                QuerySnapshot s = await ref.getDocuments();
                                                if(s.documents.length == 0){
                                                  final snackBar = SnackBar(
                                                    content: Text("There are no calls to delete"),
                                                    action: SnackBarAction(
                                                        label: 'Dismiss',
                                                        onPressed: () {

                                                        }
                                                    ),
                                                    duration: Duration(seconds: 3),
                                                  );
                                                  Scaffold.of(context).showSnackBar(snackBar);
                                                } else {
                                                  for(int i = 0; i < s.documents.length; i++) {
                                                    DocumentReference d = s.documents[i].reference;
                                                    d.delete();
                                                  }
                                                }
                                              },
                                              child: Text("Yes"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Material(
                                  child: ListTile(
                                    title: Text("Log Out"),
                                    leading: Icon(GroovinMaterialIcons.logout),
                                    onTap: (){
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text("Log Out"),
                                          content: Text("Are you sure you want to log out?"),
                                          actions: <Widget>[
                                            FlatButton(
                                              onPressed: (){
                                                Navigator.pop(context);
                                              },
                                              child: Text("No"),
                                            ),
                                            FlatButton(
                                              onPressed: (){
                                                FirebaseAuth.instance.signOut();
                                                Navigator.of(context).pushNamedAndRemoveUntil('/',(Route<dynamic> route) => false);
                                              },
                                              child: Text("Yes"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Divider(
                                  color: Colors.grey,
                                  height: 0.0,
                                ),
                                Material(
                                  child: ListTile(
                                    title: Text("About"),
                                    leading: Icon(Icons.info_outline),
                                    onTap: (){
                                      Navigator.pop(context);
                                      //Navigator.of(context).pushNamed("/AboutScreen");
                                      Navigator.push(
                                        context,
                                        SlideLeftRoute(widget: AboutScreen())
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    );
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