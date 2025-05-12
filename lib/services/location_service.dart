import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<LocationAccuracy> getAccuracyBasedOnBattery() async {
    final battery = Battery();
    final batteryLevel = await battery.batteryLevel;

    if (batteryLevel > 50) return LocationAccuracy.best;
    if (batteryLevel > 30) return LocationAccuracy.high;
    if (batteryLevel > 20) return LocationAccuracy.medium;
    return LocationAccuracy.low;
  }

  Future<Stream<Position>> getPositionStream() async {
    final accuracy = await getAccuracyBasedOnBattery();

    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: 10,
      ),
    );
  }
}