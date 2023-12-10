import 'package:vmsim/models/all_processes.dart';
import 'package:vmsim/models/page_table.dart';
import 'package:vmsim/models/process.dart';
import 'package:vmsim/models/ram.dart';
import 'package:vmsim/models/ram_row.dart';
import 'package:vmsim/models/virtual_address.dart';

const int PAGE_NOT_ALREADY_MAPPED = 1;
const int PAGE_ALREADY_MAPPED = 0;

class Algorithms {
  static int findLruPage(List<RamRow> memoryRows) {
    int minTime = memoryRows[0].lastAccessTime;
    int lruPage = 0;

    for (int i = 1; i < memoryRows.length; i++) {
      if (memoryRows[i].lastAccessTime < minTime) {
        minTime = memoryRows[i].lastAccessTime;
        lruPage = i;
      }
    }

    return lruPage;
  }

  static int findFifoPage(List<RamRow> memoryRows) {
    return 0;
  }

  static void handlePageFault(Ram ramMemory, int currentTime, int processNumber,
      int pageNumber, String content, PageTable pageTable, String algorithm) {
    int frameNumber = ramMemory.findFreeFrame();
    if (frameNumber == -1) {
      if (algorithm == "LRU")
        frameNumber = Algorithms.findLruPage(ramMemory.memoryRows);

      if (algorithm == "FIFO")
        frameNumber = Algorithms.findFifoPage(ramMemory.memoryRows);
    }

    ramMemory.setRamEntry(
        frameNumber, content, processNumber, pageNumber, currentTime);
    pageTable.setPageTableEntry(pageNumber, frameNumber);
  }

  static int execute(Ram ramMemory, int currentTime, int selectedProcessIndex,
      AllProcesses ap, String algorithm) {
    print('execute!');
    Process? process = ap.allProc[selectedProcessIndex];
    List<VirtualAddress> va = process!.va;
    PageTable pageTable = process.pt;

    int nextAddr = getNextAddress(va);

    int content = va[nextAddr].getPageNumber();
    int pageNumber = va[nextAddr].getPageNumber();

    va[nextAddr].executed = true;

    if (pageTable.getPageTableEntry(pageNumber) == -1) {
      print(
          'Page requested not found in page table. Data will be loaded from Secondary Memory.\n');
      handlePageFault(ramMemory, currentTime, process.processNumber, pageNumber,
          'Block: $content', pageTable, algorithm);

      return PAGE_NOT_ALREADY_MAPPED;
    }

    ramMemory.memoryRows[pageTable.getPageTableEntry(pageNumber)]
        .setEntryTime(currentTime);

    checkIfPageStillInRam(ramMemory, currentTime, process, 'Block: $content',
        pageTable, algorithm, pageNumber);

    return PAGE_ALREADY_MAPPED;
  }

  static int getNextAddress(List<VirtualAddress> va) {
    for (int i = 0; i < va.length; i++) {
      if (va[i].executed == false) {
        return i;
      }
    }

    return -1;
  }

  static void checkIfPageStillInRam(Ram ramMemory, int currentTime, Process p,
      String content, PageTable pageTable, String algorithm, int pageNumber) {
    if (ramMemory.memoryRows[pageTable.getPageTableEntry(pageNumber)]
                .pageNumber !=
            pageNumber ||
        ramMemory.memoryRows[pageTable.getPageTableEntry(pageNumber)]
                .processNumber !=
            p.processNumber) {
      print("Page Table outdated!, needs replacement\n");

      print(ramMemory
          .memoryRows[pageTable.getPageTableEntry(pageNumber)].pageNumber);
      print('\n');
      print(pageNumber);

      handlePageFault(ramMemory, currentTime, p.processNumber, pageNumber,
          content.toString(), pageTable, algorithm);
    }
  }
}
