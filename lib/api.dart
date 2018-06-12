import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tntech_dining_app/models.dart';

const String EP_OPEN_LOC = 'https://www.dineoncampus.com/v1/locations/open.json';
const String EP_MENU = 'https://www.dineoncampus.com/v1/location/menu.json';
const String EP_ALL_LOC =
    'https://www.dineoncampus.com/v1/locations/all_locations.json';
const String SITE_ID = '5751fd2790975b60e0489224';

Future<Set<Location>> fetchAllLocations() async {
  final response = await http.get(EP_ALL_LOC + '?site_id=' + SITE_ID);

  final responseJson = json.decode(response.body);
  Set<Location> locations = new Set();
  responseJson['locations']
      .forEach((location) => locations.add(Location.fromJson(location)));

  return locations;
}

Future<Map<String, Set<Schedule>>> fetchSchedules(DateTime date) async {
  print("Fetching schedules: " + date.toIso8601String());
  String url = EP_OPEN_LOC +
      '?site_id=' +
      SITE_ID +
      '&timestamp=' +
      date.toIso8601String();
  final response = await http.get(url);

  final responseJson = json.decode(response.body);

  Map<String, Set<Schedule>> locationSchedules = new Map();
  for (var location in responseJson['location_schedules']) {
    Set<Schedule> schedules = locationSchedules.putIfAbsent(location['id'], () => new Set());
    location['schedules'].forEach((schedule) => schedules.add(Schedule.fromJson(schedule)));
  }

  return locationSchedules;
}

Future<Menu> fetchMenuForLocation(Location location, DateTime date) async {
  String url = EP_MENU +
      "?site_id=" +
      SITE_ID +
      "&platform=0&location_id=" +
      location.id +
      "&date=" +
      date.toIso8601String();
  final response = await http.get(url);

  final responseJson = json.decode(response.body);
  return Menu.fromJson(responseJson);
}
