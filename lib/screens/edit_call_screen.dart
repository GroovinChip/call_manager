import 'package:bluejay/bluejay.dart';
import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/provided.dart';
import 'package:call_manager/utils/extensions.dart';
import 'package:call_manager/widgets/clear_button.dart';
import 'package:call_manager/widgets/contact_avatar.dart';
import 'package:call_manager/widgets/multiple_phone_numbers_sheet.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class EditCallScreen extends StatefulWidget {
  const EditCallScreen({
    Key? key,
    required this.call,
  }) : super(key: key);

  final Call call;

  @override
  _EditCallScreenState createState() => _EditCallScreenState();
}

class _EditCallScreenState extends State<EditCallScreen>
    with FirebaseMixin, Provided {
  Contact? selectedContact;
  final _formKey = GlobalKey<FormState>();

  @override
  // ignore: long-method, code-metrics
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.canvasColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Edit Call'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextEditingControllerBuilder(
                  text: widget.call.name!,
                  builder: (_, controller) {
                    return TypeAheadFormField(
                      suggestionsCallback:
                          contactsUtility.searchContactsWithQuery,
                      itemBuilder: (context, dynamic contact) {
                        return ListTile(
                          leading: ContactAvatar(contact: contact),
                          title: Text(contact.displayName),
                        );
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (dynamic contact) {
                        selectedContact = contact;
                        controller.text = selectedContact!.displayName!;
                        if (selectedContact!.phones!.length > 1) {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            builder: (_) => MultiplePhoneNumbersSheet(
                              selectedContact: selectedContact,
                            ),
                          ).then((value) => widget.call.phoneNumber = value);
                        } else {
                          widget.call.phoneNumber =
                              selectedContact!.phones!.first.value!;
                        }
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'This field is required'
                          : null,
                      onSaved: (contactName) {
                        controller.text = contactName!;
                        widget.call.name = contactName;
                      },
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
                          suffixIcon: ClearButton(
                            onPressed: () {
                              controller.clear();
                              widget.call.name = controller.text;
                            },
                          ),
                          labelText: 'Name',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                TextEditingControllerBuilder(
                  text: widget.call.phoneNumber!,
                  builder: (_, controller) {
                    return TextFormField(
                      keyboardType: TextInputType.phone,
                      maxLines: 1,
                      autofocus: false,
                      controller: controller,
                      onChanged: (value) => widget.call.phoneNumber = value,
                      validator: (value) => value == null || value.isEmpty
                          ? 'This field is required'
                          : null,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: theme.iconTheme.color,
                        ),
                        suffixIcon: ClearButton(
                          onPressed: () {
                            controller.clear();
                            widget.call.phoneNumber = controller.text;
                          },
                        ),
                        labelText: 'Phone number',
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                TextEditingControllerBuilder(
                  text: widget.call.description ?? '',
                  builder: (_, controller) {
                    return TextFormField(
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      autofocus: false,
                      controller: controller,
                      onChanged: (value) => widget.call.description = value,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(
                          Icons.comment_outlined,
                          color: theme.iconTheme.color,
                        ),
                        suffixIcon: ClearButton(
                          onPressed: () {
                            controller.clear();
                            widget.call.description = controller.text;
                          },
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
              highlightElevation: 2.0,
              onPressed: () {
                _formKey.currentState!.save();
                if (_formKey.currentState!.validate()) {
                  if (selectedContact != null) {
                    widget.call.avatar = selectedContact?.avatar != null
                        ? String.fromCharCodes(selectedContact!.avatar!)
                        : '';
                  }

                  widget.call.lastEdited = DateTime.now();

                  firestore.upcomingCalls
                      .doc(widget.call.id)
                      .update(widget.call.toJson());

                  Navigator.of(context).pop();
                }
              },
              tooltip: 'Save',
              elevation: 2.0,
              icon: const Icon(Icons.save),
              label: const Text('SAVE'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        //hasNotch: false,
        child: Row(
          children: const [
            SizedBox(width: 8.0),
            CloseButton(),
          ],
        ),
      ),
    );
  }
}
