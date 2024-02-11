import 'package:flutter/material.dart';
import 'package:flutter_book/notes/NotesDBWorker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scoped_model/scoped_model.dart';

import 'NotesModel.dart' show Note, NotesModel, notesModel;

class NotesList extends StatelessWidget {
  const NotesList({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModel<NotesModel>(
        model: notesModel,
        child: ScopedModelDescendant<NotesModel>(
          builder: (
              BuildContext context,
              Widget? child,
              NotesModel model){
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  notesModel.entityBeingEdited = Note();
                  notesModel.setColor(null);
                  notesModel.setStackIndex(1);
                },
                child: const Icon(Icons.add, color: Colors.white),
              ),
              body: ListView.builder(itemBuilder: (BuildContext context, int index) {
                Note note = notesModel.entityList[index];
                Color color = Colors.white;
                switch (note.color) {
                  case "red" : color = Colors.red;
                  case "green" : color = Colors.green;
                  case "blue" : color = Colors.blue;
                  case "yellow" : color = Colors.yellow;
                  case "grey" : color = Colors.grey;
                  case "purple" : color = Colors.purple;
                }

                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Card(
                    elevation: 8,
                    color: color,
                    child: ListTile(
                      title: Text("${note.title}"),
                      subtitle: Text("${note.content}"),
                      onTap: () async {
                        notesModel.entityBeingEdited =
                          await NotesDBWorker.db.get(note.id);
                        notesModel.setColor(notesModel.entityBeingEdited.color);
                        notesModel.setStackIndex(1);
                      },
                    ),
                  )
                );
              }),
            );
          },
        )
    );
  }

  Future _deleteNote(BuildContext context, Note note){
    return showDialog(
        context: context,
        builder: (BuildContext alertContext) {
          return AlertDialog(
            title: const Text("Delete Note"),
            content: Text(
                "Are you sure you want to delete ${note.title}?"
            ),
            actions: [
              TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(alertContext).pop();
                  }
              ),
              TextButton(
                  child: const Text("Delete"),
                  onPressed: () async {
                    await NotesDBWorker.db.delete(note.id);
                    Navigator.of(alertContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          content: Text("Note deleted"),
                        )
                    );
                    notesModel.loadData("notes", NotesDBWorker.db);
                  }
              ),
            ],
          );
        }
    );
  }
}