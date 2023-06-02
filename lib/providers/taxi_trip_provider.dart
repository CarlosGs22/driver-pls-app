import 'package:driver_please_flutter/models/taxi_trip.dart';
import 'package:flutter/foundation.dart';

class TaxiTripProvider with ChangeNotifier {
  TaxiTrip? _currentTrip;
  bool _isTripActive = false;

  void startTrip() {
    _currentTrip = TaxiTrip(distanceInMeters: 0, timeInSeconds: 0);
    _isTripActive = true;
    notifyListeners();
  }

  void updateTrip(double distanceInMeters, int timeInSeconds) {
    _currentTrip?.distanceInMeters = distanceInMeters;
    _currentTrip?.timeInSeconds = timeInSeconds;
    notifyListeners();
  }

  void stopTrip() {
    _isTripActive = false;
    notifyListeners();
  }

  void cancelTrip() {
    _currentTrip = null;
    _isTripActive = false;
    notifyListeners();
  }

  TaxiTrip? get currentTrip => _currentTrip;

  bool get isTripActive => _isTripActive;
}
