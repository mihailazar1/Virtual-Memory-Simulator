import 'dart:math';

import 'package:vmsim/models/ram_row.dart';

class Ram {
  int offsetBits;
  int physicalSize;
  List<RamRow> memoryRows = [];
  late int ramLength;

  Ram({required this.offsetBits, required this.physicalSize}) {
    ramLength = physicalSize ~/ pow(2, offsetBits);
    memoryRows = List.generate(ramLength,
        (index) => RamRow(data: '-', processNumber: -1, lastAccessTime: 0));
  }

  void setRamEntry(
      int frameNumber, String data, int processNumber, int currentTime) {
    memoryRows[frameNumber] = RamRow(
        data: data, processNumber: processNumber, lastAccessTime: currentTime);
  }

  int findFreeFrame() {
    for (int i = 0; i < ramLength; i++) {
      if (memoryRows[i].processNumber == -1) {
        return i;
      }
    }
    return -1;
  }

  RamRow getRamEntry(int frameNumber) {
    return memoryRows[frameNumber];
  }
}
