class TLBEntry {
  int virtualPage;
  int physicalPage;
  int valid;
  int pid;
  int empty;

  TLBEntry({
    required this.virtualPage,
    required this.physicalPage,
    required this.pid,
    required this.valid,
    required this.empty,
  }) {}
}
