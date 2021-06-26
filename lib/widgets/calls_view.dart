import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/widgets/call_card.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// This widget represents the content on the main screen of the app
class CallsView extends StatefulWidget {
  const CallsView({
    Key? key,
  }) : super(key: key);

  @override
  _CallsViewState createState() => _CallsViewState();
}

class _CallsViewState extends State<CallsView> with FirebaseMixin {
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
        return MobileCallsView(
          snapshot: snapshot,
        );
      },
    );
  }
}

class MobileCallsView extends StatefulWidget {
  const MobileCallsView({
    Key? key,
    required this.snapshot,
  }) : super(key: key);

  final AsyncSnapshot<List<FirestoreDocument>> snapshot;

  @override
  _MobileCallsViewState createState() => _MobileCallsViewState();
}

class _MobileCallsViewState extends State<MobileCallsView>
    with SingleTickerProviderStateMixin {
  late final tabController = TabController(length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [
        // ignore: unnecessary_null_comparison
        if (!widget.snapshot.hasData) ...[
          const Center(
            child: CircularProgressIndicator(),
          ),
        ] else ...[
          if (widget.snapshot.data!.first.docs.isNotEmpty) ...[
            _CallsList(
              calls: widget.snapshot.data!.first.docs,
            ),
          ] else ...[
            Center(
              child: Text(
                'Tap "Add Call" to get started!',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ],
          if (widget.snapshot.data!.last.docs.isNotEmpty) ...[
            _CallsList(
              calls: widget.snapshot.data!.last.docs,
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
        if (!widget.snapshot.hasData) ...[
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ],
    );
  }
}

class _CallsList extends StatelessWidget {
  const _CallsList({
    Key? key,
    required this.calls,
  }) : super(key: key);

  final List<QueryDocumentSnapshot> calls;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = Call.fromJsonWithDocId(
          calls[index].data() as Map<String, dynamic>,
          calls[index].id,
        );

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: CallCard(
            call: call,
          ),
        );
      },
    );
  }
}
