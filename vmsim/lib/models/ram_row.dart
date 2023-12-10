class RamRow {
  String data;
  int processNumber;
  int pageNumber;
  int lastAccessTime;

  RamRow({
    required this.data,
    required this.processNumber,
    required this.lastAccessTime,
    required this.pageNumber,
  });

  void setEntryTime(int currentTime) {
    lastAccessTime = currentTime;
  }
}
