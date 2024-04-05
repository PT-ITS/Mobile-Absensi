import 'package:flutter/material.dart';

class AuthState extends ChangeNotifier {
  String? userId;
  String? namaUser;
  String? emailUser;
  String? levelUser;
  String? statusUser;

  void setAuthData({
    String? userId,
    String? namaUser,
    String? emailUser,
    String? levelUser,
    String? statusUser,
  }) {
    this.userId = userId;
    this.namaUser = namaUser;
    this.emailUser = emailUser;
    this.levelUser = levelUser;
    this.statusUser = statusUser;
    notifyListeners();
  }
}
