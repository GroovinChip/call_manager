import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/widgets/call_card.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// This widget represents the content on the main screen of the app
class CallsList extends StatefulWidget {
  const CallsList({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  final TabController tabController;

  @override
  _CallsListState createState() => _CallsListState();
}

class _CallsListState extends State<CallsList> with FirebaseMixin {
  @override
  // ignore: long-method
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
      builder: (_, AsyncSnapshot<List<FirestoreDocument>> snapshot) {
        return TabBarView(
          controller: widget.tabController,
          children: [
            // ignore: unnecessary_null_comparison
            if (!snapshot.hasData) ...[
              Center(
                child: const CircularProgressIndicator(),
              ),
            ] else ...[
              if (snapshot.data!.first.docs.isNotEmpty) ...[
                ListView.builder(
                  itemCount: snapshot.data!.first.docs.length,
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
              ] else ...[
                Center(
                  child: Text(
                    'Tap "Add Call" to get started!',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ],
              if (snapshot.data!.last.docs.isNotEmpty) ...[
                ListView.builder(
                  itemCount: snapshot.data!.last.docs.length,
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
              ] else ...[
                Center(
                  child: Text(
                    'Nothing here!',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ],
            ],
            if (!snapshot.hasData) ...[
              Center(
                child: const CircularProgressIndicator(),
              ),
            ],
          ],
        );
      },
    );
  }
}
