// ignore_for_file: unnecessary_this

import 'dart:math';

class PageTable {
  int offsetBits;
  int virtualSize;
  int lastToColor = -1;
  late List<int> pages;
  late List<int> validInvalid;
  late int length;

  PageTable({required this.offsetBits, required this.virtualSize}) {
    length = virtualSize ~/ pow(2, offsetBits).toInt();
    pages = List<int>.filled(length, -1);
    validInvalid = List<int>.filled(length, 0);
  }

  void setPageTableEntry(int pageNumber, int frameNumber) {
    pages[pageNumber] = frameNumber;
    this.lastToColor = pageNumber;
  }

  bool isValid(int pageNumber) {
    if (validInvalid[pageNumber] == 0) return false;
    return true;
  }
}
