// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import "package:flutter/material.dart";
import "package:vmsim/models/all_processes.dart";
import "package:vmsim/models/ram.dart";
import "package:vmsim/util/button.dart";
import "package:vmsim/util/my_text_field.dart";
import "package:vmsim/util/ram_table.dart";

class VirtualMemory extends StatefulWidget {
  const VirtualMemory({super.key});

  @override
  State<VirtualMemory> createState() => _VirtualMemoryState();
}

class _VirtualMemoryState extends State<VirtualMemory> {
  final _cProcesses = TextEditingController();
  final _cPhysSize = TextEditingController();
  final _cVirtSize = TextEditingController();
  final _cOffset = TextEditingController();
  final _cTest = TextEditingController();
  late AllProcesses ap;

  Ram ramMemory = Ram(offsetBits: 1, physicalSize: 1);

  void startSimulation() {
    ap = AllProcesses(
      offsetBits: int.parse(_cOffset.text),
      virtualSize: int.parse(_cVirtSize.text),
      noProc: int.parse(_cProcesses.text),
    );

    ramMemory = Ram(
        offsetBits: int.parse(_cOffset.text),
        physicalSize: int.parse(_cPhysSize.text));
    _cTest.text = ap.allProc![0]!.va![0].p.toString();

    setState(() {});
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
      body: Padding(
        padding: const EdgeInsets.all(20), // Added padding for better spacing
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
              ],
            ),
            const SizedBox(width: 20),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Frame #')),
                  DataColumn(label: Text('Data')),
                ],
                rows: List.generate(
                  ramMemory.ramLength,
                  (index) => DataRow(
                    cells: [
                      DataCell(Text('$index')),
                      DataCell(Text('${ramMemory.getRamEntry(index)}')),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
