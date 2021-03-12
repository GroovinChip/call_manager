import 'package:call_manager/firebase/firebase_mixin.dart';
import 'package:call_manager/provided.dart';
import 'package:call_manager/utils/extensions.dart';
import 'package:call_manager/utils/pass_notification.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:intl/intl.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:rounded_modal/rounded_modal.dart';

// Add New Call Screen
class NewCallScreen extends StatefulWidget {
  @override
  _NewCallScreenState createState() => _NewCallScreenState();
}

class _NewCallScreenState extends State<NewCallScreen>
    with FirebaseMixin, Provided {
  // Contact Picker stuff
  Iterable<Contact> contacts;
  Contact selectedContact;

  //TextFormField controllers
  TextEditingController _nameFieldController = TextEditingController();
  TextEditingController _phoneFieldController = TextEditingController();
  TextEditingController _descriptionFieldController = TextEditingController();
  TextEditingController _dateFieldController = TextEditingController();
  TextEditingController _timeFieldController = TextEditingController();

  final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
  final timeFormat = DateFormat('h:mm a');

  DateTime reminderDate;
  TimeOfDay reminderTime;

  final formKey = GlobalKey<FormState>();

  Future<void> saveCall() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      final userCalls = firestore
          .collection('Users')
          .doc(currentUser.uid)
          .collection('Calls');
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
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          '1',
          'Call Reminders',
          'Allow Call Manager to create and send notifications about Call Reminders',
        );

        var iOSPlatformChannelSpecifics = IOSNotificationDetails();

        final platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics,
        );

        await PassNotification.of(context).schedule(
            0,
            'Reminder: call ' + _nameFieldController.text,
            'Tap to call ' + _nameFieldController.text,
            scheduledNotificationDateTime,
            platformChannelSpecifics,
            payload: _phoneFieldController.text);

        date = reminderDate.toString();
        time = reminderTime.toString();
      } else {
        date = '';
        time = '';
      }

      if (selectedContact == null || selectedContact.avatar.length == 0) {
        userCalls.add({
          'Name': _nameFieldController.text,
          'PhoneNumber': _phoneFieldController.text,
          'Description': _descriptionFieldController.text,
          'ReminderDate': date,
          'ReminderTime': time
        });
      } else if (selectedContact.avatar.length > 0) {
        userCalls.add({
          'Avatar': String.fromCharCodes(selectedContact.avatar),
          'Name': _nameFieldController.text,
          'PhoneNumber': _phoneFieldController.text,
          'Description': _descriptionFieldController.text,
          'ReminderDate': date,
          'ReminderTime': time
        });
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
          '/HomeScreen', (Route<dynamic> route) => false);
    }
  }

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
        title: Text('New Call'),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TypeAheadFormField(
                    suggestionsCallback:
                        contactsUtility.searchContactsWithQuery,
                    itemBuilder: (context, contact) {
                      //var _avatar = contact.avatar ??
                      Contact _contact = contact;
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
                      this._nameFieldController.text =
                          selectedContact.displayName;
                      if (selectedContact.phones.length > 1) {
                        showRoundedModalBottomSheet(
                            context: context,
                            color: Theme.of(context).canvasColor,
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
                                        'Choose phone number',
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
                                        phoneNums =
                                            selectedContact.phones.toList();
                                        switch (phoneNums[index].label) {
                                          case 'mobile':
                                            phoneType =
                                                Icon(OMIcons.smartphone);
                                            break;
                                          case 'work':
                                            phoneType = Icon(OMIcons.business);
                                            break;
                                          case 'home':
                                            phoneType = Icon(OMIcons.home);
                                            break;
                                          default:
                                            phoneType = Icon(OMIcons.phone);
                                        }
                                        return ListTile(
                                          leading: phoneType,
                                          title: Text(phoneNums[index].value),
                                          subtitle:
                                              Text(phoneNums[index].label),
                                          onTap: () {
                                            this._phoneFieldController.text =
                                                phoneNums[index].value;
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            });
                      } else {
                        this._phoneFieldController.text =
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
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.grey,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            onPressed: () async {
                              _nameFieldController.text = '';
                            },
                          ),
                        ),
                        labelText: 'Name (Required)',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    validator: (input) => input == null || input == ''
                        ? 'This field is required'
                        : null,
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
                            _phoneFieldController.text = '';
                          },
                        ),
                      ),
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
                      labelText: 'Description',
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
                            _descriptionFieldController.text = '';
                          },
                        ),
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  DateTimeField(
                    format: dateFormat,
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 1),
                      );
                    },
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
                      labelText: 'Reminder Date',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  DateTimeField(
                    format: timeFormat,
                    enabled: true,
                    onChanged: (timeOfDay) {
                      reminderTime = TimeOfDay.fromDateTime(timeOfDay);
                    },
                    onShowPicker: (context, currentValue) async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now()),
                      );
                      return DateTimeField.convert(time);
                    },
                    controller: _timeFieldController,
                    decoration: InputDecoration(
                      labelText: 'Reminder Time',
                      prefixIcon: Icon(
                        Icons.access_time,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.grey,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: !MediaQuery.of(context).keyboardOpen
          ? FloatingActionButton.extended(
              onPressed: saveCall,
              tooltip: 'Save',
              elevation: 2.0,
              icon: Icon(Icons.save),
              label: Text('Save'),
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