import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:groovin_widgets/groovin_widgets.dart';

class MultiplePhoneNumbersSheet extends StatelessWidget {
  const MultiplePhoneNumbersSheet({
    required this.selectedContact,
    Key? key,
  }) : super(key: key);

  final Contact? selectedContact;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ModalDrawerHandle(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Choose phone number',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
          ...List.generate(selectedContact!.phones!.length, (index) {
            List<Item> _phoneNumbers = selectedContact!.phones!.toList();
            Icon phoneType;
            switch (_phoneNumbers[index].label) {
              case 'mobile':
                phoneType = const Icon(Icons.smartphone);
                break;
              case 'work':
                phoneType = const Icon(Icons.business);
                break;
              case 'home':
                phoneType = const Icon(Icons.home_outlined);
                break;
              default:
                phoneType = const Icon(Icons.phone_outlined);
            }

            return ListTile(
              leading: phoneType,
              title: Text(_phoneNumbers[index].value!),
              subtitle: Text(_phoneNumbers[index].label!),
              onTap: () =>
                  Navigator.of(context).pop(_phoneNumbers[index].value),
            );
          }),
        ],
      ),
    );
  }
}
