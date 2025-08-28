import 'package:flutter/foundation.dart';
import 'package:mywallet/models/profile.dart';
import 'package:mywallet/services/db_service.dart';

class ProfileProvider with ChangeNotifier {
  Profile? _profile;
  final DBService db;
  ProfileProvider({required this.db});

  Profile? get profile => _profile;

  Future<void> loadProfile() async {
    _profile = await db.getProfile();
    notifyListeners();
  }

  Future<void> updateProfile(Profile profile) async {
    await db.saveProfile(profile);
    _profile = profile;
    notifyListeners();
  }
}
