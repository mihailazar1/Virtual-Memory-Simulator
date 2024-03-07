// ignore_for_file: curly_braces_in_flow_control_structures, constant_identifier_names

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vmsim/models/FIFOqueue.dart';
import 'package:vmsim/models/LRUStack.dart';
import 'package:vmsim/models/all_processes.dart';
import 'package:vmsim/models/page_table.dart';
import 'package:vmsim/models/process.dart';
import 'package:vmsim/models/ram.dart';
import 'package:vmsim/models/ram_row.dart';
import 'package:vmsim/models/tlb.dart';
import 'package:vmsim/models/virtual_address.dart';

const int PAGE_FOUND_IN_TLB = 2;
const int PAGE_NOT_ALREADY_MAPPED = 1;
const int PAGE_ALREADY_MAPPED = 0;

class Algorithms {
  static int execute(
      Ram ramMemory,
      TLB tlb,
      int selectedProcessIndex,
      AllProcesses ap,
      String algorithm,
      StackLRU lruStack,
      FIFOQueue fifoQueue) {
    Process? process = ap.allProc[selectedProcessIndex];
    List<VirtualAddress> va = process!.va;
    PageTable pageTable = process.pageTable;

    int nextAddr = getNextAddress(va);

    int content = va[nextAddr].getPageNumber(); // contents to place in RAM
    int pageNumber = va[nextAddr].getPageNumber();

    va[nextAddr].executed = true;

    if (mappingNotInTLBorInvalid(tlb, pageNumber, process.processNumber)) {
      print('tlb miss!');
      tlb.hit = 0;
      tlb.nbMiss++;

      if (pageTable.isValid(pageNumber) == false) {
        handlePageFault(ramMemory, process, tlb, pageNumber, 'Block: $content',
            pageTable, algorithm, lruStack, fifoQueue, ap);

        //lruStack.printStack();
        //fifoQueue.printQueue();
        return PAGE_NOT_ALREADY_MAPPED;
      }

      tlb.addTLBEntry(
          pageNumber, pageTable.pages[pageNumber], process.processNumber);

      if (algorithm == "LRU") {
        accessFrame(lruStack, pageTable.pages[pageNumber]);
      }
      //lruStack.printStack();
      //fifoQueue.printQueue();
      return PAGE_ALREADY_MAPPED;
    } else {
      print('TLB HIT!\n');
      tlb.nbHits++;
      tlb.hit = 1;

      if (algorithm == "LRU") {
        accessFrame(lruStack, pageTable.pages[pageNumber]);
      }

      //lruStack.printStack();

      return PAGE_FOUND_IN_TLB;
    }
  }

  //TODO================================================================================

  static void handlePageFault(
      Ram ramMemory,
      Process process,
      TLB tlb,
      int pageNumber,
      String content,
      PageTable pageTable,
      String algorithm,
      StackLRU lruStack,
      FIFOQueue fifoQueue,
      AllProcesses allProcesses) {
    int frameNumber = findFreeFrame(ramMemory);

    if (frameNumber == -1) {
      // No free frame, find free frame with an algorithm
      if (algorithm == "LRU") {
        frameNumber = Algorithms.findLRUPage(lruStack);
        print("ALGO IS LRU");
      }

      if (algorithm == "FIFO") {
        frameNumber = Algorithms.findFIFOPage(fifoQueue);
        print("ALGO IS FIFO");
      }

      if (algorithm == "RANDOM") {
        frameNumber = Algorithms.findRANDOMPage(ramMemory.ramLength);
        print("ALGO IS RANDOM");
      }
    }

    // in case a RAM frame is overwritten by another process, go to each Page Table and update. Do the same for the TLB
    for (int i = 0; i < allProcesses.noProc; i++) {
      Process? process = allProcesses.allProc[i];
      PageTable iterPageTable = process!.pageTable;
      updatePageTableToReflectFrameWasMovedToDisk(iterPageTable,
          frameNumber); // if the frame is already mapped from another page table,
      updateTLBtoReflectFrameWasMovedToDisk(
          tlb, frameNumber, process.processNumber);
    }

    setRAMEntry(ramMemory, frameNumber, content);

    tlb.addTLBEntry(pageNumber, frameNumber, process.processNumber);

    // after frame is accessed, move it on top of stack
    if (algorithm == "LRU") {
      // doing this the second time does not change anything
      accessFrame(lruStack, frameNumber);
    }

    toggleValidBit(pageTable, pageNumber); // set valid bit to 1

    pageTable.setPageTableEntry(
        pageNumber, frameNumber); // update the page table
  }

  //TODO================================================================================

  static bool mappingNotInTLBorInvalid(
      TLB tlb, int pageNumber, int processNumber) {
    for (int i = 0; i < tlb.length; i++) {
      if (tlb.entries[i].virtualPage == pageNumber &&
          tlb.entries[i].pid == processNumber) {
        if (tlb.entries[i].valid == 0) {
          return true;
        }
        return false;
      }
    }

    return true;
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
    ramMemory.lastToColor = frameNumber;
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

  static void updateTLBtoReflectFrameWasMovedToDisk(
      TLB tlb, int frameNumber, int processNumber) {
    for (int i = 0; i < tlb.length; i++) {
      if (tlb.entries[i].physicalPage == frameNumber &&
          tlb.entries[i].pid == processNumber) {
        tlb.entries[i].valid = 0;
      }
    }
  }

  static int findLRUPage(StackLRU lruStack) {
    int page = lruStack.lru();
    accessFrame(lruStack, page);
    return page;
  }

  static int findFIFOPage(FIFOQueue fifoQueue) {
    int page = fifoQueue.dequeue();
    fifoQueue.enqueue(page);
    return page;
  }

  static int findRANDOMPage(int ramLength) {
    Random random = Random();
    int page = random.nextInt(ramLength);

    return page;
  }
}
