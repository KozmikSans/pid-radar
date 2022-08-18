import 'dart:convert';
import 'package:http/http.dart';

class PidAPI {
  var headers = {
    // access token needed for the api
    'Content-Type': 'application/json; charset=utf-8',
    'x-access-token':
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImRyYWt6YnluZGFAZ21haWwuY29tIiwiaWQiOjEzOTYsIm5hbWUiOm51bGwsInN1cm5hbWUiOm51bGwsImlhdCI6MTY1OTQyODUxMSwiZXhwIjoxMTY1OTQyODUxMSwiaXNzIjoiZ29sZW1pbyIsImp0aSI6ImVjMWI4MzE3LTlkYTYtNDNhMi1iYzViLWEyY2QxMTRlYmJjZCJ9.YmHZvGmzxB5NT66eGJ_Yg4ICGgga_DJdKt4FUFKhz9o'
  };
  Future<Map> getBus(String id) async {
    // getting a specific bus
    late Map needed;
    final Uri url = Uri.parse(
        "https://api.golemio.cz/v2/vehiclepositions?limit=1000&includePositions=true&routeShortName=$id");
    Response res = await get(url, headers: headers);
    if (res.statusCode == 200) {
      // stops crashing on server issues
      needed = jsonDecode(res.body);
      return needed;
    }
    return {};
  }

  List getBusCoords(Map data) {
    // getting coordinates of all vehicles of an obtained json
    // might use it in the future
    List ret = [];
    for (var x in data.values) {
      if (x == "FeatureCollection") continue;
      for (var y in x) {
        var newcoords = y["geometry"]["coordinates"];
        var help = newcoords[0];
        newcoords[0] = newcoords[1];
        newcoords[1] = help;
        ret.add(newcoords);
      }
    }
    return ret;
  }

  Future<Map> getRoute(String id) async {
    // getting a certain route
    // will be used in a future update
    final Uri url = Uri.parse('https://api.golemio.cz/v2/gtfs/routes/$id');
    Response res = await get(url, headers: headers);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return {};
  }

  Future<Map> getAllBusses() async {
    // gets all vehicles from the api, no restrictions
    late Map needed;
    final Uri url = Uri.parse("https://api.golemio.cz/v2/vehiclepositions?");
    Response res = await get(url, headers: headers);
    if (res.statusCode == 200) {
      // stops crashing with server issues
      needed = jsonDecode(res.body);
      return needed;
    }
    return {};
  }
}
