import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:kalamoza_defteri/utilities/transactionsList.dart';
import 'package:toast/toast.dart';
import 'package:kalamoza_defteri/utilities/constants.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _formKey = GlobalKey<FormState>();

  String _cardId;
  String _userId;
  String _amount;

  DateTime dateTime;
  @override
  void initState() {
    dateTime = DateTime.now();
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
                  content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Form(
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
                                    hint: Text('Select Card'),
                                    value: _cardId,
                                    onChanged: (String select) {
                                      setState(() {
                                        print(select);
                                        _cardId = select;
                                      });
                                    },
                                    items: snapshot.data.documents
                                        .map((DocumentSnapshot document) {
                                      return DropdownMenuItem(
                                        value: document.documentID,
                                        child: Text(
                                          document.data['name'],
                                        ),
                                      );
                                    }).toList(),
                                    icon: Icon(Icons.folder_shared),
                                  );
                                }),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              validator: (input) {
                                final isDigitsOnly = int.tryParse(input);
                                return isDigitsOnly == null
                                    ? 'Input needs to be digits only'
                                    : null;
                              },
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
                      );
                    },
                  ),
                  buttons: [
                    DialogButton(
                      child: Text(
                        'ADD',
                        style: kCardPageAlertAddTextStyle,
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                        }
                        _cardId != null && _amount != null
                            ? setState(() {
                                Navigator.pop(context);

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
                                _cardId = null;
                                _amount = null;
                              })
                            : Toast.show("Please enter a valid value.", context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.TOP);
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
                  content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Form(
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
                                    value: _cardId,
                                    hint: Text('Select Card'),
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
                              keyboardType: TextInputType.number,
                              validator: (input) {
                                final isDigitsOnly = int.tryParse(input);
                                return isDigitsOnly == null
                                    ? 'Input needs to be digits only'
                                    : null;
                              },
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
                      );
                    },
                  ),
                  buttons: [
                    DialogButton(
                      child: Text(
                        'ADD',
                        style: kCardPageAlertAddTextStyle,
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                        }

                        _cardId != null && _amount != null
                            ? setState(() {
                                Navigator.pop(context);

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
                                _cardId = null;
                                _amount = null;
                              })
                            : Toast.show("Please enter a valid value.", context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.TOP);
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
        SizedBox(
          height: 20.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton.extended(
              backgroundColor: Colors.green,
              icon: Icon(Icons.date_range),
              label: Text(
                  dateTime.year.toString() + '-' + dateTime.month.toString()),
              onPressed: () {
                showMonthPicker(context: context, initialDate: DateTime.now())
                    .then((value) {
                  setState(() {
                    value != null
                        ? dateTime = value
                        : dateTime = DateTime.now();
                  });
                });
              },
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
                        children: transactionsList(
                            snapshot, dateTime, context, setState),
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
}
