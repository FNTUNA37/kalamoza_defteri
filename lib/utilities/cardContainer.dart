import 'package:flutter/material.dart';
import 'package:kalamoza_defteri/utilities/constants.dart';

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
            padding: const EdgeInsets.only(top: 70.0, left: 90.0, bottom: 20.0),
            child: Text(amount.toString() + ' ₺',
                style: kCardContainerAmountTextStyle),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  description,
                  style: kCardContainerDescTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(20.0)),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      width: 100,
    );
  }
}
