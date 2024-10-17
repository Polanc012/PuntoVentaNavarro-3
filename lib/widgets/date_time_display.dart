import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';


class DateTimeDisplay extends StatefulWidget {
  const DateTimeDisplay({Key? key}) : super(key: key);

  @override
  _DateTimeDisplayState createState() => _DateTimeDisplayState();
}

class _DateTimeDisplayState extends State<DateTimeDisplay> {
  late DateTime _currentDateTime;

  get timer => null;

  @override
  void initState() {
    super.initState();
    _currentDateTime = DateTime.now();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentDateTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(_currentDateTime);
    final formattedTime = DateFormat('hh:mm a').format(_currentDateTime);

    return Column(
      children: [
        Text(
          formattedDate,
          style: GoogleFonts.outfit(fontSize: 16),
        ),
        Text(
          formattedTime,
          style: GoogleFonts.outfit(fontSize: 16),
        ),
      ],
    );
  }
}