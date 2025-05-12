import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  LocationModel? _location;
  StreamSubscription<Position>? _positionStream;

  LocationModel? get location => _location;

  void startLocationUpdates() async {
    final stream = await _locationService.getPositionStream();
    _positionStream = stream.listen((position) {
      _location = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
