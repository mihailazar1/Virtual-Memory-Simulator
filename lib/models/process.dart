// ignore_for_file: unnecessary_this

import 'dart:collection';
import 'dart:math';
import 'package:virtualmemory/models/page_table.dart';
import 'package:virtualmemory/models/virtual_address.dart';

class Process {
  int offsetBits;
  int virtualSize;
  int noVirtualAddr;
  PageTable? pt;
  List<VirtualAddress>? va;

  Process(
      {required this.offsetBits,
      required this.virtualSize,
      required this.noVirtualAddr}) {
    pt = PageTable(offsetBits: offsetBits, virtualSize: virtualSize);
    generateVirtualAddr();
  }

  void generateVirtualAddr() {
    int instrLen = log(virtualSize) ~/ log(2);
    int pageBitsLen = instrLen - offsetBits;

    Random random = Random();

    va = List<VirtualAddress>.filled(
        this.noVirtualAddr,
        VirtualAddress(
            p: random.nextInt(pow(2, pageBitsLen).toInt()),
            d: random.nextInt(pow(2, offsetBits).toInt())));
  }
}