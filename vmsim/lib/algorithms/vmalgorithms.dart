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
    int frameNumber = ramMemory
        .findFreeFrame(); // Implement the logic to find a free frame or use a page replacement algorithm
    if (frameNumber == -1) {
      // No free frame, perform page replacement using the LRU algorithm from PageReplacementUtils
      if (algorithm == "LRU")
        frameNumber = Algorithms.findLruPage(ramMemory.memoryRows);

      if (algorithm == "FIFO")
        frameNumber = Algorithms.findFifoPage(ramMemory.memoryRows);
    }

    // Load the new page into the selected frame
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

    int content = va[nextAddr].getPageNumber(); // contents to place in RAM
    int pageNumber = va[nextAddr].getPageNumber();

    va[nextAddr].executed = true;

    if (pageTable.getPageTableEntry(pageNumber) == -1) {
      // The page is not mapped
      print(
          'Page requested not found in page table. Data will be loaded from Secondary Memory. TLB, Page Table and Physical Memory is updated accordingly\n');
      handlePageFault(ramMemory, currentTime, process.processNumber, pageNumber,
          'Block: $content', pageTable, algorithm);

      return PAGE_NOT_ALREADY_MAPPED;
    }

    ramMemory.memoryRows[pageTable.getPageTableEntry(pageNumber)]
        .setEntryTime(currentTime);

    checkIfPageStillInRam(ramMemory, pageTable, pageNumber);

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

  static void checkIfPageStillInRam(
      //TODO NU CRED CA FUNCTIONEAZA BINE
      // verifica daca nu cumva e outdatat entry-ul din page table
      Ram ramMemory,
      PageTable pageTable,
      int pageNumber) {
    if (ramMemory
            .memoryRows[pageTable.getPageTableEntry(pageNumber)].pageNumber !=
        pageTable.getPageTableEntry(pageNumber)) {
      print("Page Table outdated!, needs replacement");
    }
  }
}
