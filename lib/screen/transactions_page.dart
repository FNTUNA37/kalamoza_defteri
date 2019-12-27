import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _formKey = GlobalKey<FormState>();

  String _cardId;
  String _userId;
  String _amount;

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.currentUser().then((user) {
      _userId = user.uid;
    });
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton.extended(
              onPressed: () {
                Alert(
                  context: context,
                  title: 'Add Receivable',
                  content: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        StreamBuilder<QuerySnapshot>(
                            stream: Firestore.instance
                                .collection('cards')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return const Text('Loading...');
                              return DropdownButton(
                                items: snapshot.data.documents
                                    .map((DocumentSnapshot document) {
                                  if (document.data['userId'] == _userId) {
                                    return DropdownMenuItem(
                                      value: document.documentID,
                                      child: Text(
                                        document.data['name'],
                                      ),
                                    );
                                  } else if (document.data['userId'] !=
                                      _userId) {
                                    return DropdownMenuItem(
                                      child: Text(document['name']),
                                    );
                                  } else {
                                    return DropdownMenuItem(
                                      value: null,
                                      child: Text('Kartr Ekleyin'),
                                    );
                                  }
                                }).toList(),
                                onChanged: (select) {
                                  setState(() {
                                    print(select);
                                    _cardId = select;
                                  });
                                },
                                icon: Icon(Icons.folder_shared),
                              );
                            }),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            icon: Icon(Icons.monetization_on),
                          ),
                          onSaved: (value) {
                            return _amount = value;
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
                            .collection('transactions')
                            .document()
                            .setData({
                          'CardId': _cardId,
                          'UserId': _userId,
                          'Type': 'Receivable',
                          'Amount': _amount
                        });
                      },
                    )
                  ],
                ).show();
              },
              label: Text('Add Receivable'),
              icon: Icon(Icons.attach_money),
            ),
            FloatingActionButton.extended(
              onPressed: () {},
              label: Text('Add Debt'),
              icon: Icon(Icons.money_off),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            StreamBuilder(
              stream: Firestore.instance.collection('transactions').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
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
        )
      ],
    );
  }

  List<Widget> cardList(AsyncSnapshot snapshot, String userId) {
    return snapshot.data.documents.map<Widget>((document) {
      if (document['UserId'] == userId) {
        return Container(
          //Todo: Style taşınacak
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 4.0),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        document['Type'],
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.w600,
                          decorationColor: Colors.green,
                          color: Colors.green,
                        ),
                      ),
                      Text(document['UserId']),
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
