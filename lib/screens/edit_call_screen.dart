import 'package:bluejay/bluejay.dart';
import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/provided.dart';
import 'package:call_manager/utils/extensions.dart';
import 'package:call_manager/widgets/clear_button.dart';
import 'package:call_manager/widgets/contact_avatar.dart';
import 'package:call_manager/widgets/multiple_phone_numbers_sheet.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class EditCallScreen extends StatefulWidget {
  const EditCallScreen({
    super.key,
    required this.call,
  });

  final Call call;

  @override
  State<EditCallScreen> createState() => _EditCallScreenState();
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
                    return TypeAheadField(
                      suggestionsCallback: (pattern) async {
                        final results = await contactsUtility
                            .searchContactsWithQuery(pattern);
                        return results.toList();
                      },
                      itemBuilder: (context, dynamic contact) {
                        return ListTile(
                          leading: ContactAvatar(contact: contact),
                          title: Text(contact.displayName),
                        );
                      },
                      transitionBuilder: (context, animation, child) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.fastOutSlowIn,
                          ),
                          child: child,
                        );
                      },
                      onSelected: (dynamic contact) {
                        selectedContact = contact;
                        controller.text = selectedContact!.displayName;
                        if (selectedContact!.phones.length > 1) {
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
                              selectedContact!.phones.first.number;
                        }
                      },
                      // controller: controller,
                      errorBuilder: (context, error) {
                        return Text(
                          '$error',
                          style: const TextStyle(color: Colors.red),
                        );
                      },
                      builder: (context, controller, focusNode) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
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
                        );
                      },
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
                    widget.call.avatar = selectedContact?.photo != null
                        ? String.fromCharCodes(selectedContact!.photo!)
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
