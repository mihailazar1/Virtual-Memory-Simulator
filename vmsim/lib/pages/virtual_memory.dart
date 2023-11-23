import "package:flutter/material.dart";
import "package:vmsim/models/all_processes.dart";
import "package:vmsim/util/button.dart";
import "package:vmsim/util/my_text_field.dart";

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
  AllProcesses? ap;

  void createProcesses() {
    ap = AllProcesses(
      offsetBits: int.parse(_cOffset.text),
      virtualSize: int.parse(_cVirtSize.text),
      noProc: int.parse(_cProcesses.text),
    );

    setState(() {
      _cOffset.text = ap!.allProc![0]!.va![0].p.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 194, 177, 225),
      appBar: AppBar(
        title: Center(
          child: Text(
            "Virtual Memory Simulator",
            style: TextStyle(fontSize: 25),
          ),
        ),
        elevation: 0,
      ),
      body: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 15),
                child: SizedBox(
                  width: 140,
                  child: MyTextField(
                      hintText: "# of processes", controller: _cProcesses),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 15),
                child: SizedBox(
                  width: 140,
                  child: MyTextField(
                      hintText: "Physical Size", controller: _cPhysSize),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 15),
                child: SizedBox(
                  width: 140,
                  child: MyTextField(
                      hintText: "Virtual Size", controller: _cVirtSize),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 15),
                child: SizedBox(
                  width: 140,
                  child: MyTextField(
                      hintText: "# of offset bits", controller: _cOffset),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Button(
                  text: "Start Simulation",
                  onPressed: createProcesses,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
