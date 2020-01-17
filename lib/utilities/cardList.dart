import 'package:flutter/material.dart';
import 'package:kalamoza_defteri/utilities/constants.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void delete(String data) {}

List<Widget> cardList(
    BuildContext context, AsyncSnapshot snapshot, String userId, setState) {
  return snapshot.data.documents.map<Widget>((document) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26, width: 3.0),
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: InkWell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      document['name'],
                      style: kCardListNameTextStyle,
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
                            Text('Card Name: ',
                                style: kAlertDescriptionTextStyle),
                            Text(
                              document['name'],
                              style: kAlertDescriptionValueTextStyle,
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'Description: ',
                              style: kAlertDescriptionTextStyle,
                            ),
                            Text(
                              document['description'],
                              style: kAlertDescriptionValueTextStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                    style: AlertStyle(backgroundColor: Colors.white60),
                    buttons: [
                      DialogButton(
                        child: Text('CANCEL', style: kAlertButtonTextStyle),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.red,
                      ),
                      /*DialogButton(
                        child: Text(
                          'DEL',
                          style: kAlertButtonTextStyle,
                        ),
                        onPressed: () {
                          Firestore.instance
                              .collection('transactions')
                              .document()
                              .snapshots()
                              .map((data) {
                            data['CardId'] == document.documentID
                                ? Firestore.instance
                                    .collection('transactions')
                                    .document(data.documentID)
                                    .delete()
                                : null;
                            setState(() {
                              //todo: Sadece kartı siliyo işlem tablosundan karta ait işlemleride sil
                              Firestore.instance
                                  .collection('cards')
                                  .document(document.documentID)
                                  .delete();
                            });
                            Navigator.pop(context);
                          });
                        },
                      ),*/
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
