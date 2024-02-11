import 'package:flutter/material.dart';
import 'package:flutter_book/notes/NotesList.dart';
import 'package:scoped_model/scoped_model.dart';

import 'NotesModel.dart' show NotesModel, notesModel;

class Notes extends StatelessWidget {
  Notes({super.key}) {
    //notesModel.loadData("notes", NotesDbWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<NotesModel>(
        model: notesModel,
        child: ScopedModelDescendant<NotesModel>(
          builder: (BuildContext context, Widget? child, NotesModel model){
            return IndexedStack(
              index: model.stackIndex,
              children: const [
                NotesList(),
              ],
            );
          },
        ),
    );
  }
}