import 'dart:math';

class Ram {
  int offsetBits;
  int physicalSize;
  List<int>? memory;
  late int ramLength;

  Ram({required this.offsetBits, required this.physicalSize}) {
    ramLength = physicalSize ~/ pow(2, offsetBits);
    memory = List<int>.filled(ramLength, 0);
  }

  void setRamEntry(int frameNumber, int data) {
    memory?[frameNumber] = data;
  }

  int getRamEntry(int frameNumber) {
    return memory![frameNumber];
  }
}
