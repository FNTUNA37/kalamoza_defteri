import 'package:flutter/material.dart';
import 'package:kalamoza_defteri/utilities/cardContainer.dart';

class CardStreamBuilder extends StatelessWidget {
  CardStreamBuilder({
    this.userId,
    this.dateTime,
    this.stream,
    this.totalBalance,
    this.cardName,
    this.cardColor,
  });

  final String userId;
  final DateTime dateTime;
  final Stream stream;
  final bool totalBalance;
  final String cardName;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              int total = 0;
              snapshot.data.documents.map((doc) {
                var parsedDate = DateTime.parse(doc['Date']);
                if (parsedDate.month == dateTime.month &&
                    parsedDate.year == dateTime.year) {
                  if (totalBalance) {
                    if (doc['Type'] == 'Receivable')
                      total += int.parse(doc['Amount']);
                    else
                      total -= int.parse(doc['Amount']);
                  } else {
                    total += int.parse(doc['Amount']);
                  }
                }
              }).toString();
              return CardContainer(
                  color: cardColor,
                  description: cardName,
                  userId: userId,
                  amount: total);
          }
        });
  }
}
