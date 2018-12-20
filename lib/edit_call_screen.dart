import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:groovin_widgets/modal_drawer_handle.dart';
import 'package:intl/intl.dart';
import 'package:call_manager/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:rounded_modal/rounded_modal.dart';

class EditCallScreen extends StatefulWidget {
  @override
  _EditCallScreenState createState() => _EditCallScreenState();
}

class _EditCallScreenState extends State<EditCallScreen> {

  //TextField controllers
  TextEditingController _nameFieldController = TextEditingController();
  TextEditingController _phoneFieldController = TextEditingController();
  TextEditingController _descriptionFieldController = TextEditingController();

  String name;
  String phoneNumber;
  String description;

  final dateFormat = DateFormat("EEEE, MMMM d, yyyy");
  final timeFormat = DateFormat("h:mm a");

  DateTime reminderDate;
  TimeOfDay reminderTime;

  Iterable<Contact> contacts;
  Contact selectedContact;

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  void getContacts() async {
    contacts = await ContactsService.getContacts();
  }

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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0, top: 6.0, bottom: 8.0),
                              child: Text(
                                "Edit Call",
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
                              selectedContact = contact;
                              if(selectedContact.familyName != null)
                                this._nameFieldController.text = contact.givenName + " " + contact.familyName;
                              else
                                this._nameFieldController.text = contact.givenName;
                              if(selectedContact.phones.length > 1) {
                                showRoundedModalBottomSheet(
                                  context: context,
                                  builder: (builder) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ModalDrawerHandle(),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              "Choose phone number",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: 150.0,
                                          child: ListView.builder(
                                            itemCount: selectedContact.phones.length,
                                            itemBuilder: (context, index) {
                                              List<Item> phoneNums = [];
                                              Icon phoneType;
                                              phoneNums = selectedContact.phones.toList();
                                              switch(phoneNums[index].label){
                                                case "mobile":
                                                  phoneType = Icon(OMIcons.smartphone);
                                                  break;
                                                case "work":
                                                  phoneType = Icon(OMIcons.business);
                                                  break;
                                                case "home":
                                                  phoneType = Icon(OMIcons.home);
                                                  break;
                                                default:
                                                  phoneType = Icon(OMIcons.phone);
                                              }
                                              return ListTile(
                                                leading: phoneType,
                                                title: Text(phoneNums[index].value),
                                                subtitle: Text(phoneNums[index].label),
                                                onTap: () {
                                                  this._phoneFieldController.text = phoneNums[index].value;
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
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
                                  ),
                                ),
                                labelText: name,
                              ),
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
                                    _phoneFieldController.text = "";
                                  },
                                ),
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
                                    _descriptionFieldController.text = "";
                                  },
                                ),
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

                  if(selectedContact == null) {
                    userCalls.document(globals.callToEdit.documentID).updateData({
                      "Name":name,
                      "PhoneNumber":phoneNumber,
                      "Description":description,
                      "ReminderDate":date,
                      "ReminderTime":time
                    });
                  } else {
                    userCalls.document(globals.callToEdit.documentID).updateData({
                      "Avatar":String.fromCharCodes(selectedContact.avatar),
                      "Name":name,
                      "PhoneNumber":phoneNumber,
                      "Description":description,
                      "ReminderDate":date,
                      "ReminderTime":time
                    });
                  }
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
