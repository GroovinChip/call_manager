import 'dart:async';
import 'package:call_manager/pass_notification.dart';
import 'package:flutter/material.dart';
//import 'package:contact_picker/contact_picker.dart';
import 'package:flutter/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:datetime_picker_formfield/time_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:call_manager/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:call_number/call_number.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(AddNewCallScreen());
}

// Add New Call Screen
class AddNewCallScreen extends StatefulWidget {
  @override
  _AddNewCallScreenState createState() => _AddNewCallScreenState();
}

class _AddNewCallScreenState extends State<AddNewCallScreen> {
  // Contact Picker stuff
  /*final ContactPicker _contactPicker = ContactPicker();
  Contact _contact;*/
  Iterable<Contact> contacts;
  Contact selectedContact;

  //TextFormField controllers
  TextEditingController _nameFieldController = TextEditingController();
  TextEditingController _phoneFieldController = TextEditingController();
  TextEditingController _descriptionFieldController = TextEditingController();
  TextEditingController _dateFieldController = TextEditingController();
  TextEditingController _timeFieldController = TextEditingController();

  final dateFormat = DateFormat("EEEE, MMMM d, yyyy");
  final timeFormat = DateFormat("h:mm a");

  DateTime reminderDate;
  TimeOfDay reminderTime;

  final formKey = GlobalKey<FormState>();

  void saveCall() async {
    if(formKey.currentState.validate()){
      formKey.currentState.save();
      CollectionReference userCalls = Firestore.instance
        .collection("Users")
        .document(globals.loggedInUser.uid)
        .collection("Calls");
      String date;
      String time;
      if (reminderDate != null && reminderTime != null) {
        var scheduledNotificationDateTime = DateTime(
          reminderDate.year,
          reminderDate.month,
          reminderDate.day,
          reminderTime.hour,
          reminderTime.minute,
        );
        var androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          '1',
          'Call Reminders',
          'Allow Call Manager to create and send notifications about Call Reminders',
        );

        var iOSPlatformChannelSpecifics =
        IOSNotificationDetails();

        NotificationDetails platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics,
            iOSPlatformChannelSpecifics);

        await PassNotification.of(context).schedule(
            0,
            'Call Reminder',
            "Don't forget to call " + _nameFieldController.text + "!",
            scheduledNotificationDateTime,
            platformChannelSpecifics,
            payload: _phoneFieldController.text);

        date = reminderDate.toString();
        time = reminderTime.toString();
      } else {
        date = "";
        time = "";
      }

      if(selectedContact == null || selectedContact.avatar.length == 0) {
        userCalls.add({
          "Name": _nameFieldController.text,
          "PhoneNumber": _phoneFieldController.text,
          "Description": _descriptionFieldController.text,
          "ReminderDate": date,
          "ReminderTime": time
        });
      } else if (selectedContact.avatar.length > 0){
        userCalls.add({
          "Avatar":String.fromCharCodes(selectedContact.avatar),
          "Name": _nameFieldController.text,
          "PhoneNumber": _phoneFieldController.text,
          "Description": _descriptionFieldController.text,
          "ReminderDate": date,
          "ReminderTime": time
        });
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
          '/HomeScreen', (Route<dynamic> route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    getContacts();
    checkContactsPermission();
  }

  void getContacts() async {
    contacts = await ContactsService.getContacts();
  }

  void checkContactsPermission() async {
    PermissionStatus contactsPerm =
      await PermissionHandler.checkPermissionStatus(PermissionGroup.contacts);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
                        child: Text(
                          "Basic Info",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TypeAheadFormField(
                      suggestionsCallback: (query) {
                        return contacts.where((contact)=> contact.displayName.toLowerCase().contains(query.toLowerCase())).toList();
                      },
                      itemBuilder: (context, contact) {
                        return ListTile(
                          leading: contact.avatar.length == 0 ?
                          CircleAvatar(
                            child: Icon(Icons.person_outline),
                          ) :
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(25.0)),
                            child: CircleAvatar(
                              child: Image.memory(
                                contact.avatar,
                              ),
                            ),
                          ),
                          title: Text(contact.displayName),
                        );
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (contact) {
                        this._nameFieldController.text = contact.givenName;
                        this._phoneFieldController.text = contact.phones.first.value;
                        selectedContact = contact;
                      },
                      validator: (input) => input == null || input == "" ? 'This field is required' : null,
                      onSaved: (contactName) => _nameFieldController.text = contactName,
                      textFieldConfiguration: TextFieldConfiguration(
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
                                Icons.close,
                                color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                              onPressed: () async {
                                _nameFieldController.text = "";
                              },
                              tooltip: "Choose from Contacts",
                            ),
                          ),
                          labelText: 'Name (Required)',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 16.0),
                    child: TextFormField(
                      validator: (input) => input == null || input == "" ? 'This field is required' : null,
                      onSaved: (input) => _phoneFieldController.text = input,
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
                        labelText: 'Phone Number (Required)',
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
                        labelText: 'Description',
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
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 16.0, left: 16.0, top: 12.0),
                    child: Divider(),
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                        child: Text(
                          "Reminder",
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DateTimePickerFormField(
                      format: dateFormat,
                      dateOnly: true,
                      firstDate: DateTime.now(),
                      onChanged: (date) {
                        reminderDate = date;
                        //_dateFieldController.text = date.toString();
                      },
                      controller: _dateFieldController,
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
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                    child: TimePickerFormField(
                      format: timeFormat,
                      enabled: true,
                      initialTime: TimeOfDay.now(),
                      onChanged: (timeOfDay) {
                        reminderTime = timeOfDay;
                      },
                      controller: _timeFieldController,
                      decoration: InputDecoration(
                        labelText: "Reminder Time",
                        prefixIcon: Icon(
                          Icons.access_time,
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
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(builder: (BuildContext fabContext) {
        return FloatingActionButton.extended(
          backgroundColor: Colors.blue[700],
          onPressed: () async {
            saveCall();
          },
          tooltip: "Save",
          elevation: 2.0,
          icon: Icon(Icons.save),
          label: Text("Save"),
        );
      }),
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
