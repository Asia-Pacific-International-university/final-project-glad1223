import 'package:geolocator/geolocator.dart';
import '../error/failures.dart'; // Assuming Failure and LocationFailure are defined here

class LocationService {
  final GeolocatorPlatform _geolocator;

  LocationService({required GeolocatorPlatform geolocator})
      : _geolocator = geolocator;

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      throw LocationServiceDisabledException('Location services are disabled.');
    }

    permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now).
        throw PermissionDeniedException('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw PermissionDeniedException(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      return await _geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw LocationFailure('Failed to get current location: ${e.toString()}');
    }
  }

  // You can add other location-related methods here, e.g., stream position updates
  // Stream<Position> getPositionStream() {
  //   return _geolocator.getPositionStream();
  // }
}

// Define LocationServiceDisabledException and PermissionDeniedException
// if they are not already defined in core/error/failures.dart
class LocationServiceDisabledException extends Failure {
  const LocationServiceDisabledException(String message)
      : super(message: message);
}

class PermissionDeniedException extends Failure {
  const PermissionDeniedException(String message) : super(message: message);
}

class LocationFailure extends Failure {
  const LocationFailure(String message) : super(message: message);
}
