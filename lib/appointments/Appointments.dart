import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'AppointmentsDBWorker.dart';
import 'AppointmentsList.dart';
import 'AppointmentsModel.dart' show AppointmentsModel, appointmentsModel;

class Appointments extends StatelessWidget {
  Appointments({super.key}) {
    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext context, Widget? child, AppointmentsModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: [
              const AppointmentsList(),
              // AppointmentsEntry(),
            ],
          );
        },
      ),
    );
  }
}