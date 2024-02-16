import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'TasksDBWorker.dart';
import 'TasksList.dart';
import 'TasksModel.dart' show TaskModel, tasksModel;

class Tasks extends StatelessWidget {
  Tasks({super.key}) {
    tasksModel.loadData("tasks", TasksDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TaskModel>(
      model: tasksModel,
      child: ScopedModelDescendant<TaskModel>(
        builder: (BuildContext context, Widget? child, TaskModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: const [
              TasksList(),
              // TaskEntry(),
            ],
          );
        },
      ),
    );
  }
}
