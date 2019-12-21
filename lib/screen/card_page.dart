import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kalamoza_defteri/authentication.dart';

class CardPage extends StatefulWidget {
  @override
  _CardPageState createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  BaseAuth auth = Auth();

  @override
  Widget build(BuildContext context) {
    print(auth.getUser());
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance.collection('cards').snapshots(),
        builder: (context, snapshot) {
          return ListView(
            shrinkWrap: true,
            children: list(snapshot, auth),
          );
        },
      ),
    );
  }
}

List<Widget> list(AsyncSnapshot snapshot, BaseAuth auth) {
  return snapshot.data.documents.map<Widget>((document) {
    // if (document['UserId'] == auth.getUser()) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(document['UserId']),
        ],
      ),
    );
    // } else {
    //  return Container();
    // }
  }).toList();
}
