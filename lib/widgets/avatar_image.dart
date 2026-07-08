import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme/app_theme.dart';

/// Renders a user's profile photo regardless of where it came from:
/// - empty string            → gradient circle with initials
/// - "http(s)://..."         → CachedNetworkImage
/// - "data:image/...;base64" → decoded in-memory (captured via camera/gallery,
///                              no Firebase Storage bucket needed)
class AvatarImage extends StatelessWidget {
  final String photoUrl;
  final String initials;
  final double size;

  const AvatarImage({
    super.key,
    required this.photoUrl,
    required this.initials,
    this.size = 88,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (photoUrl.startsWith('data:image')) {
      child = _buildFromDataUri(photoUrl);
    } else if (photoUrl.startsWith('http')) {
      child = ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initialsCircle(),
          errorWidget: (_, __, ___) => _initialsCircle(),
        ),
      );
    } else {
      child = _initialsCircle();
    }

    return SizedBox(width: size, height: size, child: child);
  }

  Widget _buildFromDataUri(String uri) {
    try {
      final base64Part = uri.substring(uri.indexOf(',') + 1);
      final bytes = base64Decode(base64Part);
      return ClipOval(
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsCircle(),
        ),
      );
    } catch (_) {
      return _initialsCircle();
    }
  }

  Widget _initialsCircle() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
