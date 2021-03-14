import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase_mixin.dart';
import 'package:call_manager/provided.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ScheduleNotificationSheet extends StatefulWidget {
  const ScheduleNotificationSheet({
    Key key,
    @required this.call,
  }) : super(key: key);

  final Call call;

  @override
  _ScheduleNotificationSheetState createState() =>
      _ScheduleNotificationSheetState();
}

class _ScheduleNotificationSheetState extends State<ScheduleNotificationSheet>
    with FirebaseMixin, Provided {
  String numberToCallOnNotificationTap;

  final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
  final timeFormat = DateFormat('h:mm a');

  DateTime reminderDate;
  TimeOfDay reminderTime;

  Future<void> scheduleNotificationReminder() async {
    var scheduledNotificationDateTime = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    await notificationService.scheduleNotification(
      widget.call,
      scheduledNotificationDateTime,
    );

    Navigator.of(context).pop();
  }

  @override
  // ignore: long-method
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModalDrawerHandle(),
            SizedBox(height: 12.0),
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
            SizedBox(height: 16.0),
            DateTimeField(
              format: timeFormat,
              enabled: true,
              onChanged: (timeOfDay) =>
                  reminderTime = TimeOfDay.fromDateTime(timeOfDay),
              onShowPicker: (context, currentValue) async {
                final time = await showTimePicker(
                  context: context,
                  initialTime:
                      TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                );

                return DateTimeField.convert(time);
              },
              decoration: InputDecoration(
                labelText: 'Reminder Time',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.access_time,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(MdiIcons.bellPlusOutline),
                    label: Text('Set Reminder'),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      numberToCallOnNotificationTap =
                          '${widget.call.phoneNumber}';
                      scheduleNotificationReminder();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
