import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kalamoza_defteri/transactionsList.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:toast/toast.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _userId;
  DateTime dateTime = DateTime.now();
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
        Container(
          height: 200,
          child: PageView(
            controller: PageController(viewportFraction: 0.9),
            scrollDirection: Axis.horizontal,
            pageSnapping: true,
            children: <Widget>[
              StreamBuilder(
                  stream: Firestore.instance
                      .collection('transactions')
                      .where('UserId', isEqualTo: _userId)
                      .where('Type', isEqualTo: 'Receivable')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        int totalReceivable = 0;
                        snapshot.data.documents.map((doc) {
                          var parsedDate = DateTime.parse(doc['Date']);
                          if (parsedDate.month == dateTime.month &&
                              parsedDate.year == dateTime.year)
                            totalReceivable += int.parse(doc['Amount']);
                        }).toString();
                        return CardContainer(
                            color: Colors.blue,
                            description: 'total receivable',
                            userId: _userId,
                            amount: totalReceivable);
                    }
                  }),
              StreamBuilder(
                  stream: Firestore.instance
                      .collection('transactions')
                      .where('UserId', isEqualTo: _userId)
                      .where('Type', isEqualTo: 'Debt')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        int totalDebt = 0;
                        snapshot.data.documents.map((doc) {
                          var parsedDate = DateTime.parse(doc['Date']);
                          if (parsedDate.month == dateTime.month &&
                              parsedDate.year == dateTime.year)
                            totalDebt += int.parse(doc['Amount']);
                        }).toString();
                        return CardContainer(
                          color: Colors.red,
                          description: 'total debt',
                          amount: totalDebt,
                        );
                    }
                  }),
              StreamBuilder(
                  stream: Firestore.instance
                      .collection('transactions')
                      .where('UserId', isEqualTo: _userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        int totalBalance = 0;
                        snapshot.data.documents.map((doc) {
                          var parsedDate = DateTime.parse(doc['Date']);
                          if (parsedDate.month == dateTime.month &&
                              parsedDate.year == dateTime.year) {
                            if (doc['Type'] == 'Receivable')
                              totalBalance += int.parse(doc['Amount']);
                            else
                              totalBalance -= int.parse(doc['Amount']);
                          }
                        }).toString();
                        return CardContainer(
                          color: Colors.green,
                          description: 'total balance',
                          amount: totalBalance,
                        );
                    }
                  }),
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

//TODO:Taşınıcak
class CardContainer extends StatelessWidget {
  CardContainer({this.color, this.description, this.userId, this.amount});

  final Color color;
  final String description;
  final int amount;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(top: 80.0, left: 100.0, bottom: 20.0),
            child: Text(
              amount.toString() + ' ₺',
              style: TextStyle(
                  fontSize: 35.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 26.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(20.0)),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 100,
    );
  }
}
