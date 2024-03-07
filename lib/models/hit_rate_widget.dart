import "package:flutter/material.dart";

class HitRateText extends StatelessWidget {
  final int number;
  final int executedInstr;
  final String text;

  const HitRateText(
      {Key? key,
      required this.number,
      required this.executedInstr,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (executedInstr > 0) {
      final rate = (number * 100 / executedInstr).round();
      return Text(
        '$text$rate%',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return Text(
        '${text} 0%',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
}
