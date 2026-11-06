import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';

abstract class LocationService {
  Future<Position> getCurrentPosition();
  Future<bool> isPermissionGranted();
}

class LocationServiceImpl implements LocationService {
  @override
  Future<bool> isPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationException(
          'Location services are disabled on the device. Using default location.',
        );
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw const LocationException(
            'Location permissions are denied. Using default location.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw const LocationException(
          'Location permissions are permanently denied. Please enable them in settings.',
        );
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (e) {
      if (e is LocationException) rethrow;
      // Graceful fallback to Cairo coordinates if GPS device fails
      throw LocationException(
        'Could not obtain location: $e. Falling back to default coordinates.',
      );
    }
  }

  /// Helper factory for default fallback coordinates (Cairo, Egypt)
  static Position getDefaultFallbackPosition() {
    return Position(
      latitude: ApiConstants.defaultLatitude,
      longitude: ApiConstants.defaultLongitude,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }
}
