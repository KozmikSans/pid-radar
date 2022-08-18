import 'package:flutter/material.dart';

import 'package:pidradar/main.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsState();
  }
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themecolor,
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          settingwidget("traffic_enabled", "Traffic marking"),
          settingwidget("compass_enabled", "Compass button"),
          settingwidget("buildings_enabled", "Buildings"),
          settingwidget("enable_sound_update", "Sound after update"),
          settingwidget("start_with_mass_tracking", "Starts with mass tracking")
        ],
      ),
    );
  }

  Widget settingwidget(String id, String whatsays) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: themecolor,
      ),
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 15),
            child: Text(
              whatsays,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          Switch(
            value: prefs.getBool(id)!,
            onChanged: (value) {
              prefs.setBool(id, value);
              setState(() {});
            },
          )
        ],
      ),
    );
  }
}
