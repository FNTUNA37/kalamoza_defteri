import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kalamoza_defteri/utilities/transactionsList.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:kalamoza_defteri/utilities/cardStreamBuilder.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _userId;
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
        Container(
          height: 200,
          child: PageView(
            controller: PageController(viewportFraction: 0.9),
            scrollDirection: Axis.horizontal,
            pageSnapping: true,
            children: <Widget>[
              CardStreamBuilder(
                userId: _userId,
                dateTime: dateTime,
                totalBalance: false,
                cardColor: Colors.blue,
                cardName: 'Total Receivable',
                stream: Firestore.instance
                    .collection('transactions')
                    .where('UserId', isEqualTo: _userId)
                    .where('Type', isEqualTo: 'Receivable')
                    .snapshots(),
              ),
              CardStreamBuilder(
                userId: _userId,
                dateTime: dateTime,
                totalBalance: false,
                cardColor: Colors.red,
                cardName: 'Total Debt',
                stream: Firestore.instance
                    .collection('transactions')
                    .where('UserId', isEqualTo: _userId)
                    .where('Type', isEqualTo: 'Debt')
                    .snapshots(),
              ),
              CardStreamBuilder(
                userId: _userId,
                dateTime: dateTime,
                totalBalance: true,
                cardColor: Colors.green,
                cardName: 'Total Balance',
                stream: Firestore.instance
                    .collection('transactions')
                    .where('UserId', isEqualTo: _userId)
                    .snapshots(),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton.extended(
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
            )
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
