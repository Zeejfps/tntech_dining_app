
import 'dart:async';

import 'package:tntech_dining_app/api.dart';
import 'package:tntech_dining_app/models.dart';

Future<Set<Location>> loadLocations(DateTime date) async {

  Set<Location> allLocations = await fetchAllLocations();

  Map<String, Set<Schedule>> allSchedules = await fetchSchedules(date);

  Set<Location> openedLocations = new Set();

  allLocations.forEach((location) {
    if (!allSchedules.containsKey(location.id))
      return;

    openedLocations.add(location);
    Set<Schedule> schedules = allSchedules[location.id];
    for (var schedule in schedules) {
      DateTime start = DateTime.parse(schedule.start);
      DateTime end = DateTime.parse(schedule.end);

      if (date.isAfter(start) && date.isBefore(end)) {
        location.opened = true;
        break;
      }

    }
  });

  return openedLocations;
}
