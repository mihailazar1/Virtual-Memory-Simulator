import 'dart:math';

import 'package:vmsim/models/tlb_entry.dart';

class TLB {
  int length;
  int hit = -1;
  int nbHits = 0;
  int nbMiss = 0;
  int processedAddr = 0;
  late List<TLBEntry> entries = [];

  TLB({required this.length}) {
    entries = List.generate(
        length,
        (index) => TLBEntry(
            virtualPage: -1, physicalPage: -1, valid: 0, pid: -1, empty: 1));
  }

  void addTLBEntry(int pageNumber, int frameNumber, int processNumber) {
    // assumes that the entry is not already in the tlb

    bool found = false;

    for (int i = 0; i < entries.length; i++) {
      if (entries[i].empty == 1) {
        justAdd(i, pageNumber, frameNumber, processNumber);
        found = true;
        break;
      }
    }

    if (found == false) {
      var random = Random();

      int entryToReplace = random.nextInt(this.length);
      justAdd(entryToReplace, pageNumber, frameNumber, processNumber);
    }
  }

  void justAdd(int index, int pageNumber, int frameNumber, int processNumber) {
    entries[index].virtualPage = pageNumber;
    entries[index].physicalPage = frameNumber;
    entries[index].valid = 1;
    entries[index].pid = processNumber;
    entries[index].empty = 0;
  }
}
