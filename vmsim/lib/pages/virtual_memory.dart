// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import "package:flutter/material.dart";
import 'package:vmsim/algorithms/vmalgorithms.dart';
import "package:vmsim/models/all_processes.dart";
import "package:vmsim/models/page_table.dart";
import "package:vmsim/models/ram.dart";
import "package:vmsim/models/virtual_address.dart";
import "package:vmsim/util/button.dart";
import "package:vmsim/util/my_text_field.dart";
import "package:vmsim/util/ram_table.dart";

class VirtualMemory extends StatefulWidget {
  const VirtualMemory({super.key});

  @override
  State<VirtualMemory> createState() => _VirtualMemoryState();
}

class _VirtualMemoryState extends State<VirtualMemory> {
  int currentTime = 0; // Variable to keep track of the current time

  final _cProcesses = TextEditingController();
  final _cPhysSize = TextEditingController();
  final _cVirtSize = TextEditingController();
  final _cOffset = TextEditingController();
  final _cTest = TextEditingController();
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

    ramMemory = Ram(
        offsetBits: int.parse(_cOffset.text),
        physicalSize: int.parse(_cPhysSize.text));
    _cTest.text = ap.allProc[0]!.va[0].p.toString();

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
    PageTable? pageTable = ap.allProc?[selectedProcessIndex]?.pt;

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
            ],
            rows: List.generate(
              pageTable.length,
              (index) => DataRow(
                cells: [
                  DataCell(Text('$index')),
                  DataCell(Text('${pageTable.pages?[index]}')),
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
              DataColumn(label: Text('Process #')),
              DataColumn(label: Text('Data')),
            ],
            rows: List.generate(
              ramMemory.ramLength,
              (index) => DataRow(
                cells: [
                  DataCell(Text('$index')),
                  DataCell(
                      Text('${ramMemory.getRamEntry(index).processNumber}')),
                  DataCell(Text(ramMemory.getRamEntry(index).data)),
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
        ap.allProc?[selectedProcessIndex]?.va;

    if (virtualAddresses == null) {
      return Container(); // Display nothing if virtual addresses are not available
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Virtual Addresses for Process $selectedProcessIndex:'),
        for (var address in virtualAddresses)
          Text('P: ${address.p}, D: ${address.d}'),
      ],
    );
  }

  void executeInstruction() {
    // Check if a process is selected
    if (selectedProcessIndex != -1) {
      // Assuming each process has a reference to its PageTable
      PageTable? pageTable = ap.allProc[selectedProcessIndex]?.pt;
      int result =
          Algorithms.execute(ramMemory, currentTime, selectedProcessIndex, ap);

      if (result == 1)
        currentTime++;
      else
        print("Page already mapped\n");
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
      backgroundColor: const Color.fromARGB(255, 194, 177, 225),
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
                _buildTextField("test", _cTest),
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

            buildPageTable(), // Display the Page Table for the selected process

            buildRamTable(),
          ],
        ),
      ),
    );
  }
}
