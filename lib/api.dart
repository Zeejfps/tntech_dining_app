import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tntech_dining_app/models.dart';

const String EP_MENU = 'https://www.dineoncampus.com/v1/location/menu.json';
const String EP_ALL_LOC =
    'https://www.dineoncampus.com/v1/locations/all_locations.json';
const String SITE_ID = '5751fd2790975b60e0489224';

Future<List<Location>> fetchAllLocations() async {
  final response = await http.get(EP_ALL_LOC + '?site_id=' + SITE_ID);

  final resonseJson = json.decode(response.body);
  List<Location> locations = new List();
  resonseJson['locations']
      .forEach((location) => locations.add(Location.fromJson(location)));

  return locations;
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

  final resonseJson = json.decode(response.body);
  return Menu.fromJson(resonseJson);
}
