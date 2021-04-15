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
  //TextField controllers
  final _descriptionFieldController = TextEditingController();
  final _nameFieldController = TextEditingController();
  final _phoneFieldController = TextEditingController();


  @override
  // ignore: long-method, code-metrics
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.canvasColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Edit Call'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TypeAheadFormField(
                suggestionsCallback: contactsUtility.searchContactsWithQuery,
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
                  _nameFieldController.text = selectedContact!.displayName!;
                  if (selectedContact!.phones!.length > 1) {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      builder: (_) => MultiplePhoneNumbersSheet(
                        selectedContact: selectedContact,
                      ),
                    ).then((value) => _phoneFieldController.text = value);
                  } else {
                    _phoneFieldController.text =
                        selectedContact!.phones!.first.value!;
                  }
                },
                validator: (input) => input == null || input == ''
                    ? 'This field is required'
                    : null,
                onSaved: (contactName) =>
                    _nameFieldController.text = contactName!,
                textFieldConfiguration: TextFieldConfiguration(
                  textCapitalization: TextCapitalization.words,
                  controller: _nameFieldController,
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: theme.iconTheme.color,
                    ),
                    suffixIcon: ClearButton(
                      onPressed: () => _nameFieldController.text = '',
                    ),
                    labelText: widget.call.name,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                keyboardType: TextInputType.phone,
                maxLines: 1,
                autofocus: false,
                controller: _phoneFieldController,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: theme.iconTheme.color,
                  ),
                  suffixIcon: ClearButton(
                    onPressed: () => _phoneFieldController.text = '',
                  ),
                  labelText: widget.call.phoneNumber,
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                autofocus: false,
                controller: _descriptionFieldController,
                decoration: InputDecoration(
                  labelText: widget.call.hasDescription
                      ? widget.call.description
                      : 'Description',
                  prefixIcon: Icon(
                    Icons.comment_outlined,
                    color: theme.iconTheme.color,
                  ),
                  suffixIcon: ClearButton(
                    onPressed: () => _descriptionFieldController.text = '',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: !MediaQuery.of(context).keyboardOpen
          ? FloatingActionButton.extended(
              highlightElevation: 2.0,
              onPressed: () {
                if (_nameFieldController.text.isNotEmpty) {
                  widget.call.name = _nameFieldController.text;
                }

                if (_phoneFieldController.text.isNotEmpty) {
                  widget.call.phoneNumber = _phoneFieldController.text;
                }

                if (_descriptionFieldController.text.isNotEmpty) {
                  widget.call.description = _descriptionFieldController.text;
                }

                if (selectedContact != null) {
                  widget.call.avatar = selectedContact?.avatar != null
                      ? String.fromCharCodes(selectedContact!.avatar!)
                      : '';
                }

                widget.call.lastEdited = DateTime.now();

                firestore
                    .calls(currentUser!.uid)
                    .doc(widget.call.id)
                    .update(widget.call.toJson());

                Navigator.of(context).pop();
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
