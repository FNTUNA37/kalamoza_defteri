import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kalamoza_defteri/api.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _formKey = GlobalKey<FormState>();
  Api cardApi = Api('cards');
  Api transactionsApi = Api('transactions');
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
                            stream: cardApi.streamDataCollection(),
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
                                      child: Text('Kart Ekleyin'),
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
                    //Todo:Kod tekrarı var yeni widget oluşturup başka yere taşı
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
              onPressed: () {
                Alert(
                  context: context,
                  title: 'Add Debt',
                  content: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        StreamBuilder<QuerySnapshot>(
                            stream: cardApi.streamDataCollection(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return const Text('Loading...');
                              return DropdownButton(
                                items: snapshot.data.documents
                                    .map((DocumentSnapshot document) {
                                  //todo:Tüm kullanıcıların kartını listeliyo düzelt
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
                          'Type': 'Debt',
                          'Amount': _amount
                        });
                      },
                    )
                  ],
                ).show();
              },
              label: Text('Add Debt'),
              icon: Icon(Icons.money_off),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            StreamBuilder(
              stream: transactionsApi.streamDataCollection(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return new Text('Loading...');
                  default:
                    return ListView(
                      shrinkWrap: true,
                      children: transactionsList(snapshot, _userId),
                    );
                }
              },
            ),
          ],
        )
      ],
    );
  }

//Todo:Taşınacak
  List<Widget> transactionsList(AsyncSnapshot snapshot, String userId) {
    return snapshot.data.documents.map<Widget>((document) {
      if (document['UserId'] == userId) {
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          document['CardId'],
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          document['Amount'],
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: document['Type'] == 'Receivable'
                                  ? Colors.green
                                  : Colors.red),
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
                                  document['UserId'],
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
      } else if (document['UserId'] != userId) {
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
