// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import "package:flutter/material.dart";
import 'package:vmsim/algorithms/vmalgorithms.dart';
import "package:vmsim/models/all_processes.dart";
import "package:vmsim/models/page_table.dart";
import "package:vmsim/models/ram.dart";
import "package:vmsim/models/tlb.dart";
import "package:vmsim/models/virtual_address.dart";
import "package:vmsim/util/button.dart";
import "package:vmsim/util/dropdown_button.dart";
import "package:vmsim/util/my_text_field.dart";
import "package:vmsim/models/LRUStack.dart";

const int PAGE_NOT_ALREADY_MAPPED = 1;
const int PAGE_ALREADY_MAPPED = 0;

class VirtualMemory extends StatefulWidget {
  const VirtualMemory({super.key});

  @override
  State<VirtualMemory> createState() => _VirtualMemoryState();
}

class _VirtualMemoryState extends State<VirtualMemory> {
  int currentTime = 0; // Variable to keep track of the current time

  final _cProcesses = TextEditingController()..text = '2';
  final _cPhysSize = TextEditingController()..text = '32';
  final _cVirtSize = TextEditingController()..text = '64';
  final _cOffset = TextEditingController()..text = '2';
  final _cTLBEntries = TextEditingController()..text = '8';

  //final _cTest = TextEditingController();

  StackLRU<int> lruStack = StackLRU();
  TLB tlb = TLB(length: 0);

  String chosenAlgorithm = 'LRU';

  List<String> replAlgorithms = <String>['LRU', 'FIFO', 'RANDOM'];

  AllProcesses ap = AllProcesses(
    offsetBits: 1,
    virtualSize: 2,
    noProc: 0,
  );

  Ram ramMemory = Ram(offsetBits: 1, physicalSize: 1);
  int selectedProcessIndex = -1; // Index of the selected process

  void startSimulation() {
    ap = AllProcesses(
      offsetBits: int.parse(_cOffset.text),
      virtualSize: int.parse(_cVirtSize.text),
      noProc: int.parse(_cProcesses.text),
    );
    print(int.parse(_cTLBEntries.text));

    ramMemory = Ram(
        offsetBits: int.parse(_cOffset.text),
        physicalSize: int.parse(_cPhysSize.text));
    //_cTest.text = ap.allProc[0]!.va[0].p.toString();

    tlb = TLB(length: int.parse(_cTLBEntries.text));

    //initialize stack
    for (int i = 0; i < ramMemory.ramLength; i++) {
      lruStack.push(i);
    }

    setState(() {
      selectedProcessIndex =
          -1; // Reset the selected process index when starting a new simulation
    });
  }

  Widget _buildTextField(String hintText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      child: SizedBox(
        width: 200, // Increased width for better readability
        child: MyTextField(
          hintText: hintText,
          controller: controller,
        ),
      ),
    );
  }

  Widget buildProcessList() {
    return Expanded(
      child: Container(
        width: 200,
        height: 300, // Adjust the width as needed
        child: ListView.builder(
          itemCount: ap.allProc?.length ?? 0,
          itemBuilder: (context, index) => ListTile(
            title: Text('Process $index'),
            onTap: () {
              setState(() {
                selectedProcessIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget buildPageTable() {
    if (selectedProcessIndex == -1) {
      return Container(); // Empty container when no process is selected
    }

    // Assuming AllProcesses has a List of PageTables
    PageTable? pageTable = ap.allProc?[selectedProcessIndex]?.pageTable;

    if (pageTable == null) {
      return Container(); // Empty container when no PageTable is available for the selected process
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DataTable(
            columns: [
              DataColumn(label: Text('Page Number')),
              DataColumn(label: Text('Frame Number')),
              DataColumn(label: Text('Valid Bit')),
            ],
            rows: List.generate(
              pageTable.length,
              (index) => DataRow(
                cells: [
                  DataCell(Text(
                    '$index',
                    style: TextStyle(
                        color: (pageTable.lastToColor == index)
                            ? Colors.green
                            : Colors.black,
                        fontWeight: (pageTable.lastToColor == index)
                            ? FontWeight.bold
                            : FontWeight.normal),
                  )),
                  DataCell(Text(
                    '${pageTable.pages?[index]}',
                    style: TextStyle(
                        color: (pageTable.lastToColor == index)
                            ? Colors.green
                            : Colors.black,
                        fontWeight: (pageTable.lastToColor == index)
                            ? FontWeight.bold
                            : FontWeight.normal),
                  )),
                  DataCell(Text(
                    '${pageTable.validInvalid?[index]}',
                    style: TextStyle(
                        color: (pageTable.lastToColor == index)
                            ? Colors.green
                            : Colors.black,
                        fontWeight: (pageTable.lastToColor == index)
                            ? FontWeight.bold
                            : FontWeight.normal),
                  )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildRamTable() {
    if (ramMemory.ramLength == 0) return Container();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DataTable(
            columns: [
              DataColumn(label: Text('Frame #')),
              DataColumn(label: Text('Data')),
            ],
            rows: List.generate(
              ramMemory.ramLength,
              (index) => DataRow(
                cells: [
                  DataCell(Text('$index')),
                  // DataCell(
                  //    Text('${ramMemory.getRamEntry(index).processNumber}')),
                  DataCell(Text(
                    ramMemory.getRamEntry(index).data,
                    style: TextStyle(
                        color: (ramMemory.lastToColor == index)
                            ? Colors.green
                            : Colors.black),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTLB() {
    if (tlb.length == 0) return Container();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DataTable(
            columns: [
              DataColumn(
                label: Text(
                  'Page #',
                  style: TextStyle(
                    color: (tlb.hit == 1)
                        ? Colors.green
                        : (tlb.hit == -1)
                            ? Colors.black
                            : Colors.red,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Frame #',
                  style: TextStyle(
                    color: (tlb.hit == 1)
                        ? Colors.green
                        : (tlb.hit == -1)
                            ? Colors.black
                            : Colors.red,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Process #',
                  style: TextStyle(
                    color: (tlb.hit == 1)
                        ? Colors.green
                        : (tlb.hit == -1)
                            ? Colors.black
                            : Colors.red,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Valid',
                  style: TextStyle(
                    color: (tlb.hit == 1)
                        ? Colors.green
                        : (tlb.hit == -1)
                            ? Colors.black
                            : Colors.red,
                  ),
                ),
              ),
            ],
            rows: List.generate(
              tlb.length,
              (index) => DataRow(
                cells: [
                  DataCell(Text('${tlb.entries[index].virtualPage}')),
                  DataCell(Text('${tlb.entries[index].physicalPage}')),
                  DataCell(Text('${tlb.entries[index].pid}')),
                  DataCell(
                    Text('${tlb.entries[index].valid}'),
                    // Set the color based on the tlb.hit variable
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVirtualAddresses() {
    if (selectedProcessIndex == -1) {
      return Container(); // Display nothing if no process is selected
    }

    List<VirtualAddress>? virtualAddresses =
        ap.allProc[selectedProcessIndex]?.va;

    if (virtualAddresses == null) {
      return Container(); // Display nothing if virtual addresses are not available
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Virtual Addresses for Process $selectedProcessIndex:'),
        for (var address in virtualAddresses)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'P: ',
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: '${address.p}',
                  style: TextStyle(
                    color: address.executed == true ? Colors.green : Colors.red,
                    // Add other styles if needed
                  ),
                ),
                TextSpan(
                  text: ', D: ',
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: '${address.d}',
                  style: TextStyle(
                    color: address.executed == true ? Colors.green : Colors.red,
                    // Add other styles if needed
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void executeInstruction() {
    // Check if a process is selected
    if (selectedProcessIndex != -1) {
      // Assuming each process has a reference to its PageTable
      PageTable? pageTable = ap.allProc[selectedProcessIndex]?.pageTable;
      int result = Algorithms.execute(ramMemory, tlb, currentTime,
          selectedProcessIndex, ap, chosenAlgorithm, lruStack);

      //if (result == PAGE_NOT_ALREADY_MAPPED)
      currentTime++;
      //else
      //print("Page already mapped\n");
      // Check if the PageTable is not null
      if (pageTable != null) {
        // Update the UI by triggering a rebuild
        setState(() {
          // Update the RAM memory (you need to implement this method in your Ram class)
          //ramMemory.updateFromPageTable(pageTable);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 242, 242, 242),
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Virtual Memory Simulator",
            style: TextStyle(fontSize: 25),
          ),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: executeInstruction,
        elevation: 0,
        child: Icon(
          Icons.arrow_right,
          size: 45,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20), // Added padding for better spacing
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                _buildTextField("# of processes", _cProcesses),
                _buildTextField("Physical Size", _cPhysSize),
                _buildTextField("Virtual Size", _cVirtSize),
                _buildTextField("# of offset bits", _cOffset),
                _buildTextField("TLB entries", _cTLBEntries),

                DropdownBtn(),

                SizedBox(
                    height: 20), // Added spacing between text fields and button
                Button(
                  text: "Start Simulation",
                  onPressed: startSimulation,
                ),

                SizedBox(height: 30), // Added spacing before the process list
                buildProcessList(), // Display the list of processes
                SizedBox(height: 20),

                buildVirtualAddresses(),
                Text(
                  'Current simulation time: $currentTime',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            buildTLB(),

            buildPageTable(), // Display the Page Table for the selected process

            buildRamTable(),
          ],
        ),
      ),
    );
  }
}
