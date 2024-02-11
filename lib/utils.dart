import 'dart:io';

import 'package:flutter/material.dart';
import "package:intl/intl.dart";

Directory? docDir;

Future selectDate(
    BuildContext context,
    dynamic model,
    String? dateString) async {
  DateTime initialDate = DateTime.now();

  if (dateString != null){
    List<String> dateParts = dateString.split(",");
    initialDate = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );
  }

  DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100)
  );

  if (picked != null) {
    model.setChosenDate(
      DateFormat.yMMMMd("en_Us").format(picked.toLocal())
    );

    return "${picked.year},${picked.month}${picked.day}";
  }
}
