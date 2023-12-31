// ignore_for_file: unnecessary_this

import 'dart:collection';

import 'package:vmsim/models/process.dart';

class AllProcesses {
  int offsetBits;
  int virtualSize;
  int noProc;
  late HashMap<int, Process> allProc;

  AllProcesses(
      {required this.offsetBits,
      required this.virtualSize,
      required this.noProc}) {
    allProc = HashMap<int, Process>();
    generateProc();
  }

  void generateProc() {
    for (var i = 0; i < this.noProc; i++) {
      allProc[i] = Process(
          offsetBits: this.offsetBits,
          virtualSize: this.virtualSize,
          processNumber: i,
          numberVirtualAddr: 15);
    }
  }
}
