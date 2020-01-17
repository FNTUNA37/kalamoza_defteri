import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:kalamoza_defteri/utilities/constants.dart';
import 'package:kalamoza_defteri/utilities/cardList.dart';

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
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        _userId = user.uid;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton.extended(
              splashColor: Colors.pink,
              onPressed: () {
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
                      child: Text('ADD', style: kCardPageAlertAddTextStyle),
                      onPressed: () {
                        setState(() {
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
                        });
                      },
                    ),
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
          stream: Firestore.instance
              .collection('cards')
              .where('userId', isEqualTo: _userId)
              .orderBy('name', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                return ListView(
                  shrinkWrap: true,
                  children: cardList(context, snapshot, _userId, setState),
                );
            }
          },
        ),
      ],
    );
  }
}
