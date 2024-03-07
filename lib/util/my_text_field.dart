import "package:flutter/material.dart";

class MyTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;

  const MyTextField(
      {super.key, required this.hintText, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 15),
      ),
    );
  }
}
