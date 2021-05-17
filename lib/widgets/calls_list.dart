import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/widgets/call_card.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// This widget represents the content on the main screen of the app
class CallsList extends StatefulWidget {
  @override
  _CallsListState createState() => _CallsListState();
}

class _CallsListState extends State<CallsList> with FirebaseMixin {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: firestore.calls(currentUser!.uid).snapshots(),
      builder: (
        context,
        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      ) {
        if (!snapshot.hasData) {
          return Center(
            child: const CircularProgressIndicator(),
          );
        } else {
          if (snapshot.data!.docs.length > 0) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final call = Call.fromJsonWithDocId(
                  snapshot.data!.docs[index].data(),
                  snapshot.data!.docs[index].id,
                );

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CallCard(
                    call: call,
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text(
                'Nothing here!',
                style: Theme.of(context).textTheme.headline6,
              ),
            );
          }
        }
      },
    );
  }
}
