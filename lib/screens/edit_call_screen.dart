import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/provided.dart';
import 'package:call_manager/utils/extensions.dart';
import 'package:call_manager/widgets/multiple_phone_numbers_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class EditCallScreen extends StatefulWidget {
  const EditCallScreen({
    Key key,
    @required this.call,
  }) : super(key: key);

  final Call call;

  @override
  _EditCallScreenState createState() => _EditCallScreenState();
}

class _EditCallScreenState extends State<EditCallScreen>
    with FirebaseMixin, Provided {
  //TextField controllers
  final _nameFieldController = TextEditingController();
  final _phoneFieldController = TextEditingController();
  final _descriptionFieldController = TextEditingController();

  String name;
  String phoneNumber;
  String description;

  final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
  final timeFormat = DateFormat('h:mm a');

  DateTime reminderDate;
  TimeOfDay reminderTime;

  Contact selectedContact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.canvasColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.canvasColor,
        title: Text('Edit Call'),
        backwardsCompatibility: false,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('Users')
              .doc(currentUser.uid)
              .collection('Calls')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: const CircularProgressIndicator(),
              );
            } else {
              final doc = snapshot.data.docs
                  .where((element) => element.reference.id == widget.call.id)
                  .single;
              name = '${doc.data()['Name']}';
              phoneNumber = '${doc.data()['PhoneNumber']}';
              description = '${doc.data()['Description']}';
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TypeAheadFormField(
                      suggestionsCallback:
                          contactsUtility.searchContactsWithQuery,
                      itemBuilder: (context, contact) {
                        //var _avatar = contact.avatar ??
                        final _contact = contact;
                        return ListTile(
                          leading: _contact.avatar == null ||
                                  _contact.avatar.length == 0
                              ? CircleAvatar(
                                  child: Icon(Icons.person_outline),
                                )
                              : ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
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
                        _nameFieldController.text = selectedContact.displayName;
                        if (selectedContact.phones.length > 1) {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            builder: (_) => MultiplePhoneNumbersSheet(
                              selectedContact: selectedContact,
                            ),
                          ).then((value) {
                            _phoneFieldController.text = value;
                          });
                        } else {
                          _phoneFieldController.text =
                              selectedContact.phones.first.value;
                        }
                      },
                      validator: (input) => input == null || input == ''
                          ? 'This field is required'
                          : null,
                      onSaved: (contactName) =>
                          _nameFieldController.text = contactName,
                      textFieldConfiguration: TextFieldConfiguration(
                        enabled: true,
                        textCapitalization: TextCapitalization.words,
                        controller: _nameFieldController,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            OMIcons.person,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.grey,
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                              onPressed: () => _nameFieldController.text = '',
                            ),
                          ),
                          labelText: 'Name (Required)',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      enabled: true,
                      keyboardType: TextInputType.phone,
                      maxLines: 1,
                      autofocus: false,
                      controller: _phoneFieldController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          OMIcons.phone,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.grey,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            onPressed: () => _phoneFieldController.text = '',
                          ),
                        ),
                        labelText: phoneNumber,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      enabled: true,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      autofocus: false,
                      controller: _descriptionFieldController,
                      decoration: InputDecoration(
                        labelText: description,
                        prefixIcon: Icon(
                          OMIcons.comment,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.grey,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            onPressed: () =>
                                _descriptionFieldController.text = '',
                          ),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: !MediaQuery.of(context).keyboardOpen
          ? FloatingActionButton.extended(
              highlightElevation: 2.0,
              onPressed: () {
                if (name.isEmpty || phoneNumber.isEmpty) {
                  final snackBar = SnackBar(
                    content: Text('Please enter required fields'),
                    action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
                    duration: Duration(seconds: 3),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else {
                  try {
                    final userCalls = firestore.calls(currentUser.uid);
                    String date;
                    String time;

                    if (_nameFieldController.text.isNotEmpty) {
                      name = _nameFieldController.text;
                    }
                    if (_phoneFieldController.text.isNotEmpty) {
                      phoneNumber = _phoneFieldController.text;
                    }
                    if (_descriptionFieldController.text.isNotEmpty) {
                      description = _descriptionFieldController.text;
                    }

                    if (reminderDate == null) {
                      date = '';
                    } else {
                      date = reminderDate.toString();
                    }

                    if (reminderTime == null) {
                      time = '';
                    } else {
                      time = reminderTime.toString();
                    }

                    if (selectedContact == null) {
                      userCalls.doc(widget.call.id).update({
                        'Name': name,
                        'PhoneNumber': phoneNumber,
                        'Description': description,
                        'ReminderDate': date,
                        'ReminderTime': time
                      });
                    } else {
                      userCalls.doc(widget.call.id).update({
                        'Avatar': String.fromCharCodes(selectedContact.avatar),
                        'Name': name,
                        'PhoneNumber': phoneNumber,
                        'Description': description,
                        'ReminderDate': date,
                        'ReminderTime': time
                      });
                    }
                  } catch (e) {
                    print(e);
                  } finally {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/HomeScreen', (Route<dynamic> route) => false);
                  }
                }
              },
              tooltip: 'Save',
              elevation: 2.0,
              icon: Icon(Icons.save),
              label: Text('SAVE'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        //hasNotch: false,
        child: Row(
          children: [
            const SizedBox(width: 8.0),
            CloseButton(),
          ],
        ),
      ),
    );
  }
}
