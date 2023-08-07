import 'package:bluejay/bluejay.dart';
import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/provided.dart';
import 'package:call_manager/utils/extensions.dart';
import 'package:call_manager/widgets/clear_button.dart';
import 'package:call_manager/widgets/contact_tile.dart';
import 'package:call_manager/widgets/multiple_phone_numbers_sheet.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';

// Add New Call Screen
class NewCallScreen extends StatefulWidget {
  const NewCallScreen({Key? key}) : super(key: key);

  @override
  State<NewCallScreen> createState() => _NewCallScreenState();
}

class _NewCallScreenState extends State<NewCallScreen>
    with FirebaseMixin, Provided {
  // Contact Picker stuff
  late Call call = Call(
    name: '',
    phoneNumber: '',
  );
  Iterable<Contact>? contacts;
  final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
  final formKey = GlobalKey<FormState>();
  final phoneFieldController = TextEditingController();
  DateTime? reminderDate;
  TimeOfDay? reminderTime;
  Contact? selectedContact;
  final timeFormat = DateFormat('h:mm a');

  Future<void> saveCall() async {
    formKey.currentState!.save();
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      call.timeCreated = DateTime.now();

      if (reminderDate != null && reminderTime != null) {
        call.reminderDate = reminderDate.toString();
        call.reminderTime = reminderTime.toString();
        final scheduledNotificationDateTime = DateTime(
          reminderDate!.year,
          reminderDate!.month,
          reminderDate!.day,
          reminderTime!.hour,
          reminderTime!.minute,
        );

        await notificationService.scheduleNotification(
          call,
          scheduledNotificationDateTime,
        );
      }

      firestore.upcomingCalls.add(call.toJson());

      if (mounted) Navigator.of(context).pop();
    }
  }

  /// Show sheet and set number
  void showMultiplePhoneNumbersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      builder: (_) => MultiplePhoneNumbersSheet(
        selectedContact: selectedContact,
      ),
    ).then((value) {
      call.avatar = selectedContact?.avatar != null
          ? String.fromCharCodes(selectedContact!.avatar!)
          : '';
      //call.name = value
      call.phoneNumber = value;
      phoneFieldController.text = value;
    });
  }

  /// Set number.
  ///
  /// Called in case of single phone number.
  void setPhoneNumber() {
    call.avatar = selectedContact?.avatar != null
        ? String.fromCharCodes(selectedContact!.avatar!)
        : '';
    if (selectedContact!.phones!.isEmpty) {
      call.phoneNumber = '';
    } else {
      call.phoneNumber = selectedContact!.phones?.first.value!;
      final number = selectedContact!.phones?.first.value!;
      phoneFieldController.text = number!;
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
        title: const Text('New Call'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextEditingControllerBuilder(
                  text: call.name ?? '',
                  builder: (_, controller) {
                    return TypeAheadFormField(
                      suggestionsCallback:
                          contactsUtility.searchContactsWithQuery,
                      itemBuilder: (context, dynamic contact) =>
                          ContactTile(contact: contact),
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (dynamic contact) {
                        selectedContact = contact;
                        controller.text = selectedContact!.displayName!;
                        if (selectedContact!.phones!.length > 1) {
                          showMultiplePhoneNumbersSheet(context);
                        } else {
                          setPhoneNumber();
                        }
                      },
                      validator: (input) => input == null || input == ''
                          ? 'This field is required'
                          : null,
                      onSaved: (contactName) => call.name = contactName!,
                      textFieldConfiguration: TextFieldConfiguration(
                        textCapitalization: TextCapitalization.words,
                        controller: controller,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: theme.iconTheme.color,
                          ),
                          labelText: 'Name*',
                          suffixIcon: ClearButton(
                            onPressed: () => controller.clear(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                TextEditingControllerBuilder(
                  text: phoneFieldController.text,
                  builder: (_, controller) {
                    return TextFormField(
                      validator: (input) => input == null || input == ''
                          ? 'This field is required'
                          : null,
                      //onSaved: (input) => controller.text = input!,
                      keyboardType: TextInputType.phone,
                      maxLines: 1,
                      autofocus: false,
                      controller: phoneFieldController,
                      onChanged: (value) => call.phoneNumber = value,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: theme.iconTheme.color,
                        ),
                        labelText: 'Phone Number*',
                        suffixIcon: ClearButton(
                          onPressed: () => controller.clear(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                TextEditingControllerBuilder(
                  text: call.description ?? '',
                  builder: (_, controller) {
                    return TextFormField(
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      autofocus: false,
                      controller: controller,
                      onChanged: (value) => call.description = value,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(
                          Icons.comment_outlined,
                          color: theme.iconTheme.color,
                        ),
                        suffixIcon: ClearButton(
                          onPressed: () => controller.clear(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                TextEditingControllerBuilder(
                  text: '',
                  builder: (_, controller) {
                    return DateTimeField(
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
                      controller: controller,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.today,
                          color: theme.iconTheme.color,
                        ),
                        labelText: 'Reminder Date',
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                TextEditingControllerBuilder(
                  text: '',
                  builder: (_, controller) {
                    return DateTimeField(
                      format: timeFormat,
                      onChanged: (timeOfDay) =>
                          reminderTime = TimeOfDay.fromDateTime(timeOfDay!),
                      onShowPicker: (context, currentValue) async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now(),
                          ),
                        );

                        return DateTimeField.convert(time);
                      },
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Reminder Time',
                        prefixIcon: Icon(
                          Icons.access_time,
                          color: theme.iconTheme.color,
                        ),
                      ),
                    );
                  },
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
              icon: const Icon(Icons.save),
              label: const Text('SAVE'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomAppBar(
        //hasNotch: false,
        child: Row(
          children: [
            SizedBox(width: 8.0),
            CloseButton(),
          ],
        ),
      ),
    );
  }
}
