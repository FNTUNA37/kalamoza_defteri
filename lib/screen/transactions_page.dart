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
                                .where('userId', isEqualTo: _userId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return const Text('Loading...');
                              return DropdownButton(
                                items: snapshot.data.documents
                                    .map((DocumentSnapshot document) {
                                  return DropdownMenuItem(
                                    value: document.documentID,
                                    child: Text(
                                      document.data['name'],
                                    ),
                                  );
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
                        setState(() {
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
                            'Amount': _amount,
                            'Date': DateTime.now().toString(),
                          });
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
                            stream: Firestore.instance
                                .collection('cards')
                                .where('userId', isEqualTo: _userId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return const Text('Loading...');
                              return DropdownButton(
                                items: snapshot.data.documents
                                    .map((DocumentSnapshot document) {
                                  return DropdownMenuItem(
                                    value: document.documentID,
                                    child: Text(
                                      document.data['name'],
                                    ),
                                  );
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
                        setState(() {
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
                            'Amount': _amount,
                            'Date': DateTime.now().toString(),
                          });
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
        Container(
          height: 600.0,
          child: PageView(
            controller: PageController(viewportFraction: 1),
            scrollDirection: Axis.vertical,
            pageSnapping: true,
            children: <Widget>[
              StreamBuilder(
                stream: Firestore.instance
                    .collection('transactions')
                    .where('UserId', isEqualTo: _userId)
                    .orderBy('Date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                    default:
                      return ListView(
                        shrinkWrap: true,
                        children: transactionsList(snapshot),
                      );
                  }
                },
              ),
            ],
          ),
        )
      ],
    );
  }

//Todo:Taşınacak
  List<Widget> transactionsList(AsyncSnapshot snapshot) {
    return snapshot.data.documents.map<Widget>((document) {
      return Container(
        //Todo: Style taşınacak
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26, width: 3.0),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      StreamBuilder(
                          stream: Firestore.instance
                              .collection('cards')
                              .document(document['CardId'])
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError)
                              return new Text('Error: ${snapshot.error}');
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return Center(
                                    child: CircularProgressIndicator());
                              default:
                                var doc = snapshot.data;
                                return Text(
                                  doc['name'],
                                  style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.bold),
                                );
                            }
                          }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            document['Date'].substring(0, 16),
                            style: TextStyle(fontSize: 15.0),
                          ),
                          Text(
                            document['Amount'] + '₺',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: document['Type'] == 'Receivable'
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 20.0),
                          ),
                        ],
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
                              //Todo: kod tekrarı var
                              StreamBuilder(
                                stream: Firestore.instance
                                    .collection('cards')
                                    .document(document['CardId'])
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    Text('Loading...');
                                  }
                                  var doc = snapshot.data;
                                  return Text(
                                    doc['name'],
                                    style: TextStyle(
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold),
                                  );
                                },
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
                              StreamBuilder(
                                stream: Firestore.instance
                                    .collection('cards')
                                    .document(document['CardId'])
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    Text('Loading...');
                                  }
                                  var doc = snapshot.data;
                                  return Text(
                                    doc['description'],
                                    style: TextStyle(
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold),
                                  );
                                },
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
                        DialogButton(
                          child: Text(
                            'DEL',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
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
    }).toList();
  }
}
