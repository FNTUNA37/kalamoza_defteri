import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kalamoza_defteri/screen/card_detail_page.dart';

class CardPage extends StatefulWidget {
  @override
  _CardPageState createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final _formKey = GlobalKey<FormState>();
  Color color;
  String _userId;
  String _cardName;
  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.currentUser().then((user) {
      _userId = user.uid;
    });
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton.extended(
              splashColor: Colors.pink,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                  ),
                                  validator: (value) {
                                    return value.isEmpty
                                        ? 'Email is required'
                                        : null;
                                  },
                                  onSaved: (value) {
                                    return _cardName = value;
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RaisedButton(
                                  child: Text("Add"),
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();
                                    }
                                    Firestore.instance
                                        .collection('cards')
                                        .document()
                                        .setData({
                                      'name': _cardName,
                                      'userId': _userId
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    });
              },
              icon: Icon(Icons.add_circle),
              label: Text('Card Add'),
              backgroundColor: Colors.red,
            )
          ],
        ),
        StreamBuilder(
          stream: Firestore.instance.collection('cards').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                return ListView(
                  shrinkWrap: true,
                  children: cardList(snapshot, _userId),
                );
            }
          },
        ),
      ],
    );
  }
}

List<Widget> cardList(AsyncSnapshot snapshot, String userId) {
  return snapshot.data.documents.map<Widget>((document) {
    if (document['userId'] == userId) {
      return Container(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 4.0),
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: InkWell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      document['name'],
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.w600,
                        decorationColor: Colors.green,
                        color: Colors.green,
                      ),
                    ),
                    Text('')
                  ],
                ),
                onTap: () {
                  showDialog(
                      //context: context,
                      builder: (BuildContext context) {
                    return CardDetailPage();
                  });
                  print(document['name']);
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        child: Center(
          child: Text('Kart yok '),
        ),
      );
    }
  }).toList();
}
