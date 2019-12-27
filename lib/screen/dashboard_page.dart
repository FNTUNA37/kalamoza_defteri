import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
              CardContainer(
                color: Colors.blue,
                description: 'total receivable',
              ),
              CardContainer(
                color: Colors.red,
                description: 'total debt',
              ),
              CardContainer(
                color: Colors.green,
                description: 'total balance',
              ),
            ],
          ),
        ),
        StreamBuilder(
          stream: Firestore.instance.collection('transactions').snapshots(),
          builder: (context, snapshot) {
            return ListView(
              shrinkWrap: true,
              children: list(snapshot),
            );
          },
        ),
      ],
    );
  }

  List<Widget> list(AsyncSnapshot snapshot) {
    return snapshot.data.documents.map<Widget>((document) {
      return Container(
        child: Column(
          children: <Widget>[
            Text(document['Type']),
          ],
        ),
      );
    }).toList();
  }
}

//TODO:Taşınıcak
class CardContainer extends StatelessWidget {
  CardContainer({this.color, this.description, this.amount});

  final Color color;
  final String description;
  final int amount;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(top: 80.0, left: 100.0, bottom: 20.0),
            child: Text(
              amount.toString(),
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
