import 'dart:async';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';

class LocationService {
  StreamSubscription<Position>? _positionStream;

  Future<Position> getCurrentLocation() async {
    log('getCurrentLocation');
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  double calculateDistanceInMeters(Position position1, Position position2) {
    return Geolocator.distanceBetween(
      position1.latitude,
      position1.longitude,
      position2.latitude,
      position2.longitude,
    );
  }

  void startLocationUpdates(Function(Position) callback) {
    _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    )

        ).listen((Position newPosition) {
      callback(newPosition);
    });
  }

  void stopLocationUpdates() {
    if (_positionStream != null) {
      _positionStream!.cancel();
    }
  }
}
