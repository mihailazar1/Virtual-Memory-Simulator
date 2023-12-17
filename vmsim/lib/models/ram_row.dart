class RamRow {
  String data; // 8 bits
  //int processNumber;
  //int pageNumber;
  //int lastAccessTime; // Timestamp or usage history

  RamRow({
    required this.data,
    // required this.processNumber,
    // required this.lastAccessTime,
    // required this.pageNumber,
  });

  // void setEntryTime(int currentTime) {
  //  lastAccessTime = currentTime;
  // }
}
