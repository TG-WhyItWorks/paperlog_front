import 'package:flutter/material.dart';
import '../../../core/models/profile_model.dart';

class ProfileViewmodel extends ChangeNotifier {
  ProfileModel _profile = ProfileModel(
    avatarUrl: 'https://example.com/avatar.png',
    username: 'Starry Owl',
    bio: '자기 소개',
    followers: '123',
    following: '45',
  );

  ProfileModel get profile => _profile;

  Future<void> loadProfile() async {
    //TODO: 실제 API 호출 로직
    await Future.delayed(Duration(seconds: 2));
    notifyListeners();
  }

  Future<void> updateBio(String newBio) async {
    _profile = _profile.copyWith(bio: newBio);
    notifyListeners();
  }
}
