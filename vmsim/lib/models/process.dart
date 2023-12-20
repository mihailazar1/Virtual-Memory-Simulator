import 'dart:collection';
import 'dart:math';

import 'package:vmsim/models/page_table.dart';
import 'package:vmsim/models/virtual_address.dart';

class Process {
  int offsetBits;
  int virtualSize;
  int numberVirtualAddr;
  int processNumber;
  late PageTable pageTable;
  late List<VirtualAddress> va;

  Process(
      {required this.offsetBits,
      required this.virtualSize,
      required this.numberVirtualAddr,
      required this.processNumber}) {
    pageTable = PageTable(offsetBits: offsetBits, virtualSize: virtualSize);

    generateVirtualAddr();
  }

  void generateVirtualAddr() {
    int instrLen = log(virtualSize) ~/ log(2);
    int pageBitsLen = instrLen - offsetBits;

    Random random = Random();

    if (processNumber == 1) {
      va = [
        VirtualAddress(p: 6, d: 2, executed: false),
        VirtualAddress(p: 11, d: 0, executed: false),
        VirtualAddress(p: 9, d: 0, executed: false),
        VirtualAddress(p: 9, d: 2, executed: false),
        VirtualAddress(p: 7, d: 1, executed: false),
        VirtualAddress(p: 6, d: 3, executed: false),
        VirtualAddress(p: 14, d: 2, executed: false),
        VirtualAddress(p: 4, d: 2, executed: false),
        VirtualAddress(p: 1, d: 3, executed: false),
        VirtualAddress(p: 8, d: 2, executed: false),
        VirtualAddress(p: 5, d: 2, executed: false),
        VirtualAddress(p: 11, d: 2, executed: false),
        VirtualAddress(p: 10, d: 0, executed: false),
        VirtualAddress(p: 10, d: 1, executed: false),
        VirtualAddress(p: 5, d: 3, executed: false),
        VirtualAddress(p: 15, d: 0, executed: false),
        VirtualAddress(p: 9, d: 0, executed: false),
        VirtualAddress(p: 4, d: 0, executed: false),
      ];
    } else if (processNumber == 0) {
      va = [
        VirtualAddress(p: 1, d: 2, executed: false),
        VirtualAddress(p: 3, d: 2, executed: false),
        VirtualAddress(p: 2, d: 0, executed: false),
        VirtualAddress(p: 13, d: 1, executed: false),
        VirtualAddress(p: 4, d: 2, executed: false),
        VirtualAddress(p: 6, d: 0, executed: false),
        VirtualAddress(p: 9, d: 2, executed: false),
        VirtualAddress(p: 5, d: 3, executed: false),
        VirtualAddress(p: 10, d: 2, executed: false),
        VirtualAddress(p: 5, d: 1, executed: false),
        VirtualAddress(p: 15, d: 1, executed: false),
        VirtualAddress(p: 1, d: 0, executed: false),
        VirtualAddress(p: 4, d: 1, executed: false),
        VirtualAddress(p: 4, d: 0, executed: false),
        VirtualAddress(p: 6, d: 0, executed: false),
        VirtualAddress(p: 3, d: 2, executed: false),
        VirtualAddress(p: 15, d: 0, executed: false),
        VirtualAddress(p: 13, d: 2, executed: false),
      ];
    }

    /*
    List<VirtualAddress>.generate(
      this.numberVirtualAddr,
      (index) => VirtualAddress(
        p: random.nextInt(pow(2, pageBitsLen).toInt()),
        d: random.nextInt(pow(2, offsetBits).toInt()),
        executed: false,
      ),
    );
    
    */
  }
}
