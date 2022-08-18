import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/pidapi.dart';
import 'widg/widgets.dart';
import 'widg/settings.dart';
import 'package:geolocator/geolocator.dart';
import 'utils/utils.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'prefs/sharedprefs.dart';

// i call everything a bus, although it can be a tram or a boat as well
var themecolor = const Color.fromARGB(
    255, 59, 95, 255); // the color i use across the whole project
var apicontroller =
    PidAPI(); // our api controller object(useless by design, should have just created a class with static functions or
// used pure functions, idk why i put it here, not changing it, im lazy)
late SharedPreferences prefs; // settings preferences
var stops; // giant stops map
void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'PidRadar', home: Home());
  }
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // bloated main class
  OverlayEntry? entry; // entry used to display vehicle data
  String srchval = "";
  String curbus = ""; // used for stopping the async searching function
  String newal = ""; // used for stopping the async searching function
  late OverlayState overlay; // overlay where the entry will be placed
  late BitmapDescriptor bit; // icon datatypes
  late BitmapDescriptor bitspecial;
  late BitmapDescriptor bitspecialtram;
  late BitmapDescriptor bitspecialboat;
  late BitmapDescriptor bitram;
  late BitmapDescriptor bitboat;
  late GoogleMapController mapController;
  String? selectedid; // the id of a selected vehicle
  final LatLng _center = const LatLng(
      50.0755, 14.4378); // starting up location - centered on prague
  List busMaps = []; // list of our vehicle data maps
  Set<Marker> busMarkers = {}; // markers of all vehicles currently displayed
  bool haspermission =
      false; // basic permission stuff - asking for location and so on
  late LocationPermission permission; // ^
  bool servicestatus = false; // ^
  bool loading = true; // used during startup to show loading screen
  late LatLng loc;
  List oldcoords = [0, 0];
  bool?
      trackingall; // are we tracking all vehicles, or have we searched up a single one
  bool temploading =
      false; // used whenever we are performing a taxing action or anything that takes time
  @override
  void initState() {
    super.initState();
    firstload();
  }

  void _onMapCreated(GoogleMapController controller) {
    // these three functions are used to create our map controller and also set up custom map style
    // this takes a created controller to set up our own
    mapController = controller;
    changeMapMode(mapController);
  }

  void changeMapMode(GoogleMapController controller) {
    getJsonFile("assets/map.json")
        .then((value) => setMapStyle(value, controller));
  }

  void setMapStyle(String mapStyle, GoogleMapController controller) {
    controller.setMapStyle(mapStyle);
  }

  void firstload() async {
    // startup function
    await gpsetup();
    await setCustomMarker();
    prefs = await loadSettings(); // preference loading
    stops = await getRealJson("assets/stops.json"); // getting huge stops map
    trackingall = prefs.getBool("start_with_mass_tracking");
    loading = false;
    setState(() {});
    mainloop(); // starting mass tracking -- only goes through if trackingall == true
  }

  gpsetup() async {
    // permission, location, etc.
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return;
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }
    }
  }

  setCustomMarker() async {
    // setting up icons from assets
    bit = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/Map-icon-blue.resized.png");
    bitspecial = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/64283.resized.png");
    bitram = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/tram.resized.png");
    bitboat = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/boat-icon.png");
    bitspecialtram = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/tram-selected.resized.png");
    bitspecialboat = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/boat-special.resized.png");
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: themecolor,
            size: 200,
          ),
        ),
      ); // loading animation
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themecolor,
        title: Row(
          children: [
            SizedBox(
              width: 40,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Settings(),
                      ));
                },
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(left: 20),
                child: const Text("PID Radar")),
            Container(
              margin: const EdgeInsets.only(left: 80),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => About(),
                      ));
                },
                child: const Icon(
                  Icons.info_outlined,
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
                // button that starts mass tracking manually
                onPressed: () {
                  if (trackingall!) return;
                  trackingall = true;
                  temploading = true;
                  setState(() {});
                  mainloop();
                }, // navigate to the global map(or maybe not?)
                child: retLoad()),
          ],
        ),
      ),
      body: GoogleMap(
        // main google map widget
        buildingsEnabled: prefs.getBool("buildings_enabled")!,
        compassEnabled: prefs.getBool("compass_enabled")!,
        trafficEnabled: prefs.getBool("traffic_enabled")!,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        markers: busMarkers,
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: 200,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: themecolor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(
              width: 100,
              height: 50,
              child: TextFormField(
                onChanged: (val) {
                  srchval = val;
                },
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide:
                        const BorderSide(color: Colors.greenAccent, width: 2),
                  ),
                ),
              ),
            ),
            TextButton(
              // the button that starts search
              onPressed: () async {
                newal = srchval; // to stop the last function
                curbus = srchval;
                trackingall = false;
                temploading = true;
                setState(() {});
                while (curbus == newal && trackingall == false) {
                  busMaps = [];
                  Map help = await apicontroller
                      .getBus(curbus); // get all vehicles of a route id
                  for (var x in help.values) {
                    if (x == "FeatureCollection") {
                      continue;
                    } // stupid breaking bonus in the api
                    for (var y in x) {
                      busMaps.add(y);
                    }
                  }
                  setUpMarkers(); // displaying data in the map
                  setState(() {});
                }
                busMarkers = {};
              },
              child: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  mainloop() async {
    // tracking all the busses -- > stops once search button is pressed
    while (trackingall!) {
      busMaps = [];
      Map help = await apicontroller.getAllBusses();
      for (var x in help.values) {
        // we are getting the values of our map and then working with them, these values are ultimately the maps with data about our vehicles
        if (x == "FeatureCollection") continue;
        for (var y in x) {
          busMaps.add(y);
        }
      }
      setUpMarkers();
      setState(() {});
    }
  }

  void showOverlay(info) {
    entry = OverlayEntry(
        builder: (context) => Positioned(
              left: 37,
              top: 100,
              child: BusInfo(info, this),
            ));
    overlay = Overlay.of(context)!;
    overlay.insert(entry!);
    setState(() {});
  }

  void clearOverlay() {
    if (entry == null) return;
    entry!.remove();
    setState(() {});
  }

  void blankOver() {
    // this works, instead of killin the entry we just blank it, however
    // used because of a weird af bug with clear overlay where i could not create an overlay for some reason
    entry!.remove();
    entry = OverlayEntry(builder: (context) => Container());
    overlay = Overlay.of(context)!;
    overlay.insert(entry!);
    setState(() {});
  }

  Widget retLoad() {
    // used for temploading -- the track all button becomes loading animation - cool
    if (temploading) {
      return LoadingAnimationWidget.bouncingBall(
        color: Colors.white,
        size: 15,
      );
    }
    return const Icon(
      Icons.track_changes,
      color: Colors.white,
    );
  }

  void setUpMarkers() {
    // updates are not very frequent, however u get the positions right and all
    // every 20 secs or somthing
    busMarkers = {};

    for (var bus in busMaps) {
      var ic = bit;

      String id = bus["properties"]["trip"]["vehicle_registration_number"]
          .toString(); // "id" of a vehicle

      double coordy = bus["geometry"]["coordinates"][0]
          .toDouble(); // coords in the json are flipped, dont ask me who designed this shit
      double coordx = bus["geometry"]["coordinates"][1]
          .toDouble(); // coords in the json are flipped, dont ask me who designed this shit

      if (id == selectedid) {
        // if vehicle is selected, change icon -> play sound and update overlay upon movement
        if (bus["properties"]["trip"]["vehicle_type"] != null) {
          if (bus["properties"]["trip"]["vehicle_type"]["description_en"] ==
              "tram") {
            ic = bitspecialtram;
          } else if (bus["properties"]["trip"]["vehicle_type"]
                  ["description_en"] ==
              "boat") {
            ic = bitspecialboat;
          } else {
            ic = bitspecial;
          }
        }
        if (oldcoords[0] != coordx || oldcoords[1] != coordy) {
          // if his coordinates changed
          if (prefs.getBool("enable_sound_update")!) {
            playLocalAsset("mixkit-gaming-lock-2848.wav");
          }
          oldcoords = [coordx, coordy];
          clearOverlay(); // resetting overlay
          showOverlay(bus);
        }

        if (bus["properties"]["last_position"]["tracking"]) {
          // checking for a rare ocurrence(so rare this if is probably useless but i have ptsd)
          // showing marker pointing to stop
          List latlon = getStopCoo(bus); // displaying the next stop
          if (latlon.isEmpty == false) {
            busMarkers.add(
              Marker(
                  markerId: MarkerId("nextstop_$id"),
                  position: LatLng(latlon[0], latlon[1]),
                  infoWindow: InfoWindow(title: latlon[2])),
            );
          }
        }
      } else {
        // in case it isn't selected, display normal icons
        if (bus["properties"]["trip"]["vehicle_type"] != null) {
          if (bus["properties"]["trip"]["vehicle_type"]["description_en"] ==
              "tram") {
            ic = bitram;
          } else if (bus["properties"]["trip"]["vehicle_type"]
                  ["description_en"] ==
              "boat") {
            ic = bitboat;
          }
        }
      }
      busMarkers.add(
        // adding final marker
        Marker(
          markerId: MarkerId(id),
          position: LatLng(coordx, coordy),
          icon: ic,
          onTap: () {
            // the ontap does not go through
            temploading = true;
            clearOverlay(); // showing overlay with info upon taps
            showOverlay(bus);
            selectedid = id;
            oldcoords = [coordx, coordy];
            setState(() {});
          },
        ),
      );
    }
    temploading = false;
  }

  void setstate() {
    setState(() {});
  }
}
