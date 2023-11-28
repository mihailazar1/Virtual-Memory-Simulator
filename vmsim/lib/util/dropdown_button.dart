import "package:flutter/material.dart";

class DropdownBtn extends StatefulWidget {
  DropdownBtn({super.key});

  @override
  State<DropdownBtn> createState() => _DropdownBtnState();
}

class _DropdownBtnState extends State<DropdownBtn> {
  String chosenAlgorithm = 'LRU';
  List<String> replAlgorithms = <String>['LRU', 'FIFO', 'RANDOM'];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: chosenAlgorithm,
      onChanged: (String? newValue) {
        setState(() {
          chosenAlgorithm = newValue!;
        });
      },
      items: replAlgorithms.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
      dropdownColor: Colors.deepPurple[300],
    );
  }
}
