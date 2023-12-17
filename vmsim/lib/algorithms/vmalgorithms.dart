// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:vmsim/models/LRUStack.dart';
import 'package:vmsim/models/all_processes.dart';
import 'package:vmsim/models/page_table.dart';
import 'package:vmsim/models/process.dart';
import 'package:vmsim/models/ram.dart';
import 'package:vmsim/models/ram_row.dart';
import 'package:vmsim/models/virtual_address.dart';

const int PAGE_NOT_ALREADY_MAPPED = 1;
const int PAGE_ALREADY_MAPPED = 0;

class Algorithms {
  static int execute(Ram ramMemory, int currentTime, int selectedProcessIndex,
      AllProcesses ap, String algorithm, StackLRU lruStack) {
    Process? process = ap.allProc[selectedProcessIndex];
    List<VirtualAddress> va = process!.va;
    PageTable pageTable = process.pageTable;

    int nextAddr = getNextAddress(va);

    int content = va[nextAddr].getPageNumber(); // contents to place in RAM
    int pageNumber = va[nextAddr].getPageNumber();

    va[nextAddr].executed = true;

    if (pageTable.isValid(pageNumber) == false) {
      // The page is not mapped
      print(
          'Page requested not found in page table. Data will be loaded from Secondary Memory. TLB, Page Table and Physical Memory is updated accordingly\n');
      handlePageFault(ramMemory, pageNumber, 'Block: $content', pageTable,
          algorithm, lruStack, ap);

      print('page number $pageNumber \n');

      lruStack.printStack();
      return PAGE_NOT_ALREADY_MAPPED;
    }

    //ramMemory.memoryRows[pageTable.getPageTableEntry(pageNumber)]
    //    .setEntryTime(currentTime);

    //checkIfPageStillInRam(ramMemory, currentTime, process, 'Block: $content',
    //   pageTable, algorithm, pageNumber);

    accessFrame(lruStack, pageTable.pages[pageNumber]);
    lruStack.printStack();
    return PAGE_ALREADY_MAPPED;
  }

  static void handlePageFault(
      Ram ramMemory,
      int pageNumber,
      String content,
      PageTable pageTable,
      String algorithm,
      StackLRU lruStack,
      AllProcesses allProcesses) {
    int frameNumber = findFreeFrame(
        ramMemory); // Implement the logic to find a free frame or use a page replacement algorithm

    if (frameNumber == -1) {
      // No free frame, perform page replacement using the LRU algorithm from PageReplacementUtils
      if (algorithm == "LRU") frameNumber = Algorithms.findLRUPage(lruStack);

      //if (algorithm == "FIFO")
      // frameNumber = Algorithms.findFifoPage(ramMemory.memoryRows);
    }

    // Load the new page into the selected frame

    for (int i = 0; i < allProcesses.noProc; i++) {
      Process? process = allProcesses.allProc[i];
      PageTable iterPageTable = process!.pageTable;
      updatePageTableToReflectFrameWasMovedToDisk(iterPageTable, frameNumber);
    }

    setRAMEntry(ramMemory, frameNumber, content);
    accessFrame(lruStack, frameNumber);
    toggleValidBit(pageTable, pageNumber);
    pageTable.setPageTableEntry(pageNumber, frameNumber);
  }

  static int findLRUPage(StackLRU lruStack) {
    int page = lruStack.lru();
    accessFrame(lruStack, page);
    return page;
  }

  static void accessFrame(StackLRU lruStack, int page) {
    lruStack.moveToTop(page);
  }

  static int findFreeFrame(Ram ramMemory) {
    for (int i = 0; i < ramMemory.ramLength; i++)
      if (ramMemory.memoryRows[i].data == '-') return i;

    return -1;
  }

  static int getNextAddress(List<VirtualAddress> va) {
    for (int i = 0; i < va.length; i++) {
      if (va[i].executed == false) {
        return i;
      }
    }

    return -1;
  }

  static void setRAMEntry(Ram ramMemory, int frameNumber, String content) {
    ramMemory.memoryRows[frameNumber].data = content;
  }

  static void toggleValidBit(PageTable pageTable, int pageNumber) {
    if (pageTable.validInvalid[pageNumber] == 1)
      pageTable.validInvalid[pageNumber] = 0;
    else
      pageTable.validInvalid[pageNumber] = 1;
  }

  static void updatePageTableToReflectFrameWasMovedToDisk(
      PageTable pageTable, int frameNumber) {
    for (int i = 0; i < pageTable.length; i++)
      if (pageTable.pages[i] == frameNumber) {
        pageTable.validInvalid[i] = 0;
      }
  }

  /*
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

    checkIfPageStillInRam(ramMemory, currentTime, process, 'Block: $content',
        pageTable, algorithm, pageNumber);

    return PAGE_ALREADY_MAPPED;
  }

  

  static void checkIfPageStillInRam(
      //TODO NU CRED CA FUNCTIONEAZA BINE
      // verifica daca nu cumva e outdatat entry-ul din page table
      Ram ramMemory,
      int currentTime,
      Process p,
      String content,
      PageTable pageTable,
      String algorithm,
      int pageNumber) {
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
  */
}
