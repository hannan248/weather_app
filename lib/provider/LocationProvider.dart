import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  String _locationError = '';

  Position? get currentPosition => _currentPosition;
  String get locationError => _locationError;

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    _locationError = '';

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _locationError = 'Location services are disabled.';
      notifyListeners();
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _locationError = 'Location permissions are denied';
        notifyListeners();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _locationError = 'Location permissions are permanently denied. Please enable permissions from settings.';
      notifyListeners();
      return;
    }

    // Get the current location
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position;
      notifyListeners();
    } catch (e) {
      _locationError = 'Failed to get location: $e';
      notifyListeners();
    }
  }
}
