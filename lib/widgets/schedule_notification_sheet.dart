import 'dart:io';

import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase_mixin.dart';
import 'package:call_manager/provided.dart';
import 'package:call_manager/theme/app_colors.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ScheduleNotificationSheet extends StatefulWidget {
  const ScheduleNotificationSheet({
    Key? key,
    required this.call,
  }) : super(key: key);

  final Call call;

  @override
  _ScheduleNotificationSheetState createState() =>
      _ScheduleNotificationSheetState();
}

class _ScheduleNotificationSheetState extends State<ScheduleNotificationSheet>
    with FirebaseMixin, Provided {
  Color? backgroundColor;
  final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
  String? numberToCallOnNotificationTap;
  DateTime? reminderDate;
  late TimeOfDay reminderTime;
  Color? textColor;
  final timeFormat = DateFormat('h:mm a');

  Future<void> scheduleNotificationReminder() async {
    var scheduledNotificationDateTime = DateTime(
      reminderDate!.year,
      reminderDate!.month,
      reminderDate!.day,
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
    final theme = Theme.of(context);
    if (Platform.isMacOS) {
      backgroundColor = MacosTheme.of(context).canvasColor;
      textColor =
          MacosTheme.brightnessOf(context).isDark ? Colors.white : Colors.black;
    } else {
      backgroundColor = theme.canvasColor;
      textColor = Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;
    }

    return SafeArea(
      child: Container(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModalDrawerHandle(),
              SizedBox(height: 12.0),
              if (Platform.isMacOS) ...[
                Expanded(
                  child: CupertinoDatePicker(
                    onDateTimeChanged: (value) {
                      setState(() {
                        reminderDate =
                            DateTime(value.year, value.month, value.day);
                        reminderTime =
                            TimeOfDay(hour: value.hour, minute: value.minute);
                      });
                    },
                  ),
                ),
              ] else ...[
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
                      color: theme.iconTheme.color,
                    ),
                    labelText: 'Reminder Date',
                    labelStyle: TextStyle(
                      color: textColor,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                DateTimeField(
                  format: timeFormat,
                  enabled: true,
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
                  decoration: InputDecoration(
                    labelText: 'Reminder Time',
                    labelStyle: TextStyle(
                      color: textColor,
                    ),
                    prefixIcon: Icon(
                      Icons.access_time,
                      color: theme.iconTheme.color,
                    ),
                  ),
                ),
              ],
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: Platform.isMacOS
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  if (Platform.isMacOS) ...[
                    ElevatedButton.icon(
                      icon: Icon(MdiIcons.bellPlusOutline),
                      label: Text('Set Reminder'),
                      style: ElevatedButton.styleFrom(
                        primary: AppColors.primaryColor,
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
                  ] else ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(MdiIcons.bellPlusOutline),
                        label: Text('Set Reminder'),
                        style: ElevatedButton.styleFrom(
                          primary: AppColors.primaryColor,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
