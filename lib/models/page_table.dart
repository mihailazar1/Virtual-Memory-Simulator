import 'dart:math';

class PageTable {
  int offsetBits;
  int virtualSize;
  List<int>? pages;

  PageTable({required this.offsetBits, required this.virtualSize}) {
    pages = List<int>.filled(virtualSize ~/ pow(2, offsetBits).toInt(), -1);
  }

  void setPageTableEntry(int pageNumber, int frameNumber) {
    pages?[pageNumber] = frameNumber;
  }

  int getPageTableEntry(int pageNumber) {
    return pages![pageNumber];
  }
}
