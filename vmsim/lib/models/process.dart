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

    va = List<VirtualAddress>.generate(
      this.numberVirtualAddr,
      (index) => VirtualAddress(
        p: random.nextInt(pow(2, pageBitsLen).toInt()),
        d: random.nextInt(pow(2, offsetBits).toInt()),
        executed: false,
      ),
    );
  }
}
