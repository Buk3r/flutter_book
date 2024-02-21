import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import 'TasksDBWorker.dart';
import 'TasksModel.dart' show Task, TaskModel, tasksModel;

class TasksList extends StatelessWidget {
  const TasksList({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TaskModel>(
        model: tasksModel,
        child: ScopedModelDescendant<TaskModel>(
          builder: (BuildContext context, Widget? child, TaskModel model) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: () {
                  tasksModel.entityBeingEdited = Task();
                  tasksModel.setStackIndex(1);
                },
                child: const Icon(Icons.add, color: Colors.white),
              ),
              body: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  itemCount: tasksModel.entityList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Task task = tasksModel.entityList[index];
                    String dueDateString = "";
                    if (task.dueDate != null) {
                      List dateParts = task.dueDate!.split(",");
                      DateTime dueDate = DateTime(int.parse(dateParts[0]),
                          int.parse(dateParts[1]), int.parse(dateParts[2]));
                      dueDateString =
                          DateFormat.yMMMMd("en_US").format(dueDate.toLocal());
                    }

                    return Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Slidable(
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                label: "Delete",
                                backgroundColor: Colors.red,
                                icon: Icons.delete,
                                onPressed: (BuildContext context) async {
                                  await _deleteTask(context, task);
                                },
                              )
                            ],
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: task.completed == "true",
                              onChanged: (value) async {
                                task.completed = value.toString();
                                await TasksDBWorker.db.update(task);
                                tasksModel.loadData("tasks", TasksDBWorker.db);
                              },
                            ),
                            title: Text(
                              "${task.description}",
                              style: task.completed == "true"
                                  ? TextStyle(
                                      color: Theme.of(context).disabledColor,
                                      decoration: TextDecoration.lineThrough,
                                    )
                                  : TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.color),
                            ),
                            subtitle: task.dueDate == null
                                ? null
                                : Text(
                                    dueDateString,
                                    style: task.completed == "true"
                                        ? TextStyle(
                                            color:
                                                Theme.of(context).disabledColor,
                                            decoration:
                                                TextDecoration.lineThrough)
                                        : TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.color),
                                  ),
                            onTap: () async {
                              if (task.completed == "true") {
                                return;
                              }
                              tasksModel.entityBeingEdited =
                                  await TasksDBWorker.db.get(task.id);

                              if (tasksModel.entityBeingEdited.dueDate ==
                                  null) {
                                tasksModel.setChosenDate(null);
                              } else {
                                tasksModel.setChosenDate(dueDateString);
                              }
                              tasksModel.setStackIndex(1);
                            },
                          )),
                    );
                  }),
            );
          },
        ));
  }

  Future _deleteTask(BuildContext context, Task task) {
    return showDialog(
        context: context,
        builder: (BuildContext alertContext) {
          return AlertDialog(
            title: const Text("Delete Task"),
            content: Text("Are you sure you want to delete this task?"),
            actions: [
              TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(alertContext).pop();
                  }),
              TextButton(
                  child: const Text("Delete"),
                  onPressed: () async {
                    await TasksDBWorker.db.delete(task.id);
                    Navigator.of(alertContext).pop();
                    ScaffoldMessenger.of(alertContext)
                        .showSnackBar(const SnackBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                      content: Text("Task deleted"),
                    ));
                    tasksModel.loadData("tasks", TasksDBWorker.db);
                  }),
            ],
          );
        });
  }
}
