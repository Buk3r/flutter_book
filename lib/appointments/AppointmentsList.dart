import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import 'AppointmentsModel.dart'
    show Appointment, AppointmentsModel, appointmentsModel;

class AppointmentsList extends StatelessWidget {
  const AppointmentsList({super.key});

  @override
  Widget build(BuildContext context) {
    EventList<Event> markedDateMap = EventList(events: {});
    for (int i = 0; i < appointmentsModel.entityList.length; i++) {
      Appointment appointment = appointmentsModel.entityList[i];
      if (appointment.apptDate != null) {
        List dateParts = appointment.apptDate!.split(",");
        DateTime appDate = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );
        markedDateMap.add(
            appDate,
            Event(
                date: appDate,
                icon: Container(
                    decoration: const BoxDecoration(color: Colors.blue))));
      }
    }

    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (context, child, model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                appointmentsModel.entityBeingEdited = Appointment();
                DateTime now = DateTime.now();
                appointmentsModel.entityBeingEdited.apptDate =
                    "${now.year},${now.month},${now.day}";
                appointmentsModel.setChosenDate(
                    DateFormat.yMMMMd("en_US").format(now.toLocal()));
                appointmentsModel.setApptTime(null);
                appointmentsModel.setStackIndex(1);
              },
            ),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: CalendarCarousel<Event>(
                      thisMonthDayBorderColor: Colors.grey,
                      daysHaveCircularBorder: false,
                      markedDatesMap: markedDateMap,
                      onDayPressed: (DateTime date, List<Event> events) {
                        _showAppointments(date, context);
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAppointments(DateTime date, BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ScopedModel<AppointmentsModel>(
              model: appointmentsModel,
              child: ScopedModelDescendant<AppointmentsModel>(
                builder: (BuildContext context, Widget? child,
                    AppointmentsModel model) {
                  return Scaffold(
                    body: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Text(
                                  DateFormat.yMMMMd("en_US")
                                      .format(date.toLocal()),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontSize: 24,
                                  )),
                              const Divider(),
                              Expanded(
                                child: ListView.builder(
                                  itemCount:
                                      appointmentsModel.entityList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    Appointment appointment =
                                        appointmentsModel.entityList[index];
                                    if (appointment.apptDate !=
                                        "${date.year},${date.month},${date.day}") {
                                      return Container(height: 0);
                                    }
                                    String apptTime = "";
                                    if (appointment.apptTime != null) {
                                      List timeParts =
                                          appointment.apptTime!.split(",");
                                      TimeOfDay at = TimeOfDay(
                                          hour: int.parse(timeParts[0]),
                                          minute: int.parse(timeParts[1]));
                                      apptTime = " (${at.format(context)})";
                                    }

                                    return Slidable(
                                        endActionPane: ActionPane(
                                          motion: const DrawerMotion(),
                                          extentRatio: 0.25,
                                          children: [
                                            SlidableAction(
                                              label: "Delete",
                                              backgroundColor: Colors.red,
                                              icon: Icons.delete,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              onPressed:
                                                  (BuildContext context) async {
                                                //await _deleteAppointment(context, appointment);
                                              },
                                            )
                                          ],
                                        ),
                                        child: ListTile(
                                          title: Text(
                                              "${appointment.title}$apptTime"),
                                          subtitle: appointment.description ==
                                                  null
                                              ? null
                                              : Text(
                                                  "${appointment.description}"),
                                          onTap: () async {
                                            //_exitAppointment(context, appointment);
                                          },
                                        ));
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ));
        });
  }
}
