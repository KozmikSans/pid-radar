import 'package:flutter/material.dart';
import 'package:pidradar/main.dart';
import 'package:pidradar/utils/utils.dart';

class MoreInfo extends StatelessWidget {
  // the widget for showing extended info about a vehicle
  final Map info;
  var parent;
  String? dat; // last updated
  MoreInfo(this.info, this.parent) {
    dat = "${DateTime.now().hour}:${helpret()}";
  }
  String helpret() {
    int i = DateTime.now().minute;
    if (DateTime.now().minute < 10) {
      // return it so its human-readable(i want 19:02, not 19:2)
      return "0$i";
    }
    return "$i";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: themecolor,
      title: Row(
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Route: ${info["properties"]["trip"]["origin_route_name"]}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "id: ${info["properties"]["trip"]["vehicle_registration_number"].toString()}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 35),
                child: Text(
                  "Last Updated - $dat",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Column(
              children: [
                const Text(
                  "Terminus:",
                  style: TextStyle(color: Colors.white),
                ),
                Container(
                  width: 180,
                  alignment: Alignment.center,
                  child: Text(
                    "${info["properties"]["trip"]["gtfs"]["trip_headsign"]}", // we can request more info through route id
                    style: const TextStyle(color: Colors.greenAccent),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Column(
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
            ),
            Container(
              margin: const EdgeInsets.only(top: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        "Next stop:",
                        style: TextStyle(color: Colors.white),
                      ),
                      Container(
                        width: 180,
                        alignment: Alignment.center,
                        child: Text(
                          getStop("next_stop", info),
                          style: const TextStyle(color: Colors.amberAccent),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        "Last Stop:",
                        style: TextStyle(color: Colors.white),
                      ),
                      Container(
                        width: 180,
                        alignment: Alignment.center,
                        child: Text(
                          getStop("last_stop", info),
                          style: const TextStyle(color: Colors.amberAccent),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (info["properties"]["trip"]["wheelchair_accessible"])
                    const Icon(
                      Icons.wheelchair_pickup_rounded,
                      color: Colors.white,
                    ),
                  if (info["properties"]["trip"]["air_conditioned"] != null)
                    if (info["properties"]["trip"]["air_conditioned"])
                      const Icon(
                        Icons.air_sharp,
                        color: Colors.white,
                      )
                ],
              ),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // get back to gmap, reset everything so its like it was before
            parent.selectedid = info["properties"]["trip"]
                    ["vehicle_registration_number"]
                .toString();
            parent.temploading = true;
            parent.setstate();
            parent.clearOverlay();
            parent.showOverlay(info);
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 25),
        ),
      ],
    );
  }
}
