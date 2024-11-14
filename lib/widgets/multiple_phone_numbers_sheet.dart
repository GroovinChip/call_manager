import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';
import 'package:groovin_widgets/groovin_widgets.dart';

class MultiplePhoneNumbersSheet extends StatelessWidget {
  const MultiplePhoneNumbersSheet({
    required this.selectedContact,
    super.key,
  });

  final Contact? selectedContact;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: ModalDrawerHandle(),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose phone number',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
          ...List.generate(selectedContact!.phones.length, (index) {
            List<Phone> phoneNumbers = selectedContact!.phones;
            Icon phoneType;
            switch (phoneNumbers[index].label) {
              case PhoneLabel.mobile:
                phoneType = const Icon(Icons.smartphone);
                break;
              case PhoneLabel.work:
                phoneType = const Icon(Icons.business);
                break;
              case PhoneLabel.home:
                phoneType = const Icon(Icons.home_outlined);
                break;
              default:
                phoneType = const Icon(Icons.phone_outlined);
            }

            return ListTile(
              leading: phoneType,
              title: Text(phoneNumbers[index].number),
              subtitle: Text('${phoneNumbers[index].label}'),
              onTap: () =>
                  Navigator.of(context).pop(phoneNumbers[index].number),
            );
          }),
        ],
      ),
    );
  }
}
