class VirtualAddress {
  int p; // page number
  int d; // offset

  VirtualAddress({required this.p, required this.d});

  int getPageNumber() {
    return p;
  }

  int getOffset() {
    return d;
  }
}
