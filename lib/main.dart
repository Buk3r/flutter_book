import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'notes/Notes.dart';
import '../utils.dart' as utils;

void main() {
  startMeUp() async {
    Directory docDir = await getApplicationDocumentsDirectory();
    utils.docDir = docDir;
    runApp(const FlutterBook());
  }

  WidgetsFlutterBinding.ensureInitialized();
  startMeUp();
}

class FlutterBook extends StatelessWidget {
  const FlutterBook({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Flutter Book"),
            bottom: const TabBar(
              tabs: [
                // Tab(
                //   icon: Icon(Icons.date_range),
                //   text: "Appointments",
                // ),
                // Tab(
                //   icon: Icon(Icons.contacts),
                //   text: "Contacts",
                // ),
                Tab(
                  icon: Icon(Icons.note),
                  text: "Notes",
                ),
                // Tab(
                //   icon: Icon(Icons.assignment_turned_in),
                //   text: "Tasks",
                // ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Appointments(),
              // Contacts(),
              Notes(),
              // Tasks(),
            ],
          ),
        ),
      ),
    );
  }
}