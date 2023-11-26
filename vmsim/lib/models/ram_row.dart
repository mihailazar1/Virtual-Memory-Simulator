class RamRow {
  int data;
  int processNumber;
  int lastAccessTime; // Timestamp or usage history

  RamRow(
      {required this.data,
      required this.processNumber,
      required this.lastAccessTime});
}
