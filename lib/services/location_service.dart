import 'dart:async';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;

class LocationService {
  StreamSubscription<loc.LocationData>? _locationStream;
  loc.Location location = loc.Location();

  

  Future<Position> getCurrentLocation() async {
    log('getCurrentLocation');

    loc.LocationData currentLocation = await location.getLocation();
    Position pos = Position(
        latitude: currentLocation.latitude!.toDouble(),
        accuracy: currentLocation.accuracy!.toDouble(),
        speed: currentLocation.speed!.toDouble(),
        altitude: currentLocation.altitude!.toDouble(),
        heading: currentLocation.heading!.toDouble(),
        speedAccuracy: currentLocation.speedAccuracy!.toDouble(),
        timestamp:DateTime.now(),
        longitude: currentLocation.longitude!.toDouble());

    return pos;

    /*return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);*/
  }

  double calculateDistanceInMeters(var position1Lat,var position1Long,var position2Lat, var position2Long) {
    
    return Geolocator.distanceBetween(
      position1Lat,
      position1Long,
      position2Lat,
      position2Long,
    );
  }

  void startLocationUpdates(Function(Position) callback) {
    /*bg.BackgroundGeolocation.onLocation((bg.Location location) {
      print('[LOCATION] - $location');
      Position pos = Position(
          latitude: location.coords.latitude,
          accuracy: location.coords.accuracy,
          speed: location.coords.speed,
          altitude: location.coords.altitude,
          heading: location.coords.heading,
          speedAccuracy: location.coords.speedAccuracy,
          timestamp: DateTime.parse(location.timestamp),
          longitude: location.coords.longitude);
      callback(pos);
    });*/

    /* _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    )).listen((Position newPosition) {
      callback(newPosition);
    });*/

    location.enableBackgroundMode(enable: true);

    location.changeSettings(
        accuracy: loc.LocationAccuracy.high, distanceFilter: 0, interval: 1000);

    _locationStream = location.onLocationChanged.listen((loc.LocationData currentLocation) {
      Position pos = Position(
          latitude: currentLocation.latitude!.toDouble(),
          accuracy: currentLocation.accuracy!.toDouble(),
          speed: currentLocation.speed!.toDouble(),
          altitude: currentLocation.altitude!.toDouble(),
          heading: currentLocation.heading!.toDouble(),
          speedAccuracy: currentLocation.speedAccuracy!.toDouble(),
          timestamp: DateTime.now(),
          longitude: currentLocation.longitude!.toDouble());

      callback(pos);
    });
  }

  void stopLocationUpdates() {
   _locationStream!.cancel();
  }
}
