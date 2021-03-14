import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/provided.dart';
import 'package:call_manager/screens/home_screen.dart';
import 'package:call_manager/utils/extensions.dart';
import 'package:call_manager/widgets/contact_avatar.dart';
import 'package:call_manager/widgets/multiple_phone_numbers_sheet.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';

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
  final _nameFieldController = TextEditingController();
  final _phoneFieldController = TextEditingController();
  final _descriptionFieldController = TextEditingController();
  final _dateFieldController = TextEditingController();
  final _timeFieldController = TextEditingController();

  final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
  final timeFormat = DateFormat('h:mm a');

  DateTime reminderDate;
  TimeOfDay reminderTime;

  final formKey = GlobalKey<FormState>();

  Future<void> saveCall() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      final call = Call(
        avatar: selectedContact?.avatar != null
            ? String.fromCharCodes(selectedContact.avatar)
            : '',
        name: _nameFieldController.text,
        phoneNumber: _phoneFieldController.text,
      );

      if (reminderDate != null && reminderTime != null) {
        call.reminderDate = reminderDate.toString();
        call.reminderTime = reminderTime.toString();
        final scheduledNotificationDateTime = DateTime(
          reminderDate.year,
          reminderDate.month,
          reminderDate.day,
          reminderTime.hour,
          reminderTime.minute,
        );

        await notificationService.scheduleNotification(
          call,
          scheduledNotificationDateTime,
        );
      }

      firestore.calls(currentUser.uid).add(call.toJson());

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  // ignore: long-method
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.canvasColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('New Call'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TypeAheadFormField(
                  suggestionsCallback: contactsUtility.searchContactsWithQuery,
                  itemBuilder: (context, contact) {
                    return ListTile(
                      leading: ContactAvatar(contact: contact),
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
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: theme.iconTheme.color,
                      ),
                      labelText: 'Name (Required)',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: theme.iconTheme.color,
                          ),
                          onPressed: () => _nameFieldController.text = '',
                        ),
                      ),
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
                      Icons.phone_outlined,
                      color: theme.iconTheme.color,
                    ),
                    labelText: 'Phone Number (Required)',
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: theme.iconTheme.color,
                        ),
                        onPressed: () => _phoneFieldController.text = '',
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
                      Icons.comment_outlined,
                      color: theme.iconTheme.color,
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
                        onPressed: () => _descriptionFieldController.text = '',
                      ),
                    ),
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
                  onChanged: (date) => reminderDate = date,
                  controller: _dateFieldController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.today,
                      color: theme.iconTheme.color,
                    ),
                    labelText: 'Reminder Date',
                  ),
                ),
                const SizedBox(height: 16.0),
                DateTimeField(
                  format: timeFormat,
                  enabled: true,
                  onChanged: (timeOfDay) =>
                      reminderTime = TimeOfDay.fromDateTime(timeOfDay),
                  onShowPicker: (context, currentValue) async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        currentValue ?? DateTime.now(),
                      ),
                    );

                    return DateTimeField.convert(time);
                  },
                  controller: _timeFieldController,
                  decoration: InputDecoration(
                    labelText: 'Reminder Time',
                    prefixIcon: Icon(
                      Icons.access_time,
                      color: theme.iconTheme.color,
                    ),
                  ),
                ),
              ],
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
