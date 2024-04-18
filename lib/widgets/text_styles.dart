import 'package:flutter/material.dart';

TextStyle simpleTextStyle() {
  return TextStyle(color: const Color.fromARGB(255, 56, 20, 20), fontSize: 16);
}

InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Color.fromARGB(111, 59, 3, 3)),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: const Color.fromARGB(255, 113, 7, 7))),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: const Color.fromARGB(255, 113, 7, 7))));
}

TextStyle biggerTextStyle() {
  return TextStyle(color: const Color.fromARGB(255, 59, 18, 18), fontSize: 17);
}
