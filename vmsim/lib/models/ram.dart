import 'dart:math';

import 'package:vmsim/models/ram_row.dart';

class Ram {
  int offsetBits;
  int physicalSize;
  List<RamRow> memoryRows = [];
  late int ramLength;

  Ram({required this.offsetBits, required this.physicalSize}) {
    ramLength = physicalSize ~/ pow(2, offsetBits);
    memoryRows =
        List.generate(ramLength, (index) => RamRow(data: 0, processNumber: -1));
  }

  void setRamEntry(int frameNumber, int data, int processNumber) {
    memoryRows[frameNumber] = RamRow(data: data, processNumber: processNumber);
  }

  RamRow getRamEntry(int frameNumber) {
    return memoryRows[frameNumber];
  }
}
