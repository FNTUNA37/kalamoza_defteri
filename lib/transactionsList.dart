import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

List<Widget> transactionsList(
    AsyncSnapshot snapshot, DateTime dateTime, BuildContext context, setState) {
  return snapshot.data.documents.map<Widget>((document) {
    var parsedDate = DateTime.parse(document['Date']);

    return Container(
      //Todo: Style taşınacak
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: parsedDate.month == dateTime.month &&
                    parsedDate.year == dateTime.year
                ? Container(
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
                                  Text(
                                    document['Type'],
                                    style: TextStyle(
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    'Amount: ',
                                    style: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    document['Amount'] + ' ₺',
                                    style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.bold,
                                      color: document['Type'] == 'Receivable'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    'Date: ',
                                    style: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    document['Date'].substring(0, 16),
                                    style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16.0),
                                ),
                                onPressed: () {
                                  setState(() {
                                    Firestore.instance
                                        .collection('transactions')
                                        .document(document.documentID)
                                        .delete();
                                    Navigator.pop(context);
                                  });
                                }),
                          ],
                        ).show();
                      },
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }).toList();
}
