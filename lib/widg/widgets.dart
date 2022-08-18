import 'package:flutter/material.dart';
import 'package:pidradar/main.dart';
import 'moreinfo.dart';
import 'package:pidradar/utils/utils.dart';

class About extends StatelessWidget {
  // About section, just info
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: themecolor,
          title: const Text("About"),
        ),
        body: Container(
          margin: const EdgeInsets.all(20),
          child: const Text(
            """
Pidradar is an open source project developed by a single developer. You can see every active transport vehicle from prague integrated traffic (pid) system on the map. 

You can either use the button in the upper right corner to obtain all vehicle positions, or you can use the searchbox to search for all vehicles of a route name.(example: 175, 6, 22, 125)

Each vehicle type has a different icon, and you can see more info about a vehicle after you tap its marker. Next stop will be then highlighted on the map with a red marker. The shown overlay can be removed simply by tapping it once.

The id of a vehicle corresponds to its registration number, which can be used to search up more information.

By default, the app makes a sound after the position of a selected vehicle changes. You can change this in the settings by tapping the button in the upper left corner.
           """,
            style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          ),
        ));
  }
}

class BusInfo extends StatelessWidget {
  // further data about a vehicle
  final Map info; // the data map
  var parent; // the parent widget --> home_state
  bool? tracked;
  BusInfo(this.info, this.parent);
  @override
  Widget build(BuildContext context) {
    // play with styling
    return SizedBox(
      width: 320,
      height: 80,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(themecolor),
            elevation: MaterialStateProperty.all(4)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "${info["properties"]["trip"]["origin_route_name"]}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                    "id: ${info["properties"]["trip"]["vehicle_registration_number"].toString()}",
                    style: const TextStyle(color: Colors.white))
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      "Terminus:",
                      style: TextStyle(color: Colors.white),
                    ),
                    Container(
                      width: 100,
                      alignment: Alignment.center,
                      child: Text(
                        "${info["properties"]["trip"]["gtfs"]["trip_headsign"]}", // we can request more info through route id
                        style: const TextStyle(color: Colors.greenAccent),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      "Delay:",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "${giveRight(info)}",
                      style: const TextStyle(color: Colors.greenAccent),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text("Next stop:"),
                    Container(
                      width: 80,
                      alignment: Alignment.center,
                      child: Text(
                        getStop("next_stop", info),
                        style: const TextStyle(color: Colors.amberAccent),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  // More info button part
                  width: 80,
                  height: 30,
                  child: TextButton(
                    onPressed: () {
                      parent.blankOver();
                      // user doesnt need an overlay when he sees all in the widget
                      parent.selectedid = null;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MoreInfo(info, parent),
                        ),
                      );
                    },
                    child: const Text(
                      "Expand",
                      style: TextStyle(color: Colors.limeAccent),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
        onPressed: () {
          // when overlay is pressed, clear it
          parent.blankOver();
          parent.selectedid = null; // resetting id to clear effects
        },
      ),
    );
  }
}

/* 
this code was used when i included untracked busses, should i do such a thing
it will prove useful in the future
getRightMainWidget() {
    if (info["properties"]["last_position"]["tracking"]) {
      tracked = true;
      return  ...
    } else { // for untracked bus
      tracked = false;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "${info["properties"]["trip"]["origin_route_name"]}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Text(
                  "id: ${info["properties"]["trip"]["vehicle_registration_number"].toString()}",
                  style: const TextStyle(color: Colors.white))
            ],
          ),
          const Text(
            "Bus is currently not tracked",
            style: TextStyle(fontSize: 16),
          )
        ],
      );
    }
  }
*/