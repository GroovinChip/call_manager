import 'package:flutter/material.dart';
import 'package:contact_picker/contact_picker.dart';
import 'package:flutter/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:datetime_picker_formfield/time_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:call_manager/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class EditCallScreen extends StatefulWidget {
  @override
  _EditCallScreenState createState() => _EditCallScreenState();
}

class _EditCallScreenState extends State<EditCallScreen> {
  // Contact Picker stuff
  final ContactPicker _contactPicker = new ContactPicker();
  Contact _contact;

  //TextField controllers
  TextEditingController _nameFieldController = TextEditingController();
  TextEditingController _phoneFieldController = TextEditingController();
  TextEditingController _descriptionFieldController = TextEditingController();
  TextEditingController _dateFieldController = TextEditingController();
  TextEditingController _timeFieldController = TextEditingController();

  String name;
  String phoneNumber;
  String description;

  final dateFormat = DateFormat("EEEE, MMMM d, yyyy");
  final timeFormat = DateFormat("h:mm a");

  DateTime reminderDate;
  TimeOfDay reminderTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("Users").document(globals.loggedInUser.uid).collection("Calls").snapshots(),
          builder: (context, snapshot) {
            for(int i = 0; i < snapshot.data.documents.length; i++){
              DocumentSnapshot ds = snapshot.data.documents[i];
              if(ds.documentID == globals.callToEdit.documentID){
                name = "${ds['Name']}";
                phoneNumber = "${ds['PhoneNumber']}";
                description = "${ds['Description']}";

                return ListView(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, top: 16.0, bottom: 8.0),
                              child: Text(
                                "Basic Info",
                                style: TextStyle(
                                    fontSize: 20.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            enabled: true,
                            controller: _nameFieldController,
                            keyboardType: TextInputType.text,
                            maxLines: 1,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                OMIcons.person,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.contacts,
                                    color:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                  onPressed: () async {
                                    Contact contact =
                                    await _contactPicker.selectContact();
                                    setState(() {
                                      _contact = contact;
                                      _nameFieldController.text = _contact.fullName;
                                      _phoneFieldController.text =
                                          _contact.phoneNumber.number;
                                    });
                                  },
                                  tooltip: "Choose from Contacts",
                                ),
                              ),
                              labelText: name,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 16.0),
                          child: TextField(
                            enabled: true,
                            keyboardType: TextInputType.phone,
                            maxLines: 1,
                            autofocus: false,
                            controller: _phoneFieldController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                OMIcons.phone,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                              labelText: phoneNumber,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                          child: TextFormField(
                            enabled: true,
                            keyboardType: TextInputType.multiline,
                            maxLines: 2,
                            autofocus: false,
                            controller: _descriptionFieldController,
                            decoration: InputDecoration(
                              labelText: description,
                              prefixIcon: Icon(
                                OMIcons.comment,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            }
          },
        ),
      ),
      floatingActionButton: Builder(
        builder: (BuildContext fabContext) {
          return FloatingActionButton.extended(
            highlightElevation: 2.0,
            backgroundColor: Colors.blue[700],
            onPressed: () {
              if(name == "" || phoneNumber == "") {
                final snackBar = SnackBar(
                  content: Text("Please enter required fields"),
                  action: SnackBarAction(
                      label: 'Dismiss',
                      onPressed: () {

                      }
                  ),
                  duration: Duration(seconds: 3),
                );
                Scaffold.of(fabContext).showSnackBar(snackBar);
              } else {
                try {
                  CollectionReference userCalls = Firestore.instance.collection("Users").document(globals.loggedInUser.uid).collection("Calls");
                  String date;
                  String time;

                  if(_nameFieldController.text.isNotEmpty){
                    name = _nameFieldController.text;
                  }
                  if(_phoneFieldController.text.isNotEmpty){
                    phoneNumber = _phoneFieldController.text;
                  }
                  if(_descriptionFieldController.text.isNotEmpty){
                    description = _descriptionFieldController.text;
                  }

                  if(reminderDate == null) {
                    date = "";
                  } else {
                    date = reminderDate.toString();
                  }

                  if(reminderTime == null) {
                    time = "";
                  } else {
                    time = reminderTime.toString();
                  }

                  userCalls.document(globals.callToEdit.documentID).updateData({
                    "Name":name,
                    "PhoneNumber":phoneNumber,
                    "Description":description,
                    "ReminderDate":date,
                    "ReminderTime":time
                  });
                } catch (e) {
                  print(e);
                } finally {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/HomeScreen', (Route<dynamic> route) => false);
                }
              }
            },
            tooltip: "Save",
            elevation: 2.0,
            icon: new Icon(Icons.save),
            label: Text("Save"),
          );
        }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        child: BottomAppBar(
         //hasNotch: false,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    Navigator.pop(context);
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
