import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CardPage extends StatefulWidget {
  @override
  _CardPageState createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final _formKey = GlobalKey<FormState>();
  Color color;
  String _userId;
  String _description;
  String _cardName;

  @override
  Widget build(BuildContext context) {
    //TODO: Ayrı bi yere al sonra kullanırsın
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
                //Todo: Taşınacak
                Alert(
                  context: context,
                  title: 'Add Card',
                  content: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Name',
                            icon: Icon(Icons.folder_shared),
                          ),
                          onSaved: (value) {
                            return _cardName = value;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Description',
                            icon: Icon(Icons.folder_shared),
                          ),
                          onSaved: (value) {
                            return _description = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  buttons: [
                    DialogButton(
                      //Todo: Style taşınacak
                      child: Text(
                        'ADD',
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                        }
                        Firestore.instance
                            .collection('cards')
                            .document()
                            .setData({
                          'name': _cardName,
                          'userId': _userId,
                          'description': _description
                        });
                      },
                    )
                  ],
                ).show();
              },
              icon: Icon(Icons.add_circle),
              label: Text('Add Card'),
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

//Todo: başka yere taşı
  List<Widget> cardList(AsyncSnapshot snapshot, String userId) {
    return snapshot.data.documents.map<Widget>((document) {
      if (document['userId'] == userId) {
        return Container(
          //Todo: Style taşınacak
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 3.0),
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: InkWell(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          document['name'],
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w600,
                            decorationColor: Colors.green,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    onTap: () {
                      Alert(
                        context: context,
                        title: 'Description',
                        content: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  'Card Name: ',
                                  style: TextStyle(
                                      color: Colors.black38,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  document['name'],
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  'Description: ',
                                  style: TextStyle(
                                      color: Colors.black38,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  document['description'],
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                        style: AlertStyle(backgroundColor: Colors.white60),
                        buttons: [
                          DialogButton(
                            child: Text('CANCEL',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16.0)),
                            onPressed: () => Navigator.pop(context),
                            color: Colors.red,
                          ),
                        ],
                      ).show();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (document['userıd'] != userId) {
        return Container();
      } else {
        return Container(
          child: Center(
            child: Text('No card, click Add Card to add '),
          ),
        );
      }
    }).toList();
  }
}
