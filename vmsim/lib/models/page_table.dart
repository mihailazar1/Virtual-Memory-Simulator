import 'dart:math';

class PageTable {
  int offsetBits;
  int virtualSize;
  List<int>? pages;
  late int length;

  PageTable({required this.offsetBits, required this.virtualSize}) {
    length = virtualSize ~/ pow(2, offsetBits).toInt();
    Random random = Random();
    pages = List<int>.filled(length, random.nextInt(100));
  }

  void setPageTableEntry(int pageNumber, int frameNumber) {
    pages?[pageNumber] = frameNumber;
  }

  int getPageTableEntry(int pageNumber) {
    return pages![pageNumber];
  }
}
