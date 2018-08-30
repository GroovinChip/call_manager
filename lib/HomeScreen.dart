import 'dart:async';
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

void main() {
  runApp(HomeScreen());
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// Home Screen
class _HomeScreenState extends State<HomeScreen> {

  final dateFormat = DateFormat("EEEE, MMMM d, yyyy");
  final timeFormat = DateFormat("h:mm a");

  DateTime reminderDate;
  TimeOfDay reminderTime;

  String numberToCallOnNotificationTap;

  PermissionStatus status;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    permissions();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('ic_notification');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        selectNotification: onSelectNotification);
  }

  void permissions() async {
    Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler.requestPermissions([PermissionGroup.phone]);
    PermissionStatus permission = await PermissionHandler.checkPermissionStatus(PermissionGroup.phone);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    //await CallNumber().callNumber(numberToCallOnNotificationTap);
    launch("tel:"+numberToCallOnNotificationTap);
  }

  Future scheduleNotificationReminder(String name) async {
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

    await flutterLocalNotificationsPlugin.schedule(
      0,
      'Call Reminder',
      "Don't forget to call " + name + "!",
      scheduledNotificationDateTime,
      platformChannelSpecifics,
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

    List<PopupMenuItem> overflowAppBarItems = [
      PopupMenuItem(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text("About"),
            ),
            Icon(Icons.info_outline),
          ],
        ),
        value: "About",
      ),
      PopupMenuItem(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text("Log Out"),
            ),
            Icon(Icons.exit_to_app),
          ],
        ),
        value: "Log Out",
      ),
    ];

    List<PopupMenuItem> overflowItemsCallCard = [
      PopupMenuItem(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text("Send Email"),
            ),
            Icon(Icons.send),
          ],
        ),
        value: "Send Email",
      ),
    ];

    void _chooseAppBarOverflowAction(value){
      switch(value){
        case "About":
          Navigator.of(context).pushNamed("/AboutScreen");
          break;
        case "Log Out":
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
          break;
      }
    }

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
                      elevation: 4.0,
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
                                  icon: Icon(Icons.delete_forever),
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
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 8.0),
                                                      child: FloatingActionButton.extended(
                                                        icon: Icon(Icons.add_alert),
                                                        label: Text("Create Reminder"),
                                                        onPressed: () async {
                                                          scheduleNotificationReminder("${ds['Name']}");
                                                        },
                                                      ),
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
                                  icon: Icon(Icons.edit),
                                  onPressed: (){
                                    globals.callToEdit = ds.reference;
                                    Navigator.of(context).pushNamed("/EditCallScreen");
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
                                  icon: Icon(Icons.phone),
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
        label: Text("Add New Call"),
        onPressed: () {
          Navigator.of(context).pushNamed("/AddNewCallScreen");
        }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        elevation: 24.0,
        hasNotch: false,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: PopupMenuButton(
                itemBuilder: (BuildContext context) {
                  return overflowAppBarItems;
                },
                tooltip: "Menu",
                onSelected: (value){
                  _chooseAppBarOverflowAction(value);
                },
              ),
            ),
            Builder(
              builder: (BuildContext newContext){
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    icon: Icon(
                        Icons.clear_all),
                    onPressed: () {
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
                                  Scaffold.of(newContext).showSnackBar(snackBar);
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
                    tooltip: "Delete All Calls",
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}