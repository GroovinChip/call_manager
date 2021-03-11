import 'package:call_manager/HomeScreen/call_card.dart';
import 'package:call_manager/firebase/firebase_mixin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:call_manager/globals.dart' as globals;

/// This widget represents the content on the main screen of the app
class CallCardList extends StatefulWidget {
  @override
  _CallCardListState createState() => _CallCardListState();
}

class _CallCardListState extends State<CallCardList> with FirebaseMixin {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('Users')
            .doc(currentUser.uid)
            .collection('Calls')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return Center(child: Text('Getting Calls...'));
          } else {
            if (snapshot.data.docs.length > 0) {
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  final ds = snapshot.data.docs[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CallCard(callSnapshot: ds),
                  );
                },
              );
            } else {
              return Center(
                child: Text('No calls'),
              );
            }
          }
        },
      ),
    );
  }
}
