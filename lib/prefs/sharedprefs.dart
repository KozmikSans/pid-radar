import 'package:shared_preferences/shared_preferences.dart';

loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  bool? comp = prefs.getBool("compass_enabled"); // all settings values
  bool? traffic = prefs.getBool("traffic_enabled");
  bool? buildings = prefs.getBool("buildings_enabled");
  bool? sound = prefs.getBool("enable_sound_update");
  bool? startmass = prefs.getBool("start_with_mass_tracking");
  if (comp == null) {
    // checking if its the first time starting up and setting the default values
    await prefs.setBool("compass_enabled", true);
  }
  if (traffic == null) {
    await prefs.setBool("traffic_enabled", false);
  }
  if (buildings == null) {
    await prefs.setBool("buildings_enabled", true);
  }
  if (sound == null) {
    await prefs.setBool("enable_sound_update", true);
  }
  if (startmass == null) {
    await prefs.setBool("start_with_mass_tracking", true);
  }
  return prefs;
}
