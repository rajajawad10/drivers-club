import 'dart:typed_data';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  Uint8List? _profileBytes;

  Uint8List? get profileImageBytes => _profileBytes;

  void updateProfileImageBytes(Uint8List bytes) {
    _profileBytes = bytes;
    notifyListeners();
  }

  void clearProfileImage() {
    _profileBytes = null;
    notifyListeners();
  }

  ImageProvider? get profileImageProvider {
    if (_profileBytes != null) return MemoryImage(_profileBytes!);
    return null;
  }
}
