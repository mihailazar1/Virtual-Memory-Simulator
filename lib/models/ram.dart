import 'dart:math';

import 'package:vmsim/models/ram_row.dart';

class Ram {
  int offsetBits;
  int physicalSize;
  int lastToColor = -1; // for pretty print
  List<RamRow> memoryRows = [];
  late int ramLength;

  Ram({required this.offsetBits, required this.physicalSize}) {
    ramLength = physicalSize ~/ pow(2, offsetBits);
    memoryRows = List.generate(ramLength, (index) => RamRow(data: '-'));
  }

  RamRow getRamEntry(int frameNumber) {
    return memoryRows[frameNumber];
  }
}
