import 'dart:async';

import 'package:geolocator/geolocator.dart';

// hide the idea that this is a shared instance
Position? _pos;

class LocationDAL {

  Future<Position?> getLocationAsync() async {

    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      print("LocationDAL: Cannot get location");
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      print("LocationDAL: Permission denied");
      return null;
    }

    _pos = await Geolocator.getCurrentPosition();
    return _pos;
  }

  Position? tryGetLocation() {
    return _pos;
  }
}
