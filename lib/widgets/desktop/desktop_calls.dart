import 'dart:io';

import 'package:bluejay/bluejay.dart';
import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/widgets/call_card.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:rxdart/rxdart.dart';

class DesktopCalls extends StatelessWidget with FirebaseMixin {
  const DesktopCalls({
    Key? key,
    required this.screenIndex,
  }) : super(key: key);

  final int screenIndex;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FirestoreDocument>>(
      stream: CombineLatestStream.combine2(
        firestore.upcomingCalls.snapshots(),
        firestore.completedCalls.snapshots(),
        (a, b) => <FirestoreDocument>[
          a as FirestoreDocument,
          b as FirestoreDocument,
        ],
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: ProgressCircle(),
          );
        } else {
          return FadeIndexedStack(
            index: screenIndex,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30.0,
                      top: 50.0,
                    ),
                    child: Text(
                      'Upcoming',
                      style:
                          MacosTheme.of(context).typography.largeTitle.copyWith(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ),
                  if (snapshot.data!.first.docs.isNotEmpty) ...[
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: snapshot.data!.first.docs.length,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final call = Call.fromJsonWithDocId(
                            snapshot.data!.first.docs[index].data(),
                            snapshot.data!.first.docs[index].id,
                          );

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CallCard(
                              call: call,
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Center(
                        child: Text(
                          'Tap "Add Call" to get started!',
                          style: Platform.isMacOS
                              ? MacosTheme.of(context).typography.title1
                              : Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30.0,
                      top: 50.0,
                    ),
                    child: Text(
                      'Completed',
                      style:
                          MacosTheme.of(context).typography.largeTitle.copyWith(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ),
                  if (snapshot.data!.last.docs.isNotEmpty) ...[
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: snapshot.data!.last.docs.length,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final call = Call.fromJsonWithDocId(
                            snapshot.data!.last.docs[index].data(),
                            snapshot.data!.last.docs[index].id,
                          );

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CallCard(
                              call: call,
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Center(
                        child: Text(
                          'Nothing here!',
                          style: Platform.isMacOS
                              ? MacosTheme.of(context).typography.title1
                              : Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        }
      },
    );
  }
}
