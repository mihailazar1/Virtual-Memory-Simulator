class VirtualAddress {
  int p; // page number
  int d; // offset
  bool executed;

  VirtualAddress({required this.p, required this.d, required this.executed});

  int getPageNumber() {
    return p;
  }

  int getOffset() {
    return d;
  }
}
