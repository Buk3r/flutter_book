import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'TasksDBWorker.dart';
import 'TasksModel.dart' show TaskModel, tasksModel;
import '../utils.dart' as utils;

class TasksEntry extends StatelessWidget {
  final TextEditingController _desciptionEditingController =
    TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry({super.key}) {
    _desciptionEditingController.addListener(() {
      tasksModel.entityBeingEdited.description = _desciptionEditingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    _desciptionEditingController.text =
        tasksModel.entityBeingEdited?.description ?? "";

    return ScopedModel(
        model: tasksModel,
        child: ScopedModelDescendant<TaskModel>(
          builder: (BuildContext context, Widget? child, TaskModel model) {
            return Scaffold(
              bottomNavigationBar: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: Row(
                  children: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        model.setStackIndex(0);
                      },
                    ),
                    const Spacer(),
                    TextButton(
                      child: const Text("Save"),
                      onPressed: () {
                        _save(context, tasksModel);
                      },
                    ),
                  ],
                ),
              ),
              body: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.description,
                          ),
                        ],
                      ),
                      title: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        decoration: const InputDecoration(hintText: "Description"),
                        controller: _desciptionEditingController,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a description";
                          }

                          return null;
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.today),
                      title: const Text("Due Date"),
                      subtitle: Text(
                          tasksModel.chosenDate == null
                              ? ""
                              : tasksModel.chosenDate!
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () async {
                          String? chosenDate = await utils.selectDate(
                              context,
                              tasksModel,
                              tasksModel.entityBeingEdited.dueDate);

                          if (chosenDate != null) {
                            tasksModel.entityBeingEdited.dueDate = chosenDate;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  void _save(BuildContext context, TaskModel model) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (model.entityBeingEdited.id == null) {
      await TasksDBWorker.db.create(tasksModel.entityBeingEdited);
    } else {
      await TasksDBWorker.db.update(tasksModel.entityBeingEdited);
    }

    tasksModel.loadData("tasks", TasksDBWorker.db);

    model.setStackIndex(0);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      content: Text("Task saved"),
    ));
  }
}