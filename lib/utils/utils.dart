import 'dart:convert';
import 'package:pidradar/main.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

Future<String> getJsonFile(String path) async {
  // getting json string
  final String response = await rootBundle.loadString(path);
  return response;
}

Future<Map> getRealJson(String path) async {
  // getting json
  final String response = await rootBundle.loadString(path);
  return json.decode(response);
}

Future<AudioPlayer> playLocalAsset(path) async {
  AudioCache cache = AudioCache();
  //At the next line, DO NOT pass the entire reference such as assets/yes.mp3. This will not work.
  //Just pass the file name only.
  return await cache.play(path);
}

getStopCoo(Map busMap) {
  // returns coords and name -> [x,y,name]
  String? id = busMap["properties"]["last_position"]["next_stop"]["id"];

  for (Map stop in stops["stopGroups"]) {
    for (Map st in stop["stops"]) {
      for (String gtid in st["gtfsIds"]) {
        if (gtid == id) {
          return [st["lat"], st["lon"], stop["name"]];
        }
      }
    }
  }
  return [];
}

giveRight(info) {
  // returns the delay if there is any
  String s = info["properties"]["last_position"]["delay"]["actual"].toString();
  if (s == "null" || s == "0") {
    return "none";
  }
  return "$s s";
}

getStop(String st, info) {
  // gets stop name
  String? id = info["properties"]["last_position"][st]["id"];
  for (Map stop in stops["stopGroups"]) {
    for (Map st in stop["stops"]) {
      for (String gtid in st["gtfsIds"]) {
        if (gtid == id) {
          return stop["name"];
        }
      }
    }
  }
  return "none";
}
