import 'package:vmsim/models/all_processes.dart';
import 'package:vmsim/models/page_table.dart';
import 'package:vmsim/models/process.dart';
import 'package:vmsim/models/ram.dart';
import 'package:vmsim/models/ram_row.dart';
import 'package:vmsim/models/virtual_address.dart';

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

  static void execute(Ram ramMemory, int currentTime, int selectedProcessIndex,
      AllProcesses ap) {
    Process? process = ap.allProc[selectedProcessIndex];
    List<VirtualAddress> va = process!.va;
    PageTable pageTable = process.pt;
    int content = va[0].getPageNumber(); // contents to place in RAM
    int pageNumber = va[0].getPageNumber();

    if (pageTable.getPageTableEntry(va[0].d) == -1) {
      print(
          'Page requested not found in page table. Data will be loaded from Secondary Memory. TLB, Page Table and Physical Memory is updated accordingly\n');
      handlePageFault(ramMemory, currentTime, process.processNumber, pageNumber,
          'Block: $content', pageTable);
    }
  }
}
