class TLBEntry {
  int virtualPage;
  int physicalPage;
  int pid;
  int empty;

  TLBEntry({
    required this.virtualPage,
    required this.physicalPage,
    required this.pid,
    required this.empty,
  }) {}
}
