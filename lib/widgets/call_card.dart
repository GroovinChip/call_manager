import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/provided.dart';
import 'package:call_manager/screens/edit_call_screen.dart';
import 'package:call_manager/utils/extensions.dart';
import 'package:call_manager/widgets/call_avatar.dart';
import 'package:call_manager/widgets/dialogs/complete_call_dialog.dart';
import 'package:call_manager/widgets/dialogs/delete_call_dialog.dart';
import 'package:call_manager/widgets/dialogs/mark_incomplete_dialog.dart';
import 'package:call_manager/widgets/schedule_notification_sheet.dart';
import 'package:flutter/material.dart';
import 'package:groovin_widgets/groovin_widgets.dart';

class CallCard extends StatefulWidget {
  CallCard({
    required this.call,
  });

  final Call call;

  @override
  CallCardState createState() {
    return CallCardState();
  }
}

class CallCardState extends State<CallCard> with FirebaseMixin, Provided {
  bool isExpanded = false;

  List<PopupMenuItem> overflowItemsCallCard = [
    PopupMenuItem(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text('Send Email'),
          ),
          Icon(Icons.send_outlined),
        ],
      ),
      value: 'Send Email',
    ),
  ];

  @override
  // ignore: long-method
  Widget build(BuildContext context) {
    return Material(
      elevation: 2.0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: GroovinExpansionTile(
        leading: CallAvatar(
          call: widget.call,
        ),
        title: Text(
          widget.call.name!,
          style: TextStyle(
            color: context.isDarkTheme ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(widget.call.phoneNumber!),
        onExpansionChanged: (value) {
          setState(() => isExpanded = value);
        },
        inkwellRadius: !isExpanded
            ? BorderRadius.all(Radius.circular(8.0))
            : BorderRadius.only(
                topRight: Radius.circular(8.0),
                topLeft: Radius.circular(8.0),
              ),
        children: [
          if (widget.call.description != null &&
              widget.call.description!.isNotEmpty) ...[
            Row(
              children: [
                const SizedBox(width: 16),
                Text(widget.call.description!),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DeleteCallDialog(
                      call: widget.call,
                    ),
                  );
                },
                tooltip: 'Complete',
              ),
              if (!widget.call.isCompleted) ...[
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => CompleteCallDialog(
                        call: widget.call,
                      ),
                    );
                  },
                  tooltip: 'Complete',
                ),
              ] else ...[
                IconButton(
                  icon: Icon(Icons.check_circle),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => MarkIncompleteDialog(
                        call: widget.call,
                      ),
                    );
                  },
                  tooltip: 'Complete',
                ),
              ],
              IconButton(
                icon: Icon(Icons.notifications_none),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    builder: (_) => ScheduleNotificationSheet(
                      call: widget.call,
                    ),
                  );
                },
                tooltip: 'Set reminder',
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditCallScreen(
                        call: widget.call,
                      ),
                    ),
                  );
                },
                tooltip: 'Edit this call',
              ),
              /*IconButton(
                icon: Icon(MdiIcons.commentTextOutline),
                onPressed: () {
                  phoneUtility.sendSms(widget.call.phoneNumber);
                },
                tooltip: 'Text ${widget.call.name}',
              ),*/
              IconButton(
                icon: Icon(Icons.phone_outlined),
                onPressed: () async {
                  await phoneUtility.callNumber('${widget.call.phoneNumber}');
                },
                tooltip: 'Call ${widget.call.name}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
