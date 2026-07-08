import 'package:geolocator/geolocator.dart';

/// A single GPS reading — latitude, longitude and a display-ready string.
/// (No geocoding API key is configured for this project, so the address
/// is represented as formatted coordinates rather than a street address.)
class LocationResult {
  final double latitude;
  final double longitude;

  const LocationResult({required this.latitude, required this.longitude});

  String get formatted =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  String get asAddressLabel => 'My current location ($formatted)';
}

class LocationService {
  /// Requests permission (if needed) and returns the device's current GPS
  /// position. Throws a [LocationServiceException] with a friendly message
  /// on any failure — permission denied, GPS disabled, timeout, etc.
  static Future<LocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        'Location services are turned off. Please enable GPS and try again.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException(
          'Location permission was denied.',
        );
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permission is permanently denied. '
        'Enable it from your device settings.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      throw LocationServiceException(
        'Could not retrieve your location. Please try again.',
      );
    }
  }
}

class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);
  @override
  String toString() => message;
}
