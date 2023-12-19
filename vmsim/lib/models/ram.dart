import 'dart:math';

import 'package:vmsim/models/ram_row.dart';

class Ram {
  int offsetBits;
  int physicalSize;
  int lastToColor = -1;
  List<RamRow> memoryRows = [];
  late int ramLength;

  Ram({required this.offsetBits, required this.physicalSize}) {
    ramLength = physicalSize ~/ pow(2, offsetBits);
    memoryRows = List.generate(ramLength, (index) => RamRow(data: '-'));
  }

/*
  int findFreeFrame() {
    for (int i = 0; i < ramLength; i++) {
      if (memoryRows[i].processNumber == -1) {
        return i;
      }
    }
    return -1;
  }
*/

  void setRamEntry(int frameNumber, String data, int processNumber,
      int pageNumber, int currentTime) {
    memoryRows[frameNumber] = RamRow(data: data);
    // processNumber: processNumber,
    // pageNumber: pageNumber,
    //  lastAccessTime: currentTime);
  }

  RamRow getRamEntry(int frameNumber) {
    return memoryRows[frameNumber];
  }
}
