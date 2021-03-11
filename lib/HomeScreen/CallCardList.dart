import 'package:call_manager/HomeScreen/call_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:call_manager/globals.dart' as globals;

/// This widget represents the content on the main screen of the app
class CallCardList extends StatefulWidget {
  @override
  _CallCardListState createState() => _CallCardListState();
}

class _CallCardListState extends State<CallCardList> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Users")
            .doc(globals.loggedInUser.uid)
            .collection("Calls").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return Center(child: Text("Getting Calls..."));
          } else {
            return snapshot.data.docs.length > 0
                ? Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Call Manager",
                        style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 15,
                  child: ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CallCard(callSnapshot: ds),
                      );
                    },
                  ),
                )
              ],
            )
                : Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Call Manager",
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 15,
                  child: Center(
                    child: Text("No calls"),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
