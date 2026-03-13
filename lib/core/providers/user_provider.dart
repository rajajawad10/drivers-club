import 'dart:io';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  File? _profileImage;

  File? get profileImage => _profileImage;

  void updateProfileImage(File newImage) {
    _profileImage = newImage;
    notifyListeners();
  }

  void clearProfileImage() {
    _profileImage = null;
    notifyListeners();
  }
}
