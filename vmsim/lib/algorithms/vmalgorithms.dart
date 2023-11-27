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

  static void handlePageFault(Ram ramMemory, int currentTime, int processNumber,
      int pageNumber, String content, PageTable pageTable) {
    int frameNumber = ramMemory
        .findFreeFrame(); // Implement the logic to find a free frame or use a page replacement algorithm
    if (frameNumber == -1) {
      // No free frame, perform page replacement using the LRU algorithm from PageReplacementUtils
      frameNumber = Algorithms.findLruPage(ramMemory.memoryRows);
    }

    // Load the new page into the selected frame
    ramMemory.setRamEntry(frameNumber, content, processNumber, currentTime);
    pageTable.setPageTableEntry(pageNumber, frameNumber);
  }

  static int execute(Ram ramMemory, int currentTime, int selectedProcessIndex,
      AllProcesses ap) {
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
          'Block: $content', pageTable);

      return PAGE_NOT_ALREADY_MAPPED;
    }
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
}
