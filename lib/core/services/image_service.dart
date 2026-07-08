import 'dart:convert';
import 'package:image_picker/image_picker.dart';

/// Wraps `image_picker` and always returns raw bytes (never a file path),
/// so the same code works on Web, Android and iOS without platform checks.
class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// Opens the device camera and returns the captured photo as bytes.
  /// Returns null if the user cancels or the camera is unavailable.
  static Future<Uint8ListResult?> captureFromCamera() =>
      _pick(ImageSource.camera);

  /// Opens the gallery / file picker and returns the chosen photo as bytes.
  static Future<Uint8ListResult?> pickFromGallery() =>
      _pick(ImageSource.gallery);

  static Future<Uint8ListResult?> _pick(ImageSource source) async {
    try {
      final xfile = await _picker.pickImage(
        source: source,
        maxWidth: 640,
        maxHeight: 640,
        imageQuality: 70,
      );
      if (xfile == null) return null;
      final bytes = await xfile.readAsBytes();
      return Uint8ListResult(bytes: bytes, mimeType: _guessMime(xfile.name));
    } catch (e) {
      throw ImageServiceException(_friendlyMessage(e));
    }
  }

  static String _guessMime(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  static String _friendlyMessage(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('camera_access_denied') || msg.contains('permission')) {
      return 'Camera permission was denied. Enable it in your device settings.';
    }
    if (msg.contains('photo_access_denied')) {
      return 'Photo library permission was denied. Enable it in your device settings.';
    }
    return 'Could not open the camera/gallery. Please try again.';
  }
}

/// Bytes + mime type, with a convenience getter for a base64 data URI —
/// this lets us store a captured photo directly on the Firestore user
/// document's `photoUrl` field with no Firebase Storage bucket required.
class Uint8ListResult {
  final List<int> bytes;
  final String mimeType;

  const Uint8ListResult({required this.bytes, required this.mimeType});

  String get dataUri => 'data:$mimeType;base64,${base64Encode(bytes)}';

  int get sizeKb => (bytes.length / 1024).round();
}

class ImageServiceException implements Exception {
  final String message;
  ImageServiceException(this.message);
  @override
  String toString() => message;
}
